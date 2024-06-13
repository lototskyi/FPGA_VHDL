library ieee;
use ieee.std_logic_1164.all;

entity Synchroniser_tb is
end entity;

architecture rtl of Synchroniser_tb is
   
   component Synchroniser is
   generic
   (
      IDLE_STATE : std_logic;
   );
   port
   (
      clk      : in std_logic;
      rst      : in std_logic;
      Async    : in std_logic;
      Synced   : out std_logic
   );
   end component;
   
   signal clk    : std_logic := '0';
   signal rst    : std_logic;
   signal Async  : std_logic;
   signal Synced : std_logic
   
begin
   clk <= not clk after 10 ns;
   
   UUT : Synchroniser
   generic map
   (
      IDLE_STATE => '1'
   )
   port map
   (
      clk    => clk,
      rst    => rst,
      Async  => Async,
      Synced => Synced
   );
   
   TestProcess:process
   begin
   
      rst <= '1';
      Async <= '1';
      wait for 100 ns;
      rst <= '0';
      wait for 100 ns;
      
      wait for 3ns;
      Async <= '0';
   
   
      wait;
   end process;


end rtl;