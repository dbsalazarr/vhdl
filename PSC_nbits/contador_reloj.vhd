library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity contador_reloj is
generic(
	n : positive := 3
);

port(
	clk_in, reset : in std_logic;
	contador : out std_logic_vector(n-1 downto 0)
	
);
end entity;

architecture arch of contador_reloj is
signal count : std_logic_vector(n-1 downto 0);

begin
	gen_clock : process(clk_in, count)
	begin
		if reset = '0' then
			if rising_edge(clk_in) and clk_in = '1' then
				if count <= std_logic_vector(to_unsigned(2**n-1, n)) then
					count <= count + 1;
				else 
					count  <= std_logic_vector(to_unsigned(0, n));
				end if;
			end if;
		else
			count <= std_logic_vector(to_unsigned(0, n));
		end if;
	end process;
	contador <= count;
end architecture;


