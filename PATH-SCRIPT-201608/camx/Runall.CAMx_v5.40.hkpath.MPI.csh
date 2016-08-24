#!/bin/csh -f 

source ../../domains_def.config

set BEG_JDATE = $argv[1]
set END_JDATE = $argv[2]

set CUR_JDATE = $BEG_JDATE
echo $CUR_JDATE $END_JDATE

setenv CAMxExec $PATH_ROOTDIR/camx/src.v5.40/CAMx.v5.40.MPI.pg_linux

./cleanup

while ( $CUR_JDATE <= $END_JDATE ) 

  set DOMAINS_GRID = 1
  foreach DOMAINS_RES ($G_DOMAINS_RES_CAMX)
  
    if ( $DOMAINS_GRID != 1  ) then
      cd $BNDEXTR
      csh -f bndextr.HKPATH.D34.job $CUR_JDATE $BEG_JDATE $DOMAINS_GRID $DOMAINS_RES 
    endif
 
    cd $CAMx_HOME/runfiles
    echo "Processing CAMx: D${DOMAINS_GRID} on $CUR_JDATE "
    csh -f CAMx_v5.40.hkpath.MPI.job $CUR_JDATE $BEG_JDATE $DOMAINS_GRID $DOMAINS_RES >& msg/log.D${DOMAINS_GRID}.$CUR_JDATE
    if ( $status != 0) then
      echo "ERROR: Run CAMx_v5.40.hkpath.MPI.job ${DOMAINS_RES}km failed"
      echo "ERROR in CAMx main program"
      exit 1
    else
      echo "Finish D${DOMAINS_GRID}"
    endif
  
    @ DOMAINS_GRID ++
  end #foreach
set CUR_JDATE = `$CAMx_HOME/datelib/yyyyjjj_plus_dd $CUR_JDATE 1`

end #while

