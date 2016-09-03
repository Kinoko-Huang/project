#!/bin/csh -x

# cat gts, bc_bogus and tc_bogus files                                   

  set DERIVED_DATA_ROOT=${work_root}/gts_decoder/derived_data
  set BEG_CYMDH=${INIT_Y}-${INIT_M}-${INIT_D}_${INIT_H}

   set little_r_input = ${DERIVED_DATA_ROOT}/obs:${BEG_CYMDH}

# no bc_bogus
#   set file1 = ${WPS_root}/obs:${BEG_CYMDH}
   set file2 = ${work_root}/TC_BOGUS/derived_data/wrftclittler.tcbogus
#   cat $file1 >> $little_r_input
   cat $file2 >> $little_r_input




