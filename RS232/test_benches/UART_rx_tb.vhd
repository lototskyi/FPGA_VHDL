library ieee;
use ieee.std_logic_1164.all;

entity UART_rx_tb is
end entity;

architecture rtl of UART_rx_tb is

   component UART_rx is
   generic
   (
      DATA_WIDTH  : integer;
      SYS_CLK_FREQ: integer;
      BAUD_RATE   : integer
   );
   port
   (
      clk         : in std_logic;
      rst         : in std_logic;
      
      RS232_Rx    : in std_logic; -- Async signal received from PC
      RxIRQClear  : in std_logic;
      RxIRQ       : out std_logic;
      RxData      : out std_logic_vector(DATA_WIDTH-1 downto 0)
   );
   end component;

   signal clk         : std_logic := '0';
   signal rst         : std_logic;
      
   signal RS232_Rx    : std_logic; -- Async signal received from PC
   signal RxIRQClear  : std_logic;
   signal RxIRQ       : std_logic;
   signal RxData      : std_logic_vector(7 downto 0);
   
   signal PCData      : std_logic_vector(7 downto 0) := x"AA";
begin

   clk <= not clk after 10 ns;

   UUT:UART_rx
   generic map
   (
      DATA_WIDTH   => 8,
      SYS_CLK_FREQ => 50000000,
      BAUD_RATE    => 115200
   )
   port map
   (
      clk         => clk,
      rst         => rst,
      
      RS232_Rx    => RS232_Rx,
      RxIRQClear  => RxIRQClear,
      RxIRQ       => RxIRQ,
      RxData      => RxData
   );

   TestProcess:process
   begin
      rst <= '1';
      RS232_Rx <= '1';
      RxIRQClear <= '0';
      wait for 100 ns;
      rst <= '0';
      wait for 100 ns;
      
      
   
      wait for 50 ns;
      
      wait until rising_edge(clk);
      RxIRQClear <= '1';
      wait until rising_edge(clk);
      RxIRQClear <= '0';
   
      wait;
   end process;
   
end rtl;