library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity control_unit is
  port (
    clk      : in    std_logic;
    reset    : in    std_logic;
    ce       : in    std_logic;
    boot     : in    std_logic;
    val_inst : in    std_logic_vector((data_length - 1) downto 0);
    jalr_adr : in    std_logic_vector((data_length - 1) downto 0);
    jr_adr   : in    std_logic_vector((data_length - 1) downto 0);

    br_jal_adr     : in    std_logic_vector((data_length - 1) downto 0);
    adr_cpu        : in    std_logic_vector((data_length - 1) downto 0);
    adr_inst       : out   std_logic_vector((data_length - 1) downto 0);
    new_adr_inst   : out   std_logic_vector((data_length - 1) downto 0);
    ena_mem_inst   : out   std_logic;
    ena_mem_data   : out   std_logic;
    rw_mem_data    : out   std_logic_vector(3 downto 0);
    mem_read_depth : out   std_logic_vector(3 downto 0);
    fsm_state      : out   std_logic_vector(4 downto 0);

    sel_func_alu         : out   std_logic_vector(3 downto 0);
    reg_file_write       : out   std_logic;
    imm_type             : out   std_logic_vector(2 downto 0);
    sel_op2              : out   std_logic;
    sel_result           : out   std_logic_vector(1 downto 0);
    sel_func_alu_connect : out   std_logic_vector(2 downto 0);
    val_connect          : in    std_logic;
    select_result        : out   std_logic -- Mouad Rabiai le 03/03/2024
  );
end entity control_unit;

architecture behavioral of control_unit is

  component fsm is
    port (
      clk      : in    std_logic;
      reset    : in    std_logic;
      ce       : in    std_logic;
      init_reg : in    std_logic;
      val_inst : in    std_logic_vector((data_length - 1) downto 0);
      adr_cpu  : in    std_logic_vector((data_length - 1) downto 0);

      ena_mem_inst   : out   std_logic;
      ena_mem_data   : out   std_logic;
      rw_mem_data    : out   std_logic_vector(3 downto 0);
      mem_read_depth : out   std_logic_vector(3 downto 0);

      sel_func_alu         : out   std_logic_vector(3 downto 0);
      reg_file_write       : out   std_logic;
      imm_type             : out   std_logic_vector(2 downto 0);
      sel_op2              : out   std_logic;
      sel_result           : out   std_logic_vector(1 downto 0);
      select_result        : out   std_logic;
      sel_func_alu_connect : out   std_logic_vector(2 downto 0);
      val_connect          : in    std_logic;

      load_plus4 : out   std_logic;
      fsm_state  : out   std_logic_vector(4 downto 0);
      sel_pc_mux : out   std_logic_vector(1 downto 0)
    );
  end component;

  component inst_register is
    port (
      clk          : in    std_logic;
      reset        : in    std_logic;
      ce           : in    std_logic;
      init_counter : in    std_logic;
      load_plus4   : in    std_logic;
      val_counter  : in    std_logic_vector((data_length - 1) downto 0);
      adr_inst     : out   std_logic_vector((data_length - 1) downto 0)
    );
  end component;

  component pc_plus_4 is
    port (
      val_inst     : in    std_logic_vector((data_length - 1) downto 0);
      new_val_inst : out   std_logic_vector((data_length - 1) downto 0)
    );
  end component;

  component mux4_1 is
    port (
      in1    : in    std_logic_vector((data_length - 1) downto 0);
      in2    : in    std_logic_vector((data_length - 1) downto 0);
      in3    : in    std_logic_vector((data_length - 1) downto 0);
      in4    : in    std_logic_vector((data_length - 1) downto 0);
      sel    : in    std_logic_vector(1 downto 0);
      o : out   std_logic_vector((data_length - 1) downto 0)
    );
  end component;

  signal sig_load_plus4   : std_logic;
  signal sig_sel_pc_mux   : std_logic_vector(1 downto 0);
  signal sig_val_counter  : std_logic_vector((data_length - 1) downto 0);
  signal sig_adr_inst     : std_logic_vector((data_length - 1) downto 0);
  signal sig_new_adr_inst : std_logic_vector((data_length - 1) downto 0);
  signal sig_val_imm_adr  : std_logic_vector((data_length - 1) downto 0);

  constant zero : std_logic_vector((data_length - 1) downto 0) := (others => '0');

begin

  inst_fsm : component fsm
    port map (
      clk      => clk,
      reset    => reset,
      ce       => ce,
      val_inst => val_inst,
      init_reg => boot,
      adr_cpu  => adr_cpu,

      ena_mem_inst   => ena_mem_inst,
      ena_mem_data   => ena_mem_data,
      rw_mem_data    => rw_mem_data,
      mem_read_depth => mem_read_depth,

      sel_func_alu         => sel_func_alu,
      reg_file_write       => reg_file_write,
      imm_type             => imm_type,
      sel_op2              => sel_op2,
      sel_result           => sel_result,
      sel_func_alu_connect => sel_func_alu_connect,
      val_connect          => val_connect,
      sel_pc_mux           => sig_sel_pc_mux,
      fsm_state            => fsm_state,
      load_plus4           => sig_load_plus4,
      select_result        => select_result
    );

  pc : component inst_register
    port map (
      clk          => clk,
      reset        => reset,
      ce           => ce,
      init_counter => boot,
      load_plus4   => sig_load_plus4,
      val_counter  => sig_val_counter,
      adr_inst     => sig_adr_inst
    );

  adr_inst <= sig_adr_inst;

  pc_plus4 : component pc_plus_4
    port map (
      val_inst     => sig_adr_inst,
      new_val_inst => sig_new_adr_inst
    );

  new_adr_inst <= sig_new_adr_inst;

  inst_mux_register : component mux4_1
    port map (
      in1    => sig_new_adr_inst,
      in2    => br_jal_adr,
      in3    => jr_adr,
      in4    => jalr_adr,
      sel    => sig_sel_pc_mux,
      o => sig_val_counter
    );

end architecture behavioral;
