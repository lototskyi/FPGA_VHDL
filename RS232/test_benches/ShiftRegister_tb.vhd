library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister_tb is
end entity;

architecture rtl of ShiftRegister_tb is

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

   signal clk         : std_logic := '0';
   signal rst         : std_logic;
   signal ShiftEnable : std_logic;
   signal Din         : std_logic;
   signal Dout        : std_logic_vector(7 downto 0);

begin
   
   clk <= not clk after 10 ns;
   
   UUT : ShiftRegister
   generic map
   (
      CHAIN_LENGTH    => 8,
      SHIFT_DIRECTION => 'R'
   )
   port map
   (
      clk         => clk,
      rst         => rst,
      ShiftEnable => ShiftEnable,
      Din         => Din,
      Dout        => Dout
   );
   
   TestProcess:process
   begin
      
      rst <= '1';
      ShiftEnable <= '0';
      wait for 100 ns;
      rst <= '0';
      Din <= '0';
      wait for 100 ns;
      
      -- 0x51
      
      Din <= '1';
      wait for 4.3 us;
      wait until rising_edge(clk);
      ShiftEnable <= '1';
      wait until rising_edge(clk);
      ShiftEnable <= '0';
      wait for 4.3 us;
      
      for i in 0 to 2 loop
         Din <= '0';
         wait for 4.3 us;
         wait until rising_edge(clk);
         ShiftEnable <= '1';
         wait until rising_edge(clk);
         ShiftEnable <= '0';
         wait for 4.3 us;
      end loop;
      
      Din <= '1';
      wait for 4.3 us;
      wait until rising_edge(clk);
      ShiftEnable <= '1';
      wait until rising_edge(clk);
      ShiftEnable <= '0';
      wait for 4.3 us;
      
      Din <= '0';
      wait for 4.3 us;
      wait until rising_edge(clk);
      ShiftEnable <= '1';
      wait until rising_edge(clk);
      ShiftEnable <= '0';
      wait for 4.3 us;
      
      Din <= '1';
      wait for 4.3 us;
      wait until rising_edge(clk);
      ShiftEnable <= '1';
      wait until rising_edge(clk);
      ShiftEnable <= '0';
      wait for 4.3 us;
      
      Din <= '0';
      wait for 4.3 us;
      wait until rising_edge(clk);
      ShiftEnable <= '1';
      wait until rising_edge(clk);
      ShiftEnable <= '0';
      wait for 4.3 us;
      
      wait;
   end process;
   
end rtl;