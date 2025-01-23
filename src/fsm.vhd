library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity fsm is
  port (
    clk      : in    std_logic;
    reset    : in    std_logic;
    ce       : in    std_logic;
    val_inst : in    std_logic_vector((data_length - 1) downto 0);
    adr_cpu  : in    std_logic_vector((data_length - 1) downto 0);
    init_reg : in    std_logic;

    ena_mem_inst   : out   std_logic;
    ena_mem_data   : out   std_logic;
    rw_mem_data    : out   std_logic_vector(3 downto 0);
    mem_read_depth : out   std_logic_vector(3 downto 0);

    sel_func_alu         : out   std_logic_vector(3 downto 0);
    reg_file_write       : out   std_logic;
    imm_type             : out   std_logic_vector(2 downto 0);
    sel_op2              : out   std_logic;
    sel_result           : out   std_logic_vector(1 downto 0);
    sel_func_alu_connect : out   std_logic_vector(2 downto 0);
    val_connect          : in    std_logic;
    select_result        : out   std_logic;                            -- Mouad Rabiai le 03/03/2024
    load_plus4           : out   std_logic;
    fsm_state            : out   std_logic_vector(4 downto 0);
    sel_pc_mux           : out   std_logic_vector(1 downto 0)
  );
end entity fsm;

architecture behavioral of fsm is

  component decoblock is
    port (
      opcode               : in    std_logic_vector(6 downto 0);
      funct3               : in    std_logic_vector(2 downto 0);
      funct7               : in    std_logic_vector(6 downto 0);
      adr_cpu              : in    std_logic_vector((data_length - 1) downto 0);
      val_connect          : in    std_logic;
      sel_func_alu         : out   std_logic_vector(3 downto 0);
      imm_type             : out   std_logic_vector(2 downto 0);
      sel_op2              : out   std_logic;
      sel_result           : out   std_logic_vector(1 downto 0);
      sel_func_alu_connect : out   std_logic_vector(2 downto 0);
      sel_pc_mux           : out   std_logic_vector(1 downto 0);
      mem_read_depth       : out   std_logic_vector(3 downto 0);
      mem_rw_depth         : out   std_logic_vector(3 downto 0)
    );
  end component;

  type state_type is (init, fetchins, decode, exeop, exeopimm, exeaddr, exeload, exewrite, exectr, exejal, exejal2, exejalr, exelui, exeauipc, exenop, execordic, execordic2); -- , FetchOperand (a remettre si besoin)

  signal current_state, next_state : state_type;

  signal opcode         : std_logic_vector(6 downto 0);
  signal funct3         : std_logic_vector(2 downto 0);
  signal funct7         : std_logic_vector(6 downto 0);
  signal s_mem_rw_depth : std_logic_vector(3 downto 0);
  -- Mouad Rabiai
  signal s_count  : integer range 0 to 10 := 0;
  signal s_cordic : std_logic;

  signal addr : std_logic_vector((data_length - 1) downto 0);

