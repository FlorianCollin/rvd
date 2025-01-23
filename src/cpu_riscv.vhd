library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;


-- cpu design top level
entity cpu_riscv is
  generic (
    memory_size : integer := 10
  );
  port (
    clk               : in    std_logic;
    reset             : in    std_logic;
    ce                : in    std_logic;
    boot              : in    std_logic;
    debug             : in    std_logic;
    inst_boot         : in    std_logic;
    data_boot         : in    std_logic;
    inst_rw_boot      : in    std_logic;
    data_rw_boot      : in    std_logic;
    adr_inst_boot     : in    std_logic_vector((data_length - 1) downto 0);
    adr_data_boot     : in    std_logic_vector((data_length - 1) downto 0);
    val_inst_in_boot  : in    std_logic_vector((8 - 1) downto 0);
    val_data_in_boot  : in    std_logic_vector((8 - 1) downto 0);
    val_inst_out_boot : out   std_logic_vector((8 - 1) downto 0);
    val_data_out_boot : out   std_logic_vector((8 - 1) downto 0);

    sig_adr_inst_out     : out   std_logic_vector((data_length - 1) downto 0);
    sig_val_out_inst_out : out   std_logic_vector((data_length - 1) downto 0);
    sig_new_adr_inst_out : out   std_logic_vector((data_length - 1) downto 0);
    sig_adr_mem_data_out : out   std_logic_vector((data_length - 1) downto 0);
    sig_val_in_data_out  : out   std_logic_vector((data_length - 1) downto 0);
    sig_val_out_data_out : out   std_logic_vector((data_length - 1) downto 0);
    sig_jalr_adr_out     : out   std_logic_vector((data_length - 1) downto 0);
    sig_jr_adr_out       : out   std_logic_vector((data_length - 1) downto 0);
    sig_br_jal_adr_out   : out   std_logic_vector((data_length - 1) downto 0);
    sig_sel_func_alu_out : out   std_logic_vector(3 downto 0);
    fsm_state            : out   std_logic_vector(4 downto 0);
    val_mem_data_depth   : out   std_logic_vector((data_length - 1) downto 0);

    alu_error_capture : out std_logic;
    error_msg : out std_logic_vector((data_length*4 -1) downto 0)
    
  );
end entity cpu_riscv;

