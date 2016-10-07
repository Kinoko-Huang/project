#!/bin/csh -f

#########################################################################
set INIT_TIME=${INIT_Y}${INIT_M}${INIT_D}${INIT_H}
set INIT_GDATE=${INIT_Y}${INIT_M}${INIT_D}
set END_TIME=${END_Y}${END_Y}${END_D}${INIT_H}
#set NO_DAYS=$MET_SIM_N_DAYS
set DERIVED_DATA_ROOT=${work_root}/gts_decoder/derived_data
set GTS_TEMP_ROOT=${work_root}/gts_decoder/gts_temp
#########################################################################

#delete the residues in $DERIVED_DATA_ROOT
rm -f $DERIVED_DATA_ROOT/*
###rm -rf gts_temp/*

set INIT_JDATE = `./ymd2yj $INIT_GDATE`

set jday1 = `./yj_next $INIT_JDATE`
set jday2 = `./yj_next $jday1`
set jday3 = `./yj_next $jday2`

set CYMD1 = `./yj2ymd ${jday1}`
set CYMD2 = `./yj2ymd ${jday2}`
set CYMD3 = `./yj2ymd ${jday3}`

#wget the gts file for HKUST
###$PATH_SYSDIR/bin/get_envf_gts $INIT_GDATE $NO_DAYS $GTS_TEMP_ROOT

foreach cymd ($INIT_GDATE $CYMD1 $CYMD2 $CYMD3)
set year = `echo $cymd | cut -c1-4`
set month = `echo $cymd | cut -c5-6`
set GTS_DATA_ROOT=${GTS_TEMP_ROOT}/${year}/${year}${month}/${cymd}

pushd $GTS_DATA_ROOT
  set files = (gts_*.gz )
popd
foreach f ( $files )
   set cymdh = `echo $f | cut -c5-14`
   if ( ( "$INIT_TIME" <= "$cymdh" ) & ( "$cymdh" <= "$END_TIME" ) ) then
      ln -s $GTS_DATA_ROOT/$f .

      set ff = $f:t
      if ( "$ff:e" == "gz" ) then
          set ff = $ff:r
          gunzip -c $f >! $ff
      endif
      sed -e 's/^M//g' -i $ff
      ln -s $ff gts_data
      set cymdhm = `echo $ff | cut -c5-16`
      set  ymdhm = `echo $ff | cut -c7-16`
      echo $ymdhm >! gtsdecoder.input
      ./gts_decoder.exe < gtsdecoder.input >&! gtsdecoder.$cymdhm.output
       cat gts_out.7?? >! $cymdhm.rap.gts

       rm -rf gts_data
       rm -rf gts_in
       rm -rf gts_in_temp
       rm -rf gtsdecoder.input
       rm -rf *.output
       rm -rf gts_out.*	
       rm -rf $f $f:r
   endif

end

mv *.rap.gts $DERIVED_DATA_ROOT

end
