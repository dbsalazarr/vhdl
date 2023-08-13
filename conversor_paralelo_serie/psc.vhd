library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity psc is
generic(
	n : positive := 3
);
port(
	enable : in std_logic;
	clk : in std_logic;
	datos_paralelo : in std_logic_vector(7 downto 0);
--	datos_serie : out std_logic_vector(7 downto 0);
	datos_serie : out std_logic;
	contador : out std_logic_vector(n-1 downto 0)
);
end entity;

architecture arch of psc is

component mux8a1 
port(
	enable : in std_logic;
	data: in std_logic_vector(7 downto 0);
	selector : in std_logic_vector(2 downto 0);
	salida : out std_logic
);
end component;

component contador_reloj
generic(
	n : positive := 3
);
port(
	clk_in : in std_logic;
	contador : out std_logic_vector(n-1 downto 0)
);
end component;

signal aux_selector : std_logic_vector(2 downto 0);
begin
	C1 : contador_reloj generic map(3) port map(clk, aux_selector);
--	M1 : mux8a1 port map(enable, datos_paralelo, aux_selector, datos_serie( to_integer(unsigned(aux_selector)) ));
M1 : mux8a1 port map(enable, datos_paralelo, aux_selector, datos_serie);
	contador <= aux_selector;
	
end architecture;