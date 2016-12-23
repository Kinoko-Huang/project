load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    ;File day
    g_filetime=(/"018","019","020","021","022","023","024","025"/)

    ;Ctrl run
    data_file_name1="/disk/scratch/huangyeq/test_data/AE-test/ae6/cmaq/201501/CCTM_V5g_Linux2_x86_64pg_mpich2.PM25.2015"+g_filetime+".nc"

    ;Sensitive run
    data_file_name2="/disk/scratch/huangyeq/test_data/AE-test/ae5/cmaq/201501/CCTM_V5g_ebi_cb05cl_ae5_aq_mpich2.PM25.2015"+g_filetime+".nc"

    ;obs_data
    obsin = asciiread("/disk/scratch/huangyeq/obs_data/AE-test/obs_pm25-20150101-20150131.txt",(/744,9/),"float")

    sta_name = (/"Foshan","Guangzhou","Shenzhen","Dongguan","Huizhou","Zhongshan","Jiangmen","Zhaoqing","Zhuhai"/)
    p_lat = (/23.0467,23.1331,22.7267,23.0277,23.3404,22.5078,22.728,23.0528,22.2281/)
    p_lon = (/113.144,113.26,114.24,113.7461,114.1074,113.402,112.929,112.471,113.299/)

;---------------Read data-------------------
    varin1 = addfiles(data_file_name1,"r")
    varin2 = addfiles(data_file_name2,"r")

    var1 = varin1[:]->PM25
    var2 = varin2[:]->PM25
    var_time = varin1[:]->TSTEP
    g_hours = dimsizes(var_time(:,0))

;---------------Read lat-lon config-------------------
    latlon_in   =  addfile("/disk/hq233/huangyeq/resource/map_info/3km/GRIDCRO2D.3km.20150121","r")
    var1@lat2d = latlon_in->LAT(0,0,:,:)
    var1@lon2d = latlon_in->LON(0,0,:,:)
    var2@lat2d = latlon_in->LAT(0,0,:,:)
    var2@lon2d = latlon_in->LON(0,0,:,:)

    do i=0,dimsizes(p_lat)-1
        ; Get point coordinate
        point=getind_latlon2d(var1@lat2d,var1@lon2d,p_lat(i),p_lon(i))
        cor_x=point(0,0)
        cor_y=point(0,1)
        data=new((/3,g_hours/),float)
        data(0,:)=obsin(420:611,i)
        data(1,:)=var1(:,0,cor_x,cor_y)
        data(2,:)=var2(:,0,cor_x,cor_y)
        data@_FillValue = -99999
        data@_FillValue = 0 
        ;--------------Simulation evaluation---------------
        obs_mean = avg(data(0,:))
        ae6_mean = avg(data(1,:))
        ae5_mean = avg(data(2,:))

        ae6_MB = avg(data(1,:)-data(0,:)) 
        ae5_MB = avg(data(2,:)-data(0,:))
        
        ae6_NMB = avg(data(1,:)/data(0,:)-1)
        ae5_NMB = avg(data(2,:)/data(0,:)-1)

        ;ae6_R = (sum((data(0,:)-obs_mean)*(data(1,:)-ae6_mean)))^2/(sum((data(0,:)-obs_mean)^2)*sum((data(1,:)-ae6_mean)^2))
        ;ae5_R = sum((data(0,:)-obs_mean)*(data(2,:)-ae5_mean))/(sqrt(sum((data(0,:)-obs_mean)^2)*sum((data(2,:)-ae5_mean)^2)))      
        
        ae6_IA = 1-sum((data(1,:)-data(0,:))^2)/sum((abs(data(1,:)-obs_mean)+abs(data(0,:)-obs_mean))^2)
        ae5_IA = 1-sum((data(2,:)-data(0,:))^2)/sum((abs(data(2,:)-obs_mean)+abs(data(0,:)-obs_mean))^2)
        
        
        print(sta_name(i)+" ae6_MB="+ae6_MB+" ae5_MB="+ae5_MB)
        print(sta_name(i)+" ae6_NMB="+ae6_NMB+" ae5_NMB="+ae5_NMB)
        ;print(sta_name(i)+" ae6_R="+ae6_R+" ae5_R="+ae5_R)
        print(sta_name(i)+" ae6_IA="+ae6_IA+" ae5_IA="+ae5_IA)
    
    end do

end