begin

  decode0 : component decoblock
    port map (
      opcode               => opcode,
      funct3               => funct3,
      funct7               => funct7,
      adr_cpu              => adr_cpu,
      sel_func_alu         => sel_func_alu,
      imm_type             => imm_type,
      sel_op2              => sel_op2,
      sel_result           => sel_result,
      sel_func_alu_connect => sel_func_alu_connect,
      sel_pc_mux           => sel_pc_mux,
      val_connect          => val_connect,
      mem_read_depth       => mem_read_depth,
      mem_rw_depth         => s_mem_rw_depth
    );

  funct3 <= val_inst(14 downto 12);
  funct7 <= val_inst(31 downto 25);

  process (clk, reset) is
  begin

    if (reset = '1') then
      current_state <= init;
    elsif rising_edge(clk) then
      if (init_reg = '1') then
        current_state <= init;
      elsif (ce = '1') then
        current_state <= next_state;
      end if;
    end if;

  end process;

  process (current_state, opcode, s_cordic) is
  begin

    case current_state is

      when init =>

        next_state <= fetchins;

      when fetchins =>

        next_state <= decode;

      when decode =>

        if (opcode = "0110011") then
          next_state <= exeop;
        elsif (opcode = "0010011") then
          next_state <= exeopimm;
        elsif (opcode = "0000011") then
          next_state <= exeaddr;
        elsif (opcode = "0100011") then
          next_state <= exeaddr;
        elsif (opcode = "1100011") then
          next_state <= exectr;
        elsif (opcode = "1101111") then
          next_state <= exejal;
        elsif (opcode = "1100111") then
          next_state <= exejalr;
        elsif (opcode = "0110111") then
          next_state <= exelui;
        elsif (opcode = "0010111") then
          next_state <= exeauipc;
        elsif (opcode = "0001011" or opcode = "0101011") then
          next_state <= execordic;     -- Mouad Rabiai le 11/02/2024
        else
          next_state <= exenop;
        end if;

      when exeaddr =>

        if (opcode = "0000011") then
          next_state <= exeload;
        elsif (opcode = "0100011") then
          next_state <= exewrite;
        else
          next_state <= exenop;
        end if;

      when exeop =>

        next_state <= fetchins;

      when exeopimm =>

        next_state <= fetchins;

      when exeload =>

        next_state <= fetchins;

      when exewrite =>

        next_state <= fetchins;

      when exectr =>

        next_state <= fetchins;

      when exejal =>

        next_state <= exejal2;

      when exejal2 =>

        next_state <= fetchins;

      when exejalr =>

        next_state <= fetchins;

      when exelui =>

        next_state <= fetchins;

      when exeauipc =>

        next_state <= fetchins;

      when exenop =>

        next_state <= fetchins;

      -- Mouad Rabiai Le 11/02/2024
      when execordic =>

        if (s_cordic = '1') then
          next_state <= execordic2;
        else
          next_state <= execordic;
        end if;

      when execordic2 =>

        next_state <= fetchins;

    end case;

  end process;

  process (current_state, val_inst, s_mem_rw_depth) is
  begin

    case current_state is

      when init =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '0';
        -- init_counter <= '0';
        load_plus4    <= '0';
        opcode        <= "0000000";
        select_result <= '0';                  -- Mouad Rabiai

      when fetchins =>

        ena_mem_inst   <= '1';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '0';
        -- init_counter <= '0';
        load_plus4    <= '0';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when decode =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '0';
        -- init_counter <= '0';
        load_plus4    <= '0';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exeop =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exeopimm =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exeaddr =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '1';
        rw_mem_data    <= s_mem_rw_depth;
        reg_file_write <= '0';
        -- init_counter <= '0';
        load_plus4    <= '0';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exeload =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '1';
        rw_mem_data    <= s_mem_rw_depth;
        reg_file_write <= '1';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exewrite =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '1';
        rw_mem_data    <= s_mem_rw_depth;
        reg_file_write <= '0';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exectr =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '0';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exejal =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '0'; --
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exejal2 =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '0';
        -- init_counter <= '1';
        load_plus4    <= '0';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exejalr =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exelui =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exeauipc =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '0';
        load_plus4    <= '1';
        opcode        <= val_inst(6 downto 0);
        select_result <= '0';                  -- Mouad Rabiai

      when exenop =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '0';
        -- init_counter <= '1';
        load_plus4    <= '1';
        opcode        <= "0000000";
        select_result <= '0';                  -- Mouad Rabiai

      -- Mouad Rabiai Le 12/02/2024
      when execordic =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '1';
        load_plus4    <= '0';                  -- Mouad Rabiai
        opcode        <= val_inst(6 downto 0);
        select_result <= '1';                  -- Mouad Rabiai

      when execordic2 =>

        ena_mem_inst   <= '0';
        ena_mem_data   <= '0';
        rw_mem_data    <= "0000";
        reg_file_write <= '1';
        -- init_counter <= '1';
        load_plus4    <= '1';                  -- Mouad Rabiai
        opcode        <= val_inst(6 downto 0);
        select_result <= '1';                  -- Mouad Rabiai

    end case;

  end process;

  process (current_state) is
  begin

    case current_state is

      when init =>

        fsm_state <= "00000";

      when fetchins =>

        fsm_state <= "00001";

      when decode =>

        fsm_state <= "00010";

      when exeaddr =>

        fsm_state <= "00011";

      when exeop =>

        fsm_state <= "00100";

      when exeopimm =>

        fsm_state <= "00101";

      when exeload =>

        fsm_state <= "00110";

      when exewrite =>

        fsm_state <= "00111";

      when exectr =>

        fsm_state <= "01000";

      when exejal =>

        fsm_state <= "01001";

      when exejal2 =>

        fsm_state <= "01010";

      when exejalr =>

        fsm_state <= "01011";

      when exelui =>

        fsm_state <= "01101";

      when exeauipc =>

        fsm_state <= "01110";

      when exenop =>

        fsm_state <= "01111";

      -- Mouad Rabiai Le 12/02/2024
      when execordic =>

        fsm_state <= "10000";

      when execordic2 =>

        fsm_state <= "11111";
    ------------------------------------

    end case;

  end process;

  -- Mouad Rabiai Le 12/02/2024
  ------------------------------------
  process (clk, reset) is
  begin

    if (reset = '1') then
      s_cordic <= '0';
      s_count  <= 0;
    elsif (clk'event and clk='1') then
      if (ce ='1') then
        if (current_state = execordic) then
          if (s_count = 4) then
            s_cordic <= '1';
            s_count  <= 0;
          else
            s_count  <= s_count + 1;
            s_cordic <= '0';
          end if;
        else
          s_cordic <= '0'; ----------------
          s_count  <= 0;
        end if;
      end if;
    end if;

  end process;

------------------------------------

end architecture behavioral;
