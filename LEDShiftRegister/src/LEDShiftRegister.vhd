library ieee;
use ieee.std_logic_1164.all;


entity LEDShiftRegister is
port
(
	rst	: in std_logic; -- Reset button, asserted low.
	clk	: in std_logic; -- 50MHz
	
	sw1	: in std_logic; -- Asserted low
	led	: out std_logic_vector(1 to 4)
);
end entity;

architecture rtl of LEDShiftRegister is
	
	constant DebouncePeriod	:	integer:=2500000;

	signal ButtonPressed		: std_logic;
	signal ShiftReg			: std_logic_vector(1 to 4);
	signal sync					: std_logic_vector(1 downto 0);
	signal delayed_switch	: std_logic;
	signal Counter				: integer;
	signal DebouncesSw1		: std_logic;

begin

	led <= ShiftReg;

	SyncProcess:process(rst, clk)
	begin
	
		if rst='0' then
			sync <= "11";
			
		elsif rising_edge(clk) then
			sync(0) <= sw1;
			sync(1) <= sync(0);
		end if;
	
	end process;
	
	DebounceProcess:process(rst, clk)
	begin
	
		if rst='0' then
			Counter <= 0;
			DebouncesSw1 <= '1';
		elsif rising_edge(clk) then
			if sync(1) = '0' then
				-- If the switch is in the active state
				if Counter < DebouncePeriod then
					Counter <= Counter + 1;
				end if;
			else
				if Counter > 0 then
					Counter <= Counter - 1;
				end if;
			end if;
			
			if Counter = DebouncePeriod then
				DebouncesSw1 <= '0';
			elsif Counter = 0 then
				DebouncesSw1 <= '1';
			end if;
			
		end if;
	
	end process;
	
	ButtonPressDetect:process(rst, clk)
	begin
	
		if rst='0' then
			delayed_switch <= '1';
			ButtonPressed <= '0';
		elsif rising_edge(clk) then
			-- prevent contnious shifting when button is pressed for a long time
			delayed_switch <= DebouncesSw1;
		
			if DebouncesSw1='0' and delayed_switch='1' then
				ButtonPressed <= '1';
			else
				ButtonPressed <= '0';
			end if;
			
		end if;
	
	end process;

	ShiftProcess:process(rst, clk)
	begin
	
		if rst='0' then
			ShiftReg <= "0111";
			
		elsif rising_edge(clk) then
			if ButtonPressed='1' then
				--ShiftReg(2) <= ShiftReg(1);
				--ShiftReg(3) <= ShiftReg(2);
				--ShiftReg(4) <= ShiftReg(3);
				--ShiftReg(1) <= ShiftReg(4);
				
				ShiftReg <= ShiftReg(4) & ShiftReg(1 to 3);
			end if;
		end if;
	
	end process;


end rtl;