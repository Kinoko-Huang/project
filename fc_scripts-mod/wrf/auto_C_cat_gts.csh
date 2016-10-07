#!/bin/csh -f
set echo

# cat GTS and BC bogus files

set DERIVED_DATA_ROOT=${work_root}/gts_decoder/derived_data
set dat_dir = ${DERIVED_DATA_ROOT} 
set INIT_TIME=${INIT_Y}${INIT_M}${INIT_D}${INIT_H}
set END_TIME=${END_Y}${END_M}${END_D}${INIT_H}
set cymdh = ${INIT_TIME}

while ( ${cymdh}<= ${END_TIME} )
  set y = `echo $cymdh | cut -c1-4`
  set m = `echo $cymdh | cut -c5-6`
  set d = `echo $cymdh | cut -c7-8`
  set h = `echo $cymdh | cut -c9-10`

  set little_r_input = obs:${y}-${m}-${d}_${h} # Xie Dec 2009

  set cymdh1 = `./advance_cymdh $cymdh 1`
  set cymdh2 = `./advance_cymdh $cymdh 2`
  
  set ymdh = `echo $cymdh | cut -c3-`

  set gts_files = `ls -1 ${dat_dir}/${cymdh}5?.*`
  echo gts_files
  set nfiles = $#gts_files
  echo nfiles

  if ( $nfiles >= 1 ) then

       set file1 = ${dat_dir}/${cymdh}5?.*
    if (${cymdh}< ${END_TIME} ) then
       set file2 = ${dat_dir}/${cymdh1}5?.*
       set file3 = ${dat_dir}/${cymdh2}5?.*
     else
       set file2 = 
       set file3 =
     endif

#  else
#     set file1 =
#     set file2 =
#     set file3 =

#  endif

  set file5 = ${little_r_input}
  
  cat $file1 $file2 $file3 > $little_r_input
  endif

  set cymdh  = `./advance_cymdh $cymdh 6`
  
end


rm ${dat_dir}/little_r_in_*
mv obs:*   ${dat_dir}/

# usually the resultant files are very large 
# and we avoid keeping a backup here.
