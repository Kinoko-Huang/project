close all
clear all

% input session
beg_date = '2016010112';
end_date = '2016010512';
% RH
rh_ymin = 40;
rh_ymax = 100;
obs_rh_flnm = 'obs_data/A_RH_VT-20091216-20091226.csv';
% T
t_ymin = 0;
t_ymax = 30;
obs_t_flnm  = 'obs_data/A_TEMP-20140927-20140929.csv';
% wind
wind_ymin = -2;
wind_ymax = 2;
obs_wd_flnm = 'obs_data/A_wd-20091216-20091226.csv';
obs_ws_flnm = 'obs_data/A_ws-20091216-20091226.csv';

is_test_plotted = 0;
is_wind_plotted = 1;
is_pbl_plotted = 0;
is_t_plotted = 1;
is_rh_plotted = 1;
domain='d04';

CTRL_PATH='/home/dataop/data/nmodel/wrf_fc/2016/201601/2016010112/';
TEST_PATH='/disk/scratch/huangyeq/resident-time_output/wrf/201601';
ctrl_label='ACM2';
test_label='MYJ';
output='/disk/scratch/huangyeq/pic/plot_test';
xlabel_nm =  'Sep 2014 (local time)';

plot_stn_nm = {'CausewayBay';'HongKongAirport';'CheungChau';'Eastern'}
plot_stn_lat = [22.2868 22.3094 22.2011 22.2845 ];
plot_stn_lon = [114.1429 113.9219 114.0267 114.2169];
plot_stn_num = numel( plot_stn_lat );


% end of input session


% date handling
datenum_beg = datenum( beg_date,'yyyymmddHH' );
datenum_end = datenum( end_date,'yyyymmddHH' );
n_hour = round( ( datenum_end - datenum_beg ) * 24 + 1 )
time_str_list = generate_time_str_list( datenum_beg, datenum_end, 1, 'hour', 'yyyy/mm/dd HH:MM:SS' );


for i_hour=1:n_hour
    datenum_current = addtodate( datenum_beg, i_hour - 1, 'hour' );
    datenum_list_sim( i_hour ) = datenum_current;
    [yyyy,mm,dd,HH] = datevec( datenum_current );
    ctrl_flnm=sprintf( '%s/wrfout_%s_%04d-%02d-%02d_%02d:00:00',CTRL_PATH,domain,yyyy,mm,dd,HH)
    ctrl_vapor_data =read_cctm(ctrl_flnm,'QVAPOR');
    ctrl_u10_data(i_hour,:,:) = read_cctm(ctrl_flnm,'U10');
    ctrl_v10_data(i_hour,:,:) = read_cctm(ctrl_flnm,'V10');
    ctrl_t_data(i_hour,:,:) = read_cctm(ctrl_flnm,'T2');
    ctrl_pbl_data(i_hour,:,:) = read_cctm(ctrl_flnm,'PBLH');
    
    pressure_data=read_cctm(ctrl_flnm,'PSFC');
    ctrl_rh_data(i_hour,:,:)= calc_rh( ctrl_vapor_data(:,:,1),squeeze( ctrl_t_data(i_hour,:,:) ),pressure_data);
  
    if i_hour == 1
        ref_lon=114.;
        truelat1=15.;
        truelat2=40.;
        LAT_data = read_cctm(ctrl_flnm,'XLAT');
        LON_data = read_cctm(ctrl_flnm,'XLONG');
    end
    %

end       %%  end for time loop

if is_test_plotted == 1
    for i_hour=1:n_hour
        datenum_current = addtodate( datenum_beg, i_hour - 1, 'hour' );
        [yyyy,mm,dd,HH] = datevec( datenum_current );
 
        test_flnm=sprintf( '%s/wrfout_%s_%04d-%02d-%02d_%02d:00:00',TEST_PATH,domain,yyyy,mm,dd,HH)
        test_vapor_data = read_cctm(test_flnm,'QVAPOR');
        test_u10_data(i_hour,:,:) = read_cctm(test_flnm,'U10');
        test_v10_data(i_hour,:,:) = read_cctm(test_flnm,'V10');
        test_t_data(i_hour,:,:)   = read_cctm(test_flnm,'T2');
        test_pbl_data(i_hour,:,:) = read_cctm(test_flnm,'PBLH');
    
        pressure_data=read_cctm(test_flnm,'PSFC');
        test_rh_data(i_hour,:,:)= calc_rh( test_vapor_data(:,:,1),squeeze( test_t_data(i_hour,:,:) ),pressure_data);
    end       %%  end for time loop
end

% WIND
if is_wind_plotted == 1
obs_ws_all_stn  = [ ];
obs_wd_all_stn  = [ ];
ctrl_ws_all_stn = [ ];
ctrl_wd_all_stn = [ ];
test_ws_all_stn = [ ];
test_wd_all_stn = [ ];
[obs_stn_nm_list,obs_stn_num,obs_stn_lat,obs_stn_lon,obs_wd] = read_envf( obs_wd_flnm, time_str_list, 0.1, 400 );
[obs_stn_nm_list,obs_stn_num,obs_stn_lat,obs_stn_lon,obs_ws] = read_envf( obs_ws_flnm, time_str_list, 0.1, 100 );

