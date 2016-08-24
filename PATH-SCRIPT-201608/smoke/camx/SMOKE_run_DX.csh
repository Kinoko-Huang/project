#!/bin/csh
###########################################################
#SMOKE_RUN is to process all the steps of SMOKE automatically
# date:2008-03-22
# author :Ying LI
###########################################################

source ../../../../domains_def.config

set CUR_JDATE = $argv[1]
set INIT_H     = $argv[2]
set VERSION = "20110930"
set smokelog = $cwd/../emislog/smokelog
if ( ! -e $smokelog ) mkdir -p $smokelog

# set path
setenv EPI_STDATE $CUR_JDATE # Julian start date
#---------------------------------------------<

#Set Domain
   set INVID = 2005
   set NDAYS = 1      # Duration in days of each emissions file

#############Create inventroy list files
## AREA
cd $SMK_HOME_Alpine/data.20110930/inventory/2005/area
echo '#LIST' > area_2005.lst
ls $cwd/area_hk_2005_09Feb2009.ida_nonmarine_nonshipline >> area_2005.lst
ls $cwd/arinv.prd.lares.ida.20090706_nonmobile_nonmarine.txt >> area_2005.lst

echo '#LIST' > area_marine_2008_D3_LRV.lst
ls $cwd/marine_2008_D3_LRV.txt >> area_marine_2008_D3_LRV.lst

echo '#LIST' > area_marine_2008_D3_OGV.lst
ls $cwd/marine_2008_D3_OGV.txt >> area_marine_2008_D3_OGV.lst

