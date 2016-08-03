#!/bin/csh -f

set GREBDATE = $argv[1]
set GREEDATE = $argv[2]
set YYYY = `echo $GREBDATE | cut -c 1-4`
set MM   = `echo $GREBDATE | cut -c 5-6`
set DD   = `echo $GREBDATE | cut -c 7-8`
setenv HH  `echo $GREBDATE | cut -c 9-10`
set YYYY1 = `echo $GREEDATE | cut -c 1-4`
set MM1   = `echo $GREEDATE |cut -c 5-6`
set DD1   = `echo $GREEDATE |cut -c 7-8`

source setcase.whole.${HH}z.txt
source ../domains_def.config

set JULBDATE = `$CAMx_HOME/datelib/g2j $YYYY $MM $DD`
set JULEDATE = `$CAMx_HOME/datelib/g2j $YYYY1 $MM1 $DD1`
echo $JULBDATE $JULEDATE

##### Step 1 Prepare anthro emission for CAMx  ######
##### Run the convert program #####
###### Prepare icbc for CAMx #####
## Convert form CMAQ ###
#  cd $CMAQ2CAMx/work
#    csh -f conv_bcon_op.job $JULBDATE $JULEDATE
#    if ( $status != 0) then
#      echo "ERROR: Run conv_bcon_op.job failed"
#      echo "ERROR in step 1.2 CMAQBC2CAMx "
#      goto error
#    else
#      echo "end step 1.2 CMAQBC2CAMx"
#    endif
#    csh -f conv_icon_op.job $JULBDATE 
#    if ( $status != 0) then
#      echo "ERROR: Run conv_icon_op.job failed"
#      echo "ERROR in step 1.3 CMAQIC2CAMx "
#      goto error
#    else
#      echo "end step 1.3 CMAQIC2CAMx"
#    endif
#
###### Step 2 Prepare ahomap file for CAMx #########
#  cd $AHOMAP/work
#  csh -f $AHOMAP/work/ahomap.hk${HH}z.job $JULBDATE $JULEDATE
#  if ( $status != 0) then
#    echo "ERROR: Run ahomap.hk${HH}z.*.job failed"
#    echo "ERROR in step 3 AHOMAP"
#    goto error
#  else
#    echo "end step 3 AHOMAP"
#  endif
##
###### Step 3 Prepare tuv file for CAMx ############
#
#  cd $TUV
#  csh -f tuv4.0_1.hkpath.job   $JULBDATE $JULEDATE
#  if ( $status != 0) then
#    echo "ERROR: Run tuv4.0_1.hkpath.*.job failed"
#    echo "ERROR in step 4 TUV"
#    goto error
#  else
#    echo "end step 4 TUV"
#  endif
#### Step 4 Run CAMx of 27km ##################
  cd $CAMx_HOME/runfiles
    csh -f Runall.CAMx_v5.40.hkpath.MPI.csh $JULBDATE $JULEDATE 
    if ( $status != 0) then
      echo "ERROR: Run Runall.CAMx_v5.40.hkpath.MPI.csh failed"
      echo "ERROR in step 5 CAMx"
      goto error
    else
      echo "end step 5 CAMx"
    endif

############
  echo "--------------> Successfully Finished <---------------"
  exit 0   

###=================Label to abort the script==================
   error:
     echo "$0 exit with ERROR"
     exit 1 
