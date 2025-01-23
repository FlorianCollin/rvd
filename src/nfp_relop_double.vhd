------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity nfp_relop_double is
  port (
    clk      : in    std_logic;
    reset_x  : in    std_logic;
    enb      : in    std_logic;
    nfp_in1  : in    std_logic_vector(63 downto 0); -- ufix64
    nfp_in2  : in    std_logic_vector(63 downto 0); -- ufix64
    nfp_out1 : out   std_logic                      -- ufix1
  );
end entity nfp_relop_double;

architecture rtl of nfp_relop_double is

  -- Signals
  signal constant_out1                : std_logic;             -- ufix1
  signal constant1_out1               : unsigned(7 downto 0);  -- uint8
  signal relational_operator_relop1   : std_logic;
  signal delay1_out1                  : std_logic;
  signal logical_operator1_out1       : std_logic;
  signal logical_operator_out1        : std_logic;
  signal add_out1                     : unsigned(7 downto 0);  -- uint8
  signal delay_out1                   : unsigned(7 downto 0);  -- uint8
  signal add_add_cast                 : unsigned(7 downto 0);  -- ufix8
  signal logical_operator_out1_1      : std_logic;
  signal nfp_in1_unsigned             : unsigned(63 downto 0); -- ufix64
  signal as                           : std_logic;             -- ufix1
  signal ae                           : unsigned(10 downto 0); -- ufix11
  signal am                           : unsigned(51 downto 0); -- ufix52
  signal delay1_ps_1_out1             : unsigned(51 downto 0); -- ufix52
  signal compare_to_zero2_out1        : std_logic;
  signal logical_operator1_out1_1     : std_logic;
  signal delay_ps_1_out1              : unsigned(10 downto 0); -- ufix11
  signal nfp_in2_unsigned             : unsigned(63 downto 0); -- ufix64
  signal bs                           : std_logic;             -- ufix1
  signal be                           : unsigned(10 downto 0); -- ufix11
  signal bm                           : unsigned(51 downto 0); -- ufix52
  signal delay5_ps_1_out1             : unsigned(51 downto 0); -- ufix52
  signal compare_to_zero3_out1        : std_logic;
  signal logical_operator4_out1       : std_logic;
  signal delay4_ps_1_out1             : unsigned(10 downto 0); -- ufix11
  signal compare_to_constant_out1     : std_logic;
  signal logical_operator2_out1       : std_logic;
  signal compare_to_constant1_out1    : std_logic;
  signal logical_operator3_out1       : std_logic;
  signal logical_operator5_out1       : std_logic;
  signal delay1_ps_2_out1             : std_logic;
  signal compare_to_zero_out1         : std_logic;
  signal compare_to_zero1_out1        : std_logic;
  signal logical_operator_out1_2      : std_logic;
  signal delay_ps_2_out1              : std_logic;
  signal delay2_ps_1_out1             : std_logic;             -- ufix1
  signal delay3_ps_1_out1             : std_logic;             -- ufix1
  signal relational_operator1_relop1  : std_logic;
  signal relational_operator3_relop1  : std_logic;
  signal relational_operator5_relop1  : std_logic;
  signal logical_operator6_out1       : std_logic;
  signal delay1_ps_2_out1_1           : std_logic;
  signal logical_operator_out1_3      : std_logic;
  signal delay_ps_3_out1              : std_logic;
  signal logical_operator2_out1_1     : std_logic;
  signal relational_operator_relop1_1 : std_logic;
  signal compare_to_constant_out1_1   : std_logic;
  signal logical_operator1_out1_2     : std_logic;
  signal relational_operator2_relop1  : std_logic;
  signal relational_operator4_relop1  : std_logic;
  signal logical_operator3_out1_1     : std_logic;
  signal logical_operator2_out1_2     : std_logic;
  signal logical_operator4_out1_1     : std_logic;
  signal logical_operator5_out1_1     : std_logic;
  signal switch_out1                  : std_logic;
  signal logical_operator_out1_4      : std_logic;
  signal delay_ps_2_out1_1            : std_logic;
  signal delay2_ps_3_out1             : std_logic;
  signal logical_operator1_out1_3     : std_logic;
  signal delay1_ps_3_out1             : std_logic;
  signal logical_operator3_out1_2     : std_logic;
  signal constant_out1_1              : std_logic;
  signal switch1_out1                 : std_logic;

