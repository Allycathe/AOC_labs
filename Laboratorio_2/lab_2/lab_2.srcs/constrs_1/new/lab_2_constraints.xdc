set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { in_z }];  
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { in_y }]; 
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { in_x }];  
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { segments[0] }]; # seg_a
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { segments[1] }]; # seg_b
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { segments[2] }]; # seg_c
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { segments[3] }]; # seg_d
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { segments[4] }]; # seg_e
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { segments[5] }]; # seg_f
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { segments[6] }]; # seg_g

set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { Dout8 }]; 
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { Dout9 }]; 
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { Dout10 }]; 
