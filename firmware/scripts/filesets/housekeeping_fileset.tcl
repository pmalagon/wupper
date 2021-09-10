set VHDL_FILES [concat $VHDL_FILES \
  housekeeping/xadc_drp.vhd \
  housekeeping/dna.vhd \
  housekeeping/housekeeping_module.vhd \
  housekeeping/i2c_interface.vhd \
  housekeeping/i2c.vhd]


#Kintex ultrascale only
set XCI_FILES_KU [concat $XCI_FILES_KU \
  system_management_wiz_0.xci]

set XCI_FILES_VU37P [concat $XCI_FILES_VU37P \
  system_management_wiz_0.xci]

set XCI_FILES_VU9P [concat $XCI_FILES_VU9P \
  system_management_wiz_0.xci]

#Virtex 7 only
set XCI_FILES_V7 [concat $XCI_FILES_V7 \
  xadc_wiz_0.xci]
  
#Versal only, we need the CIPS block somewhere. For now it only provides the PCIe reset.
set BD_FILES_VERSAL [concat $BD_FILES_VERSAL \
  cips_bd.bd]

