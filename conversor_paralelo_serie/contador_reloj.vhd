 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_reloj is
generic(
	n : positive := 3
);

port(
	clk_in : in std_logic;
	contador : out std_logic_vector(n-1 downto 0)
);
end entity;

architecture arch of contador_reloj is
constant max_count : integer := (2**n - 1);
signal count : integer range 0 to max_count;

begin
	gen_clock : process(clk_in, count)
	begin
		if rising_edge(clk_in) then
			if count <= max_count then
				count <= count + 1;
			else 
--				clk_state <= not clk_state;
				count  <= 0;
			end if;
			contador <= std_logic_vector(to_unsigned(count, n));
		end if;
	end process;
end architecture;