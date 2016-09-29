#!/bin/csh -f
####################################################################################
##---This script is written by LJ(Tao RUAN)
##---nodes :  	for set the number of processor you will use but the machinefile 
##---		name for mpiexec command should be nodes.mpi
##---case  :	just for create a label for all namelist, for EPD do not change
##---initial_data_root  :	location for fnl reanalysis data 
##---WPS_root		:	location for WPS
##---WRF_root		:	location for WRF
##---obs_root		:	location for WRF ready observational file
##---archive_root	:	location for archiving the data file
##---
##---  for different case simulation, you need to change the date for each case 
##---  compatible with MM5 and only the right date can copy the right obs file
##---  because all obs files are named with the start days .
##---
##---  for now I just put the obs files for following case 
##---  20040927 to 20041001
##--- invoke this script please type,for instance, ./auto_EPD_d4nudging.csh 2004092700 2004100100
##---Revised for GTS_decoder and Boundary sounding retrival based on Xiebo's file
##---Rvised for TC_bogus based on Yao Teng and Xiebo's file
#####################################################################################
source ../domains_def.config

## This script is used for domain 4 obs nudging only
if ( $?Ncpu ) then
  setenv nodes $Ncpu
else
  setenv nodes 16
endif

if ( $?FC_MODE == 0 ) then
  echo "FC_MODE is not defined"
  exit 1
endif

if ( $FC_MODE == 0 ) then
  setenv case epd.d4nudging
else if ( $FC_MODE == 1 ) then
  setenv case epd.nonudging
else
  echo "Invalid FC_MODE = $FC_MODE, it must be 0 or 1"
  exit 1
endif

echo "FC_MODE = $FC_MODE"
echo "case = $case"

#####+++++++++++++++++++++++++#####
##--- projection used both for---##
##--- WPS and NPS             ---##
#####+++++++++++++++++++++++++#####
setenv truelat1 $LAMBERT_TRUE_LAT1
setenv truelat2 $LAMBERT_TRUE_LAT2
setenv ref_LAT $LAMBERT_CEN_LAT
setenv ref_LON $LAMBERT_CEN_LON
setenv dx ${G_DOMAINS_RES_WRF[1]}


#####+++++++++++++++++++++++++#####
##---      only for WPS       ---##
#####+++++++++++++++++++++++++#####
setenv dy ${dx} 

#####+++++++++++++++++++++++++#####
##--- for NPS to control the  ---##
##--- wind data value used for---## 
##--- obs nudging             ---##
#####+++++++++++++++++++++++++#####
setenv min_wind 0.20
setenv max_wind 25.

#setenv work_root `pwd`

if ( $FC_MODE == 0 ) then
  setenv initial_data_root ${work_root}/FNL/fnl_*
else
  setenv initial_data_root ${work_root}/GFS/gfs*
endif

#setenv WPS_root ${work_root}/WPS
#setenv WRF_root ${work_root}/met_WRFV3/test/em_real
#setenv NPS_root ${work_root}/NPS
#setenv obs_root ${work_root}/EPDdata
#setenv archive_root ${work_root}/outputs
#setenv geog_data_root ${work_root}/WPS_GEOG
#setenv GTS_root ${work_root}/gts_decoder
#setenv TCbogus_root ${work_root}/TC_BOGUS
#
#####++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#####
##--- path for handle the obs data for observational nudging.  ---##
##--- obs_data is used for store the data which is already     ---## 
##--- reformatted to PATH-ready format. FDDA_data should be    ---## 
##--- used to contain the WRF-ready data for further processing---##
##--- In the end, the nudging data for simulation period will  ---##
##--- be moved to obs_root                                     ---##
#####++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#####
## have set obs_data and FDDA_data in run_NPS.csh
#if ( $FC_MODE == 0 ) then
#  setenv obs_data ${NPS_root}/obs_data.dat
#endif

#setenv FDDA_data ${NPS_root}/wrfFDDA_EPD

set INIT_TIME = $1
set END_TIME = $2

