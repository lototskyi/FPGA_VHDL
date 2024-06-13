library ieee;
use ieee.std_logic_1164.all;

entity UART_rx is
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
end entity;

architecture rtl of UART_rx is

   component Synchroniser is
   generic
   (
      IDLE_STATE : std_logic
   );
   port
   (
      clk      : in std_logic;
      rst      : in std_logic;
      Async    : in std_logic;
      Synced   : out std_logic
   );
   end component;
   
   component ShiftRegister is
   generic
   (
      CHAIN_LENGTH      : integer;
      SHIFT_DIRECTION   : character -- 'L' - shift to the left, 'R' - to the right
   );
   port
   (
      clk         : in std_logic;
      rst         : in std_logic;
      ShiftEnable : in std_logic;
      Din         : in std_logic;
      Dout        : out std_logic_vector(CHAIN_LENGTH-1 downto 0)
   );
   end component;
   
   component BaudClkGenerator is
   generic
   (
      NUMBER_OF_CLOCKS : integer;
      SYS_CLK_FREQ     : integer;
      BAUD_RATE        : integer;
      UART_Rx          : boolean
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
   
   type SMDataType is (IDLE, COLLECT_RS232_DATA, ASSERT_IRQ);
   
   signal SMState          : SMDataType;
   signal RS232_Rx_Synced  : std_logic;
   signal Start            : std_logic;
   signal BaudClk          : std_logic;
   signal Ready            : std_logic;
   signal FallingEdge      : std_logic;
   signal RS232_Rx_Synced_delayed: std_logic;

begin
   
   Sync_Rx:Synchroniser
   generic map
   (
      IDLE_STATE => '1'
   )
   port map
   (
      clk      => clk,
      rst      => rst,
      Async    => RS232_Rx,
      Synced   => RS232_Rx_Synced
   );
   
   ShiftRegister_Rx:ShiftRegister
   generic map
   (
      CHAIN_LENGTH      => DATA_WIDTH,
      SHIFT_DIRECTION   => 'R' -- LSB first
   )
   port map
   (
      clk         => clk,
      rst         => rst,
      ShiftEnable => BaudClk,
      Din         => RS232_Rx_Synced,
      Dout        => RxData
   );
   
   BaudClkGenerator_Rx:BaudClkGenerator
   generic map
   (
      NUMBER_OF_CLOCKS => DATA_WIDTH + 1, -- start bit + data
      SYS_CLK_FREQ     => SYS_CLK_FREQ,
      BAUD_RATE        => BAUD_RATE,
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
   
   FallingEdgeDetect:process(rst, clk)
   begin
      if rst='1' then
         FallingEdge <= '0';
         RS232_Rx_Synced_delayed <= '1';
      elsif rising_edge(clk) then
         RS232_Rx_Synced_delayed <= RS232_Rx_Synced;
         
         if RS232_Rx_Synced='0' and RS232_Rx_Synced_delayed='1' then
            FallingEdge <= '1';
         else
            FallingEdge <= '0';
         end if;
      end if;
   end process;
   
   RxStateMachine:process(rst, clk)
   begin
      if rst='1' then
         Start <= '0';
         RxIRQ <= '0';
         SMState <= IDLE;
      elsif rising_edge(clk) then
         if RxIRQClear='1' then
            RxIRQ <= '0';
         end if;
      
         case SMState is
            when IDLE => 
               if FallingEdge='1' then
                  Start <= '1';
               else
                  Start <= '0';
               end if;
               
               if Ready='0' then
                  SMState <= COLLECT_RS232_DATA;
               end if;
            when COLLECT_RS232_DATA =>
               Start <= '0';
               if Ready='1' then
                  SMState <= ASSERT_IRQ;
               end if;
            when ASSERT_IRQ =>
               RxIRQ <= '1';
               SMState <= IDLE;
            when others => 
               SMState <= IDLE;
         end case;
      end if;
   end process;
   
end rtl;