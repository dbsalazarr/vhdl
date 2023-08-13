library ieee;
use ieee.std_logic_1164.all;

entity mux8a1 is
port(
	enable : in std_logic;
	data: in std_logic_vector(7 downto 0);
	selector : in std_logic_vector(2 downto 0);
	salida : out std_logic
);
end entity;

architecture arch of mux8a1 is

signal salida_aux : std_logic;

begin
	with selector select
		  salida_aux <= data(0) when "000",
							 data(1) when "001",
							 data(2) when "010",
							 data(3) when "011", 
							 data(4) when "100",
							 data(5) when "101", 
							 data(6) when "110", 
							 data(7) when "111",
							 'Z' when others;
		 salida <= salida_aux when enable = '1' else
					  'Z';
end architecture;