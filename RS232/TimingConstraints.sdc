create_clock -name Clk_50MHz -period 20 [get_ports {clk}]
set_false_path -from [get_ports {rs232_rx_pin rst}]
set_false_path -to [get_ports {rs232_tx_pin}]