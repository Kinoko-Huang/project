#! /bin/csh -f
########################################################################
## Directory setups
setenv PROMPTFLAG N
setenv EXEDIR $MGNEXE
#setenv GRIDDESC $MGNRUN/GRIDDESC
#setenv GDNAM3D ASACA36km
setenv GRIDDESC $MGNRUN/GRIDDESC.$PROJ
#setenv GDNAM3D ASACA36km

set DOMAINS_RES = $argv[1]
setenv GDNAM3D HKPATH_${DOMAINS_RES}KM
setenv INPFILE $MGNINP/MAP/${PROJ}/MDV_v21_EF_LAI_grdhk${DOMAINS_RES}.csv
mkdir -p $MGNOUT/ITMDT
setenv OUTFILE $MGNOUT/ITMDT/EFMAP_LAI_${PROJ}_${DOMAINS_RES}km.ncf
########################################################################
## Run MG2IOAPI
rm -f $OUTFILE
$EXEDIR/mg2ioapi

