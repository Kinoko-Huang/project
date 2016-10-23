#!/bin/csh -f 

   echo '-----------------------'
   echo 'OUTDATE is the data of output emission,it is the time that "m3tshift" program shift to. ORIDATE is the data of original emission'
   echo '-----------------------'
   set OUTDATE = $argv[1]
   set ORIDATE = $argv[2]
# Set up how many days want to convert the time
   set EXEC = $CAMx_HOME/datelib/m3tshift
   set YYYY1 = `$PATH_SYSDIR/bin/j2g $ORIDATE | awk '{print $1}'`
   set MM1   = `$PATH_SYSDIR/bin/j2g $ORIDATE | awk '{print $2}'`

   set CMAQ_IN = $CMAQ_ICBC/$YYYY1$MM1/BCON_COMBINE_${ORIDATE}

   set CMAQ_OUT = $cwd/../Output/ICBC
   if (! -e $CMAQ_OUT) mkdir -p ${CMAQ_OUT}

   echo "CMAQ_IN = $CMAQ_IN"
   echo "CMAQ_OUT = $CMAQ_OUT"

# delete the residual file
    rm -f $CMAQ_OUT/BCON*


       echo "Now is processing SMOKE in D1 at ${OUTDATE} ..."

       set TMPLFILE = $CMAQ_IN
       set OUTFILE  = $CMAQ_OUT/BCON_COMBINE_${OUTDATE}

       setenv EXTTMPLFILE ${TMPLFILE}
       echo $EXTTMPLFILE
       setenv EXTOUTFILE ${OUTFILE}
       echo $EXTOUTFILE
#
#   Execute program
#
/usr/bin/time    $EXEC  << -eof-
EXTTMPLFILE


$OUTDATE



EXTOUTFILE
-eof-


echo '--------------------------------'
echo 'Sucessful running M3SHIFT'
echo '--------------------------------'
exit( )
