#!/bin/csh -f 

#delete the residual log files
rm -f obsgrid.log
rm -f status.obsgrid.log
rm -f OBS_DOMAIN*

set filename_obs = $argv[1]
set id_grid = $argv[2]

cat << End_of_namelist > namelist.oa.${case}
&record1
 start_year                  =  ${INIT_Y}
 start_month                 =  ${INIT_M}
 start_day                   =  ${INIT_D}
 start_hour                  =  ${INIT_H}
 end_year                    =  ${END_Y}
 end_month                   =  ${END_M}
 end_day                     =  ${END_D}
 end_hour                    =  ${INIT_H}
 interval                    = 21600
/

&record2
 grid_id                     = ${id_grid}
 obs_filename                = '${filename_obs}'
 remove_data_above_qc_flag   = 32768
 remove_unverified_data      = .TRUE.
/
 trim_domain                 = .TRUE.
 trim_value                  = 5

&record3
 max_number_of_obs           = 100000
 fatal_if_exceed_max_obs     = .TRUE.
/

&record4
 qc_test_error_max           = .TRUE.
 qc_test_buddy               = .TRUE.
 qc_test_vert_consistency    = .FALSE.
 qc_test_convective_adj      = .FALSE.
 max_error_t                 = 10
 max_error_uv                = 13
 max_error_z                 = 8
 max_error_rh                = 50
 max_error_p                 = 600
 max_buddy_t                 = 8
 max_buddy_uv                = 4
 max_buddy_z                 = 8
 max_buddy_rh                = 40
 max_buddy_p                 = 800
 buddy_weight                = 1.0
 max_p_extend_t              = 1300
 max_p_extend_w              = 1300
/

&record5
 print_obs_files             = .FALSE.
 print_found_obs             = .FALSE.
 print_header                = .FALSE.
 print_analysis              = .TRUE.
 print_qc_vert               = .TRUE.
 print_qc_dry                = .TRUE.
 print_error_max             = .TRUE.
 print_buddy                 = .TRUE.
 print_oa                    = .TRUE.
/

&record7
 use_first_guess             = .TRUE.
 f4d                         = .TRUE.
 intf4d                      =  3600
 lagtem                      = .FALSE.
/

&record8
 smooth_type                 =  1
 smooth_sfc_wind             =  0
 smooth_sfc_temp             =  0
 smooth_sfc_rh               =  0
 smooth_sfc_slp              =  0
 smooth_upper_wind           =  0
 smooth_upper_temp           =  0
 smooth_upper_rh             =  0
/

&record9
 oa_type                     = 'Cressman'
 radius_influence            =  5,4,3,2
 mqd_minimum_num_obs         = 30
 mqd_maximum_num_obs         = 4000
 oa_min_switch               = .TRUE.
 oa_max_switch               = .TRUE.
 oa_3D_type                  = 'Cressman'
/
 oa_type                     = 'MQD'
 oa_3D_option                = 2
 oa_3D_type                  = ''
 radius_influence            = 5,4,3,2,


&plot_sounding
 file_type                   = 'raw'
 read_metoa                  = .TRUE.
/
 file_type                   = 'used'
/
End_of_namelist

echo link the namelist.oa
ln -sf namelist.oa.${case} namelist.oa

echo OBSGRID: Now running the obsgrid.exe
./obsgrid.exe   | & tee obsgrid.log

set indicator = `grep Successful obsgrid.log | cut -c 1-10`
echo $indicator
 if (${indicator} == 'Successful') then

  echo \!\!\!\!\!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\!\!\!\!\!
  echo \!\!------------------------complete the OBSGRID part--------------------------------\!\!
  echo \!\!\!\!\!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\!\!\!\!\!
  exit 0
  else
   echo \!\!--- Error occurs in obsgrid.exe
   exit 1
 endif

