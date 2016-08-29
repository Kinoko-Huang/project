#!/bin/csh -f
#
# To replace metoa2met_?days.csh in the future, From Yao Teng
#
foreach flnm (`ls -1 met_em.d01*` )
   set date_str = `echo $flnm | cut -c 12-30`
   mv $flnm ${flnm}.wps
   mv metoa_em.d01.$date_str.nc  $flnm
end
