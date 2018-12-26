library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_counter is
port(
  x, clk : in std_logic;
  y      : out std_logic_vector(15 downto 0)
);
end edge_counter;

architecture arch of edge_counter is
  signal siso : std_logic_vector(1 downto 0);
  signal counter : unsigned(15 downto 0);

  begin
    process(clk)
    begin
      if rising_edge(clk) then
        siso <= siso(0) & x;
        if counter < 65535 and siso = "01" then
          counter <= counter + 1;
        end if;
      end if;
    end process;

    y <= std_logic_vector(counter);

  end arch;
