----------------------------------------------------------------------------------
-- SDcard_writestream
--     version 1.0.1 (2017/12/08) by YB
--    (c)2017 Y. BORNAT - Bordeaux INP / ENSEIRB-MATMECA
--
-- this modules stores a data stream on a SDcard
--
--
-- DEPENDENCY: 
-- This module requires the SDcard_raw_access_v2 module and was tested with
-- version 2.0.2. Therefore, it suffers from the same limitations and bugs.
--
-- USAGE:
--    List of error and debug codes are given below and defined as constants in the
--    architecture section.
--    input data size is given by WORD_SIZE_PW2. the SDcard_raw_access_v2 module
--    actually limits the value to 64bits ouputs (v2.0.2).
--    Although the technical limitation for WORD_SIZE_PW2 is 8 (256bytes or 2kbit words),
--    the value is limited to 3 (8 bytes or 64bits) to limit resource usage
--
--    Before doing anything, the module pre-erases all data on the SDcard to improve data.
--    This behavior can be avoided setting the PRE_ERASE generic as false
--
--    Data is considered written at the rising edge of clk if 'write' and 'full_n'
--    signals are both set.
--
--    if asserted, the final_flush input generates a data flush to the SDcard. This
--    is usefull if there is less tha 512 bytes remaining in the buffer. SDcards
--    working with 512byte blocks, the last data block will be filled with random
--    data from the previous buffers. during this operation, data_full_n is cleared
--    to indicate that the module is not ready to accept new data. Once the operation
--    is performed, data_full_n is set again. User may remove the SDcard safely.
--
--
-- REAL-TIME WARNING:
--    The module has an internal 2kBytes buffer which is designed to use minimal
--    RAM resources.
--    because of SDcard technology, realtime applications should use an additionnal
--    buffer of 70ms (roughly). Although this value is not a warranty to get proper
--    real-time behavior, it is likely to work well in 95% of the cases.
--    This buffer is not included in the module to allow a wider implementation
--    choice to the developper.
--    The real-time performance of this module is SDcard dependant.
-- 
-- TODO / KNOWN BUGS:
--  - the module does not check error messages, if things go wrong, data may be lost
--  - when card has been totally filled, the END_OF_CARD message occurs too late,
--    data has been accepted in buffer and there is no room to store it
--  - The module does not transmit warnings from lower layers
--  - Here, we reset the raw access module when no card in slot, this clears everything
--    up. Should change behavior as soon as we are sure that submodule works correctly
--    when hot SDcard change.
--
-- HISTORY
-- V1.0.1 (2017/12/08) by YB
--    - minor adaptation to cope with SDcard_raw_access V2.1
--      - added VIVADO_SYNTH generic wich is directly sent to submodule
-- V1.0 (2017/08/02) by YB
--    - original release
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SDcard_writestream is
    Generic(CLK_FREQ_HZ         : integer := 125000000; -- 100000000;           -- the frequency of the clock expressed in Hz
            VIVADO_SYNTH        : boolean := True;                -- select the correct part of code to use to get a proper RAM implementation in vivado
            WORD_SIZE_PW2       : integer range 0 to 3 := 0;      -- codes the data size of interface : it is 2^WORD_SIZE_PW2 bytes
            PRE_ERASE           : boolean := True;                -- determines if the SDcard should first be pre-erased to improve performance
            HIGH_SPEED_IF       : boolean := False;               -- When True, runs SDcard bus @50MHz (might not be reliable)
            LITTLE_ENDIAN       : boolean := True);               -- when multiple bytes per word, tells which byte is stored at lower address
                                                                  --     little endian (True) mean least significant byte first
                                                                  
    Port ( clk          : in    STD_LOGIC;                                          -- Main clock, frequency given by generic CLK_FREQ_HZ
           reset        : in    STD_LOGIC;                                          -- reset, active high
           
           data_in      : in    STD_LOGIC_VECTOR(8*(2**WORD_SIZE_PW2)-1 downto 0);  -- stream data input
           data_write   : in    STD_LOGIC;                                          -- data write, tells the module to write data_in
           data_full_n  : out   STD_LOGIC;                                          -- '1' when it is possible to write
           
           final_flush  : in    STD_LOGIC := '0';                                   -- optional data flush
           
           debug        : out   STD_LOGIC_VECTOR( 5 downto 0);                      -- only meaningfull for debug or error read
           sd_error     : out   STD_LOGIC;                                          -- '1' if an error occured, error value is in debug output
                      
           SD_DAT       : inout STD_LOGIC_VECTOR( 3 downto 0);                      -- DATA line for SDcard access
           SD_CD        : in    STD_LOGIC;                                          -- SDcard detected (active low)
           SD_WP        : in    STD_LOGIC:='0';                                     -- (optional) SDcard physical write protection indicator
           SD_CLK       : out   STD_LOGIC;                                          -- Communication clock
           
           SD_CMD       : inout STD_LOGIC;
           fsm_state    : out std_logic_vector(7 downto 0);
           rst_debug : out std_logic;
           busy_debug : out std_logic;
           module_state_debug : out std_logic_vector(7 downto 0)
           );                                         -- Command line

