#! /bin/csh -f

######################################################################
#
#   IOAPI2UAM converts CMAQ 1-D emissions files (I/O API) to CAMx
#   low-level emissions files (UAM-IV). Since UAM-IV format limits
#   length of species names up tp 10 characters, last 6 characters
#   (normally blanks) of CMAQ species names are truncated. Emission
#   rate is converted from mol/s (or g/s) to mol/hr (or g/hr).It also
#   shifts time-zone from GMT to user-selected local time.
#
#   INPUT ENVIRONMENTAL VARIABLES:
#
#      INFILE1      - Logical name for input file 1 (current day)
#      INFILE2      - Logical name for input file 2 (next day;
#                      required only if additional data is needed
#                      due to time zone shifting; map projection
#                      consistency won't be checked)
#      OUTFILE      - Logical name for output file
#      TZONE        - Output time-zone (8 for PST, etc.)
#      SDATE        - Output start date (YYJJJ)
#      STIME        - Output start time (HHMMSS) in TZONE
#      RLENG        - Output run length (HHMMSS; 240000 for a CAMx
#                      daily emissions input)
#
######################################################################
## Directory setups

# Program directory
setenv EXEDIR ../bin 
# Output directory

set CUR_JDATE   = $argv[1]
set DOMAINS_RES = $argv[2]
set INIT_H   = $argv[3]
setenv OUTDIR $MGNOUT/$PROJ/$DOMAINS_RES

foreach MECH (CB05 SOAX)

  setenv RLENG   240000

  setenv INFILE1 $OUTDIR/emiss_MEGAN_${MECH}.HongKong.${DOMAINS_RES}km_${CUR_JDATE}.ncf
  setenv OUTFILE $OUTDIR/emiss_MEGAN_${MECH}.HongKong.${DOMAINS_RES}km_${CUR_JDATE}.camx
  setenv TZONE   0
  setenv SDATE   $CUR_JDATE
  setenv STIME   0
  if ( "$INIT_H" == "12" ) then
    unsetenv STIME
    setenv STIME 120000
  endif

  rm -f $OUTFILE
  $EXEDIR/ioapi2uam #>&! log.run.ioapi2uam

end


