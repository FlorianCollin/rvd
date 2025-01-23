-----------------------------------------------------------------------------------------
--
--   Fonctionnement 4 bits pour le signal RW_Mem pour permmettre l'écriture par octects
--   La mémoire mémorise des données sur 32 bits mais écriture possible par octects
--   15 combinaisons possibles pour les écritures
--   si le signal RW="000" alors lecture des 32 bits mémorisés
-----------------------------------------------------------------------------------------
--
--   Attention pour l'addressage du bloc mémoire, nous gardons seulement
--   Memory_size bits parmi les data_length bits
--
----------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.ram_pkg.all;
  use work.constants_pkg.all;

entity mem_unit is
  generic (
    memory_size : integer
  );
  port (
    clk          : in    std_logic;
    boot         : in    std_logic;
    ena_cpu      : in    std_logic;
    rw_boot      : in    std_logic;
    rw_cpu       : in    std_logic_vector(3 downto 0);
    adr_boot     : in    std_logic_vector(data_length - 1 downto 0);
    adr_cpu      : in    std_logic_vector(data_length - 1 downto 0);
    val_in_boot  : in    std_logic_vector(7 downto 0);
    val_in_cpu   : in    std_logic_vector(data_length - 1 downto 0);
    val_out_cpu  : out   std_logic_vector(data_length - 1 downto 0);
    val_out_boot : out   std_logic_vector(7 downto 0)
  );
end entity mem_unit;

architecture behavioral of mem_unit is

  component ram_unit_xilinx is
    generic (
      nb_col    : integer;
      col_width : integer;
      ram_depth : integer
    );
    port (
      addra : in    std_logic_vector(7 downto 0);
      dina  : in    std_logic_vector(data_length - 1 downto 0);
      clka  : in    std_logic;
      wea   : in    std_logic_vector(3 downto 0);
      ena   : in    std_logic;
      douta : out   std_logic_vector(data_length - 1 downto 0)
    );
  end component;

  component mux_boot_loader is
    port (
      boot    : in    std_logic;
      ena_cpu : in    std_logic;
      ena_mem : out   std_logic;
      rw_cpu  : in    std_logic_vector(3 downto 0);
      rw_boot : in    std_logic;
      rw_mem  : out   std_logic_vector(3 downto 0);

      adr_boot : in    std_logic_vector(data_length - 1 downto 0);
      adr_cpu  : in    std_logic_vector(data_length - 1 downto 0);
      adr_mem  : out   std_logic_vector(data_length - 1 downto 0);

      val_in_boot : in    std_logic_vector(7 downto 0);
      val_in_cpu  : in    std_logic_vector(data_length - 1 downto 0);
      val_in_mem  : out   std_logic_vector(data_length - 1 downto 0)
    );
  end component;

  component data_to_bootloader is
    port (
      boot     : in    std_logic;
      rw_boot  : in    std_logic;
      adr_boot : in    std_logic_vector(1 downto 0);
      val_in   : in    std_logic_vector(data_length - 1 downto 0);
      val_out  : out   std_logic_vector(7 downto 0)
    );
  end component;

  signal sig_ena_mem     : std_logic;
  signal sig_rw_mem      : std_logic_vector(3 downto 0);
  signal sig_adr_mem     : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_in_mem  : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_out_mem : std_logic_vector(data_length - 1 downto 0);

begin

  -- Mux_Boot_Loader for RAM Memory
  inst_mux_boot_loader_inst : component mux_boot_loader
    port map (
      boot        => boot,
      ena_cpu     => ena_cpu,
      ena_mem     => sig_ena_mem,
      rw_cpu      => rw_cpu,
      rw_boot     => rw_boot,
      rw_mem      => sig_rw_mem,
      adr_boot    => adr_boot,
      adr_cpu     => adr_cpu,
      adr_mem     => sig_adr_mem,
      val_in_boot => val_in_boot,
      val_in_cpu  => val_in_cpu,
      val_in_mem  => sig_val_in_mem
    );

  inst_ram_unit : component ram_unit_xilinx
    generic map (
      nb_col    => 4,
      col_width => 8,
      ram_depth => 2 ** (Memory_size - 2)
    )
    port map (
      addra => sig_adr_mem(9 downto 2),
      dina  => sig_val_in_mem,
      clka  => clk,
      wea   => sig_rw_mem,
      ena   => sig_ena_mem,
      douta => sig_val_out_mem
    );

  val_out_cpu <= sig_val_out_mem;

  inst_conv : component data_to_bootloader
    port map (
      boot     => boot,
      rw_boot  => rw_boot,
      adr_boot => adr_boot(1 downto 0),
      val_in   => sig_val_out_mem,
      val_out  => val_out_boot
    );

end architecture behavioral;
