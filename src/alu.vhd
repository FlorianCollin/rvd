library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity alu is
  port (
    sel_func_alu         : in    std_logic_vector(3 downto 0);
    sel_func_alu_connect : in    std_logic_vector(2 downto 0);
    operand1             : in    std_logic_vector((data_length - 1) downto 0);
    operand2             : in    std_logic_vector((data_length - 1) downto 0);
    result               : out   std_logic_vector((data_length - 1) downto 0);
    val_connect          : out   std_logic
  );
end entity alu;

architecture behavioral of alu is

begin

  process (sel_func_alu, sel_func_alu_connect, operand1, operand2) is
  begin

    case(sel_func_alu) is

      when "0001" =>                                                                                                               -- add

        result      <= std_logic_vector(signed(operand1) + signed(operand2));
        val_connect <= '0';

      when "0010" =>                                                                                                               -- sub

        result      <= std_logic_vector(signed(operand1) - signed(operand2));
        val_connect <= '0';

      when "1000" =>                                                                                                               -- Decalage logique à gauche <<

        -- case(to_integer(unsigned(Operand2()))) is
        case(to_integer(unsigned(operand2(4 downto 0)))) is

          when 0 =>

            result <= operand1;

          when 1 =>

            result <= operand1(30 downto 0) & std_logic_vector(to_unsigned(0, 1));

          when 2 =>

            result <= operand1(29 downto 0) & std_logic_vector(to_unsigned(0, 2));

          when 3 =>

            result <= operand1(28 downto 0) & std_logic_vector(to_unsigned(0, 3));

          when 4 =>

            result <= operand1(27 downto 0) & std_logic_vector(to_unsigned(0, 4));

          when 5 =>

            result <= operand1(26 downto 0) & std_logic_vector(to_unsigned(0, 5));

          when 6 =>

            result <= operand1(25 downto 0) & std_logic_vector(to_unsigned(0, 6));

          when 7 =>

            result <= operand1(24 downto 0) & std_logic_vector(to_unsigned(0, 7));

          when 8 =>

            result <= operand1(23 downto 0) & std_logic_vector(to_unsigned(0, 8));

          when 9 =>

            result <= operand1(22 downto 0) & std_logic_vector(to_unsigned(0, 9));

          when 10 =>

            result <= operand1(21 downto 0) & std_logic_vector(to_unsigned(0, 10));

          when 11 =>

            result <= operand1(20 downto 0) & std_logic_vector(to_unsigned(0, 11));

          when 12 =>

            result <= operand1(19 downto 0) & std_logic_vector(to_unsigned(0, 12));

          when 13 =>

            result <= operand1(18 downto 0) & std_logic_vector(to_unsigned(0, 13));

          when 14 =>

            result <= operand1(17 downto 0) & std_logic_vector(to_unsigned(0, 14));

          when 15 =>

            result <= operand1(16 downto 0) & std_logic_vector(to_unsigned(0, 15));

          when 16 =>

            result <= operand1(15 downto 0) & std_logic_vector(to_unsigned(0, 16));

          when 17 =>

            result <= operand1(14 downto 0) & std_logic_vector(to_unsigned(0, 17));

          when 18 =>

            result <= operand1(13 downto 0) & std_logic_vector(to_unsigned(0, 18));

          when 19 =>

            result <= operand1(12 downto 0) & std_logic_vector(to_unsigned(0, 19));

          when 20 =>

            result <= operand1(11 downto 0) & std_logic_vector(to_unsigned(0, 20));

          when 21 =>

            result <= operand1(10 downto 0) & std_logic_vector(to_unsigned(0, 21));

          when 22 =>

            result <= operand1(9 downto 0) & std_logic_vector(to_unsigned(0, 22));

          when 23 =>

            result <= operand1(8 downto 0) & std_logic_vector(to_unsigned(0, 23));

          when 24 =>

            result <= operand1(7 downto 0) & std_logic_vector(to_unsigned(0, 24));

          when 25 =>

            result <= operand1(6 downto 0) & std_logic_vector(to_unsigned(0, 25));

          when 26 =>

            result <= operand1(5 downto 0) & std_logic_vector(to_unsigned(0, 26));

          when 27 =>

            result <= operand1(4 downto 0) & std_logic_vector(to_unsigned(0, 27));

          when 28 =>

            result <= operand1(3 downto 0) & std_logic_vector(to_unsigned(0, 28));

          when 29 =>

            result <= operand1(2 downto 0) & std_logic_vector(to_unsigned(0, 29));

          when 30 =>

            result <= operand1(1 downto 0) & std_logic_vector(to_unsigned(0, 30));

          when 31 =>

            result <= operand1(0) & std_logic_vector(to_unsigned(0, 31));

          when others =>

            result <= (others => '0');

        end case;

        val_connect <= '0';

      when "1001" =>                                                                                                               -- Décalage logique à droite

        -- case(to_integer(unsigned(Operand2()))) is
        case(to_integer(unsigned(operand2(4 downto 0)))) is

          when 0 =>

            result <= operand1;

          when 1 =>

            result <= std_logic_vector(to_unsigned(0, 1)) & operand1(31  downto 1);

          when 2 =>

            result <= std_logic_vector(to_unsigned(0, 2)) & operand1(31  downto 2);

          when 3 =>

            result <= std_logic_vector(to_unsigned(0, 3)) & operand1(31  downto 3);

          when 4 =>

            result <= std_logic_vector(to_unsigned(0, 4)) & operand1(31  downto 4);

          when 5 =>

            result <= std_logic_vector(to_unsigned(0, 5)) & operand1(31  downto 5);

          when 6 =>

            result <= std_logic_vector(to_unsigned(0, 6)) & operand1(31  downto 6);

          when 7 =>

            result <= std_logic_vector(to_unsigned(0, 7)) & operand1(31  downto 7);

          when 8 =>

            result <= std_logic_vector(to_unsigned(0, 8)) & operand1(31  downto 8);

          when 9 =>

            result <= std_logic_vector(to_unsigned(0, 9)) & operand1(31  downto 9);

          when 10 =>

            result <= std_logic_vector(to_unsigned(0, 10)) & operand1(31  downto 10);

          when 11 =>

            result <= std_logic_vector(to_unsigned(0, 11)) & operand1(31  downto 11);

          when 12 =>

            result <= std_logic_vector(to_unsigned(0, 12)) & operand1(31  downto 12);

          when 13 =>

            result <= std_logic_vector(to_unsigned(0, 13)) & operand1(31  downto 13);

          when 14 =>

            result <= std_logic_vector(to_unsigned(0, 14)) & operand1(31  downto 14);

          when 15 =>

            result <= std_logic_vector(to_unsigned(0, 15)) & operand1(31  downto 15);

          when 16 =>

            result <= std_logic_vector(to_unsigned(0, 16)) & operand1(31  downto 16);

          when 17 =>

            result <= std_logic_vector(to_unsigned(0, 17)) & operand1(31  downto 17);

          when 18 =>

            result <= std_logic_vector(to_unsigned(0, 18)) & operand1(31  downto 18);

          when 19 =>

            result <= std_logic_vector(to_unsigned(0, 19)) & operand1(31  downto 19);

          when 20 =>

            result <= std_logic_vector(to_unsigned(0, 20)) & operand1(31  downto 20);

          when 21 =>

            result <= std_logic_vector(to_unsigned(0, 21)) & operand1(31  downto 21);

          when 22 =>

            result <= std_logic_vector(to_unsigned(0, 22)) & operand1(31 downto 22);

          when 23 =>

            result <= std_logic_vector(to_unsigned(0, 23)) & operand1(31 downto 23);

          when 24 =>

            result <= std_logic_vector(to_unsigned(0, 24)) & operand1(31 downto 24);

          when 25 =>

            result <= std_logic_vector(to_unsigned(0, 25)) & operand1(31 downto 25);

          when 26 =>

            result <= std_logic_vector(to_unsigned(0, 26)) & operand1(31 downto 26);

          when 27 =>

            result <= std_logic_vector(to_unsigned(0, 27)) & operand1(31 downto 27);

          when 28 =>

            result <= std_logic_vector(to_unsigned(0, 28)) & operand1(31 downto 28);

          when 29 =>

            result <= std_logic_vector(to_unsigned(0, 29)) & operand1(31 downto 29);

          when 30 =>

            result <= std_logic_vector(to_unsigned(0, 30)) & operand1(31 downto 30);

          when 31 =>

            result <= std_logic_vector(to_unsigned(0, 31)) & operand1(31);

          when others =>

            result <= (others => '0');

        end case;

        val_connect <= '0';

      when "1010" =>                                                                                                               -- Decalage arithmetique a droite

        -- case(to_integer(unsigned(Operand2()))) is
        case(to_integer(unsigned(operand2(4 downto 0)))) is

          when 0 =>

            result <= operand1;

          when 1 =>

            result(31) <= operand1(31);

            for i in 0 to 30 loop

              result(i) <= operand1(1 + i);

            end loop;

          when 2 =>

            result(31 downto 30) <= (others => operand1(31));

            for i in 0 to 29 loop

              result(i) <= operand1(2 + i);

            end loop;

          when 3 =>

            result(31 downto 29) <= (others => operand1(31));

            for i in 0 to 28 loop

              result(i) <= operand1(3 + i);

            end loop;

          when 4 =>

            result(31 downto 28) <= (others => operand1(31));

            for i in 0 to 27 loop

              result(i) <= operand1(4 + i);

            end loop;

          when 5 =>

            result(31 downto 27) <= (others => operand1(31));

            for i in 0 to 26 loop

              result(i) <= operand1(5 + i);

            end loop;

          when 6 =>

            result(31 downto 26) <= (others => operand1(31));

            for i in 0 to 25 loop

              result(i) <= operand1(6 + i);

            end loop;

          when 7 =>

            result(31 downto 25) <= (others => operand1(31));

            for i in 0 to 24 loop

              result(i) <= operand1(7 + i);

            end loop;

          when 8 =>

            result(31 downto 24) <= (others => operand1(31));

            for i in 0 to 23 loop

              result(i) <= operand1(8 + i);

            end loop;

          when 9 =>

            result(31 downto 23) <= (others => operand1(31));

            for i in 0 to 22 loop

              result(i) <= operand1(9 + i);

            end loop;

          when 10 =>

            result(31 downto 22) <= (others => operand1(31));

            for i in 0 to 21 loop

              result(i) <= operand1(10 + i);

            end loop;

          when 11 =>

            result(31 downto 21) <= (others => operand1(31));

            for i in 0 to 20 loop

              result(i) <= operand1(11 + i);

            end loop;

          when 12 =>

            result(31 downto 20) <= (others => operand1(31));

            for i in 0 to 19 loop

              result(i) <= operand1(12 + i);

            end loop;

          when 13 =>

            result(31 downto 19) <= (others => operand1(31));

            for i in 0 to 18 loop

              result(i) <= operand1(13 + i);

            end loop;

          when 14 =>

            result(31 downto 18) <= (others => operand1(31));

            for i in 0 to 17 loop

              result(i) <= operand1(14 + i);

            end loop;

          when 15 =>

            result(31 downto 17) <= (others => operand1(31));

            for i in 0 to 16 loop

              result(i) <= operand1(15 + i);

            end loop;

          when 16 =>

            result(31 downto 16) <= (others => operand1(31));

            for i in 0 to 15 loop

              result(i) <= operand1(16 + i);

            end loop;

          when 17 =>

            result(31 downto 15) <= (others => operand1(31));

            for i in 0 to 14 loop

              result(i) <= operand1(17 + i);

            end loop;

          when 18 =>

            result(31 downto 14) <= (others => operand1(31));

            for i in 0 to 13 loop

              result(i) <= operand1(18 + i);

            end loop;

          when 19 =>

            result(31 downto 13) <= (others => operand1(31));

            for i in 0 to 12 loop

              result(i) <= operand1(19 + i);

            end loop;

          when 20 =>

            result(31 downto 12) <= (others => operand1(31));

            for i in 0 to 11 loop

              result(i) <= operand1(20 + i);

            end loop;

          when 21 =>

            result(31 downto 11) <= (others => operand1(31));

            for i in 0 to 10 loop

              result(i) <= operand1(21 + i);

            end loop;

          when 22 =>

            result(31 downto 10) <= (others => operand1(31));

            for i in 0 to 9 loop

              result(i) <= operand1(22 + i);

            end loop;

          when 23 =>

            result(31 downto 9) <= (others => operand1(31));

            for i in 0 to 8 loop

              result(i) <= operand1(23 + i);

            end loop;

          when 24 =>

            result(31 downto 8) <= (others => operand1(31));

            for i in 0 to 7 loop

              result(i) <= operand1(24 + i);

            end loop;

          when 25 =>

            result(31 downto 7) <= (others => operand1(31));

            for i in 0 to 6 loop

              result(i) <= operand1(25 + i);

            end loop;

          when 26 =>

            result(31  downto 6) <= (others => operand1(31));

            for i in 0 to 5 loop

              result(i) <= operand1(26 + i);

            end loop;

          when 27 =>

            result(31 downto 5) <= (others => operand1(31));

            for i in 0 to 4 loop

              result(i) <= operand1(27 + i);

            end loop;

          when 28 =>

            result(31 downto 4) <= (others => operand1(31));

            for i in 0 to 3 loop

              result(i) <= operand1(28 + i);

            end loop;

          when 29 =>

            result(31 downto 3) <= (others => operand1(31));

            for i in 0 to 2 loop

              result(i) <= operand1(29 + i);

            end loop;

          when 30 =>

            result(31 downto 2) <= (others => operand1(31));

            for i in 0 to 1 loop

              result(i) <= operand1(30 + i);

            end loop;

          when others =>

            result <= (others => operand1(31));

        end case;

        val_connect <= '0';

      when "0111" =>                                                                                                               -- xor

        result      <= operand1 xor operand2;
        val_connect <= '0';

      when "0110" =>                                                                                                               -- or

        result      <= operand1 or operand2;
        val_connect <= '0';

      when "0101" =>                                                                                                               -- and

        result      <= operand1 and operand2;
        val_connect <= '0';

      when "0011" =>                                                                                                               -- slt = set less than

        if (signed(operand1) < signed(operand2)) then
          result <= std_logic_vector(to_unsigned(1, data_length));
        else
          result <= (others => '0');
        end if;

        val_connect <= '0';

      when "0100" =>                                                                                                               -- sltu = set less than unsigned

        if (unsigned(operand1) < unsigned(operand2)) then
          result <= std_logic_vector(to_unsigned(1, data_length));
        else
          result <= (others => '0');
        end if;

        val_connect <= '0';

      --            when "1011" => -- lui/auipc. Inutile en pratique, l'operation est faite par l'adder et le gen. imm. (a verifier)
      --                Result <= Operand1(19 downto 0) & std_logic_vector(to_unsigned(0,12));
      --                val_connect <= '0';

      when "1011" =>                                                                                                               -- lui attention utile en propageant OP2 pour immediat (C. JEGO 29/11:2023)

        result      <= operand2;
        val_connect <= '0';

      when "1100" =>                                                                                                               -- jalr

        result      <= std_logic_vector(unsigned(operand1) + unsigned(operand2)) and std_logic_vector(to_signed(-2, data_length));
        val_connect <= '0';                                                                                                        -- Pas de val_connect : la valeur va directement dans le pc

      when "0000" =>                                                                                                               -- Operations de branchement. sel_func_ALU_connect definit le type precis

        case(sel_func_alu_connect) is

          when "001" =>                                                                                                            -- beq = branch equal

            if (unsigned(operand1) = unsigned(operand2)) then
              val_connect <= '1';
            else
              val_connect <= '0';
            end if;

          when "010" =>                                                                                                            -- bne = branch not equal

            if (unsigned(operand1) /= unsigned(operand2)) then
              val_connect <= '1';
            else
              val_connect <= '0';
            end if;

          when "011" =>                                                                                                            -- blt = branch less than signed

            if (signed(operand1) < signed(operand2)) then
              val_connect <= '1';
            else
              val_connect <= '0';
            end if;

          when "100" =>                                                                                                            -- bge = branch greater or equal signed

            if (signed(operand1) >= signed(operand2)) then
              val_connect <= '1';
            else
              val_connect <= '0';
            end if;

          when "101" =>                                                                                                            -- bltu = branch less than unsigned

            if (unsigned(operand1) < unsigned(operand2)) then
              val_connect <= '1';
            else
              val_connect <= '0';
            end if;

          when "110" =>                                                                                                            -- bgeu = branch greater or equal unsigned

            if (unsigned(operand1) >= unsigned(operand2)) then
              val_connect <= '1';
            else
              val_connect <= '0';
            end if;

          when others =>

            val_connect <= '0';

        end case;

        result <= (others => '0');

      when others =>                                                                                                               -- "1101" to "1111"

        result      <= (others => '0');
        val_connect <= '0';

    end case;

  end process;

end architecture behavioral;