setenv INIT_Y `echo ${INIT_TIME} | cut -c 1-4`
setenv INIT_M `echo ${INIT_TIME} | cut -c 5-6`
setenv INIT_D `echo ${INIT_TIME} | cut -c 7-8`
setenv INIT_H `echo ${INIT_TIME} | cut -c 9-10`
setenv END_Y `echo ${END_TIME} | cut -c 1-4`
setenv END_M `echo ${END_TIME} | cut -c 5-6`
setenv END_D `echo ${END_TIME} | cut -c 7-8` 

#setenv hour_end `echo ${END_TIME} | cut -c 9-10`

#step1. prepare the WRF intial data through WPS
echo '#########################'
echo step1. prepare the WRF intial data through WPS
echo '#########################'
cd ${WPS_root}
./run_sepSST.csh
if ( $status != 0 ) then
  echo "Failed to run ./run_sepSST.csh"
  exit 1
endif

set status = `tail -n 1 metgrid.log | cut -c 34-43`

 if (${status} == "Successful") then

#   Emit for the fix of problematic forcast run
    if ( $FC_MODE == 0 ) then
      #perpare the observation data from HKO and GD for observation nudging   
      echo '############################' 
      echo perpare the observation data from HKO and GD for observation nudging 
      echo '############################'  
#      cd ${NPS_root}
#      ./run_NPS.csh
# use OBSGRID intead of NPS to process obs nudging files for quality control
# revised by Bo Xie on 04/12/2012
    cd ${WPS_root}
      #set filename_obs = /disk/dataop_scratch/NUDGING/obsgrid/${INIT_Y}${INIT_M}_d03/obs
      set filename_obs = ${work_root}/obsfiles/obs
# process domain 3 nudging file
      if ( ${SIM_DOMAINS_WRF} >= 3 ) then
        set id_grid = 3
        ./run_obsgrid.csh $filename $id_grid
        if ( $status != 0 ) then
          echo "Failed to run ./run_obsgrid.csh"
          exit 1
        endif
        rm -f metoa_em* wrfsfdda*
        foreach file (`ls -l ${WPS_root}/OBS_DOMAIN3* | awk '{print $9}'`)
          cat $file >> ${obs_root}/OBS_DOMAIN301_${INIT_Y}${INIT_M}${INIT_D}
        end
      endif
# process domain 4 nudging file
      if ( ${SIM_DOMAINS_WRF} >= 4 ) then
        set id_grid = 4
        ./run_obsgrid.csh $filename $id_grid
        if ( $status != 0 ) then
          echo "Failed to run ./run_obsgrid.csh"
          exit 1
        endif
        rm -f metoa_em* wrfsfdda*
        foreach file (`ls -l ${WPS_root}/OBS_DOMAIN4* | awk '{print $9}'`)
          cat $file >> ${obs_root}/OBS_DOMAIN401_${INIT_Y}${INIT_M}${INIT_D}
        end
      endif
    
    endif

# no boundary sounding
#extract the boundary sounding bogus data from the intial time WPS product
#echo '########################'
#echo extract the boundary sounding bogus data from the intial time WPS product
#echo '########################'
#    #if ( $FC_MODE == 1 ) then
#    cd ${WPS_root}
#      ./run_bsw.csh
#      if ( $status != 0 ) then
#        echo "Failed to run ./run_bsw.csh"
#        exit 1
#      endif
#    #endif

#add TC bogus from the thyphoon message information 
echo '##########################'
echo add TC bogus from the thyphoon message information 
echo '##########################'
    #if ( $FC_MODE == 1 ) then
    cd ${TCbogus_root}
      ./add_tcbogus_wrf.csh
    #endif

#get the GTS data from ENVF database and combine the intial bc bogus and TC bogus data
echo '###########################'
echo get the GTS data from ENVF database and combine the intial bc bogus and TC bogus data
echo '###########################'
    #if ( $FC_MODE == 1 ) then
    cd ${GTS_root}
      ./cleanup
      ./auto_A_gts_decoder.csh
      #if ( $status != 0 ) then
      #  echo "Failed to run ./auto_A_gts_decoder.csh"
      #  exit 1
      #endif
      ./auto_C_cat_gts.csh
      #if ( $status != 0 ) then
      #  echo "Failed to run ./auto_C_cat_gts.csh"
      #  exit 1
      #endif
