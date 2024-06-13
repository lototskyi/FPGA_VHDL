library ieee;
use ieee.std_logic_1164.all;

entity BaudClkGenerator_tb is

end entity;

architecture rtl of BaudClkGenerator_tb is

   component BaudClkGenerator is
   generic
   (
      NUMBER_OF_CLOCKS : integer;
      SYS_CLK_FREQ     : integer;
      BAUD_RATE        : integer;
		UART_Rx			  : boolean
   );
   port
   (
      clk      : in std_logic; -- 50MHz
      rst      : in std_logic;
      
      Start    : in std_logic;
      BaudClk  : out std_logic;
      Ready    : out std_logic
   );
   end component;

   signal clk  : std_logic := '0';
   signal rst  : std_logic;
   signal Start   : std_logic;
   signal BaudClk : std_logic;
   signal Ready   : std_logic;
   
begin
   
   clk <= not clk after 10 ns; -- generate clock of 50MHz, 20ns period/2
   
   UUT : BaudClkGenerator
   generic map
   (
      NUMBER_OF_CLOCKS => 10,
      SYS_CLK_FREQ     => 50000000,
      BAUD_RATE        => 115200,
      UART_Rx          => true
   )
   port map
   (
      clk      => clk,
      rst      => rst,
      
      Start    => Start,
      BaudClk  => BaudClk,
      Ready    => Ready
   );
   
   main:process
   
   begin
      rst <= '1';
      Start <= '0';
      wait for 100 ns;
      rst <= '0';
      
      wait until rising_edge(clk);
      Start <= '1';
      wait until rising_edge(clk);
      Start <= '0';
      
      wait;
   end process;
   
   
end rtl;