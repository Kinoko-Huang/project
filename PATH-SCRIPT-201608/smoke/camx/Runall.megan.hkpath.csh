# !/bin/csh -v 

#############################
#  Runall.path.csh 
#
#  This program is written to link all the running for MEGAN together, in 
#  order to run MEGAN in one script
#   
#  Fuction: (1)TPAR2IOAPI 
#           (2)MG2IOPAI
#           (3)MEGAN
#           (4)MG2MECH.CB05
#            Follows are CAMx only
#           (5)MG2MECH.SOAX
#           (5)IOAPI2UAM 
#           (6)MRGEM
#
#############################
source ../setcase
source ../../../../../domains_def.config
set meganlog = $PWD/logdir
if( ! -e $meganlog ) mkdir -p $meganlog

set CUR_JDATE = $argv[1]
set INIT_H = $argv[2]

#
#-------------------step 0 ---------------------
# delete previous temp files
  rm -f $MGNINP/TPAR/${PROJ}/TPAR.MEGAN.${PROJ}.*.ncf
  rm -f $MGNOUT/ITMDT/ER_MEGAN_${PROJ}_*.ncf
  rm -f $MGNOUT/ITMDT/EFMAP_LAI_${PROJ}_*.ncf
  rm -f logdir/*

echo "******************************************************"
echo "*                     NOTICE                         *"
echo "*             Begin to run MEGAN                     *"
echo "******************************************************"
    
#---------------------step 1 --------------------------

set DOMAINS_GRID = 1
foreach DOMAINS_RES ($G_DOMAINS_RES_SMOKE)
  echo "----------------------------------------"
  echo " now processing :D$DOMAINS_GRID                "           
  echo "----------------------------------------"

#---------------------step 1----------------------------
  ./run.tpar2ioapi.path.csh $CUR_JDATE $DOMAINS_RES $INIT_H >& $meganlog/log.tpar2ioapi.D$DOMAINS_GRID.$CUR_JDATE
  if ( $status != 0 ) then
    echo "ERROR: Run run.tpar2ioapi.path.csh failed"
    echo "ERROR in step 1.1 TPAR2IOAPI"
    exit 1
  else
    echo "end step 1.1 TPAR2IOAPI"
  endif

#-------------------setp 2---------------------------
  ./run.mg2ioapi.path.csh $DOMAINS_RES >& $meganlog/log.mg2ioapi.D$DOMAINS_GRID
  
  if ( $status != 0 ) then
    echo "ERROR: Run run.mg2ioapi.path.csh failed"
    echo "ERROR in step 1.2 MG2IOAPI"
    exit 1
  else
    echo "end step 1.2 MG2IOAPI"
  endif

#-------------------step 3----------------------------
  ./run.megan.path.csh  $CUR_JDATE $DOMAINS_RES $INIT_H >& $meganlog/log.megan.D$DOMAINS_GRID.$CUR_JDATE

  if ( $status  != 0 ) then
    echo "ERROR: Run run.megan.path.csh failed"
    echo "ERROR in step 1.3 MEGAN"
    exit 1
  else
    echo "end step 1.3 MEGAN"
  endif

#-------------------step 4---------------------------
  ./run.mg2mech.CB05.path.csh $CUR_JDATE  $DOMAINS_RES $INIT_H  >& $meganlog/log.mg2mech.CB05.D$DOMAINS_GRID.$CUR_JDATE

  if ( $status != 0 ) then
    echo "ERROR: Run run.mg2mech.CB05.path.csh failed"
    echo "ERROR in step 1.4 MG2MECH"
    exit 1
  else
    echo "end step 1.4 MG2MECH for CB05"
  endif

###############Following steps needed for CAMx only########################
  echo '*************************************'
  echo 'Prepare biogenic emission for CAMx  *'
  echo 'The following steps are CAMx only   *'
  echo '*************************************'
#---------------- Step 5 ------------------------
  ./run.mg2mech.SOAX.path.csh $CUR_JDATE  $DOMAINS_RES $INIT_H >& $meganlog/log.mg2mech.SOAX.D$DOMAINS_GRID.$CUR_JDATE

  if ( $status != 0 ) then
    echo "ERROR: Run run.mg2mech.SOAX.path.csh failed"
    echo "ERROR in step 1.5 MG2MECH"
    exit 1
  else
    echo "end step 1.5 MG2MECH for SOAX"
  endif
#------------------- Step 6 -----------------------
  ./run.ioapi2uam.CB05_SOAX.path.csh $CUR_JDATE  $DOMAINS_RES $INIT_H >& $meganlog/log.ioapi2uam.D$DOMAINS_GRID.$CUR_JDATE
  if ( $status != 0 ) then
    echo "ERROR: Run run.ioapi2uam.CB05_SOAX.path.csh failed"
    echo "ERROR in step 1.6 IOAPI2UAM"
    exit 1
  else
    echo "end step 1.6 IOAPI2UAM"
  endif
# ----------------- Step 7 ---------------------------
  ./run.mrgem.path.job $CUR_JDATE $DOMAINS_RES >& $meganlog/log.mrgem.D$DOMAINS_GRID.$CUR_JDATE
  if ( $status != 0 ) then
    echo "ERROR: Run run.mrgem.path.job failed"
    echo "ERROR in step 1.7 MRGEM"
    exit 1
  else
    echo "end step 1.7 MRGEM"
  endif
    
  echo "--------------------------------------"
  echo "finished DATE: $CUR_JDATE                 "
  echo "--------------------------------------"

  echo "--------------------------------------"
  echo "finished domain: D$DOMAINS_GRID              "
  echo "--------------------------------------"

  @ DOMAINS_GRID ++
end

