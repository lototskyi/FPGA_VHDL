

create_clock -name InputOscilator -period 20 [get_ports {clk}]

set_false_path -from [get_ports {sw1 rst}]

set_false_path -to [get_ports {led[*]}]