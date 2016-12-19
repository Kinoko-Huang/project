;*****************************************************
;Missions:
;   1. Read ggas data of RCP4.5 forcing field
;   2. Calculate 2026-2035 mean
;   3. Draw the Monthly Timeseries of CO2
;                   Zhenning Li
;                    2015-01-22
;*****************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;================================================
;Variables List:
;================================================



begin
    ;Data series
    g_filetime=(/"018","019","020","021","022","023","024","025"/)
    
    ;AE6 PM25 species
    ;g_species_PM25=(/"AECI","AECJ","ASO4I","ASO4J","ANO3I","ANO3J","APOCI","APOCJ","AOTHRJ","ANAJ","ACLI","ACLJ","ANH4I","ANH4J","APNCOMI","APNCOMJ","AALJ","ACAJ","AFEJ","ASIJ","ATIJ","AMGJ","AKJ","AMNJ","AALKJ","AXYL1J","AXYL2J","AXYL3J","ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J","ASQTJ","AORGCJ","AISO3J","AOLGAJ","AOLGBJ"/)
    
    ;AE5 PM25 species
    g_species_PM25=(/"AECI","AECJ","ASO4I","ASO4J","ANO3I","ANO3J","AORGPAI","AORGPAJ","A25J","ANAJ","ACLI","ACLJ","ANH4I","ANH4J","AALKJ","AXYL1J","AXYL2J","AXYL3J","ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J","ASQTJ","AORGCJ","AISO3J","AOLGAJ","AOLGBJ"/)
    
    ;AE6 POC
    ;g_species=(/"APOCI","APOCJ"/)

    ;AE5 POC
    ;g_species=(/"AORGPAI","AORGPAJ"/)

    ;SOA
    ;g_species=(/"AALKJ","AXYL1J","AXYL2J","ATOL1J","ATOL2J","ATOL3J","ABNZ1J","ABNZ2J","ABNZ3J","ATRP1J","ATRP2J","AISO1J","AISO2J","AISO3J","ASQTJ","AORGCJ","AOLGAJ","AOLGBJ"/)

    ;SO4
    g_species_SO4=(/"ASO4J","ASO4I"/)

    ;NO3
    g_species_NO3 = (/"ANO3J","ANO3I"/)

    ;NH4
    g_species_NH4 = (/"ANH4J","ANH4I"/)

    ;O3
    g_species_O3 = (/"ANH4J","ANH4I"/)

    ;Output species name
    out_species_name_PM25="PM25"

    ;Input file stream
    ;data_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae6/cmaq/201501/CCTM_V5g_Linux2_x86_64pg_mpich2.CONC.2015"+g_filetime
    data_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae5/cmaq/201501/CCTM_V5g_ebi_cb05cl_ae5_aq_mpich2.CONC.2015"+g_filetime
    
    ;Output file stream
    ;out_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae6/cmaq/201501/CCTM_V5g_Linux2_x86_64pg_mpich2.remodified.2015"+g_filetime+".nc"
    out_file_name="/disk/scratch/huangyeq/test_data/AE-test/ae5/cmaq/201501/CCTM_V5g_ebi_cb05cl_ae5_aq_mpich2.remodified.2015"+g_filetime+".nc"

do ii=0,dimsizes(g_filetime)-1

