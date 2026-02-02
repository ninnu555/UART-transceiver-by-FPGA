library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity fifo is
    port
    (
      ck      : in std_logic;
      reset   : in std_logic;
      data_in : in std_logic_vector (7 downto 0);
      read  : in std_logic;
      write : in std_logic;
  
      --full   : out std_logic;
      --empty : out std_logic;
      data_out : out std_logic_vector (7 downto 0)
    );
  end fifo;
  
  architecture Behavioral of fifo is
  
    signal write_p : integer;
    signal read_p  : integer;


    type address_t is array (0 to 9) of std_logic_vector (7 downto 0);
        signal data : address_t;
     
  begin

    process (ck, reset)
    begin   
        if (reset = '1') then
            read_p <= 0;
            write_p <= 0;
        elsif (ck'event and ck = '1') then
            if (write = '1') then 
                data(write_p) <= data_in;
                if (write_p < 7) then
                    write_p <= write_p + 1;
                else
                    write_p <= 0;
                end if;
            end if;
            if (read = '1') then
                data_out <= data(read_p);
                if (read_p < 7) then
                    read_p <= read_p + 1;
                else
                    read_p <= 0;
                end if;   
            end if;
        end if;
    end process;

  end Behavioral;