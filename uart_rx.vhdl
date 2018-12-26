library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
port (
      clk, d_valid, data_in : in std_logic;
      d_valid               : out std_logic;
      data_out              : out std_logic_vector(7 downto 0)
);
end uart_rx;

architecture arch of uart_rx is

signal index      : integer range 0 to 7 := 0;
signal slow_clk   : std_logic := '0';
constant bound    : integer := 651;
signal counter    : integer range 0 to bound := 0;
signal d_s1, d_s2 : std_logic;
signal sampling   : integer range 0 to 15 := 0;

type f_state is (idle, start, data, s_stop, done);
signal state : f_state := idle;

begin
  slow_clock : process(clk)
  begin
    if rising_edge(clk) then
      if counter = bound then
        counter  <= 0;
        slow_clk <= '1';
      else
        counter <= counter + 1;
      end if;
    end if;
  end process slow_clock;

--stabalize data input
  stablizer : process(clk)
  begin
    if rising_edge(clk) then
      d_s1 <= data_in;
      d_s2 <= d_s1;
    end if;
  end process stablizer;

  sampling_cycle : process(clk)
  begin
    if rising_edge(clk) then
      if slow_clk = '1' then
        if state = start then
          if sampling = 7 then
            sampling <= 0;
          else
            sampling <= sampling + 1;
          end if;
        elsif state = data or state = s_stop then
          if sampling = 15 then
            sampling <= 0;
          else
            sampling <= sampling + 1;
          end if;
        else
          sampling <= 0;
        end if;
      end if;
    end if;
  end process sampling_cycle;

states : process(clk)
begin
  if slow_clk = '1' then
    case state is
      when idle   =>
        if d_s2 = '0' then
          state <= start;
        end if;
      when start  =>
        if sampling = 7 then
          if d_s2 = '0' then
            state <= data;
          else
            state <= idle;
          end if;
        end if;
      when data   =>
        if sampling = 15 then
          data_out(index) <= d_s2;
          if index = 7 then
            state <= s_stop;
          else
            index <= index + 1;
          end if;
        end if;
      when s_stop =>
        if sampling = 15 then
          state <= done;
        end if;
      when done   =>
        state <= idle;
        inedx <= 0;
    end case;
  end if;
end process states;


d_valid <= '1' when state = done else '0';

end arch;
