library ieee;
  use ieee.std_logic_1164.all;

package ram_pkg is

  function clogb2 (
    depth: in natural
  ) return integer;

end package ram_pkg;

package body ram_pkg is

  function clogb2 (
    depth : in natural
  ) return integer is

    variable temp    : integer := depth;
    variable ret_val : integer := 0;

  begin

    while temp > 1 loop

      ret_val := ret_val + 1;
      temp    := temp / 2;

    end loop;

    return ret_val;

  end function;

end package body ram_pkg;

library ieee;

library work;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.ram_pkg.all;
  use std.textio.all;
  use work.constants_pkg.all;

entity ram_unit_xilinx is
  generic (
    nb_col    : integer; -- Specify number of columns (number of bytes)
    col_width : integer; -- Specify column width (byte width, typically 8 or 9)
    ram_depth : integer  -- Specify RAM depth (number of entries)
  -- RAM_PERFORMANCE : string := "HIGH_PERFORMANCE" -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  -- INIT_FILE : string := "RAM_INIT.dat"            -- Specify name/location of RAM initialization file if using one (leave blank if not)
  );

  -- port (

  --        addra : in std_logic_vector((clogb2(RAM_DEPTH)-1) downto 0);     -- Address bus, width determined from RAM_DEPTH
  --        dina  : in std_logic_vector(NB_COL*COL_WIDTH-1 downto 0);          -- RAM input data
  --        clka  : in std_logic;                                     -- Clock
  --        wea   : in std_logic_vector(NB_COL-1 downto 0);        -- Byte-write enable
  --        ena   : in std_logic;                                     -- RAM Enable, for additional power savings, disable port when not in use
  --        --rsta  : in std_logic;                                     -- Output reset (does not affect memory contents)
  --        --regcea: in std_logic;                                     -- Output register enable
  --        douta : out std_logic_vector(NB_COL*COL_WIDTH-1 downto 0)                 -- RAM output data
  --    );
  port (
    -- addra : in std_logic_vector(8 downto 0);     -- Address bus, width determined from RAM_DEPTH
    -- addra : in std_logic_vector(12 downto 0);
    addra : in    std_logic_vector(7 downto 0);  -- Mouad Rabiai le 18/03/2024
    dina  : in    std_logic_vector(31 downto 0); -- RAM input data
    clka  : in    std_logic;                     -- Clock
    wea   : in    std_logic_vector(3 downto 0);  -- Byte-write enable
    ena   : in    std_logic;                     -- RAM Enable, for additional power savings, disable port when not in use
    -- rsta  : in std_logic;                                     -- Output reset (does not affect memory contents)
    -- regcea: in std_logic;                                     -- Output register enable
    douta : out   std_logic_vector(31 downto 0) -- RAM output data
  );
end entity ram_unit_xilinx;

architecture rtl of ram_unit_xilinx is

  -- constant C_NB_COL     : integer := NB_COL;
  -- constant C_COL_WIDTH  : integer := COL_WIDTH;
  -- constant C_RAM_DEPTH  : integer := RAM_DEPTH;
  constant c_nb_col    : integer := 4;
  constant c_col_width : integer := 8;
  -- constant C_RAM_DEPTH  : integer := 512; --512
  -- constant C_RAM_DEPTH  : integer := 8192; --8192
  constant c_ram_depth : integer := 256; -- Mouad Rabiai le 18/03/2024
  -- constant C_RAM_PERFORMANCE : string := RAM_PERFORMANCE;
  -- constant C_INIT_FILE : string := INIT_FILE;

  signal douta_reg : std_logic_vector(c_nb_col * c_col_width - 1 downto 0) := (others => '0');

  type ram_type is array (c_ram_depth - 1 downto 0) of std_logic_vector(c_nb_col * c_col_width - 1 downto 0); -- 2D Array Declaration for RAM signal

  signal ram_data : std_logic_vector(data_length - 1 downto 0);

  -- The folowing code either initializes the memory values to a specified file or to all zeros to match hardware

  -- function initramfromfile (ramfilename : in string) return ram_type is
  -- file ramfile    : text is in ramfilename;
  -- variable ramfileline : line;
  -- variable ram_name    : ram_type;
  -- variable bitvec : bit_vector(C_NB_COL*C_COL_WIDTH-1 downto 0);
  -- begin
  --    for i in ram_type'range loop
  --        readline (ramfile, ramfileline);
  --        read (ramfileline, bitvec);
  --        ram_name(i) := to_stdlogicvector(bitvec);
  --    end loop;
  --    return ram_name;
  -- end function;

  -- function init_from_file_or_zeroes(ramfile : string) return ram_type is
  -- begin
  --  if ramfile = "RAM_INIT.dat" then
  --    return InitRamFromFile("RAM_INIT.dat") ;
  --  else
  --    return (others => (others => '0'));
  --  end if;
  -- end;
  -- Following code defines RAM

  -- signal ram_name : ram_type := init_from_file_or_zeroes(C_INIT_FILE);
  signal ram_name : ram_type;

