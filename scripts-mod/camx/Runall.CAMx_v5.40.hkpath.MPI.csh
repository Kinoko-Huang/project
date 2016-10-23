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
    
    set CUR_GDATE = `$PATH_SYSDIR/bin/yj2ymd $CUR_JDATE`
    set camx_check = `tail -n 2 $CAMx_HOME/outputs/HKPATH.${DOMAINS_RES}/CAMx5.4.HKPATH.${DOMAINS_RES}.${CUR_GDATE}.out | head -n 1 | cut -c 1-3`
    if ( $camx_check != "END" ) then
      echo "Run CAMx_v5.40.hkpath.MPI.job unsucessful, d0${DOMAINS_GRID} CUR_GDATE"
      exit 1
    endif

    echo "Successfully finished CAMX d0${DOMAINS_GRID} $CUR_JDATE"
 
    @ DOMAINS_GRID ++
  end #end of foreach
set CUR_JDATE = `$PATH_SYSDIR/bin/yj_next $CUR_JDATE 1`

end #end of while

