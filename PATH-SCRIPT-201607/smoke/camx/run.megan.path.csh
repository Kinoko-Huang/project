#! /bin/csh -f
########################################################################

## Directory setups
setenv PROMPTFLAG N

# Program directory
setenv EXEDIR $MGNEXE

# Input map data directory
setenv INPDIR $MGNINP/MAP/${PROJ}

# Intermediate file directory
setenv INTDIR $MGNOUT/ITMDT

# Output directory
setenv OUTDIR $MGNOUT

# MCIP input directory
setenv METDIR $MGNINP/TPAR/${PROJ}
##setenv METDIR $MGNINP/MCIP

########################################################################
# Set up time and date to process
set CUR_JDATE = $argv[1] 
set DOMAINS_RES  = $argv[2]
set INIT_H    = $argv[3]

########################################################################
# Set up time and date to process
setenv SDATE $CUR_JDATE
setenv STIME 0
if ( "$INIT_H" == "12" ) then
  unsetenv STIME
  setenv STIME 120000
endif
setenv RLENG 250000
setenv TSTEP 10000

########################################################################
# Set up for MEGAN
setenv RUN_MEGAN      Y    # run megan?

setenv MGNTONHR       N    # MEGAN output unit in tonnes per hour
                           # if MGNTONHR is Y, not run speciation
                           # this will produce only MEGAN 20 species

setenv ONLN_DTEMP     Y    # Online calculate daily average temperature
                           # from MCIP data (default is "YES")
                           # If "NO", MEGAN will look for the data
                           # from ECMAP and user has to provide.

setenv ONLN_DSRAD     Y    # Online calculate daily average solar
                           # radiation from MCIP data (default is "YES")
                           # If "NO", MEGAN will look for the data
                           # from ECMAP and user has to provide.

setenv PAR_INPUT      Y    # Input PAR instead of MCIP short wave radiation
                           # (default is "NO")
                           # PAR data should be given in [W/m^2]
                           #
# Input EF map
setenv ECMAP $INTDIR/EFMAP_LAI_${PROJ}_${DOMAINS_RES}km.ncf
# Output
setenv EROUT $INTDIR/ER_MEGAN_${PROJ}_${DOMAINS_RES}km_${CUR_JDATE}.ncf

## METCRO3D
# TA - air temperature (K) (default)

## METCRO2D
# TEMPG - skin temperature on ground (K)
# TEMP10 - air temperature at 10m (K)
# TEMP1P5 - air temperature at 1.5m (K) (default)
# GSW - Solar radiation absorved at ground (W/m2)
# RGRND - Solar radiation reaching surface (W/m2) (default)

# Temperature file and temperature variable
setenv TMPFILE $METDIR/TPAR.MEGAN.${PROJ}.${CUR_JDATE}.${DOMAINS_RES}km.ncf
#setenv TMPFILE $METDIR/METCRO2D_D1_2006310
# TA, TEMPG, TEMP10, TEMP1P5
#setenv TEMPVAR TEMP1P5     # temperature variable to use from MCIP
#setenv TEMPVAR TEMPG        # temperature variable to use from MCIP # w5400
setenv TEMPVAR TEMP # temperature variable to use from TPAR2IOAPI                                                                                         
# Solar radiation file and solar radiation variable
#setenv RADFILE $METDIR/METCRO2D_D1_2006310
setenv RADFILE $METDIR/TPAR.MEGAN.${PROJ}.${CUR_JDATE}.${DOMAINS_RES}km.ncf
# GSW, RGRND
setenv SRADVAR RGRND       # short wave variable
                                                                                         
########################################################################
## Run MEGAN
if ( $RUN_MEGAN == 'Y' ) then
   rm -f $EROUT
    $EXEDIR/megan
endif
  
