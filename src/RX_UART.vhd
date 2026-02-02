library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Rx_UART is
  port
  (
    ck    : in std_logic;
    reset : in std_logic;
    rx_in : in std_logic;

    rx_new  : out std_logic;
    rx_data : out std_logic_vector (7 downto 0)
  );
end Rx_UART;

architecture Behavioral of Rx_UART is

  signal cnt : unsigned (12 downto 0);

  signal en9600, clr9600, hit9600 : std_logic;

  signal reg      : unsigned (9 downto 0);
  signal en_shift : std_logic;

  signal count              : unsigned (3 downto 0);
  signal hit10, clr10, en10 : std_logic;

  signal rx_en      : std_logic;
  signal rx_new_aux : std_logic;

  type estado is (RX_IDLE, RX_INICIO, RX_BITS, RX_EXIT, RX_CHECK);
  signal state, state_nxt : estado;

begin

  -- Rx 9600Hz counter
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

  -- Rx shift register
  process (ck, reset)
  begin
    if (reset = '0') then
      reg <= (others => '0');
    elsif (ck'event and ck = '1') then
      if (en_shift = '1') then
        reg <= unsigned (rx_in & unsigned (reg(9 downto 1)));
      end if;
    end if;
  end process;

  -- Rx bit counter
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
          --											hit10 <= '0';
        else
          count <= (others => '0');
          --											hit10 <= '1';
        end if;
      end if;
    end if;
  end process;

  process (count) -- questo processo permette di attivare hit10 per un solo ciclo di clock invece che per tutto il tempo in cui count = 0 come nel precedente processo
  begin
    if (count = 9) then
      hit10 <= '1';
    else
      hit10 <= '0';
    end if;
  end process;

  -- Rx new data
  process (ck, reset)
  begin
    if (reset = '0') then
      rx_new <= '0';
    elsif (ck'event and ck = '1') then
      rx_new <= rx_new_aux;
    end if;
  end process;

  -- Rx reg
  process (ck, reset)
  begin
    if (reset = '0') then
      rx_data <= (others => '0');
    elsif (ck'event and ck = '1') then
      if (rx_en = '1') then
        rx_data <= std_logic_vector(reg (8 downto 1));
      end if;
    end if;
  end process;

  -- Tx Finite State Machine
  process (ck, reset)
  begin
    if (reset = '0') then
      state <= RX_IDLE;
    elsif (ck'event and ck = '1') then
      state <= state_nxt;
    end if;
  end process;

  process (hit9600, hit10, rx_in, state)
  begin
    case state is
      when RX_IDLE =>
        if (rx_in = '0') then
          state_nxt <= RX_INICIO;
        else
          state_nxt <= RX_IDLE;
        end if;
      when RX_INICIO =>
        state_nxt <= RX_BITS;
      when RX_BITS =>
        if (hit9600 = '1') then
          state_nxt <= RX_EXIT;
        else
          state_nxt <= RX_BITS;
        end if;
      when RX_EXIT =>
        if (hit10 = '1') then
          state_nxt <= RX_CHECK;
        else
          state_nxt <= RX_BITS;
        end if;
      when RX_CHECK =>
        state_nxt <= RX_IDLE;
      when others =>
        state_nxt <= RX_IDLE;
    end case;
  end process;

  process (state) -- forse qui ci vuole anche rx_in
  begin
    clr10      <= '0';
    rx_new_aux <= '0';
    en9600     <= '0';
    en10       <= '0';
    clr9600    <= '0';
    en_shift   <= '0';
    rx_en      <= '0';
    case state is
      when RX_IDLE =>

      when RX_INICIO =>
        clr10      <= '1';
        clr9600    <= '1';

      when RX_BITS =>
        en9600     <= '1';

      when RX_EXIT =>
        en10       <= '1';
        clr9600    <= '1';
        en_shift   <= '1';

      when RX_CHECK =>
        rx_new_aux <= '1';
        clr9600    <= '1';
        if (rx_in = '1') then
          rx_en <= '1';
        else
          rx_en <= '0';
        end if;
        
      when others =>
        en9600     <= '1';
        clr9600    <= '1';

    end case;
  end process;

end Behavioral;