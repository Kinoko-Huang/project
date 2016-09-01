#!/bin/csh -f

source ../../../../domains_def.config

#clean the residues
rm -f met_em.*
ln -sf ${WPS_root}/met_em* .

rm -f namelist.input

@ MET_SIM_N_HOURS = ${MET_SIM_N_DAYS} * 24

# prepare the namelist.input
cat << End_of_namelist > namelist.input.${case}
 &time_control
 run_days                            = ${MET_SIM_N_DAYS},
 run_hours                           = 0,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = ${INIT_Y}, ${INIT_Y}, ${INIT_Y}, ${INIT_Y},
 start_month                         = ${INIT_M},   ${INIT_M},   ${INIT_M},   ${INIT_M},
 start_day                           = ${INIT_D},   ${INIT_D},   ${INIT_D},	 ${INIT_D},
 start_hour                          = ${INIT_H},   ${INIT_H},   ${INIT_H},	 ${INIT_H},
 start_minute                        = 00,   00,   00,	 00,	
 start_second                        = 00,   00,   00,	 00,
 end_year                            = ${END_Y}, ${END_Y}, ${END_Y}, ${END_Y},
 end_month                           = ${END_M},   ${END_M},   ${END_M},	 ${END_M},
 end_day                             = ${END_D},   ${END_D},   ${END_D},   ${END_D},
 end_hour                            = ${INIT_H},   ${INIT_H},   ${INIT_H},	 ${INIT_H},
 end_minute                          = 00,   00,   00,	 00,
 end_second                          = 00,   00,   00,	 00,
 interval_seconds                    = 21600
 input_from_file                     = .true.,.true.,.true.,.true.,
 history_interval                    = 60,  60,   60,	60,
 frames_per_outfile                  =  1,   1,    1,	 1,
 restart                             = .false.,
 restart_interval                    = 1440,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 debug_level                         = 0
 auxinput11_interval_s               = 120, 120, 120, 120,
 auxinput11_end_h                    = ${MET_SIM_N_HOURS},${MET_SIM_N_HOURS},${MET_SIM_N_HOURS},${MET_SIM_N_HOURS},
 auxinput4_inname		     = "wrflowinp_d<domain>",
 auxinput4_interval		     = 360, 360, 360, 360,
 auxinput1_inname                    = "met_em.d<domain>.<date>",
 io_form_auxinput4                   = 2,
 io_form_auxinput2                   = 2,
 /

 &domains
 time_step                           = 120,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = ${SIM_DOMAINS_WRF},
 s_we                                = 1,     1,     1,	   1,
 e_we                                = ${NCOLS_MMS_Dx[1]},   ${NCOLS_MMS_Dx[2]},   ${NCOLS_MMS_Dx[3]},  ${NCOLS_MMS_Dx[4]},
 s_sn                                = 1,     1,     1,    1,
 e_sn                                = ${NROWS_MMS_Dx[1]},   ${NROWS_MMS_Dx[2]},   ${NROWS_MMS_Dx[3]},  ${NROWS_MMS_Dx[4]},
 s_vert                              = 1,     1,     1,    1,
 e_vert                              = $LAYERS_NUM_MMS,    $LAYERS_NUM_MMS,    $LAYERS_NUM_MMS,   $LAYERS_NUM_MMS,
 p_top_requested                     = 5000,
 num_metgrid_levels                  = 32,
 num_metgrid_soil_levels             = 4,
 eta_levels			     = 1.0000, 0.9979, 0.9956, 0.9931,
				       0.9904, 0.9875, 0.9844, 0.9807,
				       0.9763, 0.9711, 0.9649, 0.9575,
				       0.9488, 0.9385, 0.9263, 0.9120,
				       0.8951, 0.8753, 0.8521, 0.8251,
				       0.7937, 0.7597, 0.7229, 0.6833,
				       0.6410, 0.5960, 0.5484, 0.4985,
				       0.4467, 0.3934, 0.3393, 0.2850,
				       0.2316, 0.1801, 0.1324, 0.0903,
                                       0.0542, 0.0241, 0.0000
 dx                                  = ${G_DOMAINS_RES_WRF[1]}000,   ${G_DOMAINS_RES_WRF[2]}000,   ${G_DOMAINS_RES_WRF[3]}000,	${G_DOMAINS_RES_WRF[4]}000,
 dy                                  = ${G_DOMAINS_RES_WRF[1]}000, 	${G_DOMAINS_RES_WRF[2]}000,   ${G_DOMAINS_RES_WRF[3]}000,	${G_DOMAINS_RES_WRF[4]}000,
 grid_id                             = 1,     2,     3,	   4,
 parent_id                           = 1,     1,     2,	   3,
 i_parent_start                      = ${COL_CUT_MMS_Dx[1]},     ${COL_CUT_MMS_Dx[2]},   ${COL_CUT_MMS_Dx[3]},   ${COL_CUT_MMS_Dx[4]},
 j_parent_start                      = ${ROW_CUT_MMS_Dx[1]},     ${ROW_CUT_MMS_Dx[2]},   ${ROW_CUT_MMS_Dx[3]},   ${ROW_CUT_MMS_Dx[4]},
 parent_grid_ratio                   = ${GRID_RATIO_MMS_Dx[1]},     ${GRID_RATIO_MMS_Dx[2]},     ${GRID_RATIO_MMS_Dx[3]},	   ${GRID_RATIO_MMS_Dx[4]},
 parent_time_step_ratio              = 1,     3,     3,	   3,
 feedback                            = 0,
 smooth_option                       = 2
 /

 &physics
 mp_physics                          = 3,     3,     3,    3,
 ra_lw_physics                       = 5,     5,     5,    5,
 ra_sw_physics                       = 5,     5,     5,    5,
 radt                                = 10,    10,    10,   10,
 sf_sfclay_physics                   = 1,     1,     1,    1,
 sf_surface_physics                  = 2,     2,     2,    2,
 bl_pbl_physics                      = 7,     7,     7,    7,
 bldt                                = 0,     0,     0,    0,
 cu_physics                          = 3,     3,     0,    0,
 cudt                                = 0,     0,     5,    5,
 isfflx                              = 1,     
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = 4,
 sf_urban_physics                    = 0,     0,     0,    0,
 mp_zero_out                         = 2,
 mp_zero_out_thresh                  = 1.e-8,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 slope_rad                           = 0,
 topo_shading                        = 0,
 sst_update			     = 1,
 /

 &fdda
 grid_fdda                           = 1,     0,     0,     0,
 gfdda_inname                        = "wrffdda_d<domain>",
 gfdda_end_h                         = ${MET_SIM_N_HOURS},    0,     0,     0,
 gfdda_interval_m                    = 360,   0,     0,     0,
 fgdt                                = 0,     0,     0,     0,
 if_no_pbl_nudging_uv                = 0,     0,     0,     0,
 if_no_pbl_nudging_t                 = 1,     1,     1,     1,
 if_no_pbl_nudging_q                 = 0,     0,     0,     0,
 if_zfac_uv                          = 0,     0,     0,     0,
  k_zfac_uv                          = 10,    10,    0,     0,
 if_zfac_t                           = 0,     0,     0,     0,
  k_zfac_t                           = 10,    10,    0,     0,
 if_zfac_q                           = 0,     0,     0,     0,
  k_zfac_q                           = 10,    10,    0,     0,
 guv                                 = 0.0003,0.0003,0.0, 0.0,
 gt                                  = 3.0E-4,0,     0,     0,
 gq                                  = 1.0E-5,1.0E-5,0,     0,
 io_form_gfdda                       = 2,
 grid_sfdda                          = 0,     0,     0,     0,
 sgfdda_inname                       = "wrfsfdda_d<domain>",
 sgfdda_interval_m                   = 0,     0,     0,     0,
 sgfdda_end_h                        = 0,     0,     0,     0,
 io_form_sgfdda                      = 2,
 guv_sfc                             = 0.0003,0.0003,0.0, 0.0,
 gt_sfc                              = 3.0E-4,0,     0,     0,
 gq_sfc                              = 1.0E-5,1.0E-5,0,     0,
 rinblw                              = 250.,
 obs_nudge_opt                       = 0,     0,     0,     0,
 max_obs                             = 100000,
 fdda_start                          = 0,     0,     0,     0,
 fdda_end                            = 5760,  5760,  0,     0,
 obs_nudge_wind                      = 0,     0,     0,     0,
 obs_coef_wind                       = 6.E-4, 6.E-4, 5.E-3, 5.0E-3,
 obs_nudge_temp                      = 0,     0,     0,     0,
 obs_coef_temp                       = 6.E-4, 6.E-4, 6.E-4, 6.E-4,
 obs_nudge_mois                      = 0,     0,     0,     0,
 obs_coef_mois                       = 6.E-4, 6.E-4, 6.E-4, 6.E-4,
 obs_rinxy                           = 240.,  240.,  7.5,   7.5,
 obs_rinsig                          = 0.001,
 obs_twindo                          = 0.666667,0.666667,0.666667,0.666667,
 obs_npfi                            = 40.,
 obs_ionf                            = 2,     2,     2,     2,
 obs_idynin                          = 0,
 obs_dtramp                          = 60.,
 obs_prt_max                         = 10,
 obs_ipf_errob                       = .true.
 obs_ipf_nudob                       = .true.
 obs_ipf_in4dob                      = .true.
 obs_ipf_init                        = .true.
 if_ramping                          = 0,
 dtramp_min                          = 60.0,
 /

 &dfi_control
 /

 &tc
 /

 &scm
 /

 &fire
 /

 &dynamics
 w_damping                           = 1,
 diff_opt                            = 1,
 km_opt                              = 4,
 diff_6th_opt                        = 2,      2,      2,      2,
 diff_6th_factor                     = 0.12,   0.12,   0.12,   0.12,
 base_temp                           = 290.
 damp_opt                            = 3,
 zdamp                               = 8000.,  8000.,  8000.,  8000.,
 dampcoef                            = 0.2,    0.2,    0.2,    0.2,
 khdif                               = 0,      0,      0,      0,
 kvdif                               = 0,      0,      0,      0,
 non_hydrostatic                     = .true., .true., .true., .true.,
 moist_adv_opt                       = 2,      2,      2,      2,
 scalar_adv_opt                      = 2,      2,      2,      2,
 tke_adv_opt                         = 2,      2,      2,      2,
 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,.false.,.false.,
 nested                              = .false., .true., .true., .true.,
 /

 &grib2
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /
End_of_namelist

