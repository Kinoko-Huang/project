#!/bin/csh -f

#################################################################################
#                                                                               #
# This script is used to get typhoon infomation, which information              #
# includes the actually typhoon information,qscat data and WRF tc-bogus data,   #
# and then these data will be merge together                                    #   
#                                                                               #
#################################################################################

#########################################################################
setenv BEG_TIME ${INIT_Y}${INIT_M}${INIT_D}${INIT_H}
set END_TIME=${END_Y}${END_M}${END_D}${INIT_H}
set NO_DAYS=$MET_SIM_N_DAYS
set BOGUS_ROOT=${work_root}/TC_BOGUS
#########################################################################


#delete the previous run residuals
#rm -f wrfout_tmp/*
rm -f derived_data/*

#preset environment
#setenv work_root /home/pathop/test12/HH12_test/wrf
#setenv MET_SIM_N_DAYS 3
#setenv WRF_DATA_ROOT /home/pathop/test12/HH12_test/wrf/TC_BOGUS
#setenv PATH_SYSDIR /home/pathsys

#set environment variables
setenv tcbogus_tmp $BOGUS_ROOT/tmp
setenv TY_MAIL_DIR $BOGUS_ROOT/typhoon_mesg
setenv TC_BOGUS_ROOT $BOGUS_ROOT/tcbogus_wrf
setenv MIN_LAT 5
setenv MAX_LAT 40
setenv MIN_LON 100
setenv MAX_LON 140
setenv EXTRACT_HH 0     # starting to extract typhoon hour
setenv TCBOGUS_DOMAIN 1   # which domian is used for extracting typhoon
setenv WRFOUT_temp $BOGUS_ROOT/wrfout_tmp
setenv DERIVED_DATA_ROOT $BOGUS_ROOT/derived_data

set BEG_CCYY = `echo $BEG_TIME | cut -c1-4`
set BEG_MM   = `echo $BEG_TIME | cut -c5-6`
set BEG_DD   = `echo $BEG_TIME | cut -c7-8`
set BEG_HH   = `echo $BEG_TIME | cut -c9-10`
set BEG_GDATE = `echo $BEG_TIME | cut -c1-8`

set NO_DAYS = $MET_SIM_N_DAYS

#retrieve the typhoon message data
# Moved to wrf_run
#/bin/rm -r -f $BOGUS_ROOT/typhoon_mesg $BOGUS_ROOT/tmp_typhoon
#/bin/mkdir    $BOGUS_ROOT/typhoon_mesg $BOGUS_ROOT/tmp_typhoon || exit 1
#$PATH_SYSDIR/bin/get_envf_typhoon_mesg $BEG_GDATE $NO_DAYS $BOGUS_ROOT/tmp_typhoon
#/usr/bin/find $BOGUS_ROOT/tmp_typhoon -type f -exec /bin/mv -v {} $BOGUS_ROOT/typhoon_mesg/ \;
#/bin/rm -r -f $BOGUS_ROOT/tmp_typhoon

cd $BOGUS_ROOT

/usr/bin/python get_typhoon_information.py $BEG_TIME $MIN_LAT $MIN_LON $MAX_LAT $MAX_LON $TC_BOGUS_ROOT $TY_MAIL_DIR

/bin/cat $TC_BOGUS_ROOT/*.dat > $DERIVED_DATA_ROOT/wrftclittler.tcbogus 

/bin/rm -f $TC_BOGUS_ROOT/*.dat

