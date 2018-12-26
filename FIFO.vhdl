library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifo is
  port (
    clk, read_en, write_en  : in std_logic;
    data_in                 : in std_logic_vector(7 downto 0); --writing byte by byte into fifo
    data_out                : out std_logic_vector(7 downto 0); --reading out byte by byte out of FIFO container
    full,empty              : in std_logic
  );
end fifo;


architecture arch of fifo is
  type f_array is array (0 to 15) of std_logic_vector(7 downto 0);
  signal fifo      : f_array;
  signal write_ptr : integer range 0 to 15 := 0;
  signal read_ptr  : integer range 0 to 15 := 0;
  signal size      : integer range 0 to 16 := 0; --number of elements that has not been read yet

  begin

    read_proc : process(clk)
    begin
      if rising_edge(clk) then
        if read_en = '1' then
          data_out <= fifo(read_ptr);
          if read_ptr = 15 then
            read_ptr <= 0;
          else
            read_ptr <= read_ptr + 1;
          end if;
        end if;
      end if;
    end process read_proc;

    write_proc : process(clk)
    begin
      if rising_edge(clk) then
        if write_en = '1' then
          fifo(write_ptr) <= data_in;
          if write_ptr = 15 then
            write_ptr <= 0;
          else
            write_ptr <= write_ptr + 1;
          end if;
        end if;
      end if;
    end process write_proc;

    size_proc : process(clk)
    begin
      if rising_edge(clk) then
        if read_en = '1' and write_en = '0' and size > 0 then
          size <= size - 1;
        elsif read_en = '0' and write_en = '1' and size < 16 then
          size<= size + 1;
        end if;
      end if;
    end process size_proc;

    full  <= 1 when size = 16 else '0';
    empty <= 1 when size = 0 else '0';

  end arch;
