library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sum is
  port(
    clk : in std_logic;
    x   : in std_logic_vector(3 downto 0);
    y   : out std_logic_vector(15 downto 0)
  );
end sum;


architecture arch of sum is
  signal t_sum : unsigned(15 downto 0) := (others => '0');
  begin

    s_proc : process(clk)
    begin
      if rising_edge(clk) then
        t_sum <= t_sum + unsigned("00000000000"&x);
      end if;
    end process s_proc;

    y <= std_logic_vector(t_sum);

  end arch;


--y is a 16-bit std_logic_vector output that is the unsigned sum of all previous values of x.
