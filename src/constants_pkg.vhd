package constants_pkg is

  constant instr_mem_length : integer := 4;
  constant data_length      : integer := 32;

  -- constants for the différent instrucitons section
  constant instr_length : integer := 32;
  constant funct7_h     : integer := 31;
  constant funct7_l     : integer := 25;

  constant rs2_h : integer := 24;
  constant rs2_l : integer := 20;

  constant rs1_h : integer := 19;
  constant rs1_l : integer := 15;

  constant rd_h : integer := 11;
  constant rd_l : integer := 7;

  constant opcode_h   : integer := 6;
  constant opcode_l   : integer := 0;
  constant imm_h      : integer := 31;
  constant i_imm_l    : integer := 20;
  constant s_sb_imm_l : integer := 25;

end package constants_pkg;

package body constants_pkg is

end package body constants_pkg;
