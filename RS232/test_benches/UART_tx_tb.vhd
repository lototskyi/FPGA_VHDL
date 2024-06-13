library ieee;
use ieee.std_logic_1164.all;

entity UART_tx_tb is
generic
(
   RS232_DATA_BITS   : integer := 8;
   SYS_CLK_FREQ      : integer := 50000000;
   BAUD_RATE         : integer := 115200 -- Bit period is 8.7us
);

end entity;

architecture rtl of UART_tx_tb is

   component UART_tx is
   generic
   (
      RS232_DATA_BITS   : integer;
      SYS_CLK_FREQ      : integer;
      BAUD_RATE         : integer
   );
   port
   (
      clk         : in std_logic; -- 50MHz
      rst         : in std_logic;
      
      TxStart     : in std_logic;
      TxData      : in std_logic_vector(RS232_DATA_BITS-1 downto 0);
      
      UART_tx_pin : out std_logic;
      TxReady     : out std_logic
   );
   end component;

   signal clk         : std_logic := '0'; -- 50MHz
   signal rst         : std_logic;
      
   signal TxStart     : std_logic;
   signal TxData      : std_logic_vector(RS232_DATA_BITS-1 downto 0);
      
   signal UART_tx_pin : std_logic;
   signal TxReady     : std_logic;

begin

   clk <= not clk after 10 ns;

   UART_tx_Inst : UART_tx
   generic map
   (
      RS232_DATA_BITS   => RS232_DATA_BITS,
      SYS_CLK_FREQ      => SYS_CLK_FREQ,
      BAUD_RATE         => BAUD_RATE
   )
   port map
   (
      clk         => clk,
      rst         => rst,
      
      TxStart     => TxStart,
      TxData      => TxData,
      
      UART_tx_pin => UART_tx_pin,
      TxReady     => TxReady
   );
   
   TestProcess:process
   begin
      rst <= '1';
      TxStart <= '0';
      TxData <= (others => '0');
      wait for 100 ns;
      rst <= '0';
      wait for 100 ns;
      
      wait until rising_edge(clk);
      TxData <= x"AA";
      TxStart <= '1';
      wait until rising_edge(clk);
      TxStart <= '0';
      TxData <= (others => '0');
      
      wait;
   
   end process;

end rtl;