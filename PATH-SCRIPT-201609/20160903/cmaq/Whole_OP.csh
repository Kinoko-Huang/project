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
setenv INIT_GDATE `echo $INIT_TIME | cut -c 1-8`
setenv BEG_GDATE `/bin/date -d "${INIT_GDATE} ${CTM_SKIP_N_DAYS} day" +%Y%m%d`

setenv MCIPDIR  $2        # Data under this directory should be YYYY/YYYYMM/YYYYMMDDhh/*km/
    
echo MCIP Initial Date: $BEG_GDATE

setenv OPDIR `/bin/pwd`
setenv UTILDIR $OPDIR/utils
setenv INDIR $OPDIR/inputs
echo OPDIR=$OPDIR
echo UTILDIR=$UTILDIR
echo INDIR=$INDIR

#> set the scenario
setenv M3PLAN  HK
setenv M3CASE run.OP_mm5_cb05cl
setenv CHEM  cb05cl
setenv M3GRID 04
setenv M3VLEV 19
setenv M3EXTN mpich2

#> executable
#setenv APPL v47_ebi_cb05cl_ae5_aq_mpi_pg64
setenv APPL V5g_ebi_cb05cl_ae5_aq
setenv EXEC CCTM_$APPL

# set beginning time - either 00 or 12
setenv INIT_H `echo $INIT_TIME | cut -c 9-10`
echo INIT_H=$INIT_H

#set output directory
setenv M3CASE run.OP_mm5_cb05cl
setenv CCTMOUTDIR $OPDIR/outputs/$M3CASE

#setenv BEG_JDATE `$UTILDIR/datelib/yyyymmdd2yyyyjjj $BEG_GDATE`
setenv BEG_JDATE `$PATH_SYSDIR/bin/ymd2yj $BEG_GDATE`
set atmp = `expr ${CTM_SIM_N_DAYS} \- 1`
setenv  END_JDATE `$PATH_SYSDIR/bin/yj_next $BEG_JDATE $atmp`
echo BEG_JDATE=$BEG_JDATE
echo END_JDATE=$END_JDATE
echo BEG_GDATE=$BEG_GDATE

setenv INIT_Y `echo $INIT_GDATE | cut -c1-4`
setenv INIT_M `echo $INIT_GDATE | cut -c5-6`
echo INIT_Y=$INIT_Y
echo INIT_M=$INIT_M

####LINK MCIP TO INPUT##################################
set LINKMCIP = 1
if ( "$LINKMCIP" == 1 ) then
  #setenv MCIPDIR ~pathop/data/mcip
  echo LINK MCIP to INPUT
  echo MCIP directory $MCIPDIR/$INIT_Y/$INIT_Y$INIT_M/${INIT_TIME}
  foreach DOMAINS_RES ( $G_DOMAINS_RES_CMAQ )
    /bin/ln -sf $MCIPDIR/$INIT_Y/$INIT_Y$INIT_M/$INIT_TIME/${DOMAINS_RES}km/GRID* $INDIR/met/${DOMAINS_RES}km/
    if ( $status != 0 ) then
      echo "Failed: /bin/ln -sf $MCIPDIR/$INIT_Y/$INIT_Y$INIT_M/${INIT_TIME}/${DOMAINS_RES}km/GRID* $INDIR/met/${DOMAINS_RES}km/"
      exit 1
    endif
    /bin/ln -sf $MCIPDIR/$INIT_Y/$INIT_Y$INIT_M/$INIT_TIME/${DOMAINS_RES}km/MET* $INDIR/met/${DOMAINS_RES}km/
    if ( $status != 0 ) then
      echo "Failed: /bin/ln -sf $MCIPDIR/$INIT_Y/$INIT_Y$INIT_M/${INIT_TIME}/${DOMAINS_RES}km/MET* $INDIR/met/${DOMAINS_RES}km/"
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
  echo ./run.OP.cb05cl.jproc $BEG_JDATE $END_JDATE 
  ./run.OP.cb05cl.jproc $BEG_JDATE $END_JDATE 
  if ( $status != 0 ) then
    echo Failed ./run.OP.cb05cl.jproc $BEG_JDATE $END_JDATE
    exit 1
  endif
  
  #finished running jproc...
  cd $OPDIR

  #move jtable to input folder
  set BEG_Y = `echo $BEG_JDATE | cut -c1-4`
  set END_Y = `echo $END_JDATE | cut -c1-4`
  /bin/mkdir -p $INDIR/jproc
  set CUR_Y = $BEG_Y
  while ( "$CUR_Y" <= "$END_Y" )
    #mv -v $OPDIR/preproc/jproc/$CUR_Y/JTABLE* $INDIR/jproc/$INIT_Y/
    #mv -v $OPDIR/preproc/jproc/$CUR_Y/JTABLE* $INDIR/jproc/
    /usr/bin/find $OPDIR/preproc/jproc/$CUR_Y -type f -name "JTABLE*" -exec /bin/mv -v {} $INDIR/jproc/ \;
    #if ( $status != 0 ) then
    #  echo Failed: mv $OPDIR/preproc/jproc/$CUR_Y/JTABLE+ $INDIR/jproc/
    #  exit 1
    #endif
    set CUR_Y = `expr $CUR_Y + 1`
  end
