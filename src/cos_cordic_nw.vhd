library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity cos_cordic_nw is
  port (
    clk     : in    std_logic;
    reset_x : in    std_logic;
    enb     : in    std_logic;
    angle   : in    std_logic_vector(31 downto 0); -- sfix32_En24
    cos     : out   std_logic_vector(31 downto 0)  -- sfix32_En30
  );
end entity cos_cordic_nw;

architecture rtl of cos_cordic_nw is

  -- Signals
  signal angle_signed                          : signed(31 downto 0);       -- sfix32_En24
  signal movefractionlengthup_1                : signed(31 downto 0);       -- sfix32_En28
  signal piover2_1                             : signed(31 downto 0);       -- sfix32_En28
  signal cmp_theta_piover2_relop1              : std_logic;
  signal switch_compare_1                      : std_logic;
  signal negatepiover2_cast                    : signed(32 downto 0);       -- sfix33_En28
  signal negatepiover2_cast_1                  : signed(32 downto 0);       -- sfix33_En28
  signal negatepiover2_1                       : signed(31 downto 0);       -- sfix32_En28
  signal cmp_theta_negatepiover2_relop1        : std_logic;
  signal switch_compare_1_1                    : std_logic;
  signal constant_rsvd_1                       : std_logic;                 -- ufix1
  signal onepi_1                               : signed(31 downto 0);       -- sfix32_En28
  signal thetaplusonepi_1                      : signed(31 downto 0);       -- sfix32_En28
  signal cmp_thetaplusonepi_neg_piover2_relop1 : std_logic;
  signal switch_compare_1_2                    : std_logic;
  signal switch3_c1_1                          : std_logic;                 -- ufix1
  signal switch4_c1_1                          : std_logic;                 -- ufix1
  signal thetaminusonepi_1                     : signed(31 downto 0);       -- sfix32_En28
  signal cmp_thetaminusonepi_piover2_relop1    : std_logic;
  signal switch_compare_1_3                    : std_logic;
  signal switch_c1_1                           : std_logic;                 -- ufix1
  signal negate                                : std_logic;                 -- ufix1
  signal negate_reg_reg                        : std_logic_vector(0 to 11); -- ufix1 [12]
  signal negate_reg_reg_next                   : std_logic_vector(0 to 11); -- ufix1 [12]
  signal negate_p                              : std_logic;                 -- ufix1
  signal switch_compare_1_4                    : std_logic;
  signal switch_compare_1_5                    : std_logic;
  signal switch_compare_1_6                    : std_logic;
  signal twopi_1                               : signed(31 downto 0);       -- sfix32_En28
  signal thetaplustwopi_1                      : signed(31 downto 0);       -- sfix32_En28
  signal switch3_1                             : signed(31 downto 0);       -- sfix32_En28
  signal switch_compare_1_7                    : std_logic;
  signal thetaminustwopi_1                     : signed(31 downto 0);       -- sfix32_En28
  signal switch_compare_1_8                    : std_logic;
  signal switch4_1                             : signed(31 downto 0);       -- sfix32_En28
  signal switch4_dtc                           : signed(31 downto 0);       -- sfix32_En30
  signal switch_1                              : signed(31 downto 0);       -- sfix32_En28
  signal switch_dtc                            : signed(31 downto 0);       -- sfix32_En30
  signal corrected_theta                       : signed(31 downto 0);       -- sfix32_En30
  signal z0_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero1                            : std_logic;                 -- ufix1
  signal switch_compare_1_9                    : std_logic;
  signal lut_value_s1                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_1_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_1_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z1                                    : signed(31 downto 0);       -- sfix32_En30
  signal z1_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero2                            : std_logic;                 -- ufix1
  signal switch_compare_1_10                   : std_logic;
  signal lut_value_s2                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_2_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_2_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z2                                    : signed(31 downto 0);       -- sfix32_En30
  signal z2_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero3                            : std_logic;                 -- ufix1
  signal switch_compare_1_11                   : std_logic;
  signal lut_value_s3                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_3_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_3_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z3                                    : signed(31 downto 0);       -- sfix32_En30
  signal z3_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero4                            : std_logic;                 -- ufix1
  signal switch_compare_1_12                   : std_logic;
  signal lut_value_s4                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_4_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_4_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z4                                    : signed(31 downto 0);       -- sfix32_En30
  signal z4_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero5                            : std_logic;                 -- ufix1
  signal switch_compare_1_13                   : std_logic;
  signal lut_value_s5                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_5_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_5_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z5                                    : signed(31 downto 0);       -- sfix32_En30
  signal z5_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero6                            : std_logic;                 -- ufix1
  signal switch_compare_1_14                   : std_logic;
  signal lut_value_s6                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_6_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_6_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z6                                    : signed(31 downto 0);       -- sfix32_En30
  signal z6_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero7                            : std_logic;                 -- ufix1
  signal switch_compare_1_15                   : std_logic;
  signal lut_value_s7                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_7_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_7_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z7                                    : signed(31 downto 0);       -- sfix32_En30
  signal z7_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero8                            : std_logic;                 -- ufix1
  signal switch_compare_1_16                   : std_logic;
  signal lut_value_s8                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_8_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_8_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z8                                    : signed(31 downto 0);       -- sfix32_En30
  signal z8_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero9                            : std_logic;                 -- ufix1
  signal switch_compare_1_17                   : std_logic;
  signal lut_value_s9                          : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_9_1                  : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_9_1                  : signed(31 downto 0);       -- sfix32_En30
  signal z9                                    : signed(31 downto 0);       -- sfix32_En30
  signal z9_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero10                           : std_logic;                 -- ufix1
  signal switch_compare_1_18                   : std_logic;
  signal lut_value_s10                         : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_0_10_1                 : signed(31 downto 0);       -- sfix32_En30
  signal lut_value_temp_1_10_1                 : signed(31 downto 0);       -- sfix32_En30
  signal z10                                   : signed(31 downto 0);       -- sfix32_En30
  signal z10_p                                 : signed(31 downto 0);       -- sfix32_En30
  signal comp_zero11                           : std_logic;                 -- ufix1
  signal switch_compare_1_19                   : std_logic;
  signal switch_compare_1_20                   : std_logic;
  signal switch_compare_1_21                   : std_logic;
  signal switch_compare_1_22                   : std_logic;
  signal switch_compare_1_23                   : std_logic;
  signal switch_compare_1_24                   : std_logic;
  signal switch_compare_1_25                   : std_logic;
  signal switch_compare_1_26                   : std_logic;
  signal switch_compare_1_27                   : std_logic;
  signal switch_compare_1_28                   : std_logic;
  signal switch_compare_1_29                   : std_logic;
  signal x0                                    : signed(31 downto 0);       -- sfix32_En30
  signal y0                                    : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_1_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_p                            : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_1_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_p                            : signed(31 downto 0);       -- sfix32_En30
  signal x1                                    : signed(31 downto 0);       -- sfix32_En30
  signal x1_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_30                   : std_logic;
  signal y_temp_0_1_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_p                            : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_1_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_p                            : signed(31 downto 0);       -- sfix32_En30
  signal y1                                    : signed(31 downto 0);       -- sfix32_En30
  signal y1_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift2                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_2_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_2_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x2                                    : signed(31 downto 0);       -- sfix32_En30
  signal x2_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_31                   : std_logic;
  signal x_shift2                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_2_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_2_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y2                                    : signed(31 downto 0);       -- sfix32_En30
  signal y2_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift3                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_3_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_3_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x3                                    : signed(31 downto 0);       -- sfix32_En30
  signal x3_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_32                   : std_logic;
  signal x_shift3                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_3_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_3_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y3                                    : signed(31 downto 0);       -- sfix32_En30
  signal y3_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift4                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_4_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_4_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x4                                    : signed(31 downto 0);       -- sfix32_En30
  signal x4_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_33                   : std_logic;
  signal x_shift4                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_4_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_4_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y4                                    : signed(31 downto 0);       -- sfix32_En30
  signal y4_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift5                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_5_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_5_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x5                                    : signed(31 downto 0);       -- sfix32_En30
  signal x5_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_34                   : std_logic;
  signal x_shift5                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_5_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_5_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y5                                    : signed(31 downto 0);       -- sfix32_En30
  signal y5_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift6                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_6_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_6_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x6                                    : signed(31 downto 0);       -- sfix32_En30
  signal x6_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_35                   : std_logic;
  signal x_shift6                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_6_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_6_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y6                                    : signed(31 downto 0);       -- sfix32_En30
  signal y6_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift7                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_7_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_7_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x7                                    : signed(31 downto 0);       -- sfix32_En30
  signal x7_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_36                   : std_logic;
  signal x_shift7                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_7_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_7_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y7                                    : signed(31 downto 0);       -- sfix32_En30
  signal y7_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift8                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_8_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_8_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x8                                    : signed(31 downto 0);       -- sfix32_En30
  signal x8_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_37                   : std_logic;
  signal x_shift8                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_8_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_8_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y8                                    : signed(31 downto 0);       -- sfix32_En30
  signal y8_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift9                              : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_9_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_9_1                          : signed(31 downto 0);       -- sfix32_En30
  signal x9                                    : signed(31 downto 0);       -- sfix32_En30
  signal x9_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_38                   : std_logic;
  signal x_shift9                              : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_9_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_9_1                          : signed(31 downto 0);       -- sfix32_En30
  signal y9                                    : signed(31 downto 0);       -- sfix32_En30
  signal y9_p                                  : signed(31 downto 0);       -- sfix32_En30
  signal y_shift10                             : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_10_1                         : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_10_1                         : signed(31 downto 0);       -- sfix32_En30
  signal x10                                   : signed(31 downto 0);       -- sfix32_En30
  signal x10_p                                 : signed(31 downto 0);       -- sfix32_En30
  signal switch_compare_1_39                   : std_logic;
  signal x_shift10                             : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_0_10_1                         : signed(31 downto 0);       -- sfix32_En30
  signal y_temp_1_10_1                         : signed(31 downto 0);       -- sfix32_En30
  signal y10                                   : signed(31 downto 0);       -- sfix32_En30
  signal y10_p                                 : signed(31 downto 0);       -- sfix32_En30
  signal y_shift11                             : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_0_11_1                         : signed(31 downto 0);       -- sfix32_En30
  signal x_temp_1_11_1                         : signed(31 downto 0);       -- sfix32_En30
  signal x11                                   : signed(31 downto 0);       -- sfix32_En30
  signal x11_p                                 : signed(31 downto 0);       -- sfix32_En30
  signal x_p_negate_cast                       : signed(32 downto 0);       -- sfix33_En30
  signal x_p_negate_cast_1                     : signed(32 downto 0);       -- sfix33_En30
  signal x_p_negate_1                          : signed(31 downto 0);       -- sfix32_En30
  signal cos_tmp                               : signed(31 downto 0);       -- sfix32_En30

