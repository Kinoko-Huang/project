#!/bin/csh

# ------------------------------------------------------------
# Run.emission.merge.all.csh
#
# The script is for processing the 6 steps for generate emission
# for CMAQ, using SMOKE and fortran programes.
#
#  FUNCION:(1) prepare INTEX-B weekly D1D2D3
#          (2) Run SMOKE to process pt/ar/ma of D3.
#          (3) Merge SMOKE D3 with INTEX-B D3
#          (4) Regrid merged D3 to D1D2
#          (5) Merge regrided D3 with INTEX-B D1D2
#          (6) Merge the above D1D2D3 with Megan bio. emis.
#
#  KEY SUBROUTINES/FUNCTIONS CALLED: SMOKE,MCIP,MEGAN,
#
#  REVISON HISTORY : Ying LI, 09/02/2009 fisinsh
#
# ------------------------------------------------------------

setenv SMK_HOME $SMOKE_DIR/camx/Smoke24.combine.v2
setenv SMKOUTPUT ${SMKTempDir}/grd_Alpine_test/CMAQ
if (! -e $SMKOUTPUT ) mkdir -p $SMKOUTPUT

setenv INTEXBEG $PATH_SYSDIR/static_data_v2/SMOKE.MICS/cmaq/D1D2D3D4_merge
setenv EDSS_EXE Linux2_x86pg
set emislogs = $cwd/emislog
if ( ! -e $emislogs ) mkdir -p $emislogs


#=== for 2_SMKRUND3/SMOKE_run_D3.csh ===
setenv SMK_RUN $SMK_HOME/subsys/smoke/asgn_20110930
setenv SMK_HOME_Alpine $SMK_HOME
setenv PROJECT_HOME $SMK_HOME/../Combine/2_SMKRUND3
setenv DATELIB $PROJECT_HOME/../DATELIB

#==== check the dir is there ====
foreach d ( $SMKOUTPUT  $INTEXBEG $SMK_RUN $SMK_HOME $SMK_HOME_Alpine )
  if ( ! -e $d ) then
     echo "Error in setcase: dir does not exists"
     echo "    $d"
     exit -2
  endif
end

set BEG_JDATE = $argv[1]
set END_JDATE = $argv[2]
set INIT_H   = $argv[3]
echo $BEG_JDATE $END_JDATE $INIT_H

set CUR_JDATE = $BEG_JDATE
echo "################################################"
echo "current time at starting: `date`"
echo "################################################"
#============= loop all day ==========================
while ( $CUR_JDATE <= $END_JDATE )
   echo ""
   echo "------------------------------------------------"
   echo "step 0: deleting previous generate temp output..."
   echo "------------------------------------------------"
   rm -f $SMKOUTPUT/blank_tshift_output/Blank_*_*.ncf
   rm -f $SMKOUTPUT/Regrid/D3_regrid2_D1_*.ncf
   rm -f $SMKOUTPUT/Regrid/D3_regrid2_D2_*.ncf

   echo ""
   echo "------------------------------------------------"
   echo "start step 1_MEGAN"
   echo "------------------------------------------------"
      set stepinfo = "step 4.1: MEGAN"
        # make sure already have the weekly profile of INTEXB
   cd 1_MEGANv2.04/work
      ./Runall.megan.hkpath.csh $CUR_JDATE $INIT_H
      if ($status != 0) goto error
      cd ../..
   echo "end step4.1: MEGAN"

   echo ""
   echo "------------------------------------------------"
   echo "start step4.2: 2_SMKRUND3 on $CUR_JDATE"
   echo "------------------------------------------------"

   cd 2_SMKRUND3/
      set stepinfo = "step 4.2: 2_SMKRUND3"
      ./SMOKE_run_DX.csh $CUR_JDATE $INIT_H
      if ($status != 0) goto error
      cd ..
   echo "end step4.2: 2_SMKRUND3"
  
   echo ""
   echo "------------------------------------------------"
   echo "starting step 3_MergeD3_INB on $CUR_JDATE"
   echo "------------------------------------------------"

   cd 3_MergeD3_INB/
      set stepinfo = "step 3: 3_MergeD3_INB"
      ./run.merge_emisD3_join.csh $CUR_JDATE $INIT_H >& $emislogs/log_step3_mergeD3_INB_$CUR_JDATE
      if ($status != 0) goto error
      cd ..
   echo "end step4.3: 3_MergeD3_INB"
   