architecture behavioral of cpu_riscv is

  component mem_unit is
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
    end component;

    component control_unit is
      port (
      clk            : in    std_logic;
      reset          : in    std_logic;
      ce             : in    std_logic;
      boot           : in    std_logic;
      val_inst       : in    std_logic_vector(data_length - 1 downto 0);
      jalr_adr       : in    std_logic_vector(data_length - 1 downto 0);
      jr_adr         : in    std_logic_vector(data_length - 1 downto 0);
      br_jal_adr     : in    std_logic_vector(data_length - 1 downto 0);
      adr_cpu        : in    std_logic_vector(data_length - 1 downto 0);
      adr_inst       : out   std_logic_vector(data_length - 1 downto 0);
      new_adr_inst   : out   std_logic_vector(data_length - 1 downto 0);
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
      select_result        : out   std_logic
    );
  end component;

  component processing_unit is
    port (
      clk            : in    std_logic;
      reset          : in    std_logic;
      ce             : in    std_logic;
      boot           : in    std_logic;
      val_mem_inst   : in    std_logic_vector(data_length - 1 downto 0);
      val_mem_data   : in    std_logic_vector(data_length - 1 downto 0);
      new_adr_inst   : in    std_logic_vector(data_length - 1 downto 0);
      adr_inst       : in    std_logic_vector(data_length - 1 downto 0);
      mem_read_depth : in    std_logic_vector(3 downto 0);

      sel_func_alu         : in    std_logic_vector(3 downto 0);
      reg_file_write       : in    std_logic;
      imm_type             : in    std_logic_vector(2 downto 0);
      sel_op2              : in    std_logic;
      sel_result           : in    std_logic_vector(1 downto 0);
      sel_func_alu_connect : in    std_logic_vector(2 downto 0);
      val_connect          : out   std_logic;

      val_mem_data_depth : out   std_logic_vector(data_length - 1 downto 0);
      val_ut_adr         : out   std_logic_vector(data_length - 1 downto 0);
      val_ut_data        : out   std_logic_vector(data_length - 1 downto 0);
      val_imm_operand    : out   std_logic_vector(data_length - 1 downto 0);
      jalr_adr           : out   std_logic_vector(data_length - 1 downto 0);
      jr_adr             : out   std_logic_vector(data_length - 1 downto 0);
      br_jal_adr         : out   std_logic_vector(data_length - 1 downto 0);
      select_result      : in    std_logic;
      -- CC
      alu_error_capture : out std_logic;
      r3 : out std_logic_vector((data_length*3 - 1) downto 0)
    );
  end component;

  --CC 
  --signaux pour la mémoire de debug (capture de l'érreur de l'alu)
  signal s_r3 : std_logic_vector((data_length*3 - 1) downto 0);
  

  signal   sig_ena_mem_inst : std_logic;
  constant sig_rw_mem_inst  : std_logic_vector(3 downto 0) := "0000";
  signal   sig_adr_mem_inst : std_logic_vector(data_length - 1 downto 0);
  signal   sig_val_out_inst : std_logic_vector(data_length - 1 downto 0);

  signal sig_ena_mem_data   : std_logic;
  signal sig_rw_mem_data    : std_logic_vector(3 downto 0);
  signal sig_mem_read_depth : std_logic_vector(3 downto 0);
  signal sig_adr_mem_data   : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_in_data    : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_out_data   : std_logic_vector(data_length - 1 downto 0);

  signal sig_jalr_adr             : std_logic_vector(data_length - 1 downto 0);
  signal sig_jr_adr               : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_imm_operand      : std_logic_vector(data_length - 1 downto 0);
  signal sig_sel_func_alu         : std_logic_vector(3 downto 0);
  signal sig_reg_file_write       : std_logic;
  signal sig_imm_type             : std_logic_vector(2 downto 0);
  signal sig_sel_op2              : std_logic;
  signal sig_sel_result           : std_logic_vector(1 downto 0);
  signal sig_sel_func_alu_connect : std_logic_vector(2 downto 0);
  signal sig_val_connect          : std_logic;
  signal sig_new_adr_inst         : std_logic_vector(data_length - 1 downto 0);
  signal sig_adr_inst             : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_mem_data_depth   : std_logic_vector(data_length - 1 downto 0);

  signal sig_br_jal_adr : std_logic_vector(data_length - 1 downto 0);

  signal mem             : std_logic;
  signal debug_enable    : std_logic;
  signal sig_enable      : std_logic;
  signal s_select_result : std_logic;

