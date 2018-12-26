library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity oven is
  port(
    clk, start     : in std_logic;
    c_temp, s_temp : in std_logic_vector(7 downto 0);
    high, low      : out std_logic
  );

end oven;

architecture arch of oven is
  type oven_state is (off, preheat, warm);
  signal state : oven_state := off;
  begin

    oven_contr_proc: process(clk)
    begin
      if rising_edge(clk) then
        state = off when start = '0' else start;
        case state is
          when off =>
            if start = '1' then
              state <= preheat;
            end if;
          when preheat =>
            if c_temp >= s_temp then
              state <= warm;
            end if;
          when warm =>
        end case;
      end if;
    end process oven_contr_proc;

    high = '1' when state = preheat else '0';
    low  = '1' when state = warm    else '0';

  end arch;
