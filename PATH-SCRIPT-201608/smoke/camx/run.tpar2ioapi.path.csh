#!/bin/csh -v
#
# TPAR2IOAPI v2.03a 
# --added capability for MCIP v3.3 input (2m temperatures)
# --bug in PAR processing subroutine fixed where first few hours in GMT produced zero PAR
# --added code to fill missing par data (if valid data exists for the hours surrounding it)
#
# TPAR2IOAPI v2.0
# --added capability for MM5 or MCIP input
# 
#
#        RGRND/PAR options:
#           setenv MM5RAD  Y   Solar radiation obtained from MM5
#           OR 
#           setenv MCIPRAD Y   Solar radiation obtained from MCIP
#                  --MEGAN will internally calculate PAR for each of these options and user needs to  
#                    specify `setenv PAR_INPUT N' in the MEGAN runfile
#           OR
#           setenv SATPAR Y (satellite-derived PAR from UMD GCIP/SRB files)
#                  --user needs to specify `setenv PAR_INPUT Y' in the MEGAN runfile
#
#        TEMP options:
#           setenv CAMXTEMP Y         2m temperature, calculated from mm5camx output files
#           OR
#           setenv MM5TEMP  Y         2m temperature, calculated from MM5 output files
#                                     Note: 2m temperature is calculated since the P-X/ACM PBL
#                                     MM5 configuration (most commonly used LSM/PBL scheme for AQ 
#                                     modeling purposes) does not produce 2m temperatures.
#           OR
#           setenv MCIPTEMP Y         temperature obtained from MCIP
#              -setenv TMCIP  TEMP2   2m temperature, use for MCIP v3.3 or newer
#              -setenv TMCIP  TEMP1P5 1.5m temperature, use for MCIP v3.2 or older
#
#        TZONE   time zone for input mm5CAMx files 
#

#set MGNINP01 = $SMOKE_DIR/camx/input/MCIP/1
#set MGNINP03 = $SMOKE_DIR/camx/input/MCIP/3
#set MGNINP09 = $SMOKE_DIR/camx/input/MCIP/9
#set MGNINP27 = $SMOKE_DIR/camx/input/MCIP/27
set MGNINP01 = $MCIPDataPath/1km
set MGNINP03 = $MCIPDataPath/3km
set MGNINP09 = $MCIPDataPath/9km
set MGNINP27 = $MCIPDataPath/27km

echo MGNINP01=$MGNINP01
echo MGNINP03=$MGNINP03
echo MGNINP09=$MGNINP09
echo MGNINP27=$MGNINP27

set MGNEXE = ../bin/tpar2ioapi.rkwok
set INPATH_PAR  = ../Input/PAR
set OUTPATH     = ../Input/TPAR

set JDATE = $argv[1]
set reso  = $argv[2]
set HH    = $argv[3]
set d = $reso

@ jdy  = $JDATE - 2000000
#@ JDATEm1 = $JDATE - 1

echo $JDATE $jdy


set yr = `$DATELIB/j2g $JDATE | awk '{print $1}'`
set mo = `$DATELIB/j2g $JDATE | awk '{print $2}'`
set dy = `$DATELIB/j2g $JDATE | awk '{print $3}'`


#set start/end dates
setenv SDATE ${jdy}00
setenv EDATE ${jdy}24
echo $SDATE $EDATE
if ( "$HH" == "12" ) then
  unsetenv SDATE
  unsetenv EDATE
  set JDATE1 = `$DATELIB/yyyyjjj_plus_dd $JDATE 1`
  @ jdy1  = $JDATE1 - 2000000
  setenv SDATE ${jdy}12
  setenv EDATE ${jdy1}12
endif
echo ${jdy1} 'FIONA' $JDATE1 $JDATE $jdy
echo $SDATE $EDATE 'FIONA1'

# Set grid system
setenv GRIDDESC GRIDDESC.${PROJ}
if ($d == 1) then
   set INPATH = $MGNINP01
   setenv GDNAM3D HKPATH_1KM
else if ($d == 3) then
   set INPATH = $MGNINP03
   setenv GDNAM3D HKPATH_3KM
else if ($d == 9) then
   set INPATH = $MGNINP09
   setenv GDNAM3D HKPATH_9KM
else if ($d == 27) then
   set INPATH = $MGNINP27
   setenv GDNAM3D HKPATH_27KM
else
   echo "Resolution Error"
   exit
endif

#TEMP/PAR input choices
#
#set if using MM5CAMx meteorology
setenv CAMXTEMP N
#setenv TZONE 0
#
#setenv CAMXTP1 $INPATH/tp.camx.${d}km.$y$mo$dy.bin
#setenv CAMXZP1 $INPATH/zp.camx.${d}km.$y$mo$dy.bin
#setenv CAMXUV1 $INPATH/uv.camx.${d}km.$y$mo$dy.bin
#setenv CAMXLU  $INPATH/landuse.36km.bin 
#setenv NLAY 19

#set if using MM5 output files
setenv MM5TEMP N
setenv MM5RAD N
#setenv numMM5 2
#setenv MM5file1 ~jjohnson/denver_mm5links/MMOUT_DOMAIN1_G20060724
#setenv MM5file2 ~jjohnson/denver_mm5links/MMOUT_DOMAIN1_G20060725

#set if using UMD satellite PAR data
setenv SATPAR N
if ($SATPAR == 'Y') then
   set satpar1 = "$INPATH_PAR/$yrm1${mom1}par.h"
   set satpar2 = "$INPATH_PAR/$yr${mo}par.h"

   if ($satpar1 == $satpar2) then
     setenv numSATPAR 1
     setenv SATPARFILE1 $INPATH_PAR/$yr${mo}par.h
   else
     setenv numSATPAR 2
     setenv SATPARFILE1 $INPATH_PAR/$yrm1${mom1}par.h 
     setenv SATPARFILE2 $INPATH_PAR/$yr${mo}par.h 
   endif
endif

#set if using MCIP output files
setenv MCIPTEMP Y
setenv TMCIP  TEMP2          #MCIP v3.3 or newer
#setenv TMCIP  TEMP1P5       #MCIP v3.2 or older
setenv MCIPRAD Y
set GREDATE = `$DATELIB/yyyyjjj2yyyymmdd $JDATE`
if ($d == 1) then
   setenv MCIPfile $MGNINP01/METCRO2D.${d}km.${GREDATE}
else if ($d == 3) then
   setenv MCIPfile $MGNINP03/METCRO2D.${d}km.${GREDATE}
else if ($d == 9) then
   setenv MCIPfile $MGNINP09/METCRO2D.${d}km.${GREDATE}
else if ($d == 27) then
   setenv MCIPfile $MGNINP27/METCRO2D.${d}km.${GREDATE}
else
   echo "Resolution Error"
   exit
endif


setenv OUTFILE $OUTPATH/$PROJ/TPAR.MEGAN.${PROJ}.$JDATE.${d}km.ncf
rm -rf $OUTFILE
echo 'TEST' 
$MGNEXE

sleep 1