#combine GTS, BC bogus, and TC bogus data
#      ./combine_little_r_input.csh
#no BC bogus
      ./combine_little_r_input_noBC.csh
      if ( $status != 0 ) then
#       echo "Failed to run ./combine_little_r_input.csh"
	    echo "Failed to run ./combine_little_r_input_noBC.csh"
        exit 1
      endif
    #endif

#run the OBSGRID utility to do WRF objective analysis
echo '#########################'
echo run the OBSGRID utility to do WRF objective analysis
echo '#########################'

    #if ( $FC_MODE == 1 ) then
    cd ${WPS_root}
      set filename_obs = ${work_root}/gts_decoder/derived_data/obs
      set id_grid = 1
      ./run_obsgrid.csh $filename_obs $id_grid
      if ( $status != 0 ) then
        echo "Failed to run ./run_obsgrid.csh"
        exit 1
      endif
    #endif

#replace the orginal WPS met to new metoa
    cd ${WPS_root}
      #./metoa2met_${MET_SIM_N_DAYS}days.csh
      ./metoa2met_rename.csh
      if ( $status != 0 ) then
        #echo "Failed to run ./metoa2met_${MET_SIM_N_DAYS}days.csh"
        echo "Failed to run ./metoa2met_rename.csh"
        exit 1
      endif

 
#step2. begin the main WRF integration
echo '#########################'
echo step2. begin the main WRF integration
echo '#########################'
    cd ${WRF_root}
    ./all_clean.csh
#   Emit for the fix of problematic forcast run 
    if ( $FC_MODE == 0 ) then    # Historical run
      echo cp -f ${obs_root}/OBS_DOMAIN301_${INIT_Y}${INIT_M}${INIT_D} ${WRF_root}/OBS_DOMAIN301
      cp -f ${obs_root}/OBS_DOMAIN301_${INIT_Y}${INIT_M}${INIT_D} ${WRF_root}/OBS_DOMAIN301
      echo cp -f ${obs_root}/OBS_DOMAIN401_${INIT_Y}${INIT_M}${INIT_D} ${WRF_root}/OBS_DOMAIN401
      cp -f ${obs_root}/OBS_DOMAIN401_${INIT_Y}${INIT_M}${INIT_D} ${WRF_root}/OBS_DOMAIN401
    endif
    if ( $FC_MODE == 0 ) then
      echo ./runWRF_EPD_d4nudging.csh
      ./runWRF_EPD_d4nudging.csh
      if ( $status != 0 ) then
        echo "Failed to run ./runWRF_EPD_d4nudging.csh"
        exit 1
      endif
    else                       # Forcast mode
      echo ./runWRF_EPD_nonudging.csh
      ./runWRF_EPD_nonudging.csh
      if ( $status != 0 ) then
        echo "Failed to run ./runWRF_EPD_nonudging.csh"
        exit 1
      endif
    endif

    set wrf_check = `tail -n 1 $WRF_root/rsl.out.0000 | cut -c 30-36`
    if ( $wrf_check != "SUCCESS" ) then
      echo "Failed to run wrf.exe"
      exit 1
    endif

    echo WRF simulation complete
    echo copy data to be archived     
    
    if(! -e wrf_log) mkdir -p wrf_log
    mv -f rsl.* wrf_log/
    set archive_folder = ${archive_root}/${INIT_Y}/${INIT_Y}${INIT_M}/${INIT_Y}${INIT_M}${INIT_D}${INIT_H}
    
    if (! -e ${archive_folder}) mkdir -p ${archive_folder}

    echo wrfout
    mv wrfout_d0* ${archive_folder}/
    echo wrflog
    cp -r wrf_log ${archive_folder}/
    echo reallog
    cp -r real_log ${archive_folder}/
    #echo wrfinput
    #mv wrfinput_d0* ${archive_folder}/
    #echo wrflowinp
    #mv wrflowinp_d* ${archive_folder}/
    #echo wrfbdy
    #mv wrfbdy_* ${archive_folder}/
    #echo wrffdda
    #mv wrffdda_* ${archive_folder}/
    echo namelist
    cp namelist.input.${case} ${archive_folder}/
  else
    echo Error occurs in wrf.exe
    exit 1
 endif 
