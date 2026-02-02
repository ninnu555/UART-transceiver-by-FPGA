library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Tx_UART is
  port
  (
    ck      : in std_logic;
    reset   : in std_logic;
    tx_data : in std_logic_vector (7 downto 0);
    btn_in  : in std_logic;

    tx_out   : out std_logic;
    tx_ready : out std_logic
  );
end Tx_UART;

architecture Behavioral of Tx_UART is

  signal cnt : unsigned (12 downto 0);

  signal clr9600, hit9600, en9600 : std_logic;

  signal reg      : unsigned (9 downto 0);
  signal en_shift : std_logic;
  signal load     : std_logic;

  signal count              : unsigned (3 downto 0);
  signal hit10, en10, clr10 : std_logic;

  signal tx_ready_aux : std_logic;
  type estado is (TX_IDLE, TX_INICIO, TX_BITS, TX_EXIT, TX_CHECK);
  signal state, state_nxt : estado;

begin

  -- Tx 9600Hz counter
  process (ck, reset)
  begin
    if (reset = '0') then
      cnt <= (others => '0');
    elsif (ck'event and ck = '1') then
      if (en9600 = '1') then
        if (cnt = 2813 - 4 or clr9600 = '1') then
          cnt <= (others => '0');
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;

  process (cnt)
  begin
    if (cnt = 2813 - 4) then
      hit9600 <= '1';
    else
      hit9600 <= '0';
    end if;
  end process;

  -- Tx shift register                    
  process (ck, reset)
  begin
    if (reset = '0') then
      reg <= (others => '1');
    elsif (ck'event and ck = '1') then
      if (load = '1') then
        reg <= unsigned('1' & unsigned(tx_data) & '0');
      elsif (en_shift = '1') then
        reg <= unsigned('1' & reg(9 downto 1));
      end if;
    end if;
    --					 tx_out <= reg(0);  -- ATTENZIONE: potrebbe essere un errore mettere tx_out qui e non fuori dal processo
  end process;

  tx_out <= reg(0); -- lo mettiamo qui perchè il file VHDL essential lo pone qui e lo scolleghiamo da ogni dipendenza di ck e reset. Ora il segnale è indipendente

  -- Tx bit counter
  process (ck, reset)
  begin
    if (reset = '0') then
      count <= (others => '0');
    elsif (ck'event and ck = '1') then
      if (clr10 = '1') then
        count <= (others => '0');
      elsif (en10 = '1') then
        if (count < 9) then
          count <= count + 1;
          hit10 <= '0';
        else
          count <= (others => '0');
          hit10 <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Tx ready
  process (ck, reset)
  begin
    if (reset = '0') then
      tx_ready <= '1';
    elsif (ck'event and ck = '1') then
      tx_ready <= tx_ready_aux;
    end if;
  end process;

  -- Tx Finite State Machine
  process (ck, reset)
  begin
    if (reset = '0') then
      state <= TX_IDLE;
    elsif (ck'event and ck = '1') then
      state <= state_nxt;
    end if;
  end process;

  process (hit9600, hit10, btn_in, state)
  begin
    case state is
      when TX_IDLE =>
        if (btn_in = '0') then
          state_nxt <= TX_INICIO;
        else
          state_nxt <= TX_IDLE;
        end if;
      when TX_INICIO =>
        state_nxt <= TX_BITS;
      when TX_BITS =>
        if (hit9600 = '1') then
          state_nxt <= TX_EXIT;
        else
          state_nxt <= TX_BITS;
        end if;
      when TX_EXIT =>
        state_nxt <= TX_CHECK;
      when TX_CHECK =>
        if (hit10 = '1') then
          state_nxt <= TX_IDLE;
        else
          state_nxt <= TX_BITS;
        end if;
      when others =>
        state_nxt <= TX_IDLE;
    end case;
  end process;

  process (state)
  begin
    case state is
      when TX_IDLE =>
        tx_ready_aux <= '1';
        load         <= '0';
        en9600       <= '0';
        en10         <= '0';
        clr9600      <= '0';
        en_shift     <= '0';
        clr10        <= '0';
      when TX_INICIO =>
        tx_ready_aux <= '0';
        load         <= '1';
        en9600       <= '0';
        en10         <= '0';
        clr9600      <= '1';
        en_shift     <= '0';
        clr10        <= '1';
      when TX_BITS =>
        tx_ready_aux <= '0';
        load         <= '0';
        en9600       <= '1';
        en10         <= '0';
        clr9600      <= '0';
        en_shift     <= '0';
        clr10        <= '0';
      when TX_EXIT =>
        tx_ready_aux <= '0';
        load         <= '0';
        en9600       <= '0';
        en10         <= '1';
        clr9600      <= '0';
        en_shift     <= '0';
        clr10        <= '0';
      when TX_CHECK =>
        tx_ready_aux <= '0';
        load         <= '0';
        en9600       <= '0';
        en10         <= '0';
        clr9600      <= '1';
        en_shift     <= '1';
        clr10        <= '0';
      when others =>
        tx_ready_aux <= '0';
        load         <= '0';
        en9600       <= '1';
        en10         <= '0';
        clr9600      <= '1';
        en_shift     <= '0';
        clr10        <= '1';
    end case;
  end process;

end Behavioral;