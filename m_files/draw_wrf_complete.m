function is_drawed =draw_wrf_xuguo( beg_date, end_date )
% usage draw_wrf_xuguo( '2013121512','2013121912' )
% v0.7 Feb-9, 2015
% input session

% which to plot
is_wind_plotted = 1;
is_temp_plotted = 1;
is_pblh_plotted = 0;
is_rh_plotted = 1;
is_qv_plotted = 0;
% RH
rh_ymin = 40;
rh_ymax = 100;
obs_rh_flnm = 'obs_data/A_RH_VT-20110331-20120501.csv';
% T
t_ymin = 5;
t_ymax = 45;
obs_t_flnm  = 'obs_data/A_TEMP-20140617-20140623.csv';
% wind
wind_ymin = -0.5;
wind_ymax = 0.5;
obs_wd_flnm = 'obs_data/A_wd-20140617-20140623.csv';
obs_ws_flnm = 'obs_data/A_ws-20140617-20140623.csv';
obs_pr_flnm = 'obs_data/A_PRE_STN-20110331-20120501.csv';

is_test_plotted = 0;
domain='d04';

CTRL_PATH='/home/yaoteng/plot/draw_zhenzhou/WRF_OUTPUT/ctrl/';
TEST_PATH='/disk/hq183/yaoteng/POA/draw_WRF/WRF_OUTPUT/test';
ctrl_label='UST';
test_label='MYJ';
pic_output='/home/yaoteng/plot/draw_zhenzhou/pic_output';
xlabel_nm =  'Year 2015';
% end of input session
ref_lon=110.;
truelat1=18.;
truelat2=42.;


% date handling
datenum_beg = datenum( beg_date,'yyyymmddhh' );
datenum_end = datenum( end_date,'yyyymmddhh' );
n_hour = round( ( datenum_end - datenum_beg ) * 24 + 1 )
time_str_list = generate_time_str_list( datenum_beg, datenum_end, 1, 'hour', 'yyyy/mm/dd HH:MM:SS' );


% get station info
plot_stn_lat = [34.43];
plot_stn_lon = [108.75];
plot_stn_nm = { 'XianYang' };
plot_stn_num = numel( plot_stn_lat );
iy_list = zeros( 1, plot_stn_num );
ix_list = zeros( 1, plot_stn_num );

% read wrf lat lon
[yyyy,mm,dd,HH] = datevec( datenum_beg );
map_flnm = sprintf( '%s/wrfout_%s_%04d-%02d-%02d_%02d:00:00', CTRL_PATH, domain, yyyy, mm, dd, HH )
LAT_data = read_nc( map_flnm, 'XLAT' );
LON_data = read_nc( map_flnm, 'XLONG' );

% get stn index
for i_stn = 1:plot_stn_num    %%  loop for station
    [iy ix] = position( plot_stn_lat( i_stn ), plot_stn_lon( i_stn ), LAT_data, LON_data );
    iy_list( i_stn ) = iy;
    ix_list( i_stn ) = ix;
end

for i_hour=1:n_hour
   datenum_current = addtodate( datenum_beg, i_hour - 1, 'hour' );
   datenum_list_sim( i_hour ) = datenum_current;
   [yyyy,mm,dd,HH] = datevec( datenum_current );
   ctrl_flnm=sprintf( '%s/wrfout_%s_%04d-%02d-%02d_%02d:00:00',CTRL_PATH,domain,yyyy,mm,dd,HH);

   if is_wind_plotted == 1
      ctrl_u10_temp = read_nc(ctrl_flnm,'U10');
      ctrl_v10_temp = read_nc(ctrl_flnm,'V10');
      for i_stn = 1:plot_stn_num
         ctrl_u10_data( i_hour, i_stn ) = ctrl_u10_temp( iy_list( i_stn ), ix_list( i_stn ) );
         ctrl_v10_data( i_hour, i_stn ) = ctrl_v10_temp( iy_list( i_stn ), ix_list( i_stn ) );
      end
   end

   if is_temp_plotted == 1
      ctrl_t_temp = read_nc(ctrl_flnm,'T2');
      for i_stn = 1:plot_stn_num
         ctrl_t_data( i_hour, i_stn ) = ctrl_t_temp( iy_list( i_stn ), ix_list( i_stn ) );
      end
   end

   if is_pblh_plotted == 1
      ctrl_pbl_temp = read_nc(ctrl_flnm,'PBLH');
      for i_stn = 1:plot_stn_num
         ctrl_pbl_data( i_hour, i_stn ) = ctrl_pbl_temp( iy_list( i_stn ), ix_list( i_stn ) );
      end
   end
   
   if is_rh_plotted == 1
      ctrl_t_temp = read_nc(ctrl_flnm,'T2');
      ctrl_vapor_temp =read_nc(ctrl_flnm,'QVAPOR');
      pressure_temp=read_nc(ctrl_flnm,'PSFC');
      ctrl_rh_temp= calc_rh( ctrl_vapor_temp(:,:,1), ctrl_t_temp, pressure_temp );
      for i_stn = 1:plot_stn_num
         ctrl_rh_data( i_hour, i_stn ) = ctrl_rh_temp( iy_list( i_stn ), ix_list( i_stn ) );
      end
   end

   if is_qv_plotted == 1 
      ctrl_qv_temp = read_nc( ctrl_flnm,'QVAPOR');
      for i_stn = 1:plot_stn_num
         ctrl_qv_data( i_hour, i_stn ) = ctrl_qv_temp( iy_list( i_stn ), ix_list( i_stn ) ) .* 1000; %g/kg
      end
   end  
end       %%  end for time loop