begin

  constant_out1 <= '1';

  constant1_out1 <= to_unsigned(16#03#, 8);

  delay1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay1_out1 <= '0';
      elsif (enb = '1') then
        delay1_out1 <= relational_operator_relop1;
      end if;
    end if;

  end process delay1_process;

  logical_operator1_out1 <= NOT delay1_out1;

  logical_operator_out1 <= constant_out1 and logical_operator1_out1;

  delay_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay_out1 <= to_unsigned(16#00#, 8);
      elsif (enb = '1') then
        delay_out1 <= add_out1;
      end if;
    end if;

  end process delay_process;

  add_add_cast <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & logical_operator_out1;
  add_out1     <= delay_out1 + add_add_cast;

  relational_operator_relop1 <= '1' when add_out1 > constant1_out1 else
                                '0';

  logical_operator_out1_1 <= NOT relational_operator_relop1;

  nfp_in1_unsigned <= unsigned(nfp_in1);

  -- Split 64 bit word into FP sign, exponent, mantissa
  as <= nfp_in1_unsigned(63);
  ae <= nfp_in1_unsigned(62 downto 52);
  am <= nfp_in1_unsigned(51 downto 0);

  delay1_ps_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay1_ps_1_out1 <= to_unsigned(0, 52);
      elsif (enb = '1') then
        delay1_ps_1_out1 <= am;
      end if;
    end if;

  end process delay1_ps_1_process;

  compare_to_zero2_out1 <= '1' when delay1_ps_1_out1 = to_unsigned(0, 52) else
                           '0';

  logical_operator1_out1_1 <= NOT compare_to_zero2_out1;

  delay_ps_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay_ps_1_out1 <= to_unsigned(16#000#, 11);
      elsif (enb = '1') then
        delay_ps_1_out1 <= ae;
      end if;
    end if;

  end process delay_ps_1_process;

  nfp_in2_unsigned <= unsigned(nfp_in2);

  -- Split 64 bit word into FP sign, exponent, mantissa
  bs <= nfp_in2_unsigned(63);
  be <= nfp_in2_unsigned(62 downto 52);
  bm <= nfp_in2_unsigned(51 downto 0);

  delay5_ps_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay5_ps_1_out1 <= to_unsigned(0, 52);
      elsif (enb = '1') then
        delay5_ps_1_out1 <= bm;
      end if;
    end if;

  end process delay5_ps_1_process;

  compare_to_zero3_out1 <= '1' when delay5_ps_1_out1 = to_unsigned(0, 52) else
                           '0';

  logical_operator4_out1 <= NOT compare_to_zero3_out1;

  delay4_ps_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay4_ps_1_out1 <= to_unsigned(16#000#, 11);
      elsif (enb = '1') then
        delay4_ps_1_out1 <= be;
      end if;
    end if;

  end process delay4_ps_1_process;

  compare_to_constant_out1 <= '1' when delay_ps_1_out1 = to_unsigned(16#7FF#, 11) else
                              '0';

  logical_operator2_out1 <= logical_operator1_out1_1 and compare_to_constant_out1;

  compare_to_constant1_out1 <= '1' when delay4_ps_1_out1 = to_unsigned(16#7FF#, 11) else
                               '0';

  logical_operator3_out1 <= logical_operator4_out1 and compare_to_constant1_out1;

  logical_operator5_out1 <= logical_operator2_out1 or logical_operator3_out1;

  delay1_ps_2_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay1_ps_2_out1 <= '0';
      elsif (enb = '1') then
        delay1_ps_2_out1 <= logical_operator5_out1;
      end if;
    end if;

  end process delay1_ps_2_process;

  compare_to_zero_out1 <= '1' when delay_ps_1_out1 = to_unsigned(16#000#, 11) else
                          '0';

  compare_to_zero1_out1 <= '1' when delay4_ps_1_out1 = to_unsigned(16#000#, 11) else
                           '0';

  logical_operator_out1_2 <= compare_to_zero3_out1 and (compare_to_zero2_out1 and (compare_to_zero_out1 and compare_to_zero1_out1));

  delay_ps_2_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay_ps_2_out1 <= '0';
      elsif (enb = '1') then
        delay_ps_2_out1 <= logical_operator_out1_2;
      end if;
    end if;

  end process delay_ps_2_process;

  delay2_ps_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay2_ps_1_out1 <= '0';
      elsif (enb = '1') then
        delay2_ps_1_out1 <= as;
      end if;
    end if;

  end process delay2_ps_1_process;

  delay3_ps_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay3_ps_1_out1 <= '0';
      elsif (enb = '1') then
        delay3_ps_1_out1 <= bs;
      end if;
    end if;

  end process delay3_ps_1_process;

  relational_operator1_relop1 <= '1' when delay2_ps_1_out1 = delay3_ps_1_out1 else
                                 '0';

  relational_operator3_relop1 <= '1' when delay_ps_1_out1 = delay4_ps_1_out1 else
                                 '0';

  relational_operator5_relop1 <= '1' when delay1_ps_1_out1 = delay5_ps_1_out1 else
                                 '0';

  logical_operator6_out1 <= relational_operator5_relop1 and (relational_operator1_relop1 and relational_operator3_relop1);

  delay1_ps_2_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay1_ps_2_out1_1 <= '0';
      elsif (enb = '1') then
        delay1_ps_2_out1_1 <= logical_operator6_out1;
      end if;
    end if;

  end process delay1_ps_2_1_process;

  logical_operator_out1_3 <= delay_ps_2_out1 or delay1_ps_2_out1_1;

  delay_ps_3_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay_ps_3_out1 <= '0';
      elsif (enb = '1') then
        delay_ps_3_out1 <= logical_operator_out1_3;
      end if;
    end if;

  end process delay_ps_3_process;

  logical_operator2_out1_1 <= NOT delay_ps_3_out1;

  relational_operator_relop1_1 <= '1' when delay2_ps_1_out1 < delay3_ps_1_out1 else
                                  '0';

  compare_to_constant_out1_1 <= '1' when delay3_ps_1_out1 = '1' else
                                '0';

  logical_operator1_out1_2 <= compare_to_constant_out1_1 and relational_operator1_relop1;

  relational_operator2_relop1 <= '1' when delay_ps_1_out1 > delay4_ps_1_out1 else
                                 '0';

  relational_operator4_relop1 <= '1' when delay1_ps_1_out1 > delay5_ps_1_out1 else
                                 '0';

  logical_operator3_out1_1 <= relational_operator3_relop1 and relational_operator4_relop1;

  logical_operator2_out1_2 <= relational_operator2_relop1 or logical_operator3_out1_1;

  logical_operator4_out1_1 <= relational_operator1_relop1 and logical_operator2_out1_2;

  logical_operator5_out1_1 <= NOT logical_operator4_out1_1;

  switch_out1 <= logical_operator4_out1_1 when logical_operator1_out1_2 = '0' else
                 logical_operator5_out1_1;

  logical_operator_out1_4 <= relational_operator_relop1_1 or switch_out1;

  delay_ps_2_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay_ps_2_out1_1 <= '0';
      elsif (enb = '1') then
        delay_ps_2_out1_1 <= logical_operator_out1_4;
      end if;
    end if;

  end process delay_ps_2_1_process;

  delay2_ps_3_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay2_ps_3_out1 <= '0';
      elsif (enb = '1') then
        delay2_ps_3_out1 <= delay1_ps_2_out1;
      end if;
    end if;

  end process delay2_ps_3_process;

  logical_operator1_out1_3 <= logical_operator_out1_1 or delay2_ps_3_out1;

  delay1_ps_3_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        delay1_ps_3_out1 <= '0';
      elsif (enb = '1') then
        delay1_ps_3_out1 <= delay_ps_2_out1_1;
      end if;
    end if;

  end process delay1_ps_3_process;

  logical_operator3_out1_2 <= logical_operator2_out1_1 and delay1_ps_3_out1;

  constant_out1_1 <= '0';

  switch1_out1 <= logical_operator3_out1_2 when logical_operator1_out1_3 = '0' else
                  constant_out1_1;

  nfp_out1 <= switch1_out1;

end architecture rtl;

