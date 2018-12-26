library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
port(
  x : std_logic_vector(7   downto 0);
  y : std_logic_vector(255 downto 0)
);
end decoder;

architecture arch of decoder is
begin

de_generate : for i in 0 to 255 generate
  y(i) = '1' when i = to_integer(unsigned(x)) else '0';
end generate;

end arch;
