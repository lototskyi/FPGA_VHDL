library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevelModule_tb is
generic 
(
   RS232_DATA_BITS : integer := 8
);
end entity;

architecture rtl of TopLevelModule_tb is

   component TopLevelModule is
   generic
   (
      RS232_DATA_BITS   : integer := 8;
      SYS_CLK_FREQ      : integer := 50000000;
      BAUD_RATE         : integer := 115200
   );
   port
   (
      clk          : in std_logic;
      rst          : in std_logic;
      
      rs232_rx_pin : in std_logic;
      rs232_tx_pin : out std_logic
      
   );
   end component;
   
   signal clk          : std_logic := '0';
   signal rst          : std_logic;
   
   signal rs232_rx_pin : std_logic;
   signal rs232_tx_pin : std_logic;
   
   signal TransmittedData  : std_logic_vector(RS232_DATA_BITS-1 downto 0);
	signal TransmittedToPC  : std_logic_vector(RS232_DATA_BITS-1 downto 0);

begin
   
   clk <= not clk after 10 ns;
   
   UUT : TopLevelModule
   generic map
   (
      RS232_DATA_BITS => RS232_DATA_BITS,
      SYS_CLK_FREQ    => 50000000,
      BAUD_RATE       => 115200
   )
   port map
   (
      clk          => clk,
      rst          => rst,
      
      rs232_rx_pin => rs232_rx_pin,
      rs232_tx_pin => rs232_tx_pin
      
   );
   
   SerialToParallel:process
   begin
      -- Detect Start bit
      wait until falling_edge(rs232_tx_pin);
      -- Waiting until the middle of the start bit
      wait for 4.3 us;
      
      for i in 1 to RS232_DATA_BITS loop
         wait for 8.7 us;
         TransmittedData(i-1) <= rs232_tx_pin;
      end loop;
   
      -- Wait for stop bit
      wait for 8.7 us;
      
      TransmittedToPC <= TransmittedData;
   end process;
   
   TestProcess:process
      
      variable TransmitDataVector : std_logic_vector(RS232_DATA_BITS-1 downto 0);
      
      procedure TRANSMIT_CHAR
      (
         constant TransmitData : in integer
      ) is
      begin
         TransmitDataVector := std_logic_vector(to_unsigned(TransmitData, RS232_DATA_BITS));
      
         rs232_rx_pin <= '0'; -- Start bit
         wait for 8.7 us;
         
         -- Data --
         
         for i in 1 to RS232_DATA_BITS loop
            rs232_rx_pin <= TransmitDataVector(i-1);
            wait for 8.7 us;
         end loop;
         
         rs232_rx_pin <= '1'; -- Stop bit
         wait for 8.7 us;
      end procedure;
      
   begin
      rst <= '1';
      rs232_rx_pin <= '1';
      wait for 100 ns;
      rst <= '0';
      wait for 100 ns;
      
      --TRANSMIT_CHAR(83);
      
    for i in 0 to 255 loop
       TRANSMIT_CHAR(i);
       wait for 20 us;
    end loop;
   
      wait;
   end process;

   
end rtl;