if ($#G_DOMAINS_RES_SMOKE == 4) then
  echo '#LIST' > area_marine_2008_D4_LRV.lst
  ls $cwd/marine_2008_D4_LRV.txt >> area_marine_2008_D4_LRV.lst

  echo '#LIST' > area_marine_2008_D4_OGV.lst
  ls $cwd/marine_2008_D4_OGV.txt >> area_marine_2008_D4_OGV.lst
endif
###MOBILE
cd $SMK_HOME_Alpine/data.20110930/inventory/2005/mobile
echo '#LIST' > mobile_2005.lst
ls $cwd/pathv1_hk_mobile.txt >> mobile_2005.lst
ls $cwd/mobile_SZ_2004_100129.ida >> mobile_2005.lst
ls $cwd/arinv.prd.lares.ida.20090706_mobile.txt_nonSZ >> mobile_2005.lst

###POINT
cd $SMK_HOME_Alpine/data.20110930/inventory/2005/point
echo '#LIST' > point_2005.lst
ls $cwd/point_2005_hk.ida >> point_2005.lst
ls $cwd/point_2004_SZ.ida >> point_2005.lst
ls $cwd/ptinv.prd.lares.ida.20090706.txt.stkdiaheight_nonSZ >> point_2005.lst

if ($#G_DOMAINS_RES_SMOKE == 4) then
  set DOMAINS_MAX = 4
else 
  set DOMAINS_MAX = 3
endif
set DOMAINS_RES = 3
while ($DOMAINS_RES <= $DOMAINS_MAX)
  set DOMAINS_RES_D = `printf "%02d" $DOMAINS_RES`
  set DNAME = HK${DOMAINS_RES_D}
  set reso = ${DOMAINS_RES}000 
  set DMAIN = D$DOMAINS_RES

  set CUR_GDATE = (`$DATELIB/j2g ${CUR_JDATE}`)
  set CUR_Y = $CUR_GDATE[1]
  set CUR_M = $CUR_GDATE[2]
  set CUR_D = $CUR_GDATE[3]
  set CUR_GDATE = ${CUR_Y}${CUR_M}${CUR_D}   #Gregorian start date
  set CUR_YM = $CUR_Y$CUR_M

  # step1 run SMOKE point source
  cd $SMK_RUN
     ./smk_pnt_cmaq_cb05.ag  $CUR_JDATE $DOMAINS_RES $INIT_H >&$smokelog/tmp${DOMAINS_RES_D}_pnt_$CUR_JDATE.log
  
     set Createf_pt =  $SMKOUTPUT/${CUR_YM}.$VERSION/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05/pgts3d_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf  
   
     if ( ! -e $Createf_pt ) then
        echo "ERROR: $Createf_pt not exits "
        echo "ERROR: Run smk_pnt_cmaq_cb05_${DOMAINS_RES_D}k.ag failed "
        exit 1
     else
        echo "pass step4.2.1: D${DOMAINS_RES} point source"
     endif

  # step2 run SMOKE mobile source
  cd $SMK_RUN
     ./smk_mv_cmaq_cb05.ag  $CUR_JDATE $DOMAINS_RES $INIT_H >& $smokelog/tmp${DOMAINS_RES_D}_mv_$CUR_JDATE.log
     set Createf_mv =  $SMKOUTPUT/${CUR_YM}.$VERSION/mobile/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05/agts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf

     if ( ! -e $Createf_mv ) then
         echo "ERROR: $Createf_mv not exits "
         echo "ERROR: Run smk_mv_cmaq_cb05_${DOMAINS_RES_D}k.ag failed "
         exit 1
     else
         echo "pass step4.2.2: D${DOMAINS_RES} mobile source"
     endif
  # make symbolick from mobile source(which is pretend to run as area source) to mobile
  set mgtsf   =  $SMKOUTPUT/${CUR_YM}.$VERSION/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05/mgts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf

     ln -sf $Createf_mv $mgtsf

  # step3 run SMOKE area source
  cd $SMK_RUN
     ./smk_ar_cmaq_cb05.ag $CUR_JDATE $DOMAINS_RES $INIT_H >&$smokelog/tmp${DOMAINS_RES_D}_ar_$CUR_JDATE.log
     set Createf_ar =  $SMKOUTPUT/${CUR_YM}.$VERSION/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05/agts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf  
   
     if ( ! -e $Createf_ar ) then
        echo "ERROR: Run smk_ar_cmaq_cb05_${DOMAINS_RES_D}k.ag failed "
        exit 1
     else
        echo "pass step4.2.3: D${DOMAINS_RES} area source"
     endif

  # step4 run SMOKE marine source
############# OGV ###############
  cd $SMK_RUN
     ./smk_marine_OGV_cmaq_cb05.ag  $CUR_JDATE $DOMAINS_RES $INIT_H >&$smokelog/tmp${DOMAINS_RES_D}_OGV_$CUR_JDATE.log
  cd $PROJECT_HOME/Shiplifting
     ./run.shiplifting.OGV.csh $CUR_JDATE $DOMAINS_RES >& $smokelog/tmp${DOMAINS_RES_D}_shiplift_OGV_${CUR_JDATE}.log
          
    set Createf_ogv =  $SMKOUTPUT/${CUR_YM}.$VERSION/marine.OGV/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05/OGV_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf  
    if ( ! -e $Createf_ogv ) then
       echo "ERROR: Run smk_marine_OGV_cmaq_cb05_${DOMAINS_RES_D}k.ag failed "
       exit 1
    else
       echo "pass step4.2.4: D${DOMAINS_RES} marine_OGV source"
    endif

    set set AREAPATH = $SMKOUTPUT/${CUR_YM}.$VERSION/marine/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05
    if ( ! -e $AREAPATH ) mkdir -p $AREAPATH
    ln -s $Createf_ogv $AREAPATH/agts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf

############ LRV ##################
  cd $SMK_RUN
     ./smk_marine_LRV_cmaq_cb05.ag $CUR_JDATE $DOMAINS_RES $INIT_H >&$smokelog/tmp${DOMAINS_RES_D}_LRV_$CUR_JDATE.log
  cd $PROJECT_HOME/Shiplifting
     ./run.shiplifting.LRV.csh $CUR_JDATE $DOMAINS_RES >& $smokelog/tmp${DOMAINS_RES_D}_shiplift_LRV_${CUR_JDATE}.log
 
     set Createf_lrv =  $SMKOUTPUT/${CUR_YM}.$VERSION/marine.LRV/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05/LRV_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf
     if ( ! -e $Createf_lrv ) then
        echo "ERROR: Run smk_marine_LRV_cmaq_cb05_${DOMAINS_RES_D}k.ag failed "
        exit 1
     else
        echo "pass step4.2.5: D${DOMAINS_RES} marine_LRV source"
     endif

     set set AREAPATH = $SMKOUTPUT/${CUR_YM}.$VERSION/marine/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05
     if ( ! -e $AREAPATH ) mkdir -p $AREAPATH
     ln -s $Createf_lrv $AREAPATH/pgts3d_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf
############# Merge OGV and LRV ###########
  cd $SMK_RUN
     ./smk_mrgall_marine_cmaq_cb05.ag $CUR_JDATE $DOMAINS_RES $INIT_H >&$smokelog/tmp${DOMAINS_RES_D}_marinemerge_$CUR_JDATE.log
      set Createf_ma =  $SMKOUTPUT/${CUR_YM}.$VERSION/marine/run_${INVID}_${reso}m_${CUR_GDATE}/output/merge/egts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf
      if ( ! -e $Createf_ma ) then
         echo "ERROR: Run smk_mrgrall_marine_cmaq_cb05_${DOMAINS_RES_D}k.ag failed "
         exit 1
      else
         echo "pass step4.2.6: D${DOMAINS_RES} marine merge source"
      endif
      set bgtsf   =  $SMKOUTPUT/${CUR_YM}.$VERSION/run_${INVID}_${reso}m_${CUR_GDATE}/output/cmaq.cb05/b3gts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.met_${reso}m_${CUR_GDATE}_${INVID}_${reso}m_${CUR_GDATE}.ncf

      ln -sf $Createf_ma $bgtsf
  # step5 run SMOKE to merge point + area source
  cd $SMK_RUN
     ./smk_mrgall_cmaq_cb05.ag $CUR_JDATE $DOMAINS_RES $INIT_H >& $smokelog/tmp${DOMAINS_RES_D}_merge.log
   
     set Createf =  $SMKOUTPUT/${CUR_YM}.$VERSION/run_${INVID}_${reso}m_${CUR_GDATE}/output/merge/egts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf  
   
     if ( ! -e $Createf ) then
        echo "ERROR: Run smk_mrgall_cmaq_cb05_${DOMAINS_RES_D}k.ag failed "
        exit 1
     else
        echo "pass step4.2.7: D${DOMAINS_RES} merge all"
     endif

  @ DOMAINS_RES = $DOMAINS_RES + 1 

end 

if ($#G_DOMAINS_RES_SMOKE == 4) then
  set DNAME = HK01
  set Dk = 1
  set DK = 01
  set reso = 1000
  set DMAIN = D4
  if ( ! -e $SMKOUTPUT/SMKINTEXB ) mkdir -p $SMKOUTPUT/SMKINTEXB
    set CUR_GDATE = `$DATELIB/yyyyjjj2yyyymmdd $CUR_JDATE`
    set CUR_Y   = `echo $CUR_GDATE | cut -c 1-4`
    set CUR_M   = `echo $CUR_GDATE | cut -c 5-6`
    set CMAQ_D4 = $SMKOUTPUT/${CUR_Y}${CUR_M}.$VERSION/run_${INVID}_${reso}m_${CUR_GDATE}/output/merge
    mv $CMAQ_D4/egts_l.${CUR_GDATE}.${NDAYS}.${DNAME}.${INVID}_${reso}m_${CUR_GDATE}.ncf $SMKOUTPUT/SMKINTEXB/EM_cn${Dk}_$CUR_JDATE.ncf
endif

exit()