begin

  process (reset, clk) is
  begin

    if (reset='1') then
      mem          <= '0';
      debug_enable <= '0';
    elsif (clk='1' and clk'event) then
      mem          <= ce;
      debug_enable <= (mem xor ce) and ce;
    end if;

  end process;

  process (debug, ce, debug_enable) is
  begin

    if (debug='1') then
      sig_enable <= debug_enable;
    else                          -- Mouad Rabiai
      sig_enable <= ce;           -- Mouad Rabiai
    end if;

  end process;

  inst_mem_unit_inst : component mem_unit
    generic map (
      memory_size => Memory_size
    )
    port map (
      clk          => clk,
      boot         => inst_boot,
      ena_cpu      => sig_ena_mem_inst,
      rw_boot      => inst_rw_boot,
      rw_cpu       => sig_RW_Mem_Inst,
      adr_boot     => adr_inst_boot,
      adr_cpu      => sig_adr_inst,
      val_in_boot  => val_inst_in_boot,
      val_in_cpu   => (others => '0'),
      val_out_cpu  => sig_val_out_inst,
      val_out_boot => val_inst_out_boot
    );

  inst_mem_unit_data : component mem_unit
    generic map (
      memory_size => Memory_size
    )
    port map (
      clk          => clk,
      boot         => data_boot,
      ena_cpu      => sig_ena_mem_data,
      rw_boot      => data_rw_boot,
      rw_cpu       => sig_rw_mem_data,
      adr_boot     => adr_data_boot,
      adr_cpu      => sig_adr_mem_data,
      val_in_boot  => val_data_in_boot,
      val_in_cpu   => sig_val_in_data,
      val_out_cpu  => sig_val_out_data,
      val_out_boot => val_data_out_boot
    );

  inst_control_unit : component control_unit
    port map (
      clk                  => clk,
      reset                => reset,
      ce                   => sig_enable,
      boot                 => boot,
      val_inst             => sig_val_out_inst,
      jalr_adr             => sig_jalr_adr,
      jr_adr               => sig_jr_adr,
      br_jal_adr           => sig_br_jal_adr,
      adr_inst             => sig_adr_inst, -- valeur du pc 
      new_adr_inst         => sig_new_adr_inst,
      ena_mem_inst         => sig_ena_mem_inst,
      ena_mem_data         => sig_ena_mem_data,
      rw_mem_data          => sig_rw_mem_data,
      mem_read_depth       => sig_mem_read_depth,
      fsm_state            => fsm_state,
      adr_cpu              => sig_adr_mem_data,
      sel_func_alu         => sig_sel_func_alu,
      reg_file_write       => sig_reg_file_write,
      imm_type             => sig_imm_type,
      sel_op2              => sig_sel_op2,
      sel_result           => sig_sel_result,
      sel_func_alu_connect => sig_sel_func_alu_connect,
      val_connect          => sig_val_connect,
      select_result        => s_select_result
    );

  ----Processing Unit
  inst_processing_unit : component processing_unit
    port map (
      clk                  => clk,
      reset                => reset,
      ce                   => sig_enable,
      boot                 => boot,
      val_mem_inst         => sig_val_out_inst,
      val_mem_data         => sig_val_out_data,
      new_adr_inst         => sig_new_adr_inst,
      adr_inst             => sig_adr_inst,
      sel_func_alu         => sig_sel_func_alu,
      reg_file_write       => sig_reg_file_write,
      imm_type             => sig_imm_type,
      sel_op2              => sig_sel_op2,
      sel_result           => sig_sel_result,
      sel_func_alu_connect => sig_sel_func_alu_connect,
      val_connect          => sig_val_connect,
      mem_read_depth       => sig_mem_read_depth,

      val_mem_data_depth => sig_val_mem_data_depth,
      val_ut_adr         => sig_adr_mem_data,
      val_ut_data        => sig_val_in_data,
      val_imm_operand    => sig_val_imm_operand,
      jalr_adr           => sig_jalr_adr,
      jr_adr             => sig_jr_adr,
      br_jal_adr         => sig_br_jal_adr,
      select_result      => s_select_result,

      alu_error_capture => alu_error_capture,
      r3 => s_r3
    );

  val_mem_data_depth   <= sig_val_mem_data_depth;
  sig_adr_inst_out     <= sig_adr_inst;
  sig_val_out_inst_out <= sig_val_out_inst;
  sig_new_adr_inst_out <= sig_new_adr_inst;
  sig_adr_mem_data_out <= sig_adr_mem_data;
  sig_val_in_data_out  <= sig_val_in_data;
  sig_val_out_data_out <= sig_val_out_data;
  sig_sel_func_alu_out <= sig_sel_func_alu;
  sig_jalr_adr_out     <= sig_jalr_adr;
  sig_jr_adr_out       <= sig_jr_adr;
  sig_br_jal_adr_out   <= sig_br_jal_adr;


  -- CC

  error_msg <= sig_adr_inst & s_r3;
  

end architecture behavioral;
