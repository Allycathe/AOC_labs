set_property PACKAGE_PIN E3 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -period 10.000 -name sys_clk_pin [get_ports {clk}]

## =========================================================
## BOTONES / SWITCHES (3.3V)
## =========================================================
set_property PACKAGE_PIN M18 [get_ports {btnH}] ; set_property IOSTANDARD LVCMOS33 [get_ports {btnH}] ; # BTNU ? sumar HOME
set_property PACKAGE_PIN P18 [get_ports {btnG}] ; set_property IOSTANDARD LVCMOS33 [get_ports {btnG}] ; # BTND ? sumar GUEST
set_property PACKAGE_PIN J15 [get_ports {rstH}] ; set_property IOSTANDARD LVCMOS33 [get_ports {rstH}] ; # SW0 ? reset HOME
set_property PACKAGE_PIN L16 [get_ports {rstG}] ; set_property IOSTANDARD LVCMOS33 [get_ports {rstG}] ; # SW1 ? reset GUEST
set_property PACKAGE_PIN N17 [get_ports {rstT}] ; set_property IOSTANDARD LVCMOS33 [get_ports {rstT}] ; # BTNC ? reset TIMER

## =========================================================
## LED indicador (tiempo agotado)
## =========================================================
set_property PACKAGE_PIN H17 [get_ports {led}]
set_property IOSTANDARD LVCMOS33 [get_ports {led}]

## =========================================================
## DISPLAY 7 SEGMENTOS (SEGMENTOS)
## =========================================================
# a..g (activo en 0)
set_property PACKAGE_PIN T10 [get_ports {seg[6]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property PACKAGE_PIN R10 [get_ports {seg[5]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN K16 [get_ports {seg[4]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN K13 [get_ports {seg[3]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN P15 [get_ports {seg[2]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN T11 [get_ports {seg[1]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN L18 [get_ports {seg[0]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

## =========================================================
## DISPLAY 7 SEGMENTOS (ANODOS)
## =========================================================
# Orden físico: an[0] = derecha total ... an[7] = izquierda total
# Nuevo significado:
# an[7] = HOME decenas
# an[6] = HOME unidades
# an[5] = TIMER minutos decenas
# an[4] = TIMER minutos unidades
# an[3] = TIMER segundos decenas
# an[2] = TIMER segundos unidades
# an[1] = GUEST decenas
# an[0] = GUEST unidades

set_property PACKAGE_PIN J17 [get_ports {an[0]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN J18 [get_ports {an[1]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN T9 [get_ports {an[2]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN J14 [get_ports {an[3]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
set_property PACKAGE_PIN P14 [get_ports {an[4]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[4]}]
set_property PACKAGE_PIN T14 [get_ports {an[5]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[5]}]
set_property PACKAGE_PIN K2 [get_ports {an[6]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[6]}]
set_property PACKAGE_PIN U13 [get_ports {an[7]}] ; set_property IOSTANDARD LVCMOS33 [get_ports {an[7]}]