endif

####CHOOSE SMOKE EMISS TO INPUT###########################

if ( "$INIT_H" == "12" ) then
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
  set CUR_JDATE = $BEG_JDATE
  while ("$CUR_JDATE" <= "$END_JDATE" )
    #setenv CUR_GDATE `$UTILDIR/datelib/yyyyjjj2yyyymmdd $CUR_JDATE`
    setenv CUR_GDATE `$PATH_SYSDIR/bin/yj2ymd $CUR_JDATE`
    setenv IDOW `$UTILDIR/datelib/yyyymmdd2dow $CUR_GDATE`
    foreach DOMAINS_RES ( $G_DOMAINS_RES_CMAQ )
      switch ( $IDOW )
      case Sat:
        setenv INFILE ${EGEN_DIR}/${DOMAINS_RES}km/merged/emiss_CB05.HongKong.${DOMAINS_RES}km_Sat${hour12z}.ncf
        breaksw
      case Sun:
        setenv INFILE ${EGEN_DIR}/${DOMAINS_RES}km/merged/emiss_CB05.HongKong.${DOMAINS_RES}km_Sun${hour12z}.ncf
        breaksw
      case Mon:
        setenv INFILE ${EGEN_DIR}/${DOMAINS_RES}km/merged/emiss_CB05.HongKong.${DOMAINS_RES}km_Mon${hour12z}.ncf
        breaksw
      case Tue:
        setenv INFILE ${EGEN_DIR}/${DOMAINS_RES}km/merged/emiss_CB05.HongKong.${DOMAINS_RES}km_Tue${hour12z}.ncf
        breaksw
      case Wed:
        setenv INFILE ${EGEN_DIR}/${DOMAINS_RES}km/merged/emiss_CB05.HongKong.${DOMAINS_RES}km_Wed${hour12z}.ncf
        breaksw
      case Thu:
        setenv INFILE ${EGEN_DIR}/${DOMAINS_RES}km/merged/emiss_CB05.HongKong.${DOMAINS_RES}km_Thu${hour12z}.ncf
        breaksw
      case Fri:
        setenv INFILE ${EGEN_DIR}/${DOMAINS_RES}km/merged/emiss_CB05.HongKong.${DOMAINS_RES}km_Fri${hour12z}.ncf
        breaksw
      endsw
      setenv OUTFILE $INDIR/emiss/${DOMAINS_RES}km/emiss_CB05.HongKong.${DOMAINS_RES}km_${CUR_JDATE}.ncf
      cd $UTILDIR/m3tshift
      echo Run ./run.m3tshift.csh $CUR_JDATE $INFILE $OUTFILE
      ./run.m3tshift.csh $CUR_JDATE $INFILE $OUTFILE
      cd $OPDIR
    end #end of foreach DOMAINS_RES
    set CUR_JDATE = `$PATH_SYSDIR/bin/yj_next $CUR_JDATE 1`
  end #end of while CUR_JDATE
else
  set CUR_JDATE = $BEG_JDATE
  setenv OUTFILE $INDIR/emiss/${DOMAINS_RES}km/emiss_CB05.HongKong.${DOMAINS_RES}km_${CUR_JDATE}.ncf  #(point to our SMOKE-cmaqfc output file)
  echo emiss OUTFILE=$OUTFILE
endif

cd $OPDIR

########CHOOSE ICBC for First Grid DOMAIN################
echo CHOOSE ICBC for outmost DOMAIN
setenv WCHICBC PATHICBC
if ( "$INIT_H" == "12" ) then
  unsetenv WCHICBC
  setenv WCHICBC PATHICBC_12z
endif