begin

  angle_signed <= signed(angle);

  movefractionlengthup_1 <= angle_signed(27 downto 0) & '0' & '0' & '0' & '0';

  piover2_1 <= to_signed(421657428, 32);

  cmp_theta_piover2_relop1 <= '1' when movefractionlengthup_1 > piover2_1 else
                              '0';

  switch_compare_1 <= '1' when cmp_theta_piover2_relop1 > '0' else
                      '0';

  negatepiover2_cast   <= resize(piover2_1, 33);
  negatepiover2_cast_1 <= - (negatepiover2_cast);
  negatepiover2_1      <= negatepiover2_cast_1(31 downto 0);

  cmp_theta_negatepiover2_relop1 <= '1' when movefractionlengthup_1 < negatepiover2_1 else
                                    '0';

  switch_compare_1_1 <= '1' when cmp_theta_negatepiover2_relop1 > '0' else
                        '0';

  constant_rsvd_1 <= '0';

  onepi_1 <= to_signed(843314857, 32);

  thetaplusonepi_1 <= movefractionlengthup_1 + onepi_1;

  cmp_thetaplusonepi_neg_piover2_relop1 <= '1' when thetaplusonepi_1 >= negatepiover2_1 else
                                           '0';

  switch_compare_1_2 <= '1' when cmp_thetaplusonepi_neg_piover2_relop1 > '0' else
                        '0';

  switch3_c1_1 <= constant_rsvd_1 when switch_compare_1_2 = '0' else
                  cmp_thetaplusonepi_neg_piover2_relop1;

  switch4_c1_1 <= constant_rsvd_1 when switch_compare_1_1 = '0' else
                  switch3_c1_1;

  thetaminusonepi_1 <= movefractionlengthup_1 - onepi_1;

  cmp_thetaminusonepi_piover2_relop1 <= '1' when thetaminusonepi_1 <= piover2_1 else
                                        '0';

  switch_compare_1_3 <= '1' when cmp_thetaminusonepi_piover2_relop1 > '0' else
                        '0';

  switch_c1_1 <= constant_rsvd_1 when switch_compare_1_3 = '0' else
                 cmp_thetaminusonepi_piover2_relop1;

  negate <= switch4_c1_1 when switch_compare_1 = '0' else
            switch_c1_1;

  negate_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        negate_reg_reg(0)  <= '0';
        negate_reg_reg(1)  <= '0';
        negate_reg_reg(2)  <= '0';
        negate_reg_reg(3)  <= '0';
        negate_reg_reg(4)  <= '0';
        negate_reg_reg(5)  <= '0';
        negate_reg_reg(6)  <= '0';
        negate_reg_reg(7)  <= '0';
        negate_reg_reg(8)  <= '0';
        negate_reg_reg(9)  <= '0';
        negate_reg_reg(10) <= '0';
        negate_reg_reg(11) <= '0';
      elsif (enb = '1') then
        negate_reg_reg(0)  <= negate_reg_reg_next(0);
        negate_reg_reg(1)  <= negate_reg_reg_next(1);
        negate_reg_reg(2)  <= negate_reg_reg_next(2);
        negate_reg_reg(3)  <= negate_reg_reg_next(3);
        negate_reg_reg(4)  <= negate_reg_reg_next(4);
        negate_reg_reg(5)  <= negate_reg_reg_next(5);
        negate_reg_reg(6)  <= negate_reg_reg_next(6);
        negate_reg_reg(7)  <= negate_reg_reg_next(7);
        negate_reg_reg(8)  <= negate_reg_reg_next(8);
        negate_reg_reg(9)  <= negate_reg_reg_next(9);
        negate_reg_reg(10) <= negate_reg_reg_next(10);
        negate_reg_reg(11) <= negate_reg_reg_next(11);
      end if;
    end if;

  end process negate_reg_process;

  negate_p                <= negate_reg_reg(11);
  negate_reg_reg_next(0)  <= negate;
  negate_reg_reg_next(1)  <= negate_reg_reg(0);
  negate_reg_reg_next(2)  <= negate_reg_reg(1);
  negate_reg_reg_next(3)  <= negate_reg_reg(2);
  negate_reg_reg_next(4)  <= negate_reg_reg(3);
  negate_reg_reg_next(5)  <= negate_reg_reg(4);
  negate_reg_reg_next(6)  <= negate_reg_reg(5);
  negate_reg_reg_next(7)  <= negate_reg_reg(6);
  negate_reg_reg_next(8)  <= negate_reg_reg(7);
  negate_reg_reg_next(9)  <= negate_reg_reg(8);
  negate_reg_reg_next(10) <= negate_reg_reg(9);
  negate_reg_reg_next(11) <= negate_reg_reg(10);

  switch_compare_1_4 <= '1' when negate_p > '0' else
                        '0';

  switch_compare_1_5 <= '1' when cmp_theta_negatepiover2_relop1 > '0' else
                        '0';

  switch_compare_1_6 <= '1' when cmp_thetaplusonepi_neg_piover2_relop1 > '0' else
                        '0';

  twopi_1 <= to_signed(1686629713, 32);

  thetaplustwopi_1 <= movefractionlengthup_1 + twopi_1;

  switch3_1 <= thetaplustwopi_1 when switch_compare_1_6 = '0' else
               thetaplusonepi_1;

  switch_compare_1_7 <= '1' when cmp_thetaminusonepi_piover2_relop1 > '0' else
                        '0';

  thetaminustwopi_1 <= movefractionlengthup_1 - twopi_1;

  switch_compare_1_8 <= '1' when cmp_theta_piover2_relop1 > '0' else
                        '0';

  switch4_1 <= movefractionlengthup_1 when switch_compare_1_5 = '0' else
               switch3_1;

  switch4_dtc <= switch4_1(29 downto 0) & '0' & '0';

  switch_1 <= thetaminustwopi_1 when switch_compare_1_7 = '0' else
              thetaminusonepi_1;

  switch_dtc <= switch_1(29 downto 0) & '0' & '0';

  corrected_theta <= switch4_dtc when switch_compare_1_8 = '0' else
                     switch_dtc;

  -- Pipeline registers
  z0_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z0_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z0_p <= corrected_theta;
      end if;
    end if;

  end process z0_reg_process;

  comp_zero1 <= '1' when z0_p < to_signed(0, 32) else
                '0';

  switch_compare_1_9 <= '1' when comp_zero1 > '0' else
                        '0';

  lut_value_s1 <= to_signed(843314857, 32);

  lut_value_temp_0_1_1 <= z0_p - lut_value_s1;

  lut_value_temp_1_1_1 <= z0_p + lut_value_s1;

  z1 <= lut_value_temp_0_1_1 when switch_compare_1_9 = '0' else
        lut_value_temp_1_1_1;

  z_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z1_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z1_p <= z1;
      end if;
    end if;

  end process z_reg_process;

  comp_zero2 <= '1' when z1_p < to_signed(0, 32) else
                '0';

  switch_compare_1_10 <= '1' when comp_zero2 > '0' else
                         '0';

  lut_value_s2 <= to_signed(497837829, 32);

  lut_value_temp_0_2_1 <= z1_p - lut_value_s2;

  lut_value_temp_1_2_1 <= z1_p + lut_value_s2;

  z2 <= lut_value_temp_0_2_1 when switch_compare_1_10 = '0' else
        lut_value_temp_1_2_1;

  z_reg_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z2_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z2_p <= z2;
      end if;
    end if;

  end process z_reg_1_process;

  comp_zero3 <= '1' when z2_p < to_signed(0, 32) else
                '0';

  switch_compare_1_11 <= '1' when comp_zero3 > '0' else
                         '0';

  lut_value_s3 <= to_signed(263043837, 32);

  lut_value_temp_0_3_1 <= z2_p - lut_value_s3;

  lut_value_temp_1_3_1 <= z2_p + lut_value_s3;

  z3 <= lut_value_temp_0_3_1 when switch_compare_1_11 = '0' else
        lut_value_temp_1_3_1;

  z_reg_2_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z3_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z3_p <= z3;
      end if;
    end if;

  end process z_reg_2_process;

  comp_zero4 <= '1' when z3_p < to_signed(0, 32) else
                '0';

  switch_compare_1_12 <= '1' when comp_zero4 > '0' else
                         '0';

  lut_value_s4 <= to_signed(133525159, 32);

  lut_value_temp_0_4_1 <= z3_p - lut_value_s4;

  lut_value_temp_1_4_1 <= z3_p + lut_value_s4;

  z4 <= lut_value_temp_0_4_1 when switch_compare_1_12 = '0' else
        lut_value_temp_1_4_1;

  z_reg_3_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z4_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z4_p <= z4;
      end if;
    end if;

  end process z_reg_3_process;

  comp_zero5 <= '1' when z4_p < to_signed(0, 32) else
                '0';

  switch_compare_1_13 <= '1' when comp_zero5 > '0' else
                         '0';

  lut_value_s5 <= to_signed(67021687, 32);

  lut_value_temp_0_5_1 <= z4_p - lut_value_s5;

  lut_value_temp_1_5_1 <= z4_p + lut_value_s5;

  z5 <= lut_value_temp_0_5_1 when switch_compare_1_13 = '0' else
        lut_value_temp_1_5_1;

  z_reg_4_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z5_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z5_p <= z5;
      end if;
    end if;

  end process z_reg_4_process;

  comp_zero6 <= '1' when z5_p < to_signed(0, 32) else
                '0';

  switch_compare_1_14 <= '1' when comp_zero6 > '0' else
                         '0';

  lut_value_s6 <= to_signed(33543516, 32);

  lut_value_temp_0_6_1 <= z5_p - lut_value_s6;

  lut_value_temp_1_6_1 <= z5_p + lut_value_s6;

  z6 <= lut_value_temp_0_6_1 when switch_compare_1_14 = '0' else
        lut_value_temp_1_6_1;

  z_reg_5_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z6_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z6_p <= z6;
      end if;
    end if;

  end process z_reg_5_process;

  comp_zero7 <= '1' when z6_p < to_signed(0, 32) else
                '0';

  switch_compare_1_15 <= '1' when comp_zero7 > '0' else
                         '0';

  lut_value_s7 <= to_signed(16775851, 32);

  lut_value_temp_0_7_1 <= z6_p - lut_value_s7;

  lut_value_temp_1_7_1 <= z6_p + lut_value_s7;

  z7 <= lut_value_temp_0_7_1 when switch_compare_1_15 = '0' else
        lut_value_temp_1_7_1;

  z_reg_6_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z7_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z7_p <= z7;
      end if;
    end if;

  end process z_reg_6_process;

  comp_zero8 <= '1' when z7_p < to_signed(0, 32) else
                '0';

  switch_compare_1_16 <= '1' when comp_zero8 > '0' else
                         '0';

  lut_value_s8 <= to_signed(8388437, 32);

  lut_value_temp_0_8_1 <= z7_p - lut_value_s8;

  lut_value_temp_1_8_1 <= z7_p + lut_value_s8;

  z8 <= lut_value_temp_0_8_1 when switch_compare_1_16 = '0' else
        lut_value_temp_1_8_1;

  z_reg_7_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z8_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z8_p <= z8;
      end if;
    end if;

  end process z_reg_7_process;

  comp_zero9 <= '1' when z8_p < to_signed(0, 32) else
                '0';

  switch_compare_1_17 <= '1' when comp_zero9 > '0' else
                         '0';

  lut_value_s9 <= to_signed(4194283, 32);

  lut_value_temp_0_9_1 <= z8_p - lut_value_s9;

  lut_value_temp_1_9_1 <= z8_p + lut_value_s9;

  z9 <= lut_value_temp_0_9_1 when switch_compare_1_17 = '0' else
        lut_value_temp_1_9_1;

  z_reg_8_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z9_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z9_p <= z9;
      end if;
    end if;

  end process z_reg_8_process;

  comp_zero10 <= '1' when z9_p < to_signed(0, 32) else
                 '0';

  switch_compare_1_18 <= '1' when comp_zero10 > '0' else
                         '0';

  lut_value_s10 <= to_signed(2097149, 32);

  lut_value_temp_0_10_1 <= z9_p - lut_value_s10;

  lut_value_temp_1_10_1 <= z9_p + lut_value_s10;

  z10 <= lut_value_temp_0_10_1 when switch_compare_1_18 = '0' else
         lut_value_temp_1_10_1;

  z_reg_9_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        z10_p <= to_signed(0, 32);
      elsif (enb = '1') then
        z10_p <= z10;
      end if;
    end if;

  end process z_reg_9_process;

  comp_zero11 <= '1' when z10_p < to_signed(0, 32) else
                 '0';

  switch_compare_1_19 <= '1' when comp_zero11 > '0' else
                         '0';

  switch_compare_1_20 <= '1' when comp_zero10 > '0' else
                         '0';

  switch_compare_1_21 <= '1' when comp_zero9 > '0' else
                         '0';

  switch_compare_1_22 <= '1' when comp_zero8 > '0' else
                         '0';

  switch_compare_1_23 <= '1' when comp_zero7 > '0' else
                         '0';

  switch_compare_1_24 <= '1' when comp_zero6 > '0' else
                         '0';

  switch_compare_1_25 <= '1' when comp_zero5 > '0' else
                         '0';

  switch_compare_1_26 <= '1' when comp_zero4 > '0' else
                         '0';

  switch_compare_1_27 <= '1' when comp_zero3 > '0' else
                         '0';

  switch_compare_1_28 <= '1' when comp_zero2 > '0' else
                         '0';

  switch_compare_1_29 <= '1' when comp_zero1 > '0' else
                         '0';

  x0 <= to_signed(652032978, 32);

  y0 <= to_signed(0, 32);

  x_temp_0_1_1 <= x0 - y0;

  x_temp0_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x_temp_0_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x_temp_0_p <= x_temp_0_1_1;
      end if;
    end if;

  end process x_temp0_reg_process;

  x_temp_1_1_1 <= x0 + y0;

  -- Pipeline registers
  x_temp_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x_temp_1_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x_temp_1_p <= x_temp_1_1_1;
      end if;
    end if;

  end process x_temp_reg_process;

  x1 <= x_temp_0_p when switch_compare_1_29 = '0' else
        x_temp_1_p;

  -- Pipeline registers
  x_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x1_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x1_p <= x1;
      end if;
    end if;

  end process x_reg_process;

  switch_compare_1_30 <= '1' when comp_zero1 > '0' else
                         '0';

  y_temp_0_1_1 <= y0 + x0;

  y_temp0_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y_temp_0_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y_temp_0_p <= y_temp_0_1_1;
      end if;
    end if;

  end process y_temp0_reg_process;

  y_temp_1_1_1 <= y0 - x0;

  y_temp_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y_temp_1_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y_temp_1_p <= y_temp_1_1_1;
      end if;
    end if;

  end process y_temp_reg_process;

  y1 <= y_temp_0_p when switch_compare_1_30 = '0' else
        y_temp_1_p;

  y_reg_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y1_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y1_p <= y1;
      end if;
    end if;

  end process y_reg_process;

  y_shift2 <= SHIFT_RIGHT(y1_p, 1);

  x_temp_0_2_1 <= x1_p - y_shift2;

  x_temp_1_2_1 <= x1_p + y_shift2;

  x2 <= x_temp_0_2_1 when switch_compare_1_28 = '0' else
        x_temp_1_2_1;

  -- Pipeline registers
  x_reg_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x2_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x2_p <= x2;
      end if;
    end if;

  end process x_reg_1_process;

  switch_compare_1_31 <= '1' when comp_zero2 > '0' else
                         '0';

  x_shift2 <= SHIFT_RIGHT(x1_p, 1);

  y_temp_0_2_1 <= y1_p + x_shift2;

  y_temp_1_2_1 <= y1_p - x_shift2;

  y2 <= y_temp_0_2_1 when switch_compare_1_31 = '0' else
        y_temp_1_2_1;

  y_reg_1_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y2_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y2_p <= y2;
      end if;
    end if;

  end process y_reg_1_process;

  y_shift3 <= SHIFT_RIGHT(y2_p, 2);

  x_temp_0_3_1 <= x2_p - y_shift3;

  x_temp_1_3_1 <= x2_p + y_shift3;

  x3 <= x_temp_0_3_1 when switch_compare_1_27 = '0' else
        x_temp_1_3_1;

  -- Pipeline registers
  x_reg_2_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x3_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x3_p <= x3;
      end if;
    end if;

  end process x_reg_2_process;

  switch_compare_1_32 <= '1' when comp_zero3 > '0' else
                         '0';

  x_shift3 <= SHIFT_RIGHT(x2_p, 2);

  y_temp_0_3_1 <= y2_p + x_shift3;

  y_temp_1_3_1 <= y2_p - x_shift3;

  y3 <= y_temp_0_3_1 when switch_compare_1_32 = '0' else
        y_temp_1_3_1;

  y_reg_2_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y3_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y3_p <= y3;
      end if;
    end if;

  end process y_reg_2_process;

  y_shift4 <= SHIFT_RIGHT(y3_p, 3);

  x_temp_0_4_1 <= x3_p - y_shift4;

  x_temp_1_4_1 <= x3_p + y_shift4;

  x4 <= x_temp_0_4_1 when switch_compare_1_26 = '0' else
        x_temp_1_4_1;

  -- Pipeline registers
  x_reg_3_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x4_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x4_p <= x4;
      end if;
    end if;

  end process x_reg_3_process;

  switch_compare_1_33 <= '1' when comp_zero4 > '0' else
                         '0';

  x_shift4 <= SHIFT_RIGHT(x3_p, 3);

  y_temp_0_4_1 <= y3_p + x_shift4;

  y_temp_1_4_1 <= y3_p - x_shift4;

  y4 <= y_temp_0_4_1 when switch_compare_1_33 = '0' else
        y_temp_1_4_1;

  y_reg_3_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y4_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y4_p <= y4;
      end if;
    end if;

  end process y_reg_3_process;

  y_shift5 <= SHIFT_RIGHT(y4_p, 4);

  x_temp_0_5_1 <= x4_p - y_shift5;

  x_temp_1_5_1 <= x4_p + y_shift5;

  x5 <= x_temp_0_5_1 when switch_compare_1_25 = '0' else
        x_temp_1_5_1;

  -- Pipeline registers
  x_reg_4_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x5_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x5_p <= x5;
      end if;
    end if;

  end process x_reg_4_process;

  switch_compare_1_34 <= '1' when comp_zero5 > '0' else
                         '0';

  x_shift5 <= SHIFT_RIGHT(x4_p, 4);

  y_temp_0_5_1 <= y4_p + x_shift5;

  y_temp_1_5_1 <= y4_p - x_shift5;

  y5 <= y_temp_0_5_1 when switch_compare_1_34 = '0' else
        y_temp_1_5_1;

  y_reg_4_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y5_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y5_p <= y5;
      end if;
    end if;

  end process y_reg_4_process;

  y_shift6 <= SHIFT_RIGHT(y5_p, 5);

  x_temp_0_6_1 <= x5_p - y_shift6;

  x_temp_1_6_1 <= x5_p + y_shift6;

  x6 <= x_temp_0_6_1 when switch_compare_1_24 = '0' else
        x_temp_1_6_1;

  -- Pipeline registers
  x_reg_5_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x6_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x6_p <= x6;
      end if;
    end if;

  end process x_reg_5_process;

  switch_compare_1_35 <= '1' when comp_zero6 > '0' else
                         '0';

  x_shift6 <= SHIFT_RIGHT(x5_p, 5);

  y_temp_0_6_1 <= y5_p + x_shift6;

  y_temp_1_6_1 <= y5_p - x_shift6;

  y6 <= y_temp_0_6_1 when switch_compare_1_35 = '0' else
        y_temp_1_6_1;

  y_reg_5_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y6_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y6_p <= y6;
      end if;
    end if;

  end process y_reg_5_process;

  y_shift7 <= SHIFT_RIGHT(y6_p, 6);

  x_temp_0_7_1 <= x6_p - y_shift7;

  x_temp_1_7_1 <= x6_p + y_shift7;

  x7 <= x_temp_0_7_1 when switch_compare_1_23 = '0' else
        x_temp_1_7_1;

  -- Pipeline registers
  x_reg_6_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x7_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x7_p <= x7;
      end if;
    end if;

  end process x_reg_6_process;

  switch_compare_1_36 <= '1' when comp_zero7 > '0' else
                         '0';

  x_shift7 <= SHIFT_RIGHT(x6_p, 6);

  y_temp_0_7_1 <= y6_p + x_shift7;

  y_temp_1_7_1 <= y6_p - x_shift7;

  y7 <= y_temp_0_7_1 when switch_compare_1_36 = '0' else
        y_temp_1_7_1;

  y_reg_6_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y7_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y7_p <= y7;
      end if;
    end if;

  end process y_reg_6_process;

  y_shift8 <= SHIFT_RIGHT(y7_p, 7);

  x_temp_0_8_1 <= x7_p - y_shift8;

  x_temp_1_8_1 <= x7_p + y_shift8;

  x8 <= x_temp_0_8_1 when switch_compare_1_22 = '0' else
        x_temp_1_8_1;

  -- Pipeline registers
  x_reg_7_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x8_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x8_p <= x8;
      end if;
    end if;

  end process x_reg_7_process;

  switch_compare_1_37 <= '1' when comp_zero8 > '0' else
                         '0';

  x_shift8 <= SHIFT_RIGHT(x7_p, 7);

  y_temp_0_8_1 <= y7_p + x_shift8;

  y_temp_1_8_1 <= y7_p - x_shift8;

  y8 <= y_temp_0_8_1 when switch_compare_1_37 = '0' else
        y_temp_1_8_1;

  y_reg_7_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y8_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y8_p <= y8;
      end if;
    end if;

  end process y_reg_7_process;

  y_shift9 <= SHIFT_RIGHT(y8_p, 8);

  x_temp_0_9_1 <= x8_p - y_shift9;

  x_temp_1_9_1 <= x8_p + y_shift9;

  x9 <= x_temp_0_9_1 when switch_compare_1_21 = '0' else
        x_temp_1_9_1;

  -- Pipeline registers
  x_reg_8_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x9_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x9_p <= x9;
      end if;
    end if;

  end process x_reg_8_process;

  switch_compare_1_38 <= '1' when comp_zero9 > '0' else
                         '0';

  x_shift9 <= SHIFT_RIGHT(x8_p, 8);

  y_temp_0_9_1 <= y8_p + x_shift9;

  y_temp_1_9_1 <= y8_p - x_shift9;

  y9 <= y_temp_0_9_1 when switch_compare_1_38 = '0' else
        y_temp_1_9_1;

  y_reg_8_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y9_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y9_p <= y9;
      end if;
    end if;

  end process y_reg_8_process;

  y_shift10 <= SHIFT_RIGHT(y9_p, 9);

  x_temp_0_10_1 <= x9_p - y_shift10;

  x_temp_1_10_1 <= x9_p + y_shift10;

  x10 <= x_temp_0_10_1 when switch_compare_1_20 = '0' else
         x_temp_1_10_1;

  -- Pipeline registers
  x_reg_9_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x10_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x10_p <= x10;
      end if;
    end if;

  end process x_reg_9_process;

  switch_compare_1_39 <= '1' when comp_zero10 > '0' else
                         '0';

  x_shift10 <= SHIFT_RIGHT(x9_p, 9);

  y_temp_0_10_1 <= y9_p + x_shift10;

  y_temp_1_10_1 <= y9_p - x_shift10;

  y10 <= y_temp_0_10_1 when switch_compare_1_39 = '0' else
         y_temp_1_10_1;

  y_reg_9_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        y10_p <= to_signed(0, 32);
      elsif (enb = '1') then
        y10_p <= y10;
      end if;
    end if;

  end process y_reg_9_process;

  y_shift11 <= SHIFT_RIGHT(y10_p, 10);

  x_temp_0_11_1 <= x10_p - y_shift11;

  x_temp_1_11_1 <= x10_p + y_shift11;

  x11 <= x_temp_0_11_1 when switch_compare_1_19 = '0' else
         x_temp_1_11_1;

  -- Pipeline registers
  x_reg_10_process : process (clk) is
  begin

    if (clk'EVENT and clk = '1') then
      if (reset_x = '1') then
        x11_p <= to_signed(0, 32);
      elsif (enb = '1') then
        x11_p <= x11;
      end if;
    end if;

  end process x_reg_10_process;

  x_p_negate_cast   <= resize(x11_p, 33);
  x_p_negate_cast_1 <= - (x_p_negate_cast);
  x_p_negate_1      <= x_p_negate_cast_1(31 downto 0);

  cos_tmp <= x11_p when switch_compare_1_4 = '0' else
             x_p_negate_1;

  cos <= std_logic_vector(cos_tmp);

end architecture rtl;