;---------------Read data-------------------
    print("Preparing reading...")
    ctrl_in=addfile(data_file_name(ii),"r")
    ctrl_var_PM25 = ctrl_in->$g_species_PM25(0)$(0:23,:,:,:)    
    ctrl_var_SO4 = ctrl_in->$g_species_SO4(0)$(0:23,:,:,:)
    ctrl_var_NO3 = ctrl_in->$g_species_NO3(0)$(0:23,:,:,:)
    ctrl_var_NH4 = ctrl_in->$g_species_NH4(0)$(0:23,:,:,:)
    ctrl_var_O3 = ctrl_in->$g_species_O3(0)$(0:23,:,:,:)
    ctrl_tflag = ctrl_in->TFLAG(0:23,0,:)               
    do jj=1,dimsizes(g_species_PM25)-1
        print("Reading Day"+g_filetime(ii)+" "+g_species_PM25(jj))
        ctrl_var_PM25 = ctrl_var_PM25+ctrl_in->$g_species_PM25(jj)$(0:23,:,:,:)
    end do

    do jj=1,dimsizes(g_species_SO4)-1
        print("Reading Day"+g_filetime(ii)+" "+g_species_SO4(jj))
        ctrl_var_SO4 = ctrl_var_SO4+ctrl_in->$g_species_SO4(jj)$(0:23,:,:,:)
    end do

    do jj=1,dimsizes(g_species_NO3)-1
        print("Reading Day"+g_filetime(ii)+" "+g_species_NO3(jj))
        ctrl_var_NO3 = ctrl_var_NO3+ctrl_in->$g_species_NO3(jj)$(0:23,:,:,:)
    end do

    do jj=1,dimsizes(g_species_NH4)-1
        print("Reading Day"+g_filetime(ii)+" "+g_species_NH4(jj))
        ctrl_var_NH4 = ctrl_var_NH4+ctrl_in->$g_species_NH4(jj)$(0:23,:,:,:)
    end do

;---------------Write data-------------------
    print("Day"+g_filetime(ii)+" Writing...")
;Get dimsize
    dims=dimsizes(ctrl_var_PM25(0,:,:,:))
    nlvl=dims(0)
    nrow=dims(1)
    ncol=dims(2)
    
;Set fileoption    
    system("rm "+out_file_name(ii)+" >& /dev/null")
    fout = addfile(out_file_name(ii) ,"c")  ; open output netCDF file
    setfileoption(fout,"DefineMode",True)

;Set All field attribution
    fileAtt     = True
    fileAtt@creation_date=systemfunc("date")
    fileattdef(fout,fileAtt)

;Define Coordinate
    dimNames    =(/ctrl_var_PM25!0,ctrl_var_PM25!1,ctrl_var_PM25!2,ctrl_var_PM25!3,ctrl_tflag!1/)
    dimSizes    =(/-1,nlvl,nrow,ncol,2/)
    dimUnlim    =(/True,False,False,False,False/)
    filedimdef(fout,dimNames,dimSizes,dimUnlim)
;Define var, type and dim
    filevardef(fout,out_species_name_PM25,typeof(ctrl_var_PM25),getvardims(ctrl_var_PM25))
    filevardef(fout,"TSTEP",typeof(ctrl_tflag),getvardims(ctrl_tflag))
    filevardef(fout,"SO4",typeof(ctrl_var_PM25),getvardims(ctrl_var_SO4))
    filevardef(fout,"NO3",typeof(ctrl_var_PM25),getvardims(ctrl_var_NO3))
    filevardef(fout,"NH4",typeof(ctrl_var_PM25),getvardims(ctrl_var_NH4))
    filevardef(fout,"O3",typeof(ctrl_var_PM25),getvardims(ctrl_var_O3))

;Define Attribute
    filevarattdef(fout,out_species_name_PM25,ctrl_var_PM25)
    filevarattdef(fout,"TSTEP",ctrl_tflag)
    filevarattdef(fout,"SO4",ctrl_var_SO4)
    filevarattdef(fout,"NO3",ctrl_var_NO3)
    filevarattdef(fout,"NH4",ctrl_var_NH4)
    filevarattdef(fout,"O3",ctrl_var_O3)
    
    fout->PM25=(/ctrl_var_PM25/)
    fout->TSTEP=(/ctrl_tflag/)
    fout->O3=(/ctrl_var_O3/)
    fout->SO4=(/ctrl_var_SO4/)
    fout->NO3=(/ctrl_var_NO3/)
    fout->NH4=(/ctrl_var_NH4/)
    delete([/ctrl_var_PM25, ctrl_var_SO4, ctrl_var_NO3, ctrl_var_NH4, ctrl_var_O3, fout/])
    print("Day"+g_filetime(ii)+" Done!")

end do
end




