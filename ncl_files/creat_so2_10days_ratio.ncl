load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    g_filetime=ispan(192,213,1)

    data_file_name1="/disk/scratch/huangyeq/test_data/inven_adjust/cmaq/CCTM_V5g_ebi_cb05cl_ae5_aq_mpich2.ACONC.2016"+g_filetime+".nc"

    obsin = asciiread("/disk/scratch/huangyeq/test_data/inven_adjust/obs/so2_selected.txt",(/530,82/),"float")

    sta_name=(/"sz1","sz2","dg1","dg2","dg3","dg4","dg6","dg7","zs1","zs2", \
    "yf1","yf2","yf3","fs1","fs2","fs3","fs4","fs5","fs6","fs7","fs8","sz3","jm1","sg4","gz2","sg1","gz3","gz4","gz5","gz6", \
    "gz7","gz8","gz9","gz10","gz11","gz12","gz13","hz1","hz2","hz4","sg2","jm2","jm3","jm4","jm5", \
    "hy1","hy2","hy3","hy4","hy5","hy6","sz5","sz6","sz7","sz8","sz10","sz11","sz12","sz13","sz14","sz15", \
    "sz17","sz18","sz19","sz20","sz21","qy1","qy2","qy3","qy4","zh2","zh3","zh4","gz14","gz15","zq1","zq2","zq3","yj1","yj2","yj3","sg3"/)

    p_lon=new((/82/),float)
    p_lat=new((/82/),float)
    p_lon=obsin(1,:)
    p_lat=obsin(0,:)

;---------------Read data-------------------
    varin1 = addfiles(data_file_name1,"r")
    var1 = varin1[:]->SO2

    var_time = varin1[:]->TSTEP
    g_hours = dimsizes(var_time(:,0))

;---------------Read lat-lon config-------------------
    latlon_in   =  addfile("/disk/hq233/huangyeq/resource/map_info/3km/GRIDCRO2D.3km.20150121","r")
    var1@lat2d = latlon_in->LAT(0,0,:,:)
    var1@lon2d = latlon_in->LON(0,0,:,:)

    do i=0,dimsizes(p_lat)-1
        point=getind_latlon2d(var1@lat2d,var1@lon2d,p_lat(i),p_lon(i))
        cor_x=point(0,0)
        cor_y=point(0,1)
        data=new((/2,g_hours/),float)
        data(0,:)=obsin(2:529,i)
        data(1,:)=var1(:,0,cor_x,cor_y)
        data@_FillValue = -99999
       
        obs_day_mean=new((/22/),float)
        sim_day_mean=new((/22/),float)
        do j=0,21
            obs_day_mean(j) = avg(data(0,(0+24*j):(23+j*24)))
        end do
        do j=0,21
            sim_day_mean(j) = avg(data(1,(0+24*j):(23+j*24)))
        end do
        incre_seq=dim_pqsort_n(obs_day_mean,1,0) 
       
        MB=new((/11/),float)
        ratio_10days=new((/11/),float)
        do ii=0,10
            MB(ii)=sim_day_mean(incre_seq(ii))-obs_day_mean(incre_seq(ii))
            ratio_10days(ii)=MB(ii)/obs_day_mean(incre_seq(ii))
        end do
        
        asciiwrite ("/disk/scratch/huangyeq/test_data/inven_adjust/ratio_10days/so2_"+sta_name(i),ratio_10days)

        delete(obs_day_mean)
        delete(sim_day_mean)
    end do


end
