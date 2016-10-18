% function x = read_cctm(flnm,var)
% use matlab 2009 nc libs
% example : matrix = read_cctm('/home/yaoteng/joke.ncf','PM10');
function data = read_cctm( flnm, var_nm )
file_id = netcdf.open( flnm, 'NC_NOWRITE' );
switch var_nm
case 'OC'
   var_list = {'AALKJ';'AXYL1J';'AXYL2J';'AXYL3J';...
    'ATOL1J';'ATOL2J';'ATOL3J';'ABNZ1J';'ABNZ2J';'ABNZ3J';'ATRP1J';'ATRP2J';'AISO1J';...
     'AISO2J';'ASQTJ';'AORGCJ';'AISO3J';'AOLGAJ';'AOLGBJ';'AORGPAJ';'AORGPAI';};
case 'EC'
   var_list = {'AECI';'AECJ'};
case 'PM10'
   var_list = {'ASO4J';'ASO4I';'ANH4J';'ANH4I';'ANO3J';'ANO3I';'AALKJ';'AXYL1J';'AXYL2J';'AXYL3J';...
       'ATOL1J';'ATOL2J';'ATOL3J';'ABNZ1J';'ABNZ2J';'ABNZ3J';'ATRP1J';'ATRP2J';'AISO1J';...
       'AISO2J';'ASQTJ';'AORGCJ';'AECJ';'AECI';'A25J';'ACORS';'ASOIL';...
       'ANAJ';'ACLJ';'ACLI';'ANAK';'ACLK';'ASO4K';'ANH4K';'ANO3K';'AISO3J';'AOLGAJ';...
       'AOLGBJ';'AORGPAJ';'AORGPAI';};
case 'PM25'
   var_list = {'ASO4J';'ASO4I';'ANH4J';'ANH4I';'ANO3J';'ANO3I';'AALKJ';'AXYL1J';'AXYL2J';'AXYL3J';...
    'ATOL1J';'ATOL2J';'ATOL3J';'ABNZ1J';'ABNZ2J';'ABNZ3J';'ATRP1J';'ATRP2J';'AISO1J';...
     'AISO2J';'ASQTJ';'AORGCJ';'AECJ';'AECI';'A25J';... 
     'ANAJ';'ACLJ';'ACLI';'AISO3J';'AOLGAJ';...
      'AOLGBJ';'AORGPAJ';'AORGPAI';};
otherwise
   var_list = { var_nm };
end
   for i_var = 1:numel( var_list )
      var_id = netcdf.inqVarID( file_id, var_list{i_var} );
      var_data = netcdf.getVar( file_id, var_id );
      if i_var == 1
         data = zeros( size( var_data ) );
      end
      data = data + var_data;
   end

netcdf.close( file_id );
data = double( data );
return
