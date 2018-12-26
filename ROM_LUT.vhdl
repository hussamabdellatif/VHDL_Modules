library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- --implements the following state table using a ROM and two D-Flip Flops
-- present state  |  Next state           | Output (Z)
--                | X=0           X=1     | X=0          X=1
--       S0       | S0             S1     | 0             1
--       S1       | S2             S3     | 1             0
--       S2       | S1             S3     | 1             0
--       S3       | S3             S2     | 0             1



entity rom is
port(
  x, clk : in std_logic;
  y      : out std_logic
);

end rom;

architecture arch of rom is
  signal D1,D0,Q1,Q0 std_logic;
  type rom_type is array (0 to 7) of std_logic_vector(2 downto 0);
  constant rom : rom_type := ("000", "011", "101", "110", "011", "110", "110", "101");

  signal address : integer range 0 to 7 := 0;
  signal value : std_logic_vector(2 downto 0);

  begin

    address <= to_integer(unsigned(Q1&Q0&x));

    process(clk)
    begin
      if rising_edge(clk) then
        value <= rom(address);
        D1 <= value(2);
        D0 <= value(1);
        Z  <= value(0);
      end if;
    end process;

    process(clk)
    begin
      if rising_edge(clk) then
        Q1 <= D1;
        Q0 <= D0;
      end if;
    end process;
  end arch;
