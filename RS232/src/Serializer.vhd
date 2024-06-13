library ieee;
use ieee.std_logic_1164.all;

entity Serializer is
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
end entity;

architecture rtl of Serializer is

signal ShiftRegister : std_logic_vector(DATA_WIDTH-1 downto 0);

begin
   Dout <= ShiftRegister(0);

   Serializer:process(clk, rst)

      begin
      if rst='1' then
         ShiftRegister <= (others => DEFAULT_STATE);
      elsif rising_edge(clk) then
         if Load='1' then
            ShiftRegister <= Din;
         elsif ShiftEn='1' then
            ShiftRegister <= DEFAULT_STATE & ShiftRegister(ShiftRegister'left downto 1);
         
         end if;
      end if;
   
   
   
   end process;


end rtl;