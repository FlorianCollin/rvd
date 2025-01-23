library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity processing_unit is
  port (
    clk            : in    std_logic;
    reset          : in    std_logic;
    ce             : in    std_logic;
    boot           : in    std_logic;
    val_mem_inst   : in    std_logic_vector((data_length - 1) downto 0);
    val_mem_data   : in    std_logic_vector((data_length - 1) downto 0);
    mem_read_depth : in    std_logic_vector(3 downto 0);
    new_adr_inst   : in    std_logic_vector((data_length - 1) downto 0);
    adr_inst       : in    std_logic_vector((data_length - 1) downto 0);

    sel_func_alu         : in    std_logic_vector(3 downto 0);
    reg_file_write       : in    std_logic;
    imm_type             : in    std_logic_vector(2 downto 0);
    sel_op2              : in    std_logic;
    sel_result           : in    std_logic_vector(1 downto 0);
    sel_func_alu_connect : in    std_logic_vector(2 downto 0);
    val_connect          : out   std_logic;

    val_mem_data_depth : out   std_logic_vector((data_length - 1) downto 0);
    val_ut_adr         : out   std_logic_vector((data_length - 1) downto 0);
    val_ut_data        : out   std_logic_vector((data_length - 1) downto 0);
    val_imm_operand    : out   std_logic_vector((data_length - 1) downto 0);
    jalr_adr           : out   std_logic_vector((data_length - 1) downto 0);
    jr_adr             : out   std_logic_vector((data_length - 1) downto 0);
    br_jal_adr         : out   std_logic_vector((data_length - 1) downto 0);
    select_result      : in    std_logic; -- Mouad Rabiai le 04/03/2024
    --CC
    -- on sort les signaux de alu3 pour ammener les données dans la mémoire de débug.
    alu_error_capture : out std_logic;
    r3 : out std_logic_vector((data_length*3 - 1) downto 0)
  );
end entity processing_unit;