begin

  process (clka) is
  begin

    if rising_edge(clka) then
      if (ena = '1') then

        for i in 0 to c_nb_col - 1 loop

          if (wea(i) = '1') then
            ram_name(to_integer(unsigned(addra)))((i + 1) * C_COL_WIDTH - 1 downto i * C_COL_WIDTH) <= dina((i + 1) * c_col_width - 1 downto i * c_col_width);
          end if;

        end loop;

        ram_data <= ram_name(to_integer(unsigned(addra)));
      end if;
    end if;

  end process;

  --  Following code generates LOW_LATENCY (no output register)
  --  Following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing

  -- no_output_register : if C_RAM_PERFORMANCE = "LOW_LATENCY" generate
  douta <= ram_data;
-- end generate;

----  Following code generates HIGH_PERFORMANCE (use output register)
----  Following is a 2 clock cycle read latency with improved clock-to-out timing

-- output_register : if C_RAM_PERFORMANCE = "HIGH_PERFORMANCE"  generate
-- process(clka)
-- begin
--    if(clka'event and clka = '1') then
--        if(rsta = '1') then
--            douta_reg <= (others => '0');
--        elsif(regcea = '1') then
--            douta_reg <= ram_data;
--        end if;
--    end if;
-- end process;
-- douta <= douta_reg;

-- end generate;

end architecture rtl;

-- The following is an instantiation template for xilinx_single_port_byte_write_ram_read_first
-- Component Declaration
-- Uncomment the below component declaration when using
-- component xilinx_single_port_byte_write_ram_read_first is
-- generic (
-- NB_COL : integer,
-- COL_WIDTH : integer,
-- RAM_DEPTH : integer,
-- RAM_PERFORMANCE : string,
-- INIT_FILE : string
-- );
-- port
-- (
-- addra : in std_logic_vector(clogb2(RAM_DEPTH)-1) downto 0);
-- dina  : in std_logic_vector(NB_COL*COL_WIDTH-1 downto 0);
-- clka  : in std_logic;
-- wea   : in std_logic_vector(NB_COL-1 downto 0);
-- ena   : in std_logic;
-- rsta  : in std_logic;
-- regcea: in std_logic;
-- douta : out std_logic_vector(NB_COL*COL_WIDTH-1 downto 0)
-- );
-- end component;
--
-- Instantiation
-- Uncomment the instantiation below when using
-- <your_instance_name> : xilinx_single_port_byte_write_ram_read_first
--
-- generic map (
-- NB_COL => 4,
-- COL_WID => 8,
-- RAM_DEPTH => 1024,
-- RAM_PERFORMANCE => "HIGH_PERFORMANCE",
-- INIT_FILE => ""
-- )
--  port map  (
--
-- addra  => addra,
-- dina   => dina,
-- clka   => clka,
-- wea    => wea,
-- ena    => ena,
-- rsta   => rsta,
-- regcea => regcea,
-- douta  => douta
-- );
