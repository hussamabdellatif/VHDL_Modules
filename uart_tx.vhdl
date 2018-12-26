library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
  port (
  clk, d_valid : in std_logic;
  d_in         : in std_logic_vector(7 downto 0); -- 8-N-1 uart transmitter
  data_out     : out std_logic --serial output uart
  );
end uart_tx;

architecture arch of uart_tx is
  signal slow_clk : std_logic;
  signal counter  : unsigned(9 downto 0) := (others => '0');
  signal index : integer range 0 to 7;
  signal one_count : integer := 0;
  type f_state is (idle, start, data,e_parity ,s_stop);
  signal state : f_state := idle;
  constant bound : unsigned := 651; -- assumin 100MHz clock, and baud rate 9600 and sampling at 16xbaudrate
  begin
    slow_clock : process(clk)
    begin
      if rising_edge(clk) then
        if counter < bound then
          counter <= counter + 1;
          slow_clk <= 0;
        else
          counter <= 0;
          slow_clk <= 1;
        end if;
      end if;
    end process slow_clock;

    tx : process(clk)
    begin
      if rising_edge(clk) then
        case state is
          when idle =>
            data_out <= '1';
            index <= '0';
            if d_valid = '1' then
              state <= start;
            end if;
          when start =>
            data_out <= '0';
            if slow_clk = '1' then
              state <= data;
            end if;
          when data =>
            data_out <= d_in(index);
            one_count <= one_count + 1 when d_in(index) = '1' else one_count;
            if slow_clk = '1' then
              if index = 7 then
                state <= e_parity;
              else
                index <= index + 1;
              end if;
            end if;
          when e_parity =>
            data_out <= '0' when one_count mod 2 = 0 else '1';
            if slow_clk = '1' then
              state <= s_stop;
            end if;
          when s_stop =>
            data_out <= '1';
            if slow_clk = '1' then
            state <= idle
          end if;
    end case;
    
  end if;

end process tx;
end arch;
