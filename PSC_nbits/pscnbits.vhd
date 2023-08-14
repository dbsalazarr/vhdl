library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity pscnbits is
generic(
	n : positive := 5
);
port(
	enable, reset : in std_logic;
	clk : in std_logic;
	datos_paralelo : in std_logic_vector(2**n-1 downto 0);
	contador : out std_logic_vector(n-1 downto 0);
	datos_serie : out std_logic
);
end entity;

architecture arch of pscnbits is

component muxna1 
generic(
	n : positive
);
port(
	enable : in std_logic;
	data: in std_logic_vector(2**n-1 downto 0);
	selector : in std_logic_vector(n-1 downto 0);
	salida : out std_logic
);
end component;

component contador_reloj
generic(
	n : positive
);
port(
	clk_in, reset : in std_logic;
	contador : out std_logic_vector(n-1 downto 0)
);
end component;

signal aux_selector : std_logic_vector(n-1 downto 0) := std_logic_vector(to_unsigned(0, n));
begin
	C1 : contador_reloj generic map(n) port map(clk, reset, aux_selector);
	M1 : muxna1 generic map(n) port map(enable, datos_paralelo, aux_selector, datos_serie);
	contador <= aux_selector;
	
end architecture;





