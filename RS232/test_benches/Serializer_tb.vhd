library ieee;
use ieee.std_logic_1164.all;

entity Serializer_tb is
generic
(
   DATA_WIDTH     : integer := 8;
   DEFAULT_STATE  : std_logic := '1'
);
end entity;

architecture rtl of Serializer_tb is

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

   signal clk      : std_logic := '0';
   signal rst      : std_logic;
   
   signal ShiftEn  : std_logic;
   signal Load     : std_logic;
   signal Din      : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal Dout     : std_logic;

begin

   clk <= not clk after 10 ns;

   UUT : Serializer
   generic map
   (
      DATA_WIDTH     => DATA_WIDTH,
      DEFAULT_STATE  => DEFAULT_STATE
   )
   port map
   (
      clk      => clk,
      rst      => rst,
      
      ShiftEn  => ShiftEn,
      Load     => Load,
      Din      => Din,
      Dout     => Dout
   );
   
   TestProcess:process
   begin
      rst <= '1';
      ShiftEn <= '0';
      Load <= '0';
      Din <= (others=>'0');
      wait for 100 ns;
      rst <= '0';
      wait for 100 ns;
   
      wait until rising_edge(clk);
      Load <= '1';
      Din <= x"AA";
      wait until rising_edge(clk);
      Load <= '0';
      Din <= (others=>'0');
      
      for i in 0 to 7 loop
      wait for 8.7 us;
         wait until rising_edge(clk);
         ShiftEn <= '1';
         wait until rising_edge(clk);
         ShiftEn <= '0';
      end loop;
   
      wait;
   end process;

end rtl;