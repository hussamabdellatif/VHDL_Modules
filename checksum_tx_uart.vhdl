--not complete 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chksum is
  port(
    clk, ready                 : in std_logic;
    byte0, byte1, byte2, byte3 : in std_logic_vector(7 downto 0);
    tx_out                     : out std_logic
  );
end chksum;


architecture arch of chksum is

component uart_tx
port(
  clk, d_valid : in std_logic;
  d_in         : in std_logic_vector(7 downto 0);
  data_out     : out std_logic;
  tx_done      : out std_logic
);
end component;

-- uart input
signal d_in, d_valid : in std_logic;
signal data : std_logic_vector(7 downto 0);
signal data_out, tx_done : std_logic;

-- state maching
type state_c is (idle, byte0, byte1, byte2, byte3 , chksum);
signal state : state_c := idle;

--checksum
signal chksum : std_logic_vector(7 downto 0);

begin

  uart: uart_tx port map(clk => clk, d_valid => )