architecture behavioral of processing_unit is

  -- component alu is
  --   port (
  --     sel_func_alu         : in    std_logic_vector(3 downto 0);
  --     sel_func_alu_connect : in    std_logic_vector(2 downto 0);
  --     operand1             : in    std_logic_vector((data_length - 1) downto 0);
  --     operand2             : in    std_logic_vector((data_length - 1) downto 0);
  --     result               : out   std_logic_vector((data_length - 1) downto 0);
  --     val_connect          : out   std_logic
  --   );
  -- end component;

  -- CC
  component alu3 is
    port (
      sel_func_alu         : in    std_logic_vector(3 downto 0);
      sel_func_alu_connect : in    std_logic_vector(2 downto 0);
      operand1             : in    std_logic_vector((data_length - 1) downto 0);
      operand2             : in    std_logic_vector((data_length - 1) downto 0);
      result               : out   std_logic_vector((data_length - 1) downto 0);
      val_connect          : out   std_logic;
      alu_error_capture    : out   std_logic;
      r3                   : out   std_logic_vector((data_length*3 - 1) downto 0)  -- Concatenation des trois signaux de resultat
    );
  end component;

  component register_file is
    port (
      clk            : in    std_logic;
      reset          : in    std_logic;
      ce             : in    std_logic;
      init_reg       : in    std_logic;
      reg_file_write : in    std_logic;
      read_adr1      : in    std_logic_vector(4 downto 0);
      read_adr2      : in    std_logic_vector(4 downto 0);
      write_adr      : in    std_logic_vector(4 downto 0);
      data_read1     : out   std_logic_vector((data_length - 1) downto 0);
      data_read2     : out   std_logic_vector((data_length - 1) downto 0);
      data_write     : in    std_logic_vector((data_length - 1) downto 0)
    );
  end component;

  component imm_gen is
    port (
      imm_val     : in    std_logic_vector(24 downto 0);
      imm_type    : in    std_logic_vector(2 downto 0);
      imm_operand : out   std_logic_vector((data_length - 1) downto 0)
    );
  end component;

  component mux2_1 is
    port (
      in1    : in    std_logic_vector((data_length - 1) downto 0);
      in2    : in    std_logic_vector((data_length - 1) downto 0);
      sel    : in    std_logic;
      o : out   std_logic_vector((data_length - 1) downto 0)
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

  component adder is
    port (
      operand_1 : in    std_logic_vector(data_length - 1 downto 0);
      operand_2 : in    std_logic_vector(data_length - 1 downto 0);
      result    : out   std_logic_vector(data_length - 1 downto 0)
    );
  end component;

  component data_to_processing is
    port (
      mem_read_depth : in    std_logic_vector(3 downto 0);
      val_in         : in    std_logic_vector((data_length - 1) downto 0);
      offset         : in    std_logic_vector(1 downto 0);
      val_out        : out   std_logic_vector((data_length - 1) downto 0)
    );
  end component;
  
  -- CC : pour ce projet on n'utilisera pas le cordic
  -- component cordic_final is
  --   port (
  --     operand2     : in    std_logic_vector(data_length - 1 downto 0);
  --     sel_func_alu : in    std_logic_vector(3 downto 0);
  --     resultat     : out   std_logic_vector(data_length - 1 downto 0);
  --     clk          : in    std_logic;
  --     reset_x      : in    std_logic;
  --     clk_enable   : in    std_logic
  --   );
  -- end component;

  signal sig_operand_1_cordic : std_logic_vector((data_length - 1) downto 0);

  signal sig_operand1       : std_logic_vector((data_length - 1) downto 0);
  signal sig_operand2       : std_logic_vector((data_length - 1) downto 0);
  signal sig_operand2_mux   : std_logic_vector((data_length - 1) downto 0);
  signal sig_result         : std_logic_vector((data_length - 1) downto 0);
  signal sig_reg_data_write : std_logic_vector((data_length - 1) downto 0);
  signal sig_imm_operand    : std_logic_vector((data_length - 1) downto 0);
  signal sig_val_mem_data   : std_logic_vector((data_length - 1) downto 0);

  signal s_resultat       : std_logic_vector(data_length - 1 downto 0) := (others => '0'); -- CC pour simplifier l'enlèvement du cordic !
  signal s_resultat_final : std_logic_vector(data_length - 1 downto 0); -- Mouad Rabiai le 04/03/2024
  signal sig_auipc_out    : std_logic_vector(data_length - 1 downto 0);

begin

  -- inst_alu : component alu
  --   port map (
  --     sel_func_alu         => sel_func_alu,
  --     sel_func_alu_connect => sel_func_alu_connect,
  --     operand1             => sig_operand1,
  --     operand2             => sig_operand2,
  --     result               => sig_result,
  --     val_connect          => val_connect
  --   );

  inst_alu3: component alu3
  port map (
    sel_func_alu          => sel_func_alu,
    sel_func_alu_connect  => sel_func_alu_connect,
    operand1              => sig_operand1,             
    operand2              => sig_operand2,             
    result                => sig_result,               
    val_connect           => val_connect,     
    alu_error_capture     => alu_error_capture,    
    r3                    => r3                   
  );

  val_ut_adr <= s_resultat_final;
  jalr_adr   <= s_resultat_final;
  jr_adr     <= sig_operand1;

  inst_register_file : component register_file
    port map (
      clk            => clk,
      reset          => reset,
      ce             => ce,
      init_reg       => boot,
      reg_file_write => reg_file_write,
      read_adr1      => val_mem_inst(19 downto 15),
      read_adr2      => val_mem_inst(24 downto 20),
      write_adr      => val_mem_inst(11 downto 7),
      data_read1     => sig_operand1,
      data_read2     => sig_operand2_mux,
      data_write     => sig_reg_data_write
    );

  val_ut_data <= sig_operand2_mux;

  inst_imm_gen : component imm_gen
    port map (
      imm_val     => val_mem_inst(31 downto 7),
      imm_type    => imm_type,
      imm_operand => sig_imm_operand
    );

  val_imm_operand <= sig_imm_operand;

  inst_mux_operand2 : component mux2_1
    port map (
      in1    => sig_operand2_mux,
      in2    => sig_imm_operand,
      sel    => sel_op2,
      o => sig_operand2
    );

  -- Mux Resut ALU
  inst_mux_result : component mux4_1
    port map (
      in1    => s_resultat_final,
      in2    => sig_val_mem_data,
      in3    => new_adr_inst,
      in4    => sig_auipc_out,
      sel    => sel_result,
      o => sig_reg_data_write
    );

  inst_adder : component adder
    port map (
      operand_1 => sig_imm_operand,
      operand_2 => adr_inst,
      result    => sig_auipc_out
    );

  inst_datattoprocessing : component data_to_processing
    port map (
      mem_read_depth => mem_read_depth,
      val_in         => val_mem_data,
      offset         => sig_result(1 downto 0),
      val_out        => sig_val_mem_data
    );

  val_mem_data_depth <= sig_val_mem_data;

  br_jal_adr <= sig_auipc_out;

  process (sig_operand1, sig_operand2, sel_op2) is
  begin

    if (sel_op2 = '1') then
      sig_operand_1_cordic <= sig_operand2;
    else
      sig_operand_1_cordic <= sig_operand1;
    end if;

  end process;

  

  -- inst_cordic_final : component cordic_final
  --   port map (
  --     operand2     => sig_operand_1_cordic,
  --     sel_func_alu => sel_func_alu,
  --     resultat     => s_resultat,
  --     clk          => clk,
  --     reset_x      => reset,
  --     clk_enable   => ce
  --   );

  inst_mux_resultat : component mux2_1
    port map (
      in2    => s_resultat,
      in1    => sig_result,
      sel    => select_result,
      o => s_resultat_final
    );

end architecture behavioral;
