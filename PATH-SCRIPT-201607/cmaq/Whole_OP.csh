#! /bin/csh -f

source ../domains_def.config

if ( $#argv != 2 ) then
  echo "Usage: $0 YYYYMMDDhh MCIP_directory"
  echo " e.g.: $0 2007090200 /home/pathop/mcip_data"
  exit 1
endif

if ( ! $?NPROCS ) then
  echo "NPROCS is not set"
  exit 1
endif

if ( ! $?NPCOL_NPROW ) then
  echo "NPCOL_NPROW is not set"
  exit 1
endif

set INIT_TIME = $1
setenv GREGBEGN `echo $INIT_TIME | cut -c 1-8`
setenv GREGBEGN `/bin/date -d "${GREGBEGN} ${CTM_SKIP_N_DAYS} day" +%Y%m%d`

setenv MCIPDIR  $2        # Data under this directory should be YYYY/YYYYMM/YYYYMMDDhh/*km/
    
echo MCIP Initial Date: $GREGBEGN

setenv OPDIR `/bin/pwd`
echo OPDIR=$OPDIR
setenv UTILDIR $OPDIR/utils
echo UTILDIR=$UTILDIR
setenv INDIR $OPDIR/inputs
echo INDIR=$INDIR

# set beginning time - either 00 or 12
#setenv HH 12
setenv HH `echo $INIT_TIME | cut -c 9-10`
echo HH=$HH

#set output directory
setenv M3CASE run.OP_mm5_cb05cl
setenv CCTMOUTDIR $OPDIR/outputs/$M3CASE

setenv JULIBEGN `$UTILDIR/datelib/yyyymmdd2yyyyjjj $GREGBEGN`
#setenv JULILAST `expr "$JULIBEGN" \+ "${CTM_SIM_N_DAYS}" \- 1`
set atmp = `expr ${CTM_SIM_N_DAYS} \- 1`
setenv  JULILAST `$PATH_SYSDIR/bin/yj_next $JULIBEGN $atmp`

setenv GREGLAST `$UTILDIR/datelib/yyyyjjj2yyyymmdd $JULIBEGN`
#setenv JULIPREV `expr "$JULIBEGN" \- "${CTM_SKIP_N_DAYS}"`
setenv  JULIPREV `$PATH_SYSDIR/bin/yj_prev $JULIBEGN ${CTM_SKIP_N_DAYS}`

echo JULIBEGN=$JULIBEGN
echo JULILAST=$JULILAST
echo GREGBEGN=$GREGBEGN
echo GREGLAST=$GREGLAST

setenv GREGPREV `$UTILDIR/datelib/yyyyjjj2yyyymmdd $JULIPREV`
echo JULIPREV=$JULIPREV
echo GREGPREV=$GREGPREV

#setenv YYYY `echo $GREGBEGN | cut -c1-4`
setenv YYYY `echo $GREGPREV | cut -c1-4`
setenv MM `echo $GREGPREV | cut -c5-6`
setenv DD `echo $GREGPREV | cut -c7-8`

echo YYYY=$YYYY
echo MM=$MM
echo DD=$DD

####LINK MCIP TO INPUT##################################

set LINKMCIP = 1
if ( "$LINKMCIP" == 1 ) then
  #setenv MCIPDIR ~pathop/data/mcip
  echo LINK MCIP to INPUT
  echo MCIP directory $MCIPDIR/$YYYY/$YYYY$MM/${YYYY}${MM}${DD}${HH}
  foreach DMAIN ( $G_DOMAINS_RES )
    /bin/ln -sf $MCIPDIR/$YYYY/$YYYY$MM/{$YYYY}{$MM}{$DD}{$HH}/${DMAIN}km/GRID* $INDIR/met/${DMAIN}km/
    if ( $status != 0 ) then
      echo "Failed: /bin/ln -sf $MCIPDIR/$YYYY/$YYYY$MM/${YYYY}${MM}${DD}${HH}/${DMAIN}km/GRID* $INDIR/met/${DMAIN}km/"
      exit 1
    endif
    /bin/ln -sf $MCIPDIR/$YYYY/$YYYY$MM/{$YYYY}{$MM}{$DD}{$HH}/${DMAIN}km/MET* $INDIR/met/${DMAIN}km/
    if ( $status != 0 ) then
      echo "Failed: /bin/ln -sf $MCIPDIR/$YYYY/$YYYY$MM/${YYYY}${MM}${DD}${HH}/${DMAIN}km/MET* $INDIR/met/${DMAIN}km/"
      exit 1
    endif
  end
endif

#finished linking mcip
cd $OPDIR

####PREPARE JPROC INPUT#################################

set DOJPROC = 1
if ( "$DOJPROC" == 1 ) then
  echo "PREPARE_JPROC"
  cd $OPDIR/preproc/jproc
  echo ./run.OP.cb05cl.jproc $JULIBEGN $JULILAST 
  ./run.OP.cb05cl.jproc $JULIBEGN $JULILAST 
  if ( $status != 0 ) then
    echo Failed ./run.OP.cb05cl.jproc $JULIBEGN $JULILAST
    exit 1
  endif

  #finished running jproc...
  cd $OPDIR

  #move jtable to input folder
  set yr0 = `echo $JULIBEGN | cut -c1-4`
  set yr1 = `echo $JULILAST | cut -c1-4`
  /bin/mkdir -p $INDIR/jproc
  set yr = $yr0
  while ( "$yr" <= "$yr1" )
    #mv -v $OPDIR/preproc/jproc/$yr/JTABLE* $INDIR/jproc/$YYYY/
    #mv -v $OPDIR/preproc/jproc/$yr/JTABLE* $INDIR/jproc/
    /usr/bin/find $OPDIR/preproc/jproc/$yr -type f -name "JTABLE*" -exec /bin/mv -v {} $INDIR/jproc/ \;
    #if ( $status != 0 ) then
    #  echo Failed: mv $OPDIR/preproc/jproc/$yr/JTABLE+ $INDIR/jproc/
    #  exit 1
    #endif
    set yr = `expr $yr + 1`
  end
endif

####CHOOSE SMOKE EMISS TO INPUT###########################

if ( "$HH" == "12" ) then
  set hour12z = "_12z"
else
  set hour12z = ""
endif

#set PICKEMIS = 1
echo PICKEMIS = $PICKEMIS
if ( "$PICKEMIS" == 1 ) then
  echo CHOOSE GENERIC EMISS TO INPUT
  # Pre-generated emission data
  setenv EGEN_DIR $PATH_SYSDIR/static_data/CMAQ/emiss${hour12z}-v2
  set IDATE = $JULIBEGN
  while ("$IDATE" <= "$JULILAST" )
    setenv IGREG `$UTILDIR/datelib/yyyyjjj2yyyymmdd $IDATE`
    setenv IDOW `$UTILDIR/datelib/yyyymmdd2dow $IGREG`
    foreach DMAIN ( $G_DOMAINS_RES )
      switch ( $IDOW )
      case Sat:
        setenv INFILE ${EGEN_DIR}/${DMAIN}km/merged/emiss_CB05.HongKong.${DMAIN}km_Sat${hour12z}.ncf
        breaksw
      case Sun:
        setenv INFILE ${EGEN_DIR}/${DMAIN}km/merged/emiss_CB05.HongKong.${DMAIN}km_Sun${hour12z}.ncf
        breaksw
      case Mon:
        setenv INFILE ${EGEN_DIR}/${DMAIN}km/merged/emiss_CB05.HongKong.${DMAIN}km_Mon${hour12z}.ncf
        breaksw
      case Tue:
        setenv INFILE ${EGEN_DIR}/${DMAIN}km/merged/emiss_CB05.HongKong.${DMAIN}km_Tue${hour12z}.ncf
        breaksw
      case Wed:
        setenv INFILE ${EGEN_DIR}/${DMAIN}km/merged/emiss_CB05.HongKong.${DMAIN}km_Wed${hour12z}.ncf
        breaksw
      case Thu:
        setenv INFILE ${EGEN_DIR}/${DMAIN}km/merged/emiss_CB05.HongKong.${DMAIN}km_Thu${hour12z}.ncf
        breaksw
      case Fri:
        setenv INFILE ${EGEN_DIR}/${DMAIN}km/merged/emiss_CB05.HongKong.${DMAIN}km_Fri${hour12z}.ncf
        breaksw
      endsw
      setenv OUTFILE $INDIR/emiss/${DMAIN}km/emiss_CB05.HongKong.${DMAIN}km_${IDATE}.ncf
      cd $UTILDIR/m3tshift
      echo Run ./run.m3tshift.csh $IDATE $INFILE $OUTFILE
      ./run.m3tshift.csh $IDATE $INFILE $OUTFILE
      cd $OPDIR
    end #DMAIN
    #@ IDATE++
    set IDATE = `$PATH_SYSDIR/bin/yj_next $IDATE 1`
  end
else
  set IDATE = $JULIBEGN
  setenv OUTFILE $INDIR/emiss/${DMAIN}km/emiss_CB05.HongKong.${DMAIN}km_${IDATE}.ncf  #(point to our SMOKE-cmaqfc output file)
  echo emiss OUTFILE=$OUTFILE
endif

cd $OPDIR

########CHOOSE ICBC for 27km DOMAIN################
echo CHOOSE ICBC for outmost DOMAIN
setenv WCHICBC PATHICBC
if ( "$HH" == "12" ) then
  unsetenv WCHICBC
  setenv WCHICBC PATHICBC_12z
endif

set PICKICBC = 1
if ( "$PICKICBC" == 1 ) then
  #Determine which season of IC BC to be used
  if ( "$MM" == "12" | "$MM" == "01" | "$MM" == "02" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200601
    setenv SEAS Winter
    #gunzip $ICBCDIR/ICON_COMBINE_2006002.gz
    cp $ICBCDIR/ICON_COMBINE_2006002 $INDIR/icbc/27km/
    setenv ICON_path $INDIR/icbc/27km
    setenv ICON_file ICON_COMBINE_2006002
    #gzip $ICBCDIR/ICON_COMBINE_2006002
  else if ( "$MM" == "03" | "$MM" == "04" | "$MM" == "05" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200604
    setenv SEAS Spring
    #gunzip $ICBCDIR/ICON_COMBINE_2006091.gz
    cp $ICBCDIR/ICON_COMBINE_2006091 $INDIR/icbc/27km/
    setenv ICON_path $INDIR/icbc/27km
    setenv ICON_file ICON_COMBINE_2006091
    #gzip $ICBCDIR/ICON_COMBINE_2006091
  else if ( "$MM" == "06" | "$MM" == "07" | "$MM" == "08" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200607
    setenv SEAS Summer
    #gunzip $ICBCDIR/ICON_COMBINE_2006182.gz
    cp $ICBCDIR/ICON_COMBINE_2006182 $INDIR/icbc/27km/
    setenv ICON_path $INDIR/icbc/27km
    setenv ICON_file ICON_COMBINE_2006182
    #gzip $ICBCDIR/ICON_COMBINE_2006182
  else if ( "$MM" == "09" | "$MM" == "10" | "$MM" == "11" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200610
    setenv SEAS Autumn
    #gunzip $ICBCDIR/ICON_COMBINE_2006274.gz
    cp $ICBCDIR/ICON_COMBINE_2006274 $INDIR/icbc/27km/
    setenv ICON_path $INDIR/icbc/27km
    setenv ICON_file ICON_COMBINE_2006274
    #gzip $ICBCDIR/ICON_COMBINE_2006274
  endif 

  #Match DOW and unzip the ID'ed IC BC
  #Change time stamp and put them into the input folder
  set IDATE = $JULIBEGN
  while ( "$IDATE" <= "$JULILAST" )
    setenv IGREG `$UTILDIR/datelib/yyyyjjj2yyyymmdd $IDATE`
    setenv IDOW `$UTILDIR/datelib/yyyymmdd2dow $IGREG`
  
    switch ( $IDOW )
    case Sat:
      switch ( $SEAS )
      case Winter:
        setenv DATEDOW 2006014
        breaksw
      case Spring:
        setenv DATEDOW 2006105
        breaksw
      case Summer:
        setenv DATEDOW 2006196
        breaksw
      case Autumn:
        setenv DATEDOW 2006287
        breaksw
      endsw
      breaksw
    case Sun:
      switch ( $SEAS )
      case Winter:
        setenv DATEDOW 2006015
        breaksw
      case Spring:
        setenv DATEDOW 2006106
        breaksw
      case Summer:
        setenv DATEDOW 2006197
        breaksw
      case Autumn:
        setenv DATEDOW 2006288
        breaksw
      endsw
      breaksw
    case Mon:
      switch ( $SEAS )
      case Winter:
        setenv DATEDOW 2006016
        breaksw
      case Spring:
        setenv DATEDOW 2006107
        breaksw
      case Summer:
        setenv DATEDOW 2006198
        breaksw
      case Autumn:
        setenv DATEDOW 2006289
        breaksw
      endsw
      breaksw
    case Tue:
      switch ( $SEAS )
      case Winter:
        setenv DATEDOW 2006017
        breaksw
      case Spring:
        setenv DATEDOW 2006108
        breaksw
      case Summer:
        setenv DATEDOW 2006199
        breaksw
      case Autumn:
        setenv DATEDOW 2006290
        breaksw
      endsw
      breaksw
    case Wed:
      switch ( $SEAS )
      case Winter:
        setenv DATEDOW 2006018
        breaksw
      case Spring:
        setenv DATEDOW 2006109
        breaksw
      case Summer:
        setenv DATEDOW 2006200
        breaksw
      case Autumn:
        setenv DATEDOW 2006291
        breaksw
      endsw
      breaksw
    case Thu:
      switch ( $SEAS )
      case Winter:
        setenv DATEDOW 2006019
        breaksw
      case Spring:
        setenv DATEDOW 2006110
        breaksw
      case Summer:
        setenv DATEDOW 2006201
        breaksw
      case Autumn:
        setenv DATEDOW 2006292
        breaksw
      endsw
      breaksw
    case Fri:
      switch ( $SEAS )
      case Winter:
        setenv DATEDOW 2006020
        breaksw
      case Spring:
        setenv DATEDOW 2006111 
        breaksw
      case Summer:
        setenv DATEDOW 2006202
        breaksw
      case Autumn:
        setenv DATEDOW 2006293
        breaksw
      endsw
      breaksw
    endsw
    
    setenv INFILE $ICBCDIR/BCON_COMBINE_${DATEDOW}
    if ( "$HH" == "12" ) then
      unsetenv INFILE
      setenv INFILE $ICBCDIR/BCON_COMBINE_${DATEDOW}_12z
    endif
    setenv OUTFILE $INDIR/icbc/27km/BCON_COMBINE_$IDATE
    cd $UTILDIR/m3tshift
    ./run.m3tshift.csh $IDATE $INFILE $OUTFILE
    cd $OPDIR
    #gzip $INFILE
    #@ IDATE++
    set IDATE = `$PATH_SYSDIR/bin/yj_next $IDATE 1`
  end
endif
cd $OPDIR

########RUN CMAQ ON NESTING DOMAINS################
echo RUN CMAQ ON NESTING DOMAINS
set IDATE = $JULIBEGN
set GRID = 1
while ( "$IDATE" <= "$JULILAST" )
  setenv IGREG `$UTILDIR/datelib/yyyyjjj2yyyymmdd $IDATE`
  foreach DMAIN ( $G_DOMAINS_RES )  
  setenv MIDNAME hk${DMAIN}
#  switch ( $DMAIN )
#    case 27km
#      setenv MIDNAME hk27
#      breaksw
#    case 9km
#      setenv MIDNAME hk9
#      breaksw
#    case 3km
#      setenv MIDNAME hk3
#      breaksw
#    case 1km
#      setenv MIDNAME hk1
#      breaksw
#    endsw
#
    echo NOW IS RUNNING BCON ON ${DMAIN}km at $IDATE ...
    # run bcon
    if ( "$GRID" != "1" ) then
      cd $OPDIR/preproc/bcon
       ./run.bcon.OP.job $IDATE $GRID
      if ( $status != 0 ) then
        echo Failed: ./run.bcon.OP.job $IDATE ${DMAIN}km
        exit 1
      endif
    endif

    echo NOW IS RUNNING ICON ON $DMAIN at $IDATE ...
    # run icon
    if ( "$GRID" != "1" ) then
      if ( "$IDATE" == "$JULIBEGN" ) then
        cd $OPDIR/preproc/icon
         ./run.icon.OP.job $IDATE $GRID
        if ( $status != 0 ) then
          echo Failed: ./run.icon.OP.job $IDATE ${DMAIN}km
          exit 1
        endif
      endif
    endif
    echo NOW IS RUNNING CCTM ON ${DMAIN}km at $IDATE ...
    cd $OPDIR
    # run cmaq
    if ( $GRID == 1 ) then
      cd $OPDIR/runfiles/first_grid
      if ( $CTM_COLD_START == 1 && "$IDATE" == "$JULIBEGN" ) then
        echo "CMAQ cold start domain = ${DMAIN}km and date = $JULIBEGN"
        echo Run ./run.OP.$MIDNAME.mpich2_cold $IDATE $ICON_path $ICON_file
        ./run.OP.$MIDNAME.mpich2_cold $IDATE $ICON_path $ICON_file
        if ( $status != 0 ) then
          echo Failed: ./run.OP.$MIDNAME.mpich2_cold $IDATE $ICON_path $ICON_file
          exit 1
        endif
      else
        echo Run ./run.OP.$MIDNAME.mpich2 $IDATE
        ./run.OP.$MIDNAME.mpich2 $IDATE
        if ( $status != 0 ) then
          echo Failed: ./run.OP.$MIDNAME.mpich2 $IDATE
          exit 1
        endif
      endif
    else
       cd $OPDIR/runfiles/refined_grid
        if ( $CTM_COLD_START == 1 && "$IDATE" == "$JULIBEGN" ) then
          echo "CMAQ cold start domain = ${DMAIN}km and date = $JULIBEGN"
          ./run.OP.mpich2_cold $IDATE $DMAIN
          if ( $status != 0 ) then
            echo Failed: ./run.OP.mpich2_cold $IDATE ${DMAIN}km
            exit 1
          endif
        else
          echo Run ./run.OP.mpich2 $IDATE ${DMAIN}km
          ./run.OP.mpich2 $IDATE $DMAIN
          if ( $status != 0 ) then
            echo Failed: ./run.OP.mpich2 $IDATE ${DMAIN}km
            exit 1
          endif
        endif
    endif
    @ GRID ++
    end  # foreach DMAIN
    #@ IDATE++
    set IDATE = `$PATH_SYSDIR/bin/yj_next $IDATE 1`
  end 
  
########AT THE VERY END############################
cd $OPDIR

