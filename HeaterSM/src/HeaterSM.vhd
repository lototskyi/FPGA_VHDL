library ieee;
use ieee.std_logic_1164.all;

entity HeaterSM is
	port(
		Clk		  : in  std_logic;
		Rst		  : in  std_logic;
		Sw			  : in  std_logic;
		Temp		  : in  std_logic;
		WaterLevel : in  std_logic;
		Heater	  : out std_logic;
		RedLED	  : out std_logic;
		GreenLED   : out std_logic;
		ErrorLED	  : out std_logic
	);
end entity;

architecture rtl of HeaterSM is

	type FSMStateType is (IDLE, HEATING, READY, ERROR);
	signal State:FSMStateType;

begin
	
	FSMProcess:process(Rst, Clk)
	begin
		if Rst='1' then
		
			GreenLED <= '0';
			RedLED <= '0';
			Heater <= '0';
			State <= IDLE;
		
		elsif rising_edge(Clk) then
			
			case State is
				when IDLE =>
					GreenLED <= '0';
					RedLED   <= '0';
					Heater   <= '0';
					ErrorLED <= '0';
					
					if Sw='1' then
						State <= HEATING;
					end if;
				when HEATING =>
					RedLED <= '1';
					Heater <= '1';
					
					if Sw='0' then
						State <= IDLE;
					elsif Temp='1' then
						State <= READY;
					end if;
					
					if waterLevel='1' then
						State <= ERROR;
					end if;
					
				when READY =>
					RedLED   <= '0';
					GreenLED <= '1';
					Heater   <= '0';
					
					if Sw='0' then
						State <= IDLE;
					end if;
					
				when ERROR =>
					RedLED   <= '0';
					GreenLED <= '0';
					Heater   <= '0';
					ErrorLED <= '1';
					
					if Sw='0' then
						State <= IDLE;
					elsif WaterLevel='0' then
						State <= HEATING;
					end if;
					
				when others => State <= IDLE;
			end case;
				
		end if;
	end process;

end rtl;