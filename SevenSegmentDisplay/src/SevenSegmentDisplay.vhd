library ieee;
use ieee.std_logic_1164.all;

entity SevenSegmentDisplay is
port
(
	rst	: in std_logic;
	clk	: in std_logic;
	
	sw1	: in std_logic; --SW1 is asserted low
	
	K		: out std_logic_vector(6 downto 0); -- segments a...g
	Dp		: out std_logic;
	
	A		: out std_logic_vector(3 downto 0)
);

end entity;

architecture rtl of SevenSegmentDisplay is

type StateMachineType is (DIGIT_1, DIGIT_2, DIGIT_3, DIGIT_4);

constant DebouncePeriod		: integer := 2500000;

signal DebounceCount			: integer;

signal Sync						: std_logic_vector(1 downto 0);
signal SW1_Synced 			: std_logic;
signal SW1_Debounced 		: std_logic;

signal K_Int					: std_logic_vector(6 downto 0);

signal SMState					: StateMachineType;

signal SW1_Debounced_delay : std_logic;
signal FallingEdgeOnSW1		: std_logic;

signal Digit1					: integer;
signal Digit2					: integer;
signal Digit3					: integer;
signal Digit4					: integer;

signal PeriodCounter			: integer;

signal NumberToDisplay		: integer;

begin
	Dp <= '1';
	K <= not(K_Int);
	SW1_Synced <= Sync(1);

	SynchroniseSW1:process(rst, clk)
	begin
		if rst='0' then
			Sync <= "11";
		elsif rising_edge(clk) then
			Sync(0) <= sw1;
			Sync(1) <= Sync(0);
		end if;
		
	end process;
	
	DebounceProcess:process(rst, clk)
	begin
		if rst='0' then
			DebounceCount <= 0;
			SW1_Debounced <= '1'; -- switch is diasserted
		elsif rising_edge(clk) then
			if SW1_Synced = '0' then
				-- switch has been activated
				if DebounceCount < DebouncePeriod then
					DebounceCount <= DebounceCount + 1;
				end if;
			else
				-- switch has been de-activated
				if DebounceCount > 0 then
					DebounceCount <= DebounceCount - 1;
				end if;
			end if;
			
			if DebounceCount = DebouncePeriod then
				SW1_Debounced <= '0';
			elsif DebounceCount=0 then
				SW1_Debounced <= '1';
			end if;
		end if;
		
	end process;
	
	DetectButtonFallingEdge:process(rst, clk)
	begin
		if rst='0' then
			SW1_Debounced_delay <= '1';
			FallingEdgeOnSW1 <= '0';
		elsif rising_edge(clk) then
			SW1_Debounced_delay <= SW1_Debounced;
			
			if SW1_Debounced = '0' and SW1_Debounced_delay = '1' then
				FallingEdgeOnSW1 <= '1';
			else
				FallingEdgeOnSW1 <= '0';
			end if;
		end if;
		
	end process;
	
	CountButtonPresses:process(rst, clk)
	begin
		if rst='0' then
			Digit1 <= 0;
			Digit2 <= 0;
			Digit3 <= 0;
			Digit4 <= 0;
		elsif rising_edge(clk) then
			if FallingEdgeOnSW1='1' then
			
				if Digit1 < 9 then
					Digit1 <= Digit1 + 1;
				else
					Digit1 <= 0;
					
					if Digit2 < 9 then
						Digit2 <= Digit2 + 1;
					else
						Digit2 <= 0;
						
						if Digit3 < 9 then
							Digit3 <= Digit3 + 1;
						else
							Digit3 <= 0;
					
							if Digit4 < 9 then
								Digit4 <= Digit4 + 1;
							else
								Digit4 <= 0;
							end if;
					
						end if;
						
					end if;
					
				end if;
			end if;
		end if;
		
	end process;
	
	-- K(0) -> Seg a
	-- K(1) -> Seg b
	-- K(2) -> Seg c
	-- ..
	-- K(6) -> Seg g
	
	Decoder:process(rst, clk)
	begin
		if rst='0' then
			K_Int <= "0000000";
		elsif rising_edge(clk) then
			case NumberToDisplay is
				when 0 => K_Int <= "0111111";
				when 1 => K_Int <= "0000110";
				when 2 => K_Int <= "1011011";
				when 3 => K_Int <= "1001111";
				when 4 => K_Int <= "1100110";
				when 5 => K_Int <= "1101101";
				when 6 => K_Int <= "1111101";
				when 7 => K_Int <= "0000111";
				when 8 => K_Int <= "1111111";
				when 9 => K_Int <= "1100111";
				when others => K_Int <= "0000000";
			end case;
		end if;
		
	end process;
	
	StateMachineProcess:process(rst, clk)
	begin
		if rst='0' then
			SMstate <= DIGIT_1;
			A <= "1111";
			PeriodCounter <= 0;
		elsif rising_edge(clk) then
			
			case SMState is
				when DIGIT_1 => 
					A <= "1110";
					NumberToDisplay <= Digit1;
					
					PeriodCounter <= PeriodCounter + 1;
					
					if PeriodCounter = 50000 then
						SMState <= DIGIT_2;
						PeriodCounter <= 0;
					end if;
					
				when DIGIT_2 => 
					A <= "1101";
					NumberToDisplay <= Digit2;
					
					PeriodCounter <= PeriodCounter + 1;
					
					if PeriodCounter = 50000 then
						SMState <= DIGIT_3;
						PeriodCounter <= 0;
					end if;
				when DIGIT_3 => 
					A <= "1011";
					NumberToDisplay <= Digit3;
					
					PeriodCounter <= PeriodCounter + 1;
					
					if PeriodCounter = 50000 then
						SMState <= DIGIT_4;
						PeriodCounter <= 0;
					end if;
				when DIGIT_4 => 
					A <= "0111";
					NumberToDisplay <= Digit4;
					
					PeriodCounter <= PeriodCounter + 1;
					
					if PeriodCounter = 50000 then
						SMState <= DIGIT_1;
						PeriodCounter <= 0;
					end if;
				when others => 
					SMstate <= DIGIT_1;
			end case;
			
		end if;
		
	end process;
	
	
	
end rtl;