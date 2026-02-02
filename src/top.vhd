----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:37:18 06/14/2024 
-- Design Name: 
-- Module Name:    Tx_UART - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity UART is
  port
  (
    ck      : in std_logic;
    reset   : in std_logic;
    rx_in   : in std_logic;
    btn_in  : in std_logic;     -- maybe we have to remove it

     rx_new   : out std_logic;
    tx_out   : out std_logic;
    tx_ready : out std_logic;
    rx_data   : inout std_logic_vector (7 downto 0)
  );
end UART;

architecture Behavioral of UART is

  signal tx_data : std_logic_vector (7 downto 0);
--  signal rx_data : std_logic_vector (7 downto 0);   

  component Tx_UART is
    port
    (
      ck      : in std_logic;
      reset   : in std_logic;
      tx_data : in std_logic_vector (7 downto 0);
      btn_in  : in std_logic;

      tx_out   : out std_logic;
      tx_ready : out std_logic);
  end component;

  component Rx_UART is
    port
    (
      ck    : in std_logic;
      reset : in std_logic;
      rx_in : in std_logic;

      rx_new  : out std_logic;
      rx_data : inout std_logic_vector (7 downto 0));
  end component;

--   component fifo is
--     port
--     (
--       ck      : in std_logic;
--       reset   : in std_logic;
--       data_in : in std_logic_vector (7 downto 0);
--       read  : in std_logic;
--       write : in std_logic;
  
--       --full   : out std_logic;
--       --empty : out std_logic;
--       data_out : out std_logic_vector (7 downto 0)
--     );
--   end component;

begin
  tx_data <= rx_data;

  trasm_UART : Tx_UART
  port map
  (
    ck      => ck,
    reset   => reset,
    tx_data => rx_data,
    btn_in  => btn_in,

    tx_out   => tx_out,
    tx_ready => tx_ready
  );

  ric_UART : Rx_UART
  port
  map (
  ck    => ck,
  reset => reset,
  rx_in => rx_in,

  rx_new  => rx_new,
  rx_data => rx_data
  );

--   fifo_inst: fifo
--    port map(
--       ck => ck,
--       reset => reset,
--       data_in => rx_data,
--       read => read,
--       write => write,
--       data_out => tx_data
--   );
end Behavioral;