#####################################

echo link the namelist
echo
ln -sf namelist.input.${case} namelist.input

# start get the vertical integreation
echo \!\!---start running real
echo

#set ncpus = `/bin/grep '^processor' /proc/cpuinfo | /usr/bin/wc -l`
#set ncpus = $Ncpu
#echo `/bin/hostname -s`:$ncpus > machinefile

if (${START_MPD} == 0) then
  mpiexec -n $Ncpu ./real.exe < /dev/null
else
  mpiexec -machinefile $MPIHostFile -n $Ncpu ./real.exe < /dev/null
endif

set status = `tail -n 1 rsl.out.0000 | cut -c 34-40`

if(${status} == "SUCCESS") then
 if(! -e real_log) mkdir -p real_log
 mv -f rsl.* real_log/

# start runing the main WRF integration
 echo \!\!---start running WRF
 echo
 if ( $USE_MPIconfigfile == 1 ) then
   echo $PATH_SYSDIR/bin/mfile2cfile $MPIHostFile MPIconfigfile ./wrf.exe
   $PATH_SYSDIR/bin/mfile2cfile $MPIHostFile MPIconfigfile ./wrf.exe
   echo time mpiexec -configfile MPIconfigfile < /dev/null
   time mpiexec -configfile MPIconfigfile < /dev/null
   exit $status
 else
   if (${START_MPD} == 0) then
     time mpiexec -n $Ncpu ./wrf.exe < /dev/null
   else
     time mpiexec -machinefile $MPIHostFile -n $Ncpu ./wrf.exe < /dev/null
   endif
   exit $status
 endif
else
 echo \!\!--- Error occurs in the real.exe
 exit 1
endif
