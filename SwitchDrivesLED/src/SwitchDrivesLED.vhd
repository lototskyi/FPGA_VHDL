library ieee;
use ieee.std_logic_1164.all;


entity SwitchDrivesLED is
port
(
	sw1	:	in std_logic;
	led1	:	out std_logic;
	led3	:	out std_logic
);
end entity;

architecture rtl of SwitchDrivesLED is

begin

	led1 <= sw1;
	led3 <= '1';

end rtl;