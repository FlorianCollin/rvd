library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;

entity read_int_file is
  generic (
    file_in_inst : STRING  := "default_Inst.txt";
    file_in_data : STRING  := "default_Data.txt";
    line_size    : integer := 32;
    data_size    : integer
  );
  port (
    clk        : in    std_logic;
    rst        : in    std_logic;
    enable     : in    std_logic;
    stream_out : out   std_logic_vector(data_size - 1 downto 0)
  );
end entity read_int_file;

architecture logic of read_int_file is

  signal data_counter : integer range 0 to line_size - 1;
  signal buf_data     : std_logic_vector(data_size - 1 downto 0);

begin

  -- keep track of the value index in the current parsed line
  data_count : process (rst, clk) is
  begin

    if (rst = '1') then
      data_counter <= 0;
    elsif (clk'event and clk = '1') then
      if (enable = '1') then
        if (data_counter = 0) then
          data_counter <= line_size - 1;
        else
          data_counter <= data_counter  - 1;
        end if;
      end if;
    end if;

  end process data_count;

  -- parse file
  process (rst, clk) is

    file     data_file_Inst : TEXT OPEN read_mode IS file_in_inst;
    file     data_file_Data : TEXT OPEN read_mode IS file_in_data;
    variable data_line      : line;
    variable tmp            : integer;

  begin

    if (rst = '1') then
      buf_data <= (others => '0');
    elsif (clk'event and clk = '1') then
      -- if(data_counter = 0 and enable = '1' and rst = '0') then
      if (enable = '1') then
        if (data_counter = 0) then
          if (NOT endfile(data_file_Inst)) then
            readline(data_file_Inst, data_line);
            read(data_line, tmp);
            buf_data <= std_logic_vector(to_unsigned(tmp, data_size));
          elsif (NOT endfile(data_file_Data)) then
            readline(data_file_Data, data_line);
            read(data_line, tmp);
            buf_data <= std_logic_vector(to_unsigned(tmp, data_size));
          else
            buf_data <= (others => '-');
          end if;
        end if;
      end if;
    --            read(data_line, tmp);
    --            buf_data <=  std_logic_vector(to_unsigned(tmp,data_size));
    end if;

  end process;

  stream_out <= buf_data;

end architecture logic;
