library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


--pulse width modulation 


entity pwm is
port (
  x   : in std_logic_vector(7 downto 0);
  clk : in std_logic;
  y   : out std_logic
);
end pwm;

architecture arch of pwm is
signal counter : unsigned(7 downto 0) := (others => '0');
begin

  duty_cycle : process(clk)
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
      if counter >= unsigned(x) then
        y <= '1';
      else
        y <= '0';
      end if;
    end if;
  end duty_cycle;

end arch;
