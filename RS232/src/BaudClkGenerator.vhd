library ieee;
use ieee.std_logic_1164.all;

entity BaudClkGenerator is
generic
(
   NUMBER_OF_CLOCKS : integer;
   SYS_CLK_FREQ     : integer;
   BAUD_RATE        : integer;
	UART_Rx			  : boolean -- True if BaudClkGenerator is used in UART_Rx module, false otherwise
);
port
(
   clk      : in std_logic; -- 50MHz
   rst      : in std_logic;
   
   Start    : in std_logic;
   BaudClk  : out std_logic;
   Ready    : out std_logic
);
end entity;

architecture rtl of BaudClkGenerator is

constant BIT_PERIOD 			: integer := SYS_CLK_FREQ / BAUD_RATE;
constant HALF_BIT_PERIOD	: integer := SYS_CLK_FREQ / (2*BAUD_RATE);

signal BitPeriodCounter		: integer range 0 to BIT_PERIOD;
signal ClocksLeft				: integer range 0 to NUMBER_OF_CLOCKS;

begin

   BitPeriodProcess:process(rst, clk)
   begin
      if rst='1' then
         BaudClk <= '0';
         BitPeriodCounter <= 0;
      elsif rising_edge(clk) then
         if ClocksLeft > 0 then
            if BitPeriodCounter=BIT_PERIOD then
               BaudClk <= '1';
               BitPeriodCounter <= 0;
            else
               BaudClk <= '0';
               BitPeriodCounter <= BitPeriodCounter + 1;
            end if;
         else
            BaudClk <= '0';
				if Uart_Rx=true then
					-- in the case of receiver mode, we load the BitPeriodCounter with BIT_PERIOD / 2 so that the first
					-- BaudClk pulse occures 1/2 bit period after asserting the Start port
					BitPeriodCounter <= HALF_BIT_PERIOD;
				else
					-- in the case of transmitter mode, we load the BitPeriodCounter with 0 so that the first
					-- BaudClk pulse occures 1 bit period after asserting the Start port
					BitPeriodCounter <= 0;
				end if;
         end if;

      end if;
   end process;
   
   BeginOrEndBaudClk:process(rst, clk)
   begin
      if rst='1' then
         ClocksLeft <= 0;
      elsif rising_edge(clk) then
         
         if Start='1' then
            ClocksLeft <= NUMBER_OF_CLOCKS;
         elsif BaudClk = '1' then
            ClocksLeft <= ClocksLeft - 1;
         end if;
      end if;
   end process;
   
   GenerateReady:process(rst, clk)
   begin
      if rst='1' then
         Ready <= '1';
      elsif rising_edge(clk) then
         if Start='1' then
            Ready <= '0';
         elsif ClocksLeft=0 then
            Ready <= '1';
         
         end if;
         
      end if;
   end process;

end rtl;