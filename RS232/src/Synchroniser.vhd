library ieee;
use ieee.std_logic_1164.all;

entity Synchroniser is
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
end entity;

architecture rtl of Synchroniser is
   signal SR   : std_logic_vector(1 downto 0);
begin

   Synced <= SR(1);

   SynchronisationProcess:process(rst, clk)
      begin
      
      if rst='1' then
         SR <= (others => IDLE_STATE);
      elsif rising_edge(clk) then
         SR(0) <= Async;
         SR(1) <= SR(0);
      end if;
      
   end process;

end rtl;