end SDcard_writestream;

architecture Behavioral of SDcard_writestream is

   -------------------------------------------------------------------------
   -- Error/Debug codes
   -- the message is an error only if MSB is set
   -------------------------------------------------------------------------
   constant NOTHING_TO_SAY        : std_logic_vector(5 downto 0) := "000000"; -- everything is working perfectly fine

   -- INFORMATION CODES
   constant END_OF_CARD           : std_logic_vector(5 downto 0) := "000001"; -- reached end of file, no more data to produce
   constant INIT                  : std_logic_vector(5 downto 0) := "000010"; -- initialization pending
   
   -- WARNING CODES
   
   -- ERROR CODES (from SDcard management module)
   constant NO_CARD               : std_logic_vector(5 downto 0) := "100000"; -- these error messages come from the raw access
   constant INVALID_CARD          : std_logic_vector(5 downto 0) := "100001"; --    module of the SDcard please refer to this
   constant INVALID_DATA_BLOCK    : std_logic_vector(5 downto 0) := "100010"; --    module for more details.
   constant WRITE_ERROR_FROM_CARD : std_logic_vector(5 downto 0) := "100011"; --
   constant INCONSISTENT_CSD      : std_logic_vector(5 downto 0) := "100100"; --
   constant TO0_MANY_CRC_RETRIES  : std_logic_vector(5 downto 0) := "100101"; --
   constant CARD_RESP_TIMEOUT     : std_logic_vector(5 downto 0) := "100110"; --
   constant WRITE_PROTECTED       : std_logic_vector(5 downto 0) := "100111"; --
   -- ERROR CODES (from this module)

   signal old_SD_err_code         : std_logic_vector( 3 downto 0);  -- error output of last clock cycle to detect changes



   type t_block_FSM is (initializing,  -- SDcard is initializing
                        erase_start,   -- send the first block to erase
                        erase_stop,    -- send the last block to erase
                        ready,         -- the SDcard is up and available for storing data
                        writing,       -- a write operation is in progess
                        flush,         -- writes all data in buffer to SDcard
                        last_block,    -- flushing the last data block
                        ejected,       -- all data has been written
                        card_full);
   signal block_FSM : t_block_FSM;



   --------------------------------------------------------------
   -- Signals used to control the SDcard
   --------------------------------------------------------------
   signal SDcard_reset          : std_logic;                      -- local reset for the SDcard
   signal SD_block_num          : std_logic_vector(31 downto 0);  -- ID of the SDblock on which we perform the next operation
   signal SD_op_buff            : std_logic_vector( 1 downto 0);  -- the buffer on which we perform the operation
   signal SD_write_blk          : std_logic;                      -- SDcard write order
   signal SD_erase_blk          : std_logic;                      -- SDcard write order
   signal SD_multiple           : std_logic;                      -- multiple block operation
   signal SD_busy               : std_logic;                      -- SDcard module is busy
   signal SD_err_code           : std_logic_vector( 3 downto 0);  -- error output
   signal SD_nb_blocks          : std_logic_vector(31 downto 0);  -- The number of blocks available on the SDcard

   --------------------------------------------------------------
   -- Signals used by user to retreive data
   --------------------------------------------------------------
   signal USER_write_buffer     : std_logic_vector( 1 downto 0);  -- the buffer on which user writes data
   signal USER_write_address    : std_logic_vector(8-WORD_SIZE_PW2   downto 0);  -- the address of write in buffer
   signal USER_write_data_in    : std_logic_vector((2**WORD_SIZE_PW2)*8-1 downto 0);  -- data write to buffer by user
   signal USER_write_data_en    : std_logic;                      -- actual write order to buffer memory
   
   --------------------------------------------------------------
   -- internal FIFO signals
   --------------------------------------------------------------
   signal elements_in_fifo      : integer range 0 to 2**(11-WORD_SIZE_PW2);          -- the number of written elements in whole buffers
   
   --------------------------------------------------------------
   -- card management
   --------------------------------------------------------------
   signal synced_CD             : std_logic;                                           -- synchronized version of SD_CD
   signal synced_WP             : std_logic;                                           -- synchronized version of SD_WP


