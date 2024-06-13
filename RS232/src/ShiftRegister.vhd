library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister is
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
end entity;

architecture rtl of ShiftRegister is

   signal SR   : std_logic_vector(CHAIN_LENGTH-1 downto 0);

begin
   
   Dout <= SR;
   
   SHIFT_TO_THE_RIGTH : if SHIFT_DIRECTION='R' generate
      -- Shift SR to the right, used when the serial data is tranmitted LSB first
      
      ShiftProcess:process(clk, rst)
   
      begin
         if rst='1' then
            SR <= (others => '0');
         elsif rising_edge(clk) then
            if ShiftEnable='1' then
               SR <= Din & SR(SR'left downto 1);
            end if;
         
         end if;
      end process;
   end generate;
   
   SHIFT_TO_THE_LEFT : if SHIFT_DIRECTION='L' generate
      -- Shift SR to the left, used when the serial data is tranmitted MSB first
      
      ShiftProcess:process(clk, rst)
   
      begin
         if rst='1' then
            SR <= (others => '0');
         elsif rising_edge(clk) then
            if ShiftEnable='1' then
               SR <= SR(SR'left-1 downto 1) & Din;
            end if;
         
         end if;
      end process;
   end generate;
end rtl;