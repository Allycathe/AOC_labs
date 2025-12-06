## =======================================================
## RELOJ DE 100 MHz (oscilador principal)
## =======================================================
set_property PACKAGE_PIN E3 [get_ports {ck}]
set_property IOSTANDARD LVCMOS33 [get_ports {ck}]
create_clock -period 10.000 -name sys_clk -waveform {0 5} [get_ports {ck}]

## =======================================================
## BOTÓN BTN0 ? señal 'inicio' (genera el pulso)
## =======================================================
set_property PACKAGE_PIN U18 [get_ports {inicio}]
set_property IOSTANDARD LVCMOS33 [get_ports {inicio}]

## =======================================================
## SWITCH SW0 ? señal 'x'
## =======================================================
set_property PACKAGE_PIN J15 [get_ports {x}]
set_property IOSTANDARD LVCMOS33 [get_ports {x}]

## =======================================================
## LED0 ? señal 'z'
## =======================================================
set_property PACKAGE_PIN H17 [get_ports {z}]
set_property IOSTANDARD LVCMOS33 [get_ports {z}]
