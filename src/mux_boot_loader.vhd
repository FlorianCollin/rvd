library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.constants_pkg.all;

entity mux_boot_loader is
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
end entity mux_boot_loader;

architecture behavioral of mux_boot_loader is

  component mux2_1 is
    port (
      in1    : in    std_logic_vector(data_length - 1 downto 0);
      in2    : in    std_logic_vector(data_length - 1 downto 0);
      sel    : in    std_logic;
      o : out   std_logic_vector(data_length - 1 downto 0)
    );
  end component;

  -- signal sig_boot    : std_logic_vector(0 downto 0);
  -- signal sig_ena_cpu : std_logic_vector(0 downto 0);
  -- signal sig_ena_mem : std_logic_vector(0 downto 0);

  -- signal sig_rw_cpu  : std_logic_vector(3 downto 0);
  -- signal sig_rw_boot : std_logic_vector(3 downto 0);
  -- signal sig_rw_mem  : std_logic_vector(3 downto 0);

  signal sig_boot    : std_logic_vector(data_length - 1 downto 0);
  signal sig_ena_cpu : std_logic_vector(data_length - 1 downto 0);
  signal sig_ena_mem : std_logic_vector(data_length - 1 downto 0);

  signal sig_rw_cpu  : std_logic_vector(data_length - 1 downto 0);
  signal sig_rw_boot : std_logic_vector(data_length - 1 downto 0);
  signal sig_rw_mem  : std_logic_vector(data_length - 1 downto 0);

  signal sig_adr_boot : std_logic_vector(data_length - 1 downto 0);
  signal sig_adr_cpu  : std_logic_vector(data_length - 1 downto 0);
  signal sig_adr_mem  : std_logic_vector(data_length - 1 downto 0);

  signal sig_val_in_boot : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_in_cpu  : std_logic_vector(data_length - 1 downto 0);
  signal sig_val_in_mem  : std_logic_vector(data_length - 1 downto 0);

  constant octet_null : std_logic_vector(7 downto 0) := "00000000";

begin

  sig_boot(0)            <= boot;
  sig_ena_cpu(0)         <= ena_cpu;
  ena_mem                <= sig_ena_mem(0);
  sig_rw_cpu(3 downto 0) <= rw_cpu;
  rw_mem                 <= sig_rw_mem(3 downto 0);

  sig_adr_cpu <= adr_cpu;
  adr_mem     <= sig_adr_mem;

  -- sig_Val_In_CPU  <= Val_In_CPU;
  val_in_mem <= sig_val_in_mem;

  -- Memory 32 bits gestion for Boot
  process (adr_boot, rw_boot, boot, val_in_boot) is
  begin

    if (boot='1') then
      if (rw_boot ='1') then

        case (adr_boot(1 downto 0)) is

          when "11" =>

            sig_rw_boot(3 downto 0) <= "1000";
            sig_val_in_boot         <= val_in_boot & octet_null & octet_null & octet_null;

          when "10" =>

            sig_rw_boot(3 downto 0) <= "0100";
            sig_val_in_boot         <= octet_null & val_in_boot & octet_null & octet_null;

          when "01" =>

            sig_rw_boot(3 downto 0) <= "0010";
            sig_val_in_boot         <= octet_null & octet_null & val_in_boot & octet_null;

          when others =>

            sig_rw_boot(3 downto 0) <= "0001";
            sig_val_in_boot         <= octet_null & octet_null & octet_null & val_in_boot;

        end case;

        sig_adr_boot <= adr_boot((data_length - 1) downto 2) & "00";
      else

        case (adr_boot(1 downto 0)) is

          when "11" =>

            sig_rw_boot(3 downto 0) <= "0000";
            sig_val_in_boot         <= octet_null & octet_null & octet_null & octet_null;

          when "10" =>

            sig_rw_boot(3 downto 0) <= "0000";
            sig_val_in_boot         <= octet_null & octet_null & octet_null & octet_null;

          when "01" =>

            sig_rw_boot(3 downto 0) <= "0000";
            sig_val_in_boot         <= octet_null & octet_null & octet_null & octet_null;

          when others =>

            sig_rw_boot(3 downto 0) <= "0000";
            sig_val_in_boot         <= octet_null & octet_null & octet_null & octet_null;

        end case;

        sig_adr_boot <= adr_boot((data_length - 1) downto 2) & "00";
      end if;
    else
      sig_rw_boot(3 downto 0) <= "0000";
      sig_val_in_boot         <= octet_null & octet_null & octet_null & octet_null;
      sig_adr_boot            <= octet_null & octet_null & octet_null & octet_null;
    end if;

  end process;

  -- Memory 32 bits gestion de l'écriture
  process (sig_rw_cpu, val_in_cpu) is
  begin

    case (sig_rw_cpu(3 downto 0)) is

      when "0001" =>

        sig_val_in_cpu <= octet_null & octet_null & octet_null & val_in_cpu(7 downto 0);

      when "0010" =>

        sig_val_in_cpu <= octet_null & octet_null & val_in_cpu(7 downto 0) & octet_null;

      when "0100" =>

        sig_val_in_cpu <= octet_null & val_in_cpu(7 downto 0) & octet_null & octet_null;

      when "1000" =>

        sig_val_in_cpu <= val_in_cpu(7 downto 0) & octet_null & octet_null & octet_null;

      when "0011" =>

        sig_val_in_cpu <= octet_null & octet_null & val_in_cpu(15 downto 0);

      when "1100" =>

        sig_val_in_cpu <= val_in_cpu(15 downto 0) & octet_null & octet_null;

      when "1111" =>

        sig_val_in_cpu <= val_in_cpu;

      when others =>

        sig_val_in_cpu <= (others => '0');

    end case;

  end process;

  -- Mux Enable_Data
  inst_mux_ena_data : component mux2_1
    port map (
      in1    => sig_ena_cpu,
      in2    => sig_boot,
      sel    => boot,
      o => sig_ena_mem
    );

  -- Mux RW_Data
  inst_mux_rw_data : component mux2_1
    port map (
      in1    => sig_rw_cpu,
      in2    => sig_rw_boot,
      sel    => boot,
      o => sig_rw_mem
    );

  -- Mux Adr_Data
  inst_mux_adr_data : component mux2_1
    port map (
      in1    => sig_adr_cpu,
      in2    => sig_adr_boot,
      sel    => boot,
      o => sig_adr_mem
    );

  -- Mux Val_Data
  inst_mux_val_data : component mux2_1
    port map (
      in1    => sig_val_in_cpu,
      in2    => sig_val_in_boot,
      sel    => boot,
      o => sig_val_in_mem
    );

end architecture behavioral;