begin

   process(clk)
   begin
      if rising_edge(clk) then
         synced_CD <= SD_CD;
         synced_WP <= SD_WP;
      end if;
   end process;

   -----------------------------------------------------------------
   -- the module state machine
   -----------------------------------------------------------------

   rst_debug <= reset;
   busy_debug <= SD_busy;

   process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' or synced_CD = '1' then
            block_FSM <= initializing;
         else
            case block_FSM is

               when initializing => 
               fsm_state <= std_logic_vector(to_unsigned(0, 8));
               if SD_busy = '0' and synced_WP = '0'          then
                                    if PRE_ERASE                            then block_FSM <= erase_start;
                                    else                                         block_FSM <= ready;       end if; end if;

               when erase_start  =>
               fsm_state <= std_logic_vector(to_unsigned(1, 8)); 
               if SD_busy = '0'     and SD_erase_blk = '0'   then block_FSM <= erase_stop;  end if;
               

               when erase_stop   => 
               fsm_state <= std_logic_vector(to_unsigned(2, 8));
               if SD_busy = '0'     and SD_erase_blk = '0'   then block_FSM <= ready;       end if;
               

               when ready        => 
               fsm_state <= std_logic_vector(to_unsigned(3, 8));
               if final_flush = '1' and elements_in_fifo > 0 then block_FSM <= flush;
                                 elsif final_flush = '1'                          then block_FSM <= last_block;
                                 elsif SD_nb_blocks = SD_block_num                then block_FSM <= card_full;
                                 elsif elements_in_fifo >= 2**(9-WORD_SIZE_PW2)   then block_FSM <= writing;     end if;


               when writing      =>
               fsm_state <= std_logic_vector(to_unsigned(4, 8));
               if final_flush = '1'                          then block_FSM <= flush;
                                 elsif SD_busy = '0'     and SD_write_blk = '0'   then block_FSM <= ready;       end if;
                       
                                 
               when flush        => 
               fsm_state <= std_logic_vector(to_unsigned(5, 8));
               if SD_nb_blocks = SD_block_num                then block_FSM <= card_full;
                                 elsif elements_in_fifo < 2**(9-WORD_SIZE_PW2)    then block_FSM <= last_block;  end if;


               when last_block   => 
               fsm_state <= std_logic_vector(to_unsigned(6, 8));
               if SD_busy = '0'                              then block_FSM <= ejected;     end if;
               

               when ejected      => 
               fsm_state <= std_logic_vector(to_unsigned(7, 8));
               if final_flush = '0'                          then block_FSM <= ready;       end if;
               
               when card_full    =>
               fsm_state <= std_logic_vector(to_unsigned(8, 8));
            end case;
         end if;
      end if;
   end process;


   -----------------------------------------------------------------
   -- block storage management
   -----------------------------------------------------------------
   -- we are only writing sequentially to the SDcard, so the working block will always be
   -- the block number mudulo 4
   SD_op_buff        <= SD_block_num(1 downto 0);
   
   SD_block_retreival : process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' or synced_CD = '1' then
            SD_write_blk      <= '0';
            SD_erase_blk      <= '0';
            SD_multiple       <= '0';
         else
            if block_FSM = initializing and SD_busy = '0' and synced_WP = '0' and PRE_ERASE then
               SD_erase_blk      <= '1';
               SD_multiple       <= '1';
            elsif block_FSM = erase_start and SD_busy = '0' and SD_erase_blk = '0' then
               SD_erase_blk      <= '1';
               SD_multiple       <= '1';
            elsif block_FSM = ready and final_flush = '1' and elements_in_fifo > 0 then
               SD_write_blk   <= '1';
               SD_multiple    <= '1';               
            elsif block_FSM = ready and elements_in_fifo >= 2**(9-WORD_SIZE_PW2) then
            -- module is ready and we have enough data to send a block to SDcard
               SD_write_blk   <= '1';
               SD_multiple    <= '1';
            elsif block_FSM = flush and SD_write_blk = '0' and SD_busy = '0' then
            -- module is ready and we have enough data to send a block to SDcard
               SD_write_blk   <= '1';
               SD_multiple    <= '1';
            elsif block_FSM = last_block then
               SD_write_blk   <= '0';
               SD_multiple    <= '0';               
            elsif SD_busy = '1' then
            -- the write/erase block has been taken into account, we still wait for SD_busy to be asserted to avoid
            -- block_FSM returning back to ready state BEFORE busy is asserted.
               SD_write_blk   <= '0';
               SD_erase_blk   <= '0';
               -- this one is clearly not mandatory because erase multiple can only have two command steps,
               -- but it is just cleaner to formalize the split between erase multiple and write multiple
               if block_FSM = erase_stop then
                  SD_multiple <= '0';
               end if;
            end if;
         end if;
      end if;
   end process;
   

   -- we always wait for SD_busy to be reset before updating SD_block_num, this makes it possible
   -- to use the PARAMETER_BUFFERING=False property of SDcard_raw_access_V2, and we save 32 flip-flops.
   SD_block_counting : process(clk)
   begin
      if rising_edge(clk) then
         if block_FSM = initializing then 
            -- just after initialization, we will erase blocks from 0 to SD_nb_blocks-1
            SD_block_num <= x"00000000";
         elsif  block_FSM = erase_start and SD_busy = '0' and SD_erase_blk = '0'  then
            -- the last block to erase
            SD_block_num <= std_logic_vector(unsigned(SD_nb_blocks)-1);
         elsif block_FSM = erase_stop and SD_busy = '0' and SD_erase_blk = '0'  then
            -- write preparation sequence is over, this is the actual reset of SD_block_num
            SD_block_num <= x"00000000";
         elsif (block_FSM = writing or block_FSM = flush) and SD_busy = '0' and SD_write_blk = '0'  then
            -- write is over, preparing next block number
            SD_block_num <= std_logic_vector(unsigned(SD_block_num)+1);
         end if;
      end if;
   end process;





   -----------------------------------------------------------------
   -- number of elements in FIFO
   -----------------------------------------------------------------
   count_FIFO_elts : process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' or synced_CD = '1' then
            elements_in_fifo <= 0;
         elsif elements_in_fifo < 2**(11-WORD_SIZE_PW2) and data_write = '1' then
            if block_FSM = writing and SD_busy = '0' and SD_write_blk = '0' then
               -- both operation : block written to SDcard and element received
               elements_in_fifo <= elements_in_fifo - 2**(9-WORD_SIZE_PW2) + 1;
            else
               -- we just received an element
               elements_in_fifo <= elements_in_fifo + 1;
            end if;
         elsif (block_FSM = writing or block_FSM = flush) and SD_busy = '0' and SD_write_blk = '0' then
            -- a block has just been written to SDcard
            elements_in_fifo <= elements_in_fifo - 2**(9-WORD_SIZE_PW2);
         end if;
      end if;
   end process;




   -----------------------------------------------------------------
   -- input FIFO management and translation into block accesses
   -----------------------------------------------------------------
   data_full_n        <= '0' when elements_in_fifo >= 2**(11-WORD_SIZE_PW2) or (block_FSM /= ready and block_FSM /= writing) else '1';
   USER_write_data_en <= data_write when elements_in_fifo < 2**(11-WORD_SIZE_PW2) and (block_FSM = ready or block_FSM = writing) else '0';

   USER_write_data_in <= data_in;
   
   process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' or synced_CD = '1' then
            USER_write_address <= (others => '0');
            USER_write_buffer  <= "00";
         elsif USER_write_data_en = '1' then
            USER_write_address <= std_logic_vector(unsigned(USER_write_address)+1);
            if USER_write_address = (8-WORD_SIZE_PW2   downto 0 => '1') then
               USER_write_buffer  <= std_logic_vector(unsigned(USER_write_buffer)+1);
            end if;
         end if;
      end if;
   end process;



   -----------------------------------------------------------------
   -- The call to the raw SDblock controler
   -----------------------------------------------------------------

   SDcard_reset <= reset or synced_CD;

    SD_raw_controler : entity work.SDcard_raw_access
        GENERIC MAP ( CLK_FREQ_HZ         => CLK_FREQ_HZ,
                      VIVADO_SYNTH        => VIVADO_SYNTH,
                      WORD_SIZE_PW2       => WORD_SIZE_PW2,
                      HIGH_SPEED_IF       => HIGH_SPEED_IF,
                      BUFFER_NUM_PW2      => 2,
                      PARAMETER_BUFFERING => False,
                      LITTLE_ENDIAN       => LITTLE_ENDIAN)
        PORT MAP ( clk        => clk,
                   reset      => SDcard_reset,
                   
                   SD_block    => SD_block_num,
                   TR_buffer   => SD_op_buff,
                   read_block  => '0',
                   write_block => SD_write_blk,
                   erase_block => SD_erase_blk,
                   multiple    => SD_multiple,
                   --prep_block  => SD_prep_block,
                   busy        => SD_busy,
                   err_code    => SD_err_code,
                   blocks      => SD_nb_blocks,
                   
                   loc_buffer  => USER_write_buffer,
                   address     => USER_write_address,
                   data_write  => USER_write_data_en,
                   data_in     => USER_write_data_in,
                   data_out    => open,
                   
                   SD_DAT     => SD_DAT,
                   SD_CD      => SD_CD,
                   SD_WP      => SD_WP,
                   SD_CLK     => SD_CLK,
                   SD_CMD     => SD_CMD,
                   module_state_debug => module_state_debug);


   -----------------------------------------------------------------
   -- reporting
   -----------------------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            sd_error <= '0';
            debug    <= NOTHING_TO_SAY;
         elsif synced_CD = '1' then -- this one is necessary because we reset the module when no card
            sd_error <= '1';
            debug    <= NO_CARD;            
         elsif synced_WP = '1' then
            sd_error <= '1';
            debug    <= WRITE_PROTECTED;
         elsif SD_err_code(3) = '1' then
            debug    <= "100" & SD_err_code(2 downto 0);
            sd_error <= '1';
         elsif block_FSM = initializing or block_FSM = erase_start or block_FSM = erase_stop then
            debug    <= INIT;
         else
            sd_error <= '0';
            if block_FSM = card_full then
               debug <= END_OF_CARD;
            else
               debug <= SD_err_code(3) & "00" & SD_err_code(2 downto 0);
            end if;
         end if;
      end if;
   end process;



end Behavioral;