#   echo ""
#   echo "------------------------------------------------"
#   echo "start step4.4.1: 4_RegridD3/MakeBlank if blank file not exits"
#   echo "------------------------------------------------"

#   cd 4_RegridD3/MakeBlank/run
#      set stepinfo = "step4.4.1: 4_RegridD3/MakeBlank/run"
#      ./run.mk_blank_tvncf.csh >& $emislogs/log_step4.1_mk_blank
#      if ($status != 0) goto error
#      cd ../../..
   
   echo "------------------------------------------------"
   echo "start step4.4: 4_RegridD3/mtxblend on $CUR_JDATE"
   echo "------------------------------------------------"

   cd 4_RegridD3/mtxblend/
      set stepinfo = "step4.4: 4_RegridD3/mtxblend"
       # shift time of blank file
       ./run_tshift_D1D2_blank.csh $CUR_JDATE $INIT_H >& $emislogs/log_step4.2_tshift_$CUR_JDATE
      if ($status != 0) goto error
       
       # mtxblend D1
       ./run_mtxblend_3to27 $CUR_JDATE >& $emislogs/log_step4.3_mtxblend_D3toD1_$CUR_JDATE
      if ($status != 0) goto error
       
       # mtxblend D2 
       ./run_mtxblend_3to9  $CUR_JDATE >& $emislogs/log_step4.4_mtxblend_D3toD2_$CUR_JDATE
      if ($status != 0) goto error
   
       cd ../../
   echo "end step4.4: 4_RegridD3"
  
   echo ""
   echo "------------------------------------------------"
   echo "start step4.5: 5_Insert2D1D2 on $CUR_JDATE"
   echo "------------------------------------------------"

   cd 5_Insert2D1D2/
      set stepinfo = "step 4.5: 5_Insert2D1D2"
       ./run.merge_emisD1D2_join.csh $CUR_JDATE $INIT_H >& $emislogs/log_step5_merge_D3toD12_$CUR_JDATE

      if ($status != 0) goto error
       cd ..
   echo "end step4.5: 5_Insert2D1D2"
   
   echo ""
   echo "------------------------------------------------"
   echo "start step4.6: 6_CMAQ2CAMx/ on $CUR_JDATE"
   echo "------------------------------------------------"

  cd 6_CMAQ2CAMx/work
    set stepinfo = "step 6: 6_CMAQ2CAMx"
    ./conv_emis_intexb_DX.job $CUR_JDATE $CUR_JDATE >&  $emislogs/log_step6_cmaq2camx_intexb_$CUR_JDATE
    if ($status != 0 ) goto error
      cd ../..
       echo "end step4.6: 6_CMAQ2CAMx"

   echo ""
   echo "------------------------------------------------"
   echo "start step4.7: 7_Merge_MEGAN/ on $CUR_JDATE"
   echo "------------------------------------------------"

  cd 7_Merge_MEGAN
    set stepinfo = "step 7: 7_Merge_MEGAN"
    csh -x merge_intexb_bio_DX_distrib.job $CUR_JDATE $CUR_JDATE $INIT_H >& $emislogs/log_step7_merge_intexb_bio_$CUR_JDATE
    if ($status != 0 ) goto error
      cd ..
       echo "end step4.7: 7_Merge_MEGAN"

   echo ""
   echo "------------------------------------------------"


   echo ""
   echo "------------------------------------------------"
   echo "finish $CUR_JDATE, sleep 10s, if keep tmp out, press ctrl+c now"
   echo "------------------------------------------------"
        sleep 10

   set CUR_JDATE = `$DATELIB/yyyyjjj_plus_dd $CUR_JDATE 1`
   
   end
   
   echo "################################################"
   echo "current time at finish: `date`"
   echo "################################################"
   
   exit 0
   
   #========== labels to abort the script =================
   error:
     echo "------------------------------------------------"
     echo "Error occurs. Some info:"
     echo "------------------------------------------------"
     echo "  BEG_JDATE=$BEG_JDATE"
     echo "  END_JDATE=$END_JDATE"
     echo "  CUR_JDATE   =$CUR_JDATE"
     echo "  error in step: $stepinfo"
     exit 1
