library ieee;
use ieee.std_logic_1164.all;

entity UART_tx is
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
end entity;

architecture rtl of UART_tx is

   component Serializer is
   generic
   (
      DATA_WIDTH     : integer;
      DEFAULT_STATE  : std_logic
   );
   port
   (
      clk      : in std_logic;
      rst      : in std_logic;
      
      ShiftEn  : in std_logic;
      Load     : in std_logic;
      Din      : in std_logic_vector(DATA_WIDTH-1 downto 0);
      Dout     : out std_logic
   );
   end component;
   
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
   
   signal BaudClk    : std_logic;
   signal TxPacket   : std_logic_vector(RS232_DATA_BITS+1 downto 0);

begin

   TxPacket <= '1' & TxData & '0'; -- LSB first

   UART_SERIALIZER_INST : Serializer
   generic map
   (
      DATA_WIDTH     => RS232_DATA_BITS + 2,
      DEFAULT_STATE  => '1'
   )
   port map
   (
      clk      => clk,
      rst      => rst,
      
      ShiftEn  => BaudClk,
      Load     => TxStart,
      Din      => TxPacket,
      Dout     => UART_tx_pin
   );

   
   UART_BIT_TIMING_INST : BaudClkGenerator
   generic map
   (
      NUMBER_OF_CLOCKS => RS232_DATA_BITS + 2,
      SYS_CLK_FREQ     => SYS_CLK_FREQ,
      BAUD_RATE        => BAUD_RATE,
		UART_Rx			  => false
   )
   port map
   (
      clk      => clk,
      rst      => rst,
      
      Start    => TxStart,
      BaudClk  => BaudClk,
      Ready    => TxReady
   );


end rtl;