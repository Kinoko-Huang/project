load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    city_number = 14

    city_name = (/"dg","fs","gz","hy","hz","jm","qy","sg","sz","yf","yj","zh","zq","zs"/)
    obs_number = (/6,8,14,6,3,5,4,4,18,3,3,3,3,2/)
   
    ratio_med=new((/14/),float)
    ratio_mean=new((/14/),float)
    do i=0,city_number-1
        city_ratio=new((/obs_number(i)*10/),float)
        city_ratio = asciiread("/disk/scratch/huangyeq/test_data/inven_adjust/ratio_10days/so2_"+city_name(i),(/obs_number(i)*10,1/),"float")
        ratio_med(i) = dim_median(city_ratio)
        ratio_mean(i) = avg(city_ratio)
        delete(city_ratio)
    end do

    do j=0,city_number-1
        asciiwrite ("/disk/scratch/huangyeq/test_data/inven_adjust/ratio_10days/so2_med-mean"+city_name(j),city_name(j)+": "+ratio_med(j)+"   "+ratio_mean(j))
    end do
end