for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    [stn_nm, is_found] = checkStationName( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ) );
    stn_index = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat,obs_stn_lon );

    stn_nm = sprintf('%8.4f_%8.4f_%s',plot_stn_lat( i_stn ) ,plot_stn_lon( i_stn ), stn_nm );
    [iy ix] = position( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),LAT_data,LON_data );

    if stn_index > 0
       [obs_u, obs_v] = calc_uv( squeeze( obs_ws( :, stn_index ) ), ...
                                 squeeze( obs_wd( :, stn_index ) ) );
        plot_data( struct_index ).name = 'obs';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = obs_u;
        plot_data( struct_index ).data( :, 3 ) = obs_v;
        struct_index = struct_index + 1;
    end

    ctrl_u10 = squeeze( ctrl_u10_data( 1:n_hour, iy,ix ) );
    ctrl_v10 = squeeze( ctrl_v10_data( 1:n_hour, iy,ix ) );
    for i = 1:numel( ctrl_u10 )
       [ctrl_u10_true( i ), ctrl_v10_true( i )] = calc_uvmet( ctrl_u10( i ), ctrl_v10( i ), ...
                                                              LAT_data( iy, ix ), LON_data( iy, ix ), ...
                                                              truelat1, truelat2, ref_lon) ;
    end
    plot_data( struct_index ).name = 'ctrl';
    plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
    plot_data( struct_index ).data( :, 2 ) = ctrl_u10_true;
    plot_data( struct_index ).data( :, 3 ) = ctrl_v10_true;
    struct_index = struct_index + 1;


    if is_test_plotted == 1
        test_u10 = squeeze( test_u10_data( 1:n_hour, iy,ix ) );
        test_v10 = squeeze( test_v10_data( 1:n_hour, iy,ix ) );
        [test_u10_true, test_v10_true] = calc_uvmet( test_u10, test_v10, ...
                                                     LAT_data( iy, ix ), LON_data( iy, ix ), ...
                                                     truelat1, truelat2, ref_lon );
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_u10_true;
        plot_data( struct_index ).data( :, 3 ) = test_v10_true;

    end

    title_nm = sprintf(' %s wind',strrep( plot_stn_nm{ i_stn }, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( 'output/wind_%s_%s_%s.png', strrep( plot_stn_nm{ i_stn }, beg_date, end_date );
    is_plotted = struct_to_feather( plot_data, [datenum_beg datenum_end wind_ymin wind_ymax],...
                                    title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data

    obs_ws_all_stn = [ obs_ws_all_stn, squeeze( obs_ws( :, i_stn ) ) ];
    obs_wd_all_stn = [ obs_wd_all_stn, squeeze( obs_wd( :, i_stn ) ) ];
    [ctrl_ws, ctrl_wd] = calc_ws_wd( ctrl_u10_true, ctrl_v10_true );
    ctrl_ws_all_stn = [ctrl_ws_all_stn, ctrl_ws ];
    ctrl_wd_all_stn = [ctrl_wd_all_stn, ctrl_wd ];
    if is_test_plotted == 1
        [test_ws, test_wd] = calc_ws_wd( test_u10_true, test_v10_true );
        test_ws_all_stn = [test_ws_all_stn, test_ws ];
        test_wd_all_stn = [test_wd_all_stn, test_wd ];
    end
end % i_stn loop for wind
statics_output = calc_statics( obs_ws_all_stn, ctrl_ws_all_stn, 0, 'WS_ctrl.txt' )
statics_output = calc_statics( obs_wd_all_stn, ctrl_wd_all_stn, 1, 'WD_ctrl.txt' )
if is_test_plotted == 1
   statics_output = calc_statics( obs_ws_all_stn, test_ws_all_stn, 0, 'WS_test.txt' )
   statics_output = calc_statics( obs_wd_all_stn, test_wd_all_stn, 1, 'WD_test.txt' )
end
end % is_wind_plotted

% T 
if is_t_plotted == 1
obs_t_all_stn  = [ ];
ctrl_t_all_stn = [ ];
test_t_all_stn = [ ];
[obs_stn_nm_list,obs_stn_num,obs_stn_lat,obs_stn_lon,obs_t] = read_envf( obs_t_flnm,time_str_list, 0.01, 100 );
for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    [stn_nm, is_found] = checkStationName( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ) );
    stn_index = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat,obs_stn_lon );

    stn_nm = sprintf('%8.4f_%8.4f_%s',plot_stn_lat( i_stn ) ,plot_stn_lon( i_stn ), stn_nm );

    [iy ix] = position( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),LAT_data,LON_data );
    
    ctrl_t = squeeze( ctrl_t_data( 1:n_hour, iy, ix ) );
    ctrl_t_celcius = ctrl_t - 273.15;
    if stn_index > 0
        plot_data( struct_index ).name = 'obs'; 
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = squeeze( obs_t( :, stn_index ) );
        struct_index = struct_index + 1;
    end

    plot_data( struct_index ).name = 'ctrl';
    plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
    plot_data( struct_index ).data( :, 2 ) = ctrl_t_celcius;
    struct_index = struct_index + 1;

    if is_test_plotted == 1
        test_t = squeeze( test_t_data( 1:n_hour, iy, ix ) );
        test_t_celcius = test_t - 273.15;
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_t_celcius;
    end
    
    title_nm = sprintf(' %s temperature [^oC]',strrep( strrep( plot_stn_nm{ i_stn }, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( 'output/T_%s_%s_%s.png', strrep( plot_stn_nm{ i_stn }, beg_date, end_date );
    is_plotted = struct_to_line( plot_data, [datenum_beg datenum_end t_ymin t_ymax],...
                                 title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data

    obs_t_all_stn = [ obs_t_all_stn, squeeze( obs_t( :, i_stn ) ) + 273.15 ];
    ctrl_t_all_stn = [ctrl_t_all_stn, ctrl_t ];
    if is_test_plotted == 1
        test_t_all_stn = [test_t_all_stn, test_t ];
    end
end % i_stn loop for T
statics_output = calc_statics( obs_t_all_stn, ctrl_t_all_stn, 0, 'T_ctrl.txt' )
if is_test_plotted == 1
   statics_output = calc_statics( obs_t_all_stn, test_t_all_stn, 0, 'T_test.txt' )
end
end % is_t_plotted

% PBLH, use temperature observation location
if is_pbl_plotted == 1
[obs_stn_nm_list,obs_stn_num,obs_stn_lat,obs_stn_lon,obs_t] = read_envf( obs_t_flnm,time_str_list, 0.01, 100 );
for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    [stn_nm, is_found] = checkStationName( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ) );
    stn_index = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat,obs_stn_lon );

    stn_nm = sprintf('%8.4f_%8.4f_%s',plot_stn_lat( i_stn ) ,plot_stn_lon( i_stn ), stn_nm );

    [iy ix] = position( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),LAT_data,LON_data );

    ctrl_pbl = squeeze( ctrl_pbl_data( 1:n_hour, iy, ix ) );
    plot_data( struct_index ).name = 'ctrl';
    plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
    plot_data( struct_index ).data( :, 2 ) = ctrl_pbl;
    struct_index = struct_index + 1;

    if is_test_plotted == 1
        test_pbl = squeeze( test_pbl_data( 1:n_hour, iy, ix ) );
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_pbl;

    end

    title_nm = sprintf(' %s PBLH  [m]',strrep( strrep( plot_stn_nm{ i_stn }, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( 'output/PBLH_%s_%s_%s.png', strrep( plot_stn_nm{ i_stn }, beg_date, end_date );
    is_plotted = struct_to_line( plot_data, [datenum_beg datenum_end 0 1000],...
                                 title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data
end % i_stn loop for PBLH
end % is_pbl_plotted



% RH
if is_rh_plotted == 1
obs_rh_all_stn  = [ ];
ctrl_rh_all_stn = [ ];
test_rh_all_stn = [ ];
[obs_stn_nm_list,obs_stn_num,obs_stn_lat,obs_stn_lon,obs_rh] = read_envf( obs_rh_flnm,time_str_list, 0.01, 100 );

for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    [stn_nm, is_found] = checkStationName( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ) );
    stn_index = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat,obs_stn_lon );

    stn_nm = sprintf('%8.4f_%8.4f_%s',plot_stn_lat( i_stn ) ,plot_stn_lon( i_stn ), stn_nm );

    [iy ix] = position( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),LAT_data,LON_data );

    if stn_index > 0
        plot_data( struct_index ).name = 'obs';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = squeeze( obs_rh( :, stn_index ) );
        struct_index = struct_index + 1;
    end

    ctrl_rh  = squeeze( ctrl_rh_data( 1:n_hour, iy,ix ) );
    plot_data( struct_index ).name = 'ctrl';
    plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
    plot_data( struct_index ).data( :, 2 ) = ctrl_rh;
    struct_index = struct_index + 1;

    if is_test_plotted == 1
        test_rh  = squeeze( test_rh_data( 1:n_hour, iy,ix ) );
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_rh;
    end

    title_nm = sprintf(' %s RH  [%%]',strrep( strrep( plot_stn_nm{ i_stn }, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( 'output/RH_%s_%s_%s.png', strrep( plot_stn_nm{ i_stn }, beg_date, end_date );
    is_plotted = struct_to_line( plot_data, [datenum_beg datenum_end rh_ymin rh_ymax],...
                                 title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data

    obs_rh_all_stn = [ obs_rh_all_stn, squeeze( obs_rh( :, i_stn ) ) ];
    ctrl_rh_all_stn = [ctrl_rh_all_stn, ctrl_rh ];
    if is_test_plotted == 1
        test_rh_all_stn = [test_rh_all_stn, test_rh ];
    end
end % i_stn loop for RH
statics_output = calc_statics( obs_rh_all_stn, ctrl_rh_all_stn, 0, 'RH_ctrl.txt' )
if is_test_plotted == 1
   statics_output = calc_statics( obs_rh_all_stn, test_rh_all_stn, 0, 'RH_test.txt' )
end
end % is_rh_plotted

