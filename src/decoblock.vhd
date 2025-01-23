library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity decoblock is
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
end entity decoblock;

architecture behavioral of decoblock is

begin

  process (opcode, funct3, funct7, val_connect, adr_cpu) is
  begin

    case opcode is

      when "0110011" =>                    -- Op reg-reg

        -- signaux communs a chaque instruction reg-reg
        imm_type             <= "000";     -- Type R
        sel_op2              <= '0';       -- '00' si rs2, '01' si imm, "10" si auipc
        sel_result           <= "00";
        sel_pc_mux           <= "00";      -- 01 pour les branchements et jal, 10 pour mettre a 0 le pc, 11 pour jalr, 00 sinon
        sel_func_alu_connect <= "000";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";
        -- calcul du signal pour chaque instruction
        case funct3 is

          when "000" =>

            if (funct7="0100000") then
              sel_func_alu <= "0010";      -- sub
            elsif (funct7="0000000") then
              sel_func_alu <= "0001";      -- add
            else
              sel_func_alu <= "0000";      -- nop
            end if;

          when "001" =>

            sel_func_alu <= "1000";        -- sll

          when "010" =>

            sel_func_alu <= "0011";        -- slt

          when "011" =>

            sel_func_alu <= "0100";        -- sltu

          when "100" =>

            sel_func_alu <= "0111";        -- xor

          when "101" =>

            if (funct7="0100000") then
              sel_func_alu <= "1010";      -- sra
            elsif (funct7="0000000") then
              sel_func_alu <= "1001";      -- srl
            else
              sel_func_alu <= "0000";      -- nop
            end if;

          when "110" =>

            sel_func_alu <= "0110";        -- or

          when "111" =>

            sel_func_alu <= "0101";        -- and

          when others =>

            sel_func_alu <= "0000";        -- nop

        end case;

      when "0010011" =>                    -- Op reg-imm

        -- signaux communs a chaque instruction reg-imm
        imm_type             <= "001";     -- Type I
        sel_op2              <= '1';
        sel_result           <= "00";
        sel_pc_mux           <= "00";      -- 01 pour les branchements, 10 pour jal, 00 sinon
        sel_func_alu_connect <= "000";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";
        -- signal a modifier pour chaque instruction
        case funct3 is

          when "000" =>                    -- addi

            sel_func_alu <= "0001";

          when "010" =>                    -- slti

            sel_func_alu <= "0011";

          when "011" =>                    -- sltiu

            sel_func_alu <= "0100";

          when "111" =>                    -- andi

            sel_func_alu <= "0101";

          when "110" =>                    -- ori

            sel_func_alu <= "0110";

          when "100" =>                    -- xori

            sel_func_alu <= "0111";

          when "001" =>                    -- slli

            sel_func_alu <= "1000";

          when "101" =>

            if (funct7="0000000") then     -- srli
              sel_func_alu <= "1001";
            elsif (funct7="0100000") then  -- srai
              sel_func_alu <= "1010";
            else
              sel_func_alu <= "0000";      -- nop
            end if;

          when others =>

            sel_func_alu <= "0000";

        end case;

      when "0000011" =>                    -- Op load

        -- signaux communs a chaque instruction load
        imm_type             <= "001";     -- Type I
        sel_op2              <= '1';
        sel_result           <= "01";      -- 00 pour l'ALU, 01 pour m�moire et 10 pour PC
        sel_pc_mux           <= "00";      -- 01 pour les branchements, 10 pour jal, 00 sinon
        sel_func_alu_connect <= "000";
        sel_func_alu         <= "0001";
        mem_rw_depth         <= "0000";

        -- signal a modifier pour chaque instruction
        case funct3 is

          when "000" =>                    -- lb

            sel_func_alu   <= "0001";
            mem_read_depth <= "0001";

          when "001" =>                    -- lh

            sel_func_alu   <= "0001";
            mem_read_depth <= "0011";

          when "010" =>                    -- lw

            sel_func_alu   <= "0001";
            mem_read_depth <= "0111";

          when "100" =>                    -- lbu

            sel_func_alu   <= "0001";
            mem_read_depth <= "1001";

          when "101" =>                    -- lhu

            sel_func_alu   <= "0001";
            mem_read_depth <= "1011";

          when others =>

            sel_func_alu   <= "0000";
            mem_read_depth <= "0000";

        end case;

      when "0100011" =>                    -- Op Write

        -- signaux communs a chaque instruction write
        imm_type             <= "010";     -- Type S
        sel_op2              <= '1';
        sel_result           <= "01";      -- 00 pour l'ALU, 01 pour memoire et 10 pour PC
        sel_pc_mux           <= "00";      -- 01 pour les branchements, 10 pour jal, 00 sinon
        sel_func_alu_connect <= "000";
        sel_func_alu         <= "0001";
        mem_read_depth       <= "0000";
        -- signal a modifier pour chaque instruction
        case funct3 is

          when "000" =>                    -- sb = save byte

            sel_func_alu <= "0001";
            --                                                        mem_rw_depth <= "0001"; --01
            case (adr_cpu(1 downto 0)) is

              when "01" =>

                mem_rw_depth <= "0010";

              when "10" =>

                mem_rw_depth <= "0100";

              when "11" =>

                mem_rw_depth <= "1000";

              when others =>

                mem_rw_depth <= "0001";

            end case;

          when "001" =>                    -- sh = save half

            sel_func_alu <= "0001";
            --                                                       mem_rw_depth <= "0011"; --10
            case (adr_cpu(1)) is

              when '1' =>

                mem_rw_depth <= "1100";

              when others =>

                mem_rw_depth <= "0011";

            end case;

          when "010" =>                    -- sw = save word

            sel_func_alu <= "0001";
            mem_rw_depth <= "1111";        -- 11

          when others =>

            sel_func_alu <= "0000";
            mem_rw_depth <= "0000";

        end case;

      when "1100011" =>                    -- Op control

        -- signaux communs a chaque instruction control
        imm_type       <= "011";           -- Type B
        sel_op2        <= '0';
        sel_result     <= "10";            -- 00 pour l'ALU, 01 pour m�moire et 10 pour PC
        sel_func_alu   <= "0000";
        mem_rw_depth   <= "0000";
        mem_read_depth <= "0000";
        -- signal a modifier pour chaque instruction
        case funct3 is

          when "000" =>                    -- beq

            sel_func_alu_connect <= "001";

          when "001" =>                    -- bne

            sel_func_alu_connect <= "010";

          when "100" =>                    -- blt

            sel_func_alu_connect <= "011";

          when "101" =>                    -- bge

            sel_func_alu_connect <= "100";

          when "110" =>                    -- bltu

            sel_func_alu_connect <= "101";

          when "111" =>                    -- bgeu

            sel_func_alu_connect <= "110";

          when others =>

            sel_func_alu_connect <= "000";

        end case;

        -- branchement
        if (val_connect = '1') then
          sel_pc_mux <= "01";              -- 01 pour les branchements, 10 pour jal, 00 sinon
        else
          sel_pc_mux <= "00";              -- on continue normalement
        end if;

      when "1101111" =>                    -- Op Jal

        imm_type             <= "101";     -- Type J
        sel_op2              <= '0';
        sel_result           <= "10";      -- 00 pour l'ALU, 01 pour memoire et 10 pour PC
        sel_pc_mux           <= "01";      -- 01 pour les branchementset jal, 10 pour mettre le pc a 0, 11 pour jalr, 00 sinon
        sel_func_alu_connect <= "000";
        sel_func_alu         <= "0000";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";

      when "1100111" =>                    -- Op Jalr

        imm_type             <= "001";     -- Type I
        sel_op2              <= '1';
        sel_result           <= "10";      -- 00 pour l'ALU, 01 pour memoire, 10 pour PC et 11 pour l'Adder
        sel_pc_mux           <= "11";      -- 01 pour les branchements et jal, 10 pour mettre a 0 le pc, 11 pour jalr, 00 sinon
        sel_func_alu_connect <= "000";
        sel_func_alu         <= "1100";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";

      when "0110111" =>                    -- Op Lui

        imm_type             <= "100";     -- Type U
        sel_op2              <= '1';
        sel_result           <= "00";      -- 00 pour l'ALU, 01 pour memoire, 10 pour PC et 11 pour l'Adder
        sel_pc_mux           <= "00";      -- 01 pour les branchements et jal, 10 pour mettre a 0 le pc, 11 pour jalr, 00 sinon
        sel_func_alu_connect <= "000";
        sel_func_alu         <= "1011";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";

      when "0010111" =>                    -- Op Auipc

        imm_type             <= "100";     -- Type U
        sel_op2              <= '0';
        sel_result           <= "11";      -- 00 pour l'ALU, 01 pour memoire, 10 pour PC et 11 pour l'Adder
        sel_pc_mux           <= "00";      -- 01 pour les branchements et jal, 10 pour mettre a 0 le pc, 11 pour jalr, 00 sinon
        sel_func_alu_connect <= "000";
        sel_func_alu         <= "1011";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";

      -- Mouad Rabiai le 11/02/2024
      ---------------------------------------------------------------------------------------------------
      when "0001011" =>                    -- op cordic

        imm_type             <= "000";     -- Type R
        sel_op2              <= '0';       -- '00' si rs2, '01' si imm, "10" si auipc
        sel_result           <= "00";
        sel_pc_mux           <= "00";      -- 01 pour les branchements et jal, 10 pour mettre a 0 le pc, 11 pour jalr, 00 sinon
        sel_func_alu_connect <= "000";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";

        case funct7 is

          when "0000000" =>

            case(funct3) is

              when "000" =>

                sel_func_alu <= "0001";    -- corcos

              when "001" =>

                sel_func_alu <= "0010";    -- corsin

              when "010" =>

                sel_func_alu <= "0011";    -- cortan

              when "011" =>

                sel_func_alu <= "0100";    -- coracos

              when "100" =>

                sel_func_alu <= "0101";    -- corasin

              when "101" =>

                sel_func_alu <= "0110";    -- coratan

              when others =>

                sel_func_alu <= "0000";

            end case;

          when "0000001" =>

            case(funct3) is

              when "000" =>

                sel_func_alu <= "0111";    -- cormul

              when "001" =>

                sel_func_alu <= "1000";    -- cordiv

              when "010" =>

                sel_func_alu <= "1001";    -- corexp

              when "011" =>

                sel_func_alu <= "1010";    -- corln

              when "100" =>

                sel_func_alu <= "1011";    -- corsqrt

              when others =>

                sel_func_alu <= "0000";

            end case;

          when others =>

            sel_func_alu <= "0000";

        end case;

      when "0101011" =>                    -- op cordic imm

        imm_type             <= "001";     -- Type I
        sel_op2              <= '1';
        sel_result           <= "00";
        sel_pc_mux           <= "00";      -- 01 pour les branchements, 10 pour jal, 00 sinon
        sel_func_alu_connect <= "000";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";

        case funct3 is

          when "000" =>

            sel_func_alu <= "0001";        -- corcosimm

          when "001" =>

            sel_func_alu <= "0010";        -- corsin_imm

          when "010" =>

            sel_func_alu <= "0011";        -- cortan_imm

          when "011" =>

            sel_func_alu <= "0100";        -- coracos_imm

          when "100" =>

            sel_func_alu <= "0101";        -- corasin_imm

          when "101" =>

            sel_func_alu <= "0110";        -- coratan_imm

          when "110" =>

            sel_func_alu <= "0111";        -- cormul_imm

          when "111" =>

            sel_func_alu <= "1000";        -- cordiv_imm

          when others =>

            sel_func_alu <= "0000";

        end case;

      -------------------------------------------------------------------------------------------------------------------------------------
      when others =>

        imm_type             <= "000";
        sel_op2              <= '0';
        sel_result           <= "00";
        sel_pc_mux           <= "00";
        sel_func_alu_connect <= "000";
        sel_func_alu         <= "0000";
        mem_rw_depth         <= "0000";
        mem_read_depth       <= "0000";

    end case;

  end process;

end architecture behavioral;