if is_test_plotted == 1
    for i_hour=1:n_hour
        datenum_current = addtodate( datenum_beg, i_hour - 1, 'hour' );
        [yyyy,mm,dd,HH] = datevec( datenum_current );
 
        test_flnm=sprintf( '%s/wrfout_%s_%04d-%02d-%02d_%02d:00:00',TEST_PATH,domain,yyyy,mm,dd,HH);

        if is_wind_plotted == 1
           test_u10_temp = read_nc(test_flnm,'U10');
           test_v10_temp = read_nc(test_flnm,'V10');
           for i_stn = 1:plot_stn_num
              test_u10_data( i_hour, i_stn ) = test_u10_temp( iy_list( i_stn ), ix_list( i_stn ) );
              test_v10_data( i_hour, i_stn ) = test_v10_temp( iy_list( i_stn ), ix_list( i_stn ) );
           end
        end
        if is_temp_plotted + is_rh_plotted > 0
           test_t_temp = read_nc(test_flnm,'T2');
           for i_stn = 1:plot_stn_num
              test_t_data( i_hour, i_stn ) = test_t_temp( iy_list( i_stn ), ix_list( i_stn ) );
           end
        end
        
        if is_pblh_plotted == 1
           test_pbl_temp = read_nc(test_flnm,'PBLH');
           for i_stn = 1:plot_stn_num
              test_pbl_data( i_hour, i_stn ) = test_pbl_temp( iy_list( i_stn ), ix_list( i_stn ) );
           end
        end
        
        if is_rh_plotted == 1
           test_vapor_temp =read_nc(test_flnm,'QVAPOR');
           pressure_temp=read_nc(test_flnm,'PSFC');
           test_rh_temp= calc_rh( test_vapor_temp(:,:,1), test_t_temp, pressure_temp );
           for i_stn = 1:plot_stn_num
              test_rh_data( i_hour, i_stn ) = test_rh_temp( iy_list( i_stn ), ix_list( i_stn ) );
           end
        end
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
[obs_stn_nm_list,obs_stn_num,obs_stn_lat_wd,obs_stn_lon_wd,obs_wd] = read_envf( obs_wd_flnm, time_str_list, 0.1, 361 );
[obs_stn_nm_list,obs_stn_num,obs_stn_lat_ws,obs_stn_lon_ws,obs_ws] = read_envf( obs_ws_flnm, time_str_list, 0.8, 9  );

