#!/bin/csh -f

#clean residue from the previous run
rm -f namelist.wps
rm -f FILE:*
rm -f FNL:*
rm -f SST:*
rm -f myECMWF:*
rm -f SKINT:*
rm -f ORSM:*
rm -f orsmSKINT:*
rm -f GFStop:*
rm -f met_em*
rm -f metgrid.log
rm -f geogrid.log
rm -f ungrib.log
rm -f geo_em.d*.nc
rm -f wrfsfdda_*
rm -f obsgrid.log
rm -f GRIBFILE.A*
rm -f obs:*
rm -f OBS_DOMAIN*

#link the GRIB data
./link_grib.csh ${initial_data_root}

ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable

#Prepare the 'namelist.wps'
cat << End_of_namelist > namelist.wps.${case}
&share
 wrf_core = 'ARW',
 max_dom = ${MET_SIM_N_DOMAINS},
 start_date = '${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00',
 end_date   = '${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00',
 interval_seconds = 21600
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   1,   1,	2,  3,
 parent_grid_ratio =   1,   3,  3,  3,
 i_parent_start    =   1,   116,43, 67,
 j_parent_start    =   1,   45, 55, 22,
 e_we              =  283,  223, 172, 214,
 e_sn              =  184,  163, 130, 163,
 geog_data_res     = '10m','5m','2m','30s',
 dx = ${dx}000,
 dy = ${dy}000,
 map_proj = 'lambert',
 ref_lat   =  ${ref_LAT},
 ref_lon   =  ${ref_LON},
 truelat1  =  ${truelat1},
 truelat2  =  ${truelat2},
 stand_lon =  ${ref_LON},
 geog_data_path = '${geog_data_root}'
/

&ungrib
 out_format = 'WPS',
 prefix = 'FNL',
/

&metgrid
 fg_name = 'FNL'
 io_form_metgrid = 2, 
/
End_of_namelist

echo link the namelist
ln -sf namelist.wps.${case} namelist.wps

#start runing the utility GEOGRID
echo GEOGRID\!\!---start define the simulation domains, and interpolate various terrestrial data sets to the model grids
echo
./geogrid.exe | & tee geogrid.log

set status = `tail -n 1 geogrid.log | cut -c 34-43`

if (${status} == "Successful") then

#start running the utility UNGRIB
echo UNGRIB\!\!---reading GRIB files then writes the FNL data in the intermediate format
echo
./ungrib.exe | & tee ungrib.log

set status = `tail -n 2 ungrib.log | grep "Successful" | cut -c 34-43`

if (${status} == "Successful") then
echo Extract SST from FNL data 

ln -sf ungrib/Variable_Tables/Vtable.SST Vtable

cat << End_of_namelist > namelist.wps.${case}
&share
 wrf_core = 'ARW',
 max_dom = ${MET_SIM_N_DOMAINS},
 start_date = '${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00',
 end_date   = '${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00',
 interval_seconds = 21600
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   1,   1,  2,  3,
 parent_grid_ratio =   1,   3,  3,  3,
 i_parent_start    =   1,   116,43, 67,
 j_parent_start    =   1,   45, 55, 22,
 e_we              =  283,  223, 172, 214,
 e_sn              =  184,  163, 130, 163,
 geog_data_res     = '10m','5m','2m','30s',
 dx = ${dx}000,
 dy = ${dy}000,
 map_proj = 'lambert',
 ref_lat   = ${ref_LAT},
 ref_lon   = ${ref_LON},
 truelat1  = ${truelat1},
 truelat2  = ${truelat2},
 stand_lon = ${ref_LON},
 geog_data_path = '${geog_data_root}'
/

&ungrib
 out_format = 'WPS',
 prefix = 'SST',
/

&metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2,
/
End_of_namelist

echo link the namelist
ln -sf namelist.wps.${case} namelist.wps

#starting run UNGRIB
echo UNGRIB\!\!---reading GRIB files then writes the SST data in the intermediate format
echo
./ungrib.exe | & tee ungrib.log


set status = `tail -n 2 ungrib.log | grep "Successful" | cut -c 34-43`

if (${status} == "Successful") then

#starting run METGRID
echo METGRID\!\!---horizontally interpolates the intermediate-format meteorological data onto the simulation domains
echo

cat << End_of_namelist > namelist.wps.${case}
&share
 wrf_core = 'ARW',
 max_dom = ${MET_SIM_N_DOMAINS},
 start_date = '${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00','${year_start}-${month_start}-${day_start}_${hour_start}:00:00',
 end_date   = '${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00','${year_end}-${month_end}-${day_end}_${hour_end}:00:00',
 interval_seconds = 21600
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   1,   1,  2,  3,
 parent_grid_ratio =   1,   3,  3,  3,
 i_parent_start    =   1,   116,43, 67,
 j_parent_start    =   1,   45, 55, 22,
 e_we              =  283,  223, 172, 214,
 e_sn              =  184,  163, 130, 163,
 geog_data_res     = '10m','5m','2m','30s',
 dx = ${dx}000,
 dy = ${dy}000,
 map_proj = 'lambert',
 ref_lat   = ${ref_LAT},
 ref_lon   = ${ref_LON},
 truelat1  = ${truelat1},
 truelat2  = ${truelat2},
 stand_lon = ${ref_LON},
 geog_data_path = '${geog_data_root}'
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FNL', 'SST'
 io_form_metgrid = 2,
/
End_of_namelist

echo link the namelist
ln -sf namelist.wps.${case} namelist.wps

#start running METGRID
./metgrid.exe | & tee metgrid.log 

set status = `tail -n 1 metgrid.log | cut -c 34-43`

 if (${status} == "Successful") then

  echo \!\!\!\!\!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\!\!\!\!\!
  echo \!\!---complete the WPS part,but check every log file for three parts of WPS---\!\!
  echo \!\!\!\!\!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\!\!\!\!\!
  exit 0
  else
   echo \!\!--- Error occurs in metgrid.exe
   exit 1
 endif  

else 
  echo \!\!--- Error occurs in SST
  exit 1
endif

else
  echo \!\!--- Error occurs in ungrib.exe fnl data
  exit 1
endif

else
  echo \!\!--- Error occous in geogrid.exe
  exit 1
endif

