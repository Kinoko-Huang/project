#! /bin/csh -f
########################################################################

## Directory setups
setenv PROMPTFLAG N

# Program directory
setenv EXEDIR $MGNEXE
setenv MG2MECH mg2mech.fix_CB05

# Input map data directory
setenv INPDIR $MGNINP/MAP

# Intermediate file directory
setenv INTDIR $MGNOUT/ITMDT

# Output directory
setenv OUTDIR $MGNOUT

# MCIP input directory
setenv METDIR $MGNINP/MCIP
########################################################################

########################################################################
# Set up time and date to process
set CUR_JDATE = $argv[1]
set DOMAINS_RES  = $argv[2]
set INIT_H    = $argv[3]

setenv STIME 0
if ( "$INIT_H" == "12" ) then
  unsetenv STIME
  setenv STIME 120000
endif

setenv RLENG 250000
setenv TSTEP 10000
########################################################################

########################################################################
# Set up for MECHCONV
setenv RUN_SPECIATE   Y    # run speciation to 138
                           # units are g/s

setenv RUN_CONVERSION Y    # run conversions?
                           # run conversions MEGAN to model mechanism
                           # units are mole/s

setenv SPCTONHR       N    # speciation output unit in tonnes per hour
                           # This will convert 134 species to tonne per
                           # hour or mechasnim species to tonne per hour.

# If RUN_CONVERSION is set to "Y", one of mechanisms has to be selected.
#setenv MECHANISM    SAPRCII
#setenv MECHANISM    SAPRC99
#setenv MECHANISM    RADM2
#setenv MECHANISM    RACM
#setenv MECHANISM    CBMZ
setenv MECHANISM    CB05 #w5400
#setenv MECHANISM    SOAX

# MEGAN ER filename
   setenv MGERFILE $INTDIR/ER_MEGAN_${PROJ}_${DOMAINS_RES}km_${CUR_JDATE}.ncf #w5400
# PFT fraction filename
   setenv PFTFFILE $INPDIR/$PROJ/MDV_v21_PFTF_grdhk${DOMAINS_RES}.csv
# Output filename
   mkdir -p $OUTDIR/${PROJ}/${DOMAINS_RES}
   setenv OUTPFILE $OUTDIR/${PROJ}/${DOMAINS_RES}/emiss_MEGAN_${MECHANISM}.${PROJ}.${DOMAINS_RES}km_${CUR_JDATE}.ncf
########################################################################
## Run speciation and mechanism conversion
if ( $RUN_SPECIATE == 'Y' ) then
   rm -f $OUTPFILE
   $EXEDIR/$MG2MECH
endif

