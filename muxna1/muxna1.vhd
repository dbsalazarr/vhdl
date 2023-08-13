library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity muxna1 is
generic( n : positive := 4);
port(
	enable : in std_logic;
	entradas : in std_logic_vector(2**n - 1 downto 0);
	selector : in std_logic_vector(n-1 downto 0 );
	salida : out std_logic
);
end entity;

architecture arch of muxna1 is

begin
--	salida <= entradas(0) when selector = "000"
	process (enable, entradas, selector)
	begin
		if enable = '1' then
			for i in 0 to 2**n - 1 loop
				if i = conv_integer(selector) then
					salida <= entradas(i);
				end if;
			end loop;
		else
			salida <= 'Z';
		end if;
	end process;
end architecture;