for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    stn_index_ws = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat_ws,obs_stn_lon_ws );
    stn_index_wd = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat_wd,obs_stn_lon_wd );
    stn_nm = plot_stn_nm{ i_stn };


    if stn_index_ws*stn_index_wd > 0
       [obs_u, obs_v] = calc_uv( squeeze( obs_ws( :, stn_index_ws ) ), ...
                                 squeeze( obs_wd( :, stn_index_wd ) ) );
        plot_data( struct_index ).name = 'obs';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = obs_u;
        plot_data( struct_index ).data( :, 3 ) = obs_v;
        struct_index = struct_index + 1;
    end

    ctrl_u10 = squeeze( ctrl_u10_data( 1:n_hour, i_stn ) );
    ctrl_v10 = squeeze( ctrl_v10_data( 1:n_hour, i_stn ) );
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
        test_u10 = squeeze( test_u10_data( 1:n_hour, i_stn ) );
        test_v10 = squeeze( test_v10_data( 1:n_hour, i_stn ) );
        [test_u10_true, test_v10_true] = calc_uvmet( test_u10, test_v10, ...
                                                     LAT_data( iy, ix ), LON_data( iy, ix ), ...
                                                     truelat1, truelat2, ref_lon );
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_u10_true;
        plot_data( struct_index ).data( :, 3 ) = test_v10_true;

    end

    title_nm = sprintf(' %s wind',strrep( stn_nm, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( '%s/wind_%s_%s_%s.png', pic_output,stn_nm, beg_date, end_date );
    is_plotted = struct_to_feather( plot_data, [datenum_beg datenum_end wind_ymin wind_ymax],...
                                    title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data
    if stn_index_ws*stn_index_wd > 0 
       obs_ws_all_stn = [ obs_ws_all_stn, squeeze( obs_ws( :, stn_index_ws ) ) ];
       obs_wd_all_stn = [ obs_wd_all_stn, squeeze( obs_wd( :, stn_index_wd ) ) ];
       [ctrl_ws, ctrl_wd] = calc_ws_wd( ctrl_u10_true, ctrl_v10_true );
       ctrl_ws_all_stn = [ctrl_ws_all_stn, ctrl_ws ];
       ctrl_wd_all_stn = [ctrl_wd_all_stn, ctrl_wd ];
       if is_test_plotted == 1
           [test_ws, test_wd] = calc_ws_wd( test_u10_true, test_v10_true );
           test_ws_all_stn = [test_ws_all_stn, test_ws ];
           test_wd_all_stn = [test_wd_all_stn, test_wd ];
       end
    end 
    clear stn_index_ws
    clear stn_index_wd
end % i_stn loop for wind
statics_output = calc_statics( obs_ws_all_stn, ctrl_ws_all_stn, 0, 'WS_ctrl.txt' )
statics_output = calc_statics( obs_wd_all_stn, ctrl_wd_all_stn, 1, 'WD_ctrl.txt' )
if is_test_plotted == 1
   statics_output = calc_statics( obs_ws_all_stn, test_ws_all_stn, 0, 'WS_test.txt' )
   statics_output = calc_statics( obs_wd_all_stn, test_wd_all_stn, 1, 'WD_test.txt' )
end
end % is_wind_plotted

if is_temp_plotted == 1
% T 
obs_t_all_stn  = [ ];
ctrl_t_all_stn = [ ];
test_t_all_stn = [ ];
[obs_stn_nm_list,obs_stn_num,obs_stn_lat,obs_stn_lon,obs_t] = read_envf( obs_t_flnm,time_str_list, -30, 50 );
for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    stn_index  = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat ,obs_stn_lon  );

    stn_nm = plot_stn_nm{ i_stn };
    
    ctrl_t = squeeze( ctrl_t_data( 1:n_hour, i_stn ) );
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
        test_t = squeeze( test_t_data( 1:n_hour, i_stn ) );
        test_t_celcius = test_t - 273.15;
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_t_celcius;
    end
    
    title_nm = sprintf(' %s temperature [^oC]',strrep( stn_nm, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( '%s/T_%s_%s_%s.png', pic_output, stn_nm, beg_date, end_date );
    is_plotted = struct_to_line( plot_data, [datenum_beg datenum_end t_ymin t_ymax],...
                                 title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data

    if stn_index > 0
       obs_t_all_stn = [ obs_t_all_stn, squeeze( obs_t( :, stn_index ) ) + 273.15 ];
       ctrl_t_all_stn = [ctrl_t_all_stn, ctrl_t ];
       if is_test_plotted == 1
           test_t_all_stn = [test_t_all_stn, test_t ];
       end
    end
    clear stn_index
end % i_stn loop for T
statics_output = calc_statics( obs_t_all_stn, ctrl_t_all_stn, 0, 'T_ctrl.txt' )
if is_test_plotted == 1
   statics_output = calc_statics( obs_t_all_stn, test_t_all_stn, 0, 'T_test.txt' )
end
end % is_temp_plotted

if is_pblh_plotted == 1
% PBLH, use temperature observation location
for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    stn_index = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat,obs_stn_lon );
    stn_nm = plot_stn_nm{ i_stn };


    ctrl_pbl = squeeze( ctrl_pbl_data( 1:n_hour, i_stn ) );
    plot_data( struct_index ).name = 'ctrl';
    plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
    plot_data( struct_index ).data( :, 2 ) = ctrl_pbl;
    struct_index = struct_index + 1;

    if is_test_plotted == 1
        test_pbl = squeeze( test_pbl_data( 1:n_hour, i_stn ) );
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_pbl;

    end

    title_nm = sprintf(' %s PBLH  [m]',strrep( stn_nm, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( '%s/PBLH_%s_%s_%s.png', pic_output, stn_nm, beg_date, end_date );
    is_plotted = struct_to_line( plot_data, [datenum_beg datenum_end 0 1000],...
                                 title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data
end % i_stn loop for PBLH
end % is_pblh_plotted 


if is_rh_plotted == 1
% RH
obs_rh_all_stn  = [ ];
ctrl_rh_all_stn = [ ];
test_rh_all_stn = [ ];
[obs_stn_nm_list,obs_stn_num,obs_stn_lat,obs_stn_lon,obs_rh] = read_envf( obs_rh_flnm,time_str_list, 0.01, 100 );

for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    stn_index = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat,obs_stn_lon );

    stn_nm = plot_stn_nm{ i_stn };


    if stn_index > 0
        plot_data( struct_index ).name = 'obs';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = squeeze( obs_rh( :, stn_index ) );
        struct_index = struct_index + 1;
    end

    ctrl_rh  = squeeze( ctrl_rh_data( 1:n_hour, i_stn ) );
    plot_data( struct_index ).name = 'ctrl';
    plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
    plot_data( struct_index ).data( :, 2 ) = ctrl_rh;
    struct_index = struct_index + 1;

    if is_test_plotted == 1
        test_rh  = squeeze( test_rh_data( 1:n_hour, i_stn ) );
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_rh;
    end

    title_nm = sprintf(' %s RH  [%%]',strrep( stn_nm, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( '%s/RH_%s_%s_%s.png', pic_output, stn_nm, beg_date, end_date );
    is_plotted = struct_to_line( plot_data, [datenum_beg datenum_end rh_ymin rh_ymax],...
                                 title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data

    if stn_index > 0
       obs_rh_all_stn = [ obs_rh_all_stn, squeeze( obs_rh( :, stn_index ) ) ];
       ctrl_rh_all_stn = [ctrl_rh_all_stn, ctrl_rh ];
       if is_test_plotted == 1
           test_rh_all_stn = [test_rh_all_stn, test_rh ];
       end
    end
    clear stn_index
end % i_stn loop for RH
statics_output = calc_statics( obs_rh_all_stn, ctrl_rh_all_stn, 0, 'RH_ctrl.txt' )
if is_test_plotted == 1
   statics_output = calc_statics( obs_rh_all_stn, test_rh_all_stn, 0, 'RH_test.txt' )
end
clear stn_index
end % is_rh_plotted

if is_qv_plotted == 1
% Q
obs_qv_all_stn  = [ ];
ctrl_qv_all_stn = [ ];
test_qv_all_stn = [ ];
[obs_stn_nm_list,obs_stn_num,obs_stn_lat_rh,obs_stn_lon_rh,obs_rh] = read_envf( obs_rh_flnm,time_str_list, 0.01, 100 );
[obs_stn_nm_list,obs_stn_num,obs_stn_lat_t, obs_stn_lon_t, obs_t ] = read_envf( obs_t_flnm,time_str_list, 0.01, 100 );
[obs_stn_nm_list,obs_stn_num,obs_stn_lat_pr,obs_stn_lon_pr,obs_pr] = read_envf( obs_pr_flnm,time_str_list, 80000, 110000 );

for i_stn = 1:plot_stn_num    %%  loop for station
    struct_index = 1;
    stn_index_rh = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat_rh,obs_stn_lon_rh );
    stn_index_t  = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat_t ,obs_stn_lon_t  );
    stn_index_pr = find_stn_in_obs( plot_stn_lat( i_stn ),plot_stn_lon( i_stn ),obs_stn_lat_pr ,obs_stn_lon_pr );

    stn_nm = plot_stn_nm{ i_stn };

    if stn_index_rh*stn_index_t*stn_index_pr > 0
        obs_qv = calc_qs( squeeze( obs_rh( :, stn_index_rh ) ), ...
                          squeeze( obs_t( :, stn_index_t ) ) + 273.15, ... % ciculs to Kelvin
                          squeeze( obs_pr( :, stn_index_pr ) ) ./ 100 );   % Pa to hPa

        plot_data( struct_index ).name = 'obs';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = obs_qv;
        struct_index = struct_index + 1;
    end

    ctrl_qv  = squeeze( ctrl_qv_data( 1:n_hour, i_stn ) );
    plot_data( struct_index ).name = 'ctrl';
    plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
    plot_data( struct_index ).data( :, 2 ) = ctrl_qv;
    struct_index = struct_index + 1;

    if is_test_plotted == 1
        test_qv  = squeeze( test_qv_data( 1:n_hour, i_stn ) );
        plot_data( struct_index ).name = 'test';
        plot_data( struct_index ).data( :, 1 ) = datenum_list_sim;
        plot_data( struct_index ).data( :, 2 ) = test_qv;
    end

    title_nm = sprintf(' %s Q  [g/kg]',strrep( stn_nm, '_', ' ' ) );
    ylabel_nm =  '';
    pic_nm = sprintf( '%s/QV_%s_%s_%s.png', pic_output, stn_nm, beg_date, end_date );
    is_plotted = struct_to_line( plot_data, [datenum_beg datenum_end rh_ymin rh_ymax],...
                                 title_nm, xlabel_nm, ylabel_nm, pic_nm );
    clear plot_data

    if stn_index_rh*stn_index_t*stn_index_pr > 0
       obs_qv_all_stn = [ obs_qv_all_stn, obs_qv  ];
       ctrl_qv_all_stn = [ctrl_qv_all_stn, ctrl_qv ];
       if is_test_plotted == 1
           test_qv_all_stn = [test_qv_all_stn, test_qv ];
       end
    end
    clear stn_index_rh stn_index_t stn_index_pr
end % i_stn loop for QV
statics_output = calc_statics( obs_qv_all_stn, ctrl_qv_all_stn, 0, 'QV_ctrl.txt' )



if is_test_plotted == 1
   statics_output = calc_statics( obs_qv_all_stn, test_qv_all_stn, 0, 'QV_test.txt' )
end
end % is_qv_plotted
return % end of draw_wrf_xuguo

% function x = read_nc(flnm,var)
% use matlab 2009 nc libs
% example : matrix = read_nc('/home/yaoteng/joke.ncf','PM10');
function var_data = read_nc( flnm, var_nm )
    file_id = netcdf.open( flnm, 'NC_NOWRITE' );
    var_id = netcdf.inqVarID( file_id, var_nm );
    var_data = netcdf.getVar( file_id, var_id );
    netcdf.close( file_id );
return
% calc_rh.m
% rh unit[%], P unit[hPa], t unit[K]
% q unit [g/kg]

function q = calc_qs( rh, t, p )
rh = rh ./ 100;
es = 6.1078 .* exp( ( t - 273.16 ) .* 17.27 ./ ( t - 35.86 ) );
qs = 0.622 .* es ./ p;
q = 1000 .* rh .* qs;
return
% calc_rh.m

function rh =calc_rh( qv,ta,pres )
    esat  = 610.94 .* exp( 17.625 .* ( ta - 273.15 ) ./ ( ta - 273.15 + 243.04 ) );
    rh = pres .* qv ./ ( ( 0.6220 + qv ) .*  esat );
    rh = min( 0.99, max( 0.005,  rh ) );
return
% calc_statics.m
function statics_output = calc_statics( obs_data, sim_data, is_winddir,  flnm )
    if nargin < 2 || nargin > 4
        error( 'invalid input argument number' )
    end
    if nargin < 3
        is_winddir = 0;
    end

    if numel( obs_data ) ~= numel( sim_data )
        error( 'sizes of input arrays do not match' )
    end
    
    nan_index = find( obs_data ~= obs_data );
    obs_data( nan_index ) = [];
    sim_data( nan_index ) = [];
    n_record = numel( obs_data ); 
    correlation_temp = corrcoef( obs_data, sim_data );
    mnb_temp = calc_mnb( obs_data, sim_data );
    nmb_temp = calc_nmb( obs_data, sim_data );
    if is_winddir == 1
        ioa_temp = calc_wind_dir_ioa( obs_data, sim_data );
        mb_temp  = calc_wind_dir_mb( obs_data, sim_data );
        rmse_temp  = calc_wind_dir_rmse( obs_data, sim_data );
    elseif is_winddir == 0
        ioa_temp = calc_ioa( obs_data, sim_data );
        mb_temp  = calc_mb( obs_data, sim_data );
        rmse_temp = calc_rmse( obs_data, sim_data );
    end
    
    statics_output( 1 ) = ioa_temp;
    statics_output( 2 ) = correlation_temp( 1, 2 );
    statics_output( 3 ) = mb_temp( 1 );
    statics_output( 4 ) = mb_temp( 2 );
    statics_output( 5 ) = mnb_temp( 1 );
    statics_output( 6 ) = mnb_temp( 2 );
    statics_output( 7 ) = nmb_temp( 1 );
    statics_output( 8 ) = nmb_temp( 2 );
    statics_output( 9 ) = rmse_temp( 1 );
    statics_output( 10) = n_record;

% write output to text
    if nargin  == 4
        fid = fopen( flnm, 'w' );
        fprintf( fid, '%s \n', 'IOA    Corr    MB    MAGE   MNB    MNGE    NMB    NMGE    RMSE  n=' );
        fprintf( fid, '%6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %d \n', statics_output(:) );
        fclose( fid )
    end
return

% calc_ioa calculates index of agreement between given observed data
% and corresponding simulated values
function IOA = calc_ioa( obs,sim );
   if numel( obs ) ~= numel( sim )
      error( 'sizes of input arrays do not match' )
   end
   ave_obs = mean( obs );
   DS_N = 0;
   DS_D = 0;
   for i = 1:numel( obs )
       DS_N = DS_N + ( sim( i ) - obs( i ) ) ^ 2;
       DS_D = DS_D + ( abs( sim( i ) - ave_obs ) + abs( obs( i ) - ave_obs ) ) ^ 2;
   end
   if  DS_D > 0  
       DS = DS_N/DS_D;
       IOA = ( 1 - DS ); 
   else
       IOA = NaN;
   end
return

% calc_wind_dir_ioa calculates index of agreement between given observed data
% and corresponding simulated values
function IOA = calc_wind_dir_ioa( obs,sim );
   if numel( obs ) ~= numel( sim )
      error( 'sizes of input arrays do not match' )
   end
   data_validation =[ min( obs( : ) ) < 0, max( obs( : ) ) > 360 ];
   if max( data_validation ) == 1
      error( 'wrong obs input' )
   end
   data_validation =[ min( sim( : ) ) < 0, max( sim( : ) ) > 360 ];
   if max( data_validation ) == 1
      error( 'wrong sim input' )
   end

   DS_N = 0;
   n_record = length( obs );
   for i = 1:n_record
       dir_diff = abs(  sim( i ) - obs( i ) );
       min_diff = min( dir_diff, 360 - dir_diff );
       DS_N = DS_N + min_diff ^ 2;
   end
   IOA =  1 - DS_N / n_record / 180 / 180;
return


% calc_mnb calculates mean normalized bias ( MNB ) and mean normalized gross error ( MNGE )
function func = calc_mnb( obs,sim );
    if numel( obs ) ~= numel( sim )
       error( 'sizes of input arrays do not match' )
    end
    mnb = 0;
    mnge = 0;
    n_record = length( obs );
    for i = 1:n_record
        mnb = mnb + ( sim( i )-obs( i ) ) / obs( i );
        mnge = mnge + abs( sim( i )-obs( i ) ) / obs( i );
    end
    mnb = mnb / n_record * 100;
    mnge = mnge / n_record * 100;
    func = [mnb mnge]; 
return

% calculate normalized mean bias (NMB) and normalized mean error (NME)

function func = calc_nmb( obs,sim );
    if numel( obs ) ~= numel( sim )
       error( 'sizes of input arrays do not match' )
    end
    n_record = length( obs );
    nmb_temp = 0;
    nme_temp = 0;
    sum_obs = sum( obs( : ) );
    for i = 1:n_record
        nmb_temp = nmb_temp + ( sim( i ) - obs( i ) );
        nme_temp = nme_temp + abs( sim( i ) - obs( i ) );
    end
    if sum_obs ~= 0
        nmb = nmb_temp * 100 / sum_obs;
        nme = nme_temp * 100 / sum_obs;
    else
        nmb = NaN;
        nme = NaN;
    end
    func = [nmb nme];
return

% calculate mean bias (MB) and mean absolute gross error (MAGE)
function func = calc_mb( obs, sim );
    if numel( obs ) ~= numel( sim )
       error( 'sizes of input arrays do not match' )
    end
    n_record = numel( obs );
    mb = 0;
    mage = 0;
    for i = 1:n_record
        mb = mb + ( sim( i ) - obs( i ) );
        mage = mage + abs( sim( i ) - obs( i ) );
    end
    mb = mb / n_record;
    mage = mage / n_record;
    func = [mb mage];
return

% calculate mean bias (MB) and mean absolute gross error (MAGE)
function func = calc_wind_dir_mb( obs, sim );
    if numel( obs ) ~= numel( sim )
       error( 'sizes of input arrays do not match' )
    end
    n_record = numel( obs );
    mb = 0;
    mage = 0;
    for i = 1:n_record
        sim_obs_diff = sim( i ) - obs( i );
        if sim_obs_diff < -180 
           sim_obs_diff = sim_obs_diff + 360;
        end
        if sim_obs_diff > 180
           sim_obs_diff = sim_obs_diff - 360;
        end

        mb = mb + sim_obs_diff;
        mage = mage + abs( sim_obs_diff );
    end
    mb = mb / n_record;
    mage = mage / n_record;
    func = [mb mage];
return

% RMSE.m calculates root mean squared error for given observed data
% and corresponding simulated values

function func=calc_rmse(obs,sim);
    if numel( obs ) ~= numel( sim )
       error( 'sizes of input arrays do not match' )
    end
    n_record = numel( obs );

    rmse=0;
    
    for i = 1 : n_record
         rmse = rmse + ( sim( i ) - obs( i ) ) ^ 2;
    end
    
    if n_record > 0
        rmse = rmse / n_record;
        rmse = sqrt( rmse );
    else
        rmse = NaN;
    end
    func = rmse;
return


% and corresponding simulated values

function func=calc_wind_dir_rmse(obs,sim);
    if numel( obs ) ~= numel( sim )
       error( 'sizes of input arrays do not match' )
    end
    n_record = numel( obs );

    rmse=0;
    sum=0;

    for i=1:n_record
        sum=sum+1;
        sim_obs_diff = sim( i ) - obs( i );
        if sim_obs_diff < -180
           sim_obs_diff = sim_obs_diff + 360;
        end
        if sim_obs_diff > 180
           sim_obs_diff = sim_obs_diff - 360;
        end

        rmse = rmse + sim_obs_diff ^ 2;
    end

    if n_record > 0
        rmse = rmse / n_record;
        rmse = sqrt( rmse );
    else
        rmse = NaN;
    end
    func = rmse;
return
function [u, v]=calc_uv( speed,direction )
 
deg_per_rad = 57.2958;
u = -sin( direction ./ deg_per_rad ) .* speed;
v = -cos( direction ./ deg_per_rad ) .* speed;
return
function [umet, vmet]=calc_uvmet(u,v,xlat,xlon,truelat1,truelat2,ref_lon)
 
 deg_per_rad=57.2958;
 rad_per_deg=0.0174533;

 if(length(u)==length(v))
   n=length(u);
  
   if(abs(truelat1-truelat2)>0.1 )
     fac1=log(cos(truelat1*rad_per_deg))-log(cos(truelat2*rad_per_deg));
     fac2=log(tan((90.0-abs(truelat1))*rad_per_deg*0.5));
     fac3=log(tan((90.0-abs(truelat2))*rad_per_deg*0.5));

     cone=fac1/(fac2-fac3);
    
    else
      cone=sin(abs(truelat1)*rad_per_deg);
   end
 
     diff=xlon-ref_lon;
     if(diff>180.)
        diff=diff-360.
     end
     if(diff<-180)
        diff=diff+360.
     end
   
     if (xlat>0.)
       alpha=-diff*cone*rad_per_deg;
      else
       alpha=diff*cone*rad_per_deg;
     end

     umet=v.*sin(alpha)+u.*cos(alpha);
     vmet=v.*cos(alpha)-u.*sin(alpha);
   
%%   ws=sqrt(u.*u+v.*v);
%%   wd=270.-atan2(v,u).*deg_per_rad;
      
%%   wd(find(wd>360.))=wd(find(wd>360.))-360.;
%%   num=length(wd)
  else
   disp('error in calculate umet and vmet');
 end

 

function [ws, wd]=calc_ws_wd(u,v)
 
    if length( u ) ~= length( v )
       error( 'input u and v have different size' )
    end
    deg_per_rad = 57.2958;

    n = length( u );
   
    ws = sqrt( u .* u + v .* v );
    wd = 270 - atan2( v, u ) .* deg_per_rad;
       
    wd( find( wd > 360 ) ) = wd( find( wd > 360 ) ) - 360;
return

% read files downloaded from envf
% usage : [stn_nm,n_stn,stn_lat,stn_lon,conc]=read_envf(flnm);
%
% no more sscanf, use textscan and textscan, no need to strip the space
% Feb 08 2013


function [stn_nm,n_stn,stn_lat,stn_lon] = read_envf_header( flnm )

if ~exist( flnm,'file' )
    error( [flnm, ' file not exist'] );
end

fid = fopen( flnm,'r' );
fgetl( fid );
fgetl( fid );

% station number
n_stn = strread( read_line_stripped(fid),'%*s%d','delimiter',':' )
data_format = '%*s';
for i_stn = 1:n_stn
    data_format = [data_format,'%f'];
end

fgetl( fid );
fgetl( fid );

% station name:
stn_nm_cell =  textscan( read_line_stripped( fid ),'%s','Delimiter',',' );
stn_nm = stn_nm_cell{ 1 };
stn_nm( 1 ) = [];
if length( stn_nm ) ~= n_stn
    error(' station names do not match station numbers' );
end
stn_nm = reshape( stn_nm,1,n_stn )

% station Lat & Lon
stn_lat = cell2mat( textscan( read_line_stripped( fid ),data_format,'Delimiter',',' ) );
stn_lon = cell2mat( textscan( read_line_stripped( fid ),data_format,'Delimiter',',' ) );

return

function str = read_line_stripped( file_id )
% after read line, remove '"'
% then return str
str = strrep( fgetl( file_id ),'"','');
return
     
% read files downloaded from envf
% usage : [stn_nm,n_stn,stn_lat,stn_lon,conc]=read_envf(flnm);
%
% no more sscanf, use textscan and textscan, no need to strip the space
% Feb 08 2013


function [stn_nm,n_stn,stn_lat,stn_lon,conc] = read_envf( flnm,time_str_list, low_limit, high_limit )

if ~exist( flnm,'file' )
    error( [flnm, ' file not exist'] );
end

if low_limit > high_limit
    error( ' low_limit should be high_limit' );
end

fid = fopen( flnm,'r' );
fgetl( fid );
fgetl( fid );

% station number
n_hour = length( time_str_list );
n_stn = strread( read_line_stripped(fid),'%*s%d','delimiter',':' )
data_format = '%*s';
for i_stn = 1:n_stn
    data_format = [data_format,'%f'];
end

fgetl( fid );
fgetl( fid );

% station name:
stn_nm_cell =  textscan( read_line_stripped( fid ),'%s','Delimiter',',' );
stn_nm = stn_nm_cell{ 1 };
stn_nm( 1 ) = [];
if length( stn_nm ) ~= n_stn
    error(' station names do not match station numbers' );
end
stn_nm = reshape( stn_nm,1,n_stn )

% station Lat & Lon
stn_lat = cell2mat( textscan( read_line_stripped( fid ),data_format,'Delimiter',',' ) );
stn_lon = cell2mat( textscan( read_line_stripped( fid ),data_format,'Delimiter',',' ) );

read_line_stripped(fid);
i=1;
while 1
   tline = read_line_stripped(fid)
   if ~ischar(tline), break, end
   temp_str = strread( tline,'%s',1,'delimiter',',' );
   obs_time_str_list{i} = temp_str{ 1 };
   conc_temp( i,: )= cell2mat( textscan( tline,data_format,'Delimiter',',' ) );
   i = i + 1;
end
fclose(fid);

for i_hour = 1:n_hour
    str_index = strcmpi( time_str_list{ i_hour },obs_time_str_list );
    if ( sum( str_index ) == 1)
        data_index = find( str_index == 1 );
        conc( i_hour,: ) = conc_temp( data_index,: );
    elseif ( sum( str_index ) == 0 )
        conc( i_hour,: ) = NaN;
    else
        disp( 'error with input time string or obs file' );
        fprintf( 'input time string is %s', time_str_list{ i_hour } );
        exit
    end
end
for i = 1:numel( conc( : ) )
   data_invalidation =[ conc( i ) < low_limit, conc( i ) > high_limit ];
   if max( data_invalidation ) == 1
       conc( i ) = NaN;
   end
end

% remove stn with no data at all
conc_check = sum( isnan( conc ), 1 );
no_data_stn_index = find( conc_check == n_hour );
if numel( no_data_stn_index ) > 0
   stn_nm( no_data_stn_index ) = [];
   n_stn = n_stn - numel( no_data_stn_index );
   stn_lat( no_data_stn_index ) = [];
   stn_lon( no_data_stn_index ) = [];
   conc( :, no_data_stn_index ) = [];
end
return % end of read_envf function

function [iy,ix]=position(stn_lat,stn_lon,xlat,xlon);
% usage:
% [iy,ix] = position( 22.4 114.5,xlat,xlon);
% stn_lat certern location lat
% stn_lon certern location lon
% xlat  domain latitude matrix
% xlon  domain longitude matrix
% position.m

    difflat = stn_lat - xlat;
    difflon = stn_lon - xlon;
    rad = sqrt( difflat .^2 + difflon .^2 );
   
    rad_min = min( rad( : ) );
    [iy,ix] = find( rad==rad_min );

return

% get structure containning data name and value from input
% and plot feather for time series
% struct_to_feather.m
function is_plotted = struct_to_feather( plot_data, axis_lim, title_nm, x_label, y_label, pic_nm )

% plot info
xy_label_fontsize = 26;
title_fontsize = 28;
gca_fontsize = 24;
color_list = [ 0 0 0; ...
               1 0 0; ...
               0 0 1; ...
             ];
str_template = '%10s';
n_var = numel( plot_data );

% plotting ...
hFig = figure;
set( hFig, ...
     'visible', 'on', ...
     'color', 'w', ...
     'PaperPosition', [0.25 0.25 16 12], ...
     'papertype', 'A4', ...
     'paperorientation', 'portrait', ...
     'renderer', 'painters' );

for i_var = 1:n_var
   temp_data = plot_data( i_var ).data;
   [ wswd_data( i_var ).ws( :,1 ), wswd_data( i_var ).wd( :, 1 ) ] = calc_ws_wd( temp_data( :,2 ), temp_data( :,3 ) );
   h_plot( i_var ) = quiver( temp_data( :,1 ), zeros( size( temp_data( :,1 ) ) ), ... 
                             temp_data( :,2 ), temp_data( :,3 ), ...
                             'color', color_list( i_var,: ) );
   hold on;
   legend_nm{ i_var } = plot_data( i_var ).name;
end

h_legend = legend( h_plot, legend_nm );
title( title_nm, 'FontName', 'Helvetica', 'FontSize', title_fontsize, 'FontWeight', 'Bold' )
ylabel( y_label, 'FontName', 'Helvetica', 'FontSize', xy_label_fontsize, 'FontWeight', 'Bold' )
xlabel( x_label, 'FontName', 'Helvetica', 'FontSize', xy_label_fontsize, 'FontWeight', 'Bold' )

if numel( axis_lim ) > 0
   axis( axis_lim );
   set( gca, 'xTick',axis_lim(1):axis_lim(2) );
   plot_box_aspect_ratio = ( axis_lim(2) - axis_lim(1) ) / ( axis_lim(4) - axis_lim(3) );
end
if n_var >= 2 && strcmpi( 'obs', legend_nm{ 1 } )

    for i_var = 2:n_var
       statics_output_ws( i_var - 1, : ) = calc_statics( wswd_data( 1 ).ws, wswd_data( i_var ).ws );
       statics_output_wd( i_var - 1, : ) = calc_statics( wswd_data( 1 ).wd, wswd_data( i_var ).wd, 1 );
       str_template = [ str_template, ' %3.2f' ];
    end
    string_1 = sprintf( str_template, 'IA :'       , statics_output_ws( :, 2 ) );
    string_2 = sprintf( str_template, 'MB [%] :'   , statics_output_ws( :, 3 ) );
    string_3 = sprintf( str_template, 'NMB [%] : ' , statics_output_ws( :, 6 ) );
    string_4 = sprintf( str_template, 'NMGE [%] : ', statics_output_ws( :, 7 ) );
    string_5 = sprintf( str_template, 'WD IOA : '  , statics_output_wd( :, 1 ) );
    
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.95, string_1, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.85, string_2, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.75, string_3, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.65, string_4, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.55, string_5, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
end

set( gca, 'FontSize', gca_fontsize, ...
          'FontName', 'Helvetica', ...
          'FontWeight', 'Bold', ...
          'Xgrid', 'on', ...
          'Ygrid', 'on', ...
          'Ygrid', 'on', ...
          'YMinorGrid', 'on', ...
          'TickDir', 'out' )
set( gca, 'PlotBoxAspectRatio',[ plot_box_aspect_ratio, 1, 1 ] );
set( gca, 'Position', [0.08    0.1476    0.9    0.75] )
datetick( 'x','dd HH:MM', 'keeplimits', 'keepticks' );
rotateXLabels( gca, 90 )

hold off;
print( '-dpng', '-r300', pic_nm );
close
is_plotted = 1;
return
% get structure containning data name and value from input
% and plot lines for time series
% struct_to_line.m
function is_plotted = struct_to_line( plot_data, axis_lim, title_nm, x_label, y_label, pic_nm )

% plot info
xy_label_fontsize = 20;
title_fontsize = 24;
gca_fontsize = 20;
color_list = [ 0 0 0; ...
               1 0 0; ...
               0 0 1; ...
             ];
str_template = '%10s';
n_var = numel( plot_data );

% plotting ...
hFig = figure;
set( hFig, ...
     'visible', 'on', ...
     'color', 'w', ...
     'PaperPosition', [0.25 0.25 16 12], ...
     'papertype', 'A4', ...
     'paperorientation', 'portrait', ...
     'renderer', 'painters' );

for i_var = 1:n_var
   h_plot( i_var ) = plot( plot_data( i_var ).data( :,1 ),...
                           plot_data( i_var ).data( :,2 ),...
                           'color', color_list( i_var,: ), 'linewidth', 2 );
   hold on;
   legend_nm{ i_var } = plot_data( i_var ).name;
end

h_legend = legend( h_plot, legend_nm );
title( title_nm, 'FontName', 'Helvetica', 'FontSize', title_fontsize, 'FontWeight', 'Bold' )
ylabel( y_label, 'FontName', 'Helvetica', 'FontSize', xy_label_fontsize, 'FontWeight', 'Bold' )
xlabel( x_label, 'FontName', 'Helvetica', 'FontSize', xy_label_fontsize, 'FontWeight', 'Bold' )

if numel( axis_lim ) > 0
   axis( axis_lim );
   set( gca, 'xTick',axis_lim(1):1:axis_lim(2) );
end

if n_var >= 2 && strcmpi( 'obs', legend_nm{ 1 } ) 
    for i_var = 2:n_var 
       statics_output( i_var - 1, : ) = calc_statics( plot_data( 1 ).data( :,2 ), plot_data( i_var ).data( :,2 ) );
       str_template = [ str_template, ' %3.2f' ];
    end

    string_1=sprintf( str_template, 'IA :'       , statics_output( :, 1 ) );
    string_2=sprintf( str_template, 'MB [%] :'   , statics_output( :, 3 ) );
    string_3=sprintf( str_template, 'NMB [%] : ' , statics_output( :, 6 ) );
    string_4=sprintf( str_template, 'NMGE [%] : ', statics_output( :, 7 ) );
    
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.95, string_1, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.88, string_2, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.81, string_3, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
    text( axis_lim( 1 ), axis_lim( 4 ) * 0.74, string_4, 'FontSize', gca_fontsize, 'FontName', 'Helvetica' );
end

set( gca, 'FontSize', gca_fontsize, ...
          'FontName', 'Helvetica', ...
          'FontWeight', 'Bold', ...
          'Xgrid', 'on', ...
          'Ygrid', 'on', ...
          'Ygrid', 'on', ...
          'YMinorGrid', 'on', ...
          'TickDir', 'out' );
set( gca, 'Position', [0.08    0.1476    0.9    0.75] );
datetick( 'x','dd HH:MM', 'keeplimits', 'keepticks' );
rotateXLabels( gca, 90 )

hold off;
print( '-dpng', '-r300', pic_nm );
close
is_plotted = 1;
return

function time_str_list = generate_time_str_list( datenum_beg,...
                                                 datenum_end,...
                                                 n_interval,...
                                                 unit,...
                                                 time_str_format )
% usage:
% time_str_list = generate_time_str_list( '2012/06/01  08:00:00',...
%                                         '2012/06/02  08:00:00',...
%                                         1,...
%                                         'hour',...
%                                         'yyyy/mm/dd  HH:MM:SS' );
% datenum + 1 means one day forward
% datenum + 1/24 means one hour forward, 1/24 = 0.4166666
% Jul 22, 2013
% input argument are always datenum now Feb 2014
% generate_time_str_list.m

if nargin ~= 5
   disp( 'Usage:' )
   disp( 'time_str_list = generate_time_str_list( 735021.0,...' )
   disp( '                                        735022.0,...' )
   disp( '                                        1,...'                      )
   disp( '                                        "hour",...'                 )
   disp( '                                        "yyyy/mm/dd  HH:MM:SS" );'  )
   error( nargchk( 5,5,nargin ) );
end

datenum_current = datenum_beg;
i_time = 0;
i_record = 1;
while( datenum_current <= datenum_end )
    time_str_current = datestr( datenum_current,time_str_format );
    time_str_list{ i_record } = time_str_current;
    i_time = i_time + n_interval;
    i_record = i_record + 1;
    datenum_current = addtodate( datenum_beg,i_time,unit );
end
return



function stn_index = find_stn_in_obs( plot_stn_lat,plot_stn_lon,obs_lat_list,obs_lon_list )
% obs_lat_list & obs_lon_list are available station lat & lon
% plot_stn_lat & plot_stn_lon are the location need to be plotted
     sub_lat = find( obs_lat_list == plot_stn_lat );
     sub_lon = find( obs_lon_list == plot_stn_lon );
     stn_index = intersect( sub_lat,sub_lon );
     if length( stn_index ) == 0
         stn_index = 0;
     end
     if length( stn_index ) > 1
         warning( 'duplicated stations in obs file' )
         stn_index = stn_index( 1 );
     end
return


