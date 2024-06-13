library ieee;
use ieee.std_logic_1164.all;

entity TopLevelModule is
generic
(
   RS232_DATA_BITS   : integer := 8;
   SYS_CLK_FREQ      : integer := 50000000;
   BAUD_RATE         : integer := 115200
);
port
(
   clk         : in std_logic;
   rst         : in std_logic;
   
   rs232_rx_pin : in std_logic;
   rs232_tx_pin : out std_logic
   
);
end entity;

architecture rtl of TopLevelModule is

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
      rst         : in std_logic; -- Asserted LOW
      
      TxStart     : in std_logic;
      TxData      : in std_logic_vector(RS232_DATA_BITS-1 downto 0);
      
      UART_tx_pin : out std_logic;
      TxReady     : out std_logic
   );
   end component;
   
   type SMType is (IDLE, START_TRANSMITTER);
   
   signal SMState : SMType;
   signal TxStart : std_logic;
   signal TxReady : std_logic;
   signal RxIRQ   : std_logic;
   signal RxData  : std_logic_vector(RS232_DATA_BITS-1 downto 0);

begin
   
   UART_Receiver : UART_rx
   generic map
   (
      DATA_WIDTH   => RS232_DATA_BITS,
      SYS_CLK_FREQ => SYS_CLK_FREQ,
      BAUD_RATE    => BAUD_RATE
   )
   port map
   (
      clk         => clk,
      rst         => not(rst),
      
      RS232_Rx    => rs232_rx_pin,
      RxIRQClear  => TxStart,
      RxIRQ       => RxIRQ,
      RxData      => RxData
   );
   
   UART_Transmitter : UART_tx
   generic map
   (
      RS232_DATA_BITS   => RS232_DATA_BITS,
      SYS_CLK_FREQ      => SYS_CLK_FREQ,
      BAUD_RATE         => BAUD_RATE
   )
   port map
   (
      clk         => clk,
      rst         => not(rst),
      
      TxStart     => TxStart,
      TxData      => RxData,
      
      UART_tx_pin => rs232_tx_pin,
      TxReady     => TxReady
   );
   
   StateMachineProcess:process(clk, rst)
   begin
      
      if rst='0' then
      
         SMState <= IDLE;
         TxStart <= '0';
      
      elsif rising_edge(clk) then
      
         case SMState is
            when IDLE =>
               
               if RxIRQ='1' and TxReady='1' then
                  SMState <= START_TRANSMITTER;
                  TxStart <= '1';
               end if;
               
            when START_TRANSMITTER =>
               TxStart <= '0';
               SMState <= IDLE;
            when others =>
               SMState <= IDLE;
         end case;
      
      end if;
      
   end process;
   
end rtl;