#!/bin/csh -f 

source ../../domains_def.config

set JULBDATE = $argv[1]
set JULEDATE = $argv[2]

set BDATE = $JULBDATE
set JULDATE = $JULBDATE
echo $JULDATE $JULEDATE

setenv CAMxExec $PATH_ROOTDIR/camx/src.v5.40/CAMx.v5.40.MPI.pg_linux

./cleanup

while ( $JULDATE <= $JULEDATE ) 

  set GRID = 1
  foreach DOMAINS_RES ($G_DOMAINS_RES)
  
    if ( $GRID != 1  ) then
      cd $BNDEXTR
      csh -f bndextr.HKPATH.D34.job $JULDATE $BDATE $GRID $DOMAINS_RES 
    endif
 
    cd $CAMx_HOME/runfiles
    echo "Processing CAMx: D${GRID} on $JULDATE "
    csh -f CAMx_v5.40.hkpath.MPI.job $JULDATE $BDATE $GRID $DOMAINS_RES >& msg/log.D${GRID}.$JULDATE
    if ( $status != 0) then
      echo "ERROR: Run CAMx_v5.40.hkpath.MPI.job ${DOMAINS_RES}km failed"
      echo "ERROR in CAMx main program"
      exit 1
    else
      echo "Finish D${GRID}"
    endif
  
    @ GRID ++
  end #end of foreach
set JULDATE = `$CAMx_HOME/datelib/yyyyjjj_plus_dd $JULDATE 1`

end #end of while