set PICKICBC = 1
if ( "$PICKICBC" == 1 ) then
  #Determine which season of IC BC to be used
  if ( "$INIT_M" == "12" | "$INIT_M" == "01" | "$INIT_M" == "02" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200601
    setenv SEAS Winter
    #gunzip $ICBCDIR/ICON_COMBINE_2006002.gz
    cp $ICBCDIR/ICON_COMBINE_2006002 $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km/
    setenv ICON_path $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km
    setenv ICON_file ICON_COMBINE_2006002
    #gzip $ICBCDIR/ICON_COMBINE_2006002
  else if ( "$INIT_M" == "03" | "$INIT_M" == "04" | "$INIT_M" == "05" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200604
    setenv SEAS Spring
    #gunzip $ICBCDIR/ICON_COMBINE_2006091.gz
    cp $ICBCDIR/ICON_COMBINE_2006091 $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km/
    setenv ICON_path $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km
    setenv ICON_file ICON_COMBINE_2006091
    #gzip $ICBCDIR/ICON_COMBINE_2006091
  else if ( "$INIT_M" == "06" | "$INIT_M" == "07" | "$INIT_M" == "08" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200607
    setenv SEAS Summer
    #gunzip $ICBCDIR/ICON_COMBINE_2006182.gz
    cp $ICBCDIR/ICON_COMBINE_2006182 $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km/
    setenv ICON_path $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km
    setenv ICON_file ICON_COMBINE_2006182
    #gzip $ICBCDIR/ICON_COMBINE_2006182
  else if ( "$INIT_M" == "09" | "$INIT_M" == "10" | "$INIT_M" == "11" ) then
    setenv ICBCDIR $OPDIR/preproc/$WCHICBC/200610
    setenv SEAS Autumn
    #gunzip $ICBCDIR/ICON_COMBINE_2006274.gz
    cp $ICBCDIR/ICON_COMBINE_2006274 $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km/
    setenv ICON_path $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km
    setenv ICON_file ICON_COMBINE_2006274
    #gzip $ICBCDIR/ICON_COMBINE_2006274
  endif 

  #Match DOW and unzip the ID'ed IC BC
  #Change time stamp and put them into the input folder
  set CUR_JDATE = $BEG_JDATE
  while ( "$CUR_JDATE" <= "$END_JDATE" )
    setenv CUR_GDATE `$PATH_SYSDIR/bin/yj2ymd $CUR_JDATE`
    setenv IDOW `$UTILDIR/datelib/yyyymmdd2dow $CUR_GDATE`
  
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
    if ( "$INIT_H" == "12" ) then
      unsetenv INFILE
      setenv INFILE $ICBCDIR/BCON_COMBINE_${DATEDOW}_12z
    endif
    setenv OUTFILE $INDIR/icbc/${G_DOMAINS_RES_CMAQ[1]}km/BCON_COMBINE_$CUR_JDATE
    cd $UTILDIR/m3tshift
    ./run.m3tshift.csh $CUR_JDATE $INFILE $OUTFILE
    cd $OPDIR
    #gzip $INFILE
    set CUR_JDATE = `$PATH_SYSDIR/bin/yj_next $CUR_JDATE 1`
  end
endif
cd $OPDIR

########RUN CMAQ ON NESTING DOMAINS################
echo RUN CMAQ ON NESTING DOMAINS
set CUR_JDATE = $BEG_JDATE
while ( "$CUR_JDATE" <= "$END_JDATE" )
  setenv CUR_GDATE `$PATH_SYSDIR/bin/yj2ymd $CUR_JDATE`
  set YES_JDATE = `$PATH_SYSDIR/bin/yj_prev $CUR_JDATE 1`
  set DOMAINS_GRID = 1
  foreach DOMAINS_RES ( $G_DOMAINS_RES_CMAQ )  
    setenv MIDNAME hk${DOMAINS_RES}
    
    echo NOW IS RUNNING BCON ON ${DOMAINS_RES}km at $CUR_JDATE ...
    # run bcon
    if ( "$DOMAINS_GRID" != "1" ) then
      cd $OPDIR/preproc/bcon
       ./run.bcon.OP.job $CUR_JDATE $DOMAINS_GRID
      if ( $status != 0 ) then
        echo Failed: ./run.bcon.OP.job $CUR_JDATE ${DOMAINS_RES}km
        exit 1
      endif
    endif

    echo NOW IS RUNNING ICON ON $DOMAINS_RES at $CUR_JDATE ...
    # run icon
    if ( "$DOMAINS_GRID" != "1" ) then
      if ( "$CUR_JDATE" == "$BEG_JDATE" ) then
        cd $OPDIR/preproc/icon
         ./run.icon.OP.job $CUR_JDATE $DOMAINS_GRID
        if ( $status != 0 ) then
          echo Failed: ./run.icon.OP.job $CUR_JDATE ${DOMAINS_RES}km
          exit 1
        endif
      endif
    endif

    echo NOW IS RUNNING CCTM ON ${DOMAINS_RES}km at $CUR_JDATE ...
    cd $OPDIR
    # run cmaq
    cd $OPDIR/runfiles/runfiles
    if ( $CTM_COLD_START == 1 && "$CUR_JDATE" == "$BEG_JDATE" ) then
      setenv NEW_START true
    else
      setenv NEW_START false  
    endif
    echo "CMAQ cold start domain = ${DOMAINS_RES}km and date = $CUR_JDATE"
    echo Run ./run.OP.mpich2 $CUR_JDATE $ICON_path $ICON_file
    ./run.OP.mpich2 $CUR_JDATE $ICON_path $ICON_file $DOMAINS_GRID
    if ( $status != 0 ) then
      echo Failed: ./run.OP.mpich2 $CUR_JDATE $ICON_path $ICON_file
      exit 1
    endif
    @ DOMAINS_GRID ++
    end  # foreach DOMAINS_RES
    set CUR_JDATE = `$PATH_SYSDIR/bin/yj_next $CUR_JDATE 1`
  end #while 
  
########AT THE VERY END############################
cd $OPDIR

