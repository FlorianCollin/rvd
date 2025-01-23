library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants_pkg.all;

entity error_to_sd is
  port (
    clk : in std_logic;
    reset : in std_logic;
    error_msg : in std_logic_vector((128 - 1) downto 0);
    alu_error_capture : in std_logic;
    data_full_n : in std_logic;
    we : out std_logic; -- write enable for SD card module
    data : out std_logic_vector(7 downto 0);
    counter_debug : out std_logic_vector(3 downto 0);
    status_debug : out std_logic;
    final_flush : out std_logic;
    fsm_state_debug : out std_logic_vector(1 downto 0)
  );
end entity error_to_sd;

architecture fsm_arch of error_to_sd is

  -- Définition des états
  type state_type is (IDLE, LOAD, SEND, BREAK, FINALIZE);
  signal current_state, next_state : state_type := IDLE;

  signal internal_counter : unsigned(3 downto 0) := to_unsigned(0, 4);
  signal reg_current_error_message : std_logic_vector(127 downto 0) := (others => '0');
  signal s_final_flush : std_logic := '0';
  signal counter_wait : unsigned(7 downto 0) := (others => '0');
  signal counter_finalize : unsigned(4 downto 0) := (others => '0');

begin

  -- FSM principale
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        current_state <= IDLE;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  -- Logique combinatoire de la FSM
  process(current_state, alu_error_capture, data_full_n, internal_counter)
  begin
    case current_state is
      when IDLE =>
        if alu_error_capture = '1' and data_full_n = '1' then
          next_state <= LOAD;
        else
          next_state <= IDLE;
        end if;

      when LOAD =>
        next_state <= SEND;

      when SEND =>
        if internal_counter = to_unsigned(15, 4) then
          next_state <= BREAK;
        elsif data_full_n = '1' then
          next_state <= SEND;
        else
          next_state <= IDLE; -- Erreur, impossible d'écrire
        end if;

      when BREAK =>
        if counter_wait = to_unsigned(100, 8) then
          next_state <= FINALIZE;
        else
          next_state <= BREAK;
        end if;

      when FINALIZE =>
        if counter_finalize = to_unsigned(4, 4) then
          next_state <= IDLE;
        else
          next_state <= FINALIZE;
        end if;
        
    end case;
  end process;

  -- Actions synchrones
  process(clk)
  begin
    if rising_edge(clk) then
      case current_state is
        when IDLE =>
          counter_finalize <= (others => '0');
          fsm_state_debug <= "00";
          internal_counter <= to_unsigned(0, 4);
          reg_current_error_message <= (others => '0');
          s_final_flush <= '0';

        when LOAD =>
          fsm_state_debug <= "01";
          reg_current_error_message <= error_msg;

        when SEND =>
          fsm_state_debug <= "10";
          if data_full_n = '1' then
            we <= '1';
            -- Choix de l'octet à envoyer
            case internal_counter is
              when to_unsigned( 0 , 4) => data <= reg_current_error_message( 7 downto 0 );
              when to_unsigned( 1 , 4) => data <= reg_current_error_message( 15 downto 8 );
              when to_unsigned( 2 , 4) => data <= reg_current_error_message( 23 downto 16 );
              when to_unsigned( 3 , 4) => data <= reg_current_error_message( 31 downto 24 );
              when to_unsigned( 4 , 4) => data <= reg_current_error_message( 39 downto 32 );
              when to_unsigned( 5 , 4) => data <= reg_current_error_message( 47 downto 40 );
              when to_unsigned( 6 , 4) => data <= reg_current_error_message( 55 downto 48 );
              when to_unsigned( 7 , 4) => data <= reg_current_error_message( 63 downto 56 );
              when to_unsigned( 8 , 4) => data <= reg_current_error_message( 71 downto 64 );
              when to_unsigned( 9 , 4) => data <= reg_current_error_message( 79 downto 72 );
              when to_unsigned( 10, 4) => data <= reg_current_error_message( 87 downto 80 );
              when to_unsigned( 11, 4) => data <= reg_current_error_message( 95 downto 88 );
              when to_unsigned( 12, 4) => data <= reg_current_error_message(103 downto 96 );
              when to_unsigned( 13, 4) => data <= reg_current_error_message(111 downto 104);
              when to_unsigned( 14, 4) => data <= reg_current_error_message(119 downto 112);
              when to_unsigned( 15, 4) => data <= reg_current_error_message(127 downto 120);
              when others => data <= (others => '1');
            end case;

            internal_counter <= internal_counter + 1;
          end if;
        
        when BREAK => -- ajout d'un état break ou on attendant pendant x periode d'horloge
          we <= '0';
          counter_wait <= counter_wait + 1;

        when FINALIZE =>
          counter_finalize <= counter_finalize + 1;
          counter_wait <= (others => '0');
          fsm_state_debug <= "11";
          we <= '0'; -- Désactivation de l'écriture
          s_final_flush <= '1'; -- test de ne pas utiliser final_flush 

      end case;
    end if;
  end process;

  -- Sorties de débogage
  counter_debug <= std_logic_vector(internal_counter);
  status_debug <= '1' when current_state /= IDLE else '0';
  final_flush <= s_final_flush;

  --compteur pour rajouter un delay avant de rentré dans l'état FINALIZE 100 Tclk

end architecture fsm_arch;

