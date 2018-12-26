--not complete yet...

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master is
  port (
        sync_pulse, r_w_bit, clk : in std_logic;
        write_data, address : in std_logic_vector(7 downto 0);
        sda : inout std_logic;
        scl : out std_logic;
        read_data: out std_logic_vector(7 downto 0)
  );

end i2c_master;

architecture arch of i2c_master is

  signal counter_div256 : unsigned(7 downto 0) := (others => '0'); --clock is 100MHz. 25% of phase shift 2^8 = 256 is the 6th bit and most sig bit for duty cycle.
  signal clk_390khz : std_logic;
  signal clk_390khz_shift : std_logic := '0';
  signal clk_390khz_shift_edge_det : std_logic_vector(1 downto 0) := "00";
  signal sync_pulse_latch : std_logic := '0';

  type state_tpye is (idle, i2c_start, write_addr, read_write, addr_ack, read_byte, write_byte, read_nack, write_ack, i2c_stop);
  signal state : state_type := idle;
  signal bit_count : integer range 0 to 7 := 7;


  begin

  clk_div_proc : process(clk)
  begin
    if rising_edge(clk) then
      counter_div256 <= counter_div256 + 1;
    end if;
  end process clk_div_proc;

  clk_390khz <= counter_div256(7);

  clk_shift_proc : process(clk)
  begin
    if rising_edge(clk) then
      if counter_div256(6) = '1' then
        clk_390khz_shift <= clk_390khz;
      end if;
    end if;
  end process clk_shift_proc;

  sc1 <= clk_390khz_shift;

  edge_det_proc : process(clk)
  begin
    if rising_edge(clk) then
      clk_390khz_shift_edge_det <= clk_390khz_shift_edge_det(0) & clk_390khz;
    end if;
  end process edge_det_proc;

  bit_count_proc: process(clk)
  begin
    if rising_edge(clk) then
      if clk_390khz_shift_edge_det = "01" then --rising edge of clock
        if state = write_addr or state = write_byte or state = read_byte then
          bit_count <= bit_count - 1;
        end if;
      end if;
    end if;
  end process bit_count_proc;

  sync_latch_proc : process(clk)
  begin
    if rising_edge(clk) then
      if state = idle then
        if sync_pulse = '1' then
          sync_pulse_latch <= '1';
        end if;
      else
        sync_pulse_latch <= '0';
      end if;
    end if;
  end process sync_latch_proc;

  state_proc : process(clk)
  begin
    if rising_edge(clk) then
      if clk_390khz_shift_edge_det = "01" then
        case state is
          when idle =>
            if sync_pulse_latch = '1' then
              state <= i2c_start;
            end if;
          when i2c_start =>
            state <= write_addr;
          when write_addr =>
            if r_w_bit = '1' then
              state <= write_byte;
            else
              state <= read_byte;
            end if;
          when write_byte =>
            if bit_count = '0' then
              state <= write_ack;
            end if;
          when read_byte =>
            if bit_count = '0' then
              state <= read_nack;
            end if;
          when write_ack =>
            state <= i2c_stop;
          when read_nack =>
            state <= i2c_stop;
          when i2c_stop =>
            state <= idle;
        end case;
      end if;
    end if;
  end process state_proc;

  sda_proc : process(clk)
  begin
    if rising_edge(clk) then
      case state is
        when idle =>
          sda <= '1';
        when i2c_start =>
          if clk_390khz_shift_edge_det = "10" then
            sda <= '0';
          end if;
        when write_addr =>
          sda <= address(bit_count);
        when read_write =>
          sda <= r_w_bit;
        when addr_ack =>
          sda <= 'z';
        when write_byte =>
          sda <= write_data(bit_count);
        when read_byte =>
          sda <= 'z';
        when write_ack =>
          sda <= 'z';
