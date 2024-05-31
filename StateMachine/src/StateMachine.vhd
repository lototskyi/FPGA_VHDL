library ieee;
use ieee.std_logic_1164.all;

entity StateMachine is
port
(
   rst	:	in	std_logic; -- From the reset push button
	clk	:	in std_logic; -- 50MHz
	sw		:	in std_logic_vector(3 downto 1);
	led	:	out std_logic_vector(3 downto 1)
);
end entity;

architecture rtl of StateMachine is

component PLL IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC 
	);
end component;

type DataTypeOfSMState is (STATE1, STATE2, STATE3);

signal StateVariable	: DataTypeOfSMState;
signal clk_25Mhz		: std_logic;

begin

	PLL1:PLL
		port map
		(
			areset	=>	not(rst),
			inclk0	=> clk, --50Mhz
			c0			=> clk_25Mhz
		);


	Process1:process(rst, clk_25Mhz)
	begin
		
		if rst = '0' then
			StateVariable <= STATE1;
			led <= "111";
		elsif rising_edge(clk_25Mhz) then
		
			case StateVariable is
				when STATE1 =>
					--led(1) <= '0';	-- Enabled
					--led(2) <= '1'; -- Disabled
					--led(3) <= '1';
					
					led <= "110";
					
					if sw(1) = '0' then
						StateVariable <= STATE2;
					end if;
					
				when STATE2 =>
					led <= "101";
					
					if sw(2) = '0' then
						StateVariable <= STATE3;
					end if;
					
				when STATE3 =>
					led <= "011";
					
					if sw(3) = '0' then
						StateVariable <= STATE1;
					end if;
					
				when others =>
					StateVariable <= STATE1;

			end case;
			
		end if;
		
	end process;

end rtl;