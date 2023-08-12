library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_reloj is
generic(
	n : positive := 4
);

port(
	clk_in : in std_logic;
	contador : out std_logic_vector(n-1 downto 0);
	clk: out std_logic
);
end entity;

architecture arch of contador_reloj is
constant max_count : integer := (2**n - 1);
signal count : integer range 0 to max_count;
signal clk_state : std_logic;

begin
	gen_clock : process(clk_in, clk_state, count)
	begin
		if clk_in'event and clk_in = '1' then
			if count <= max_count then
				clk_state <= '0';
				count <= count + 1;
			else 
--				clk_state <= not clk_state;
				clk_state <= '1';
				count  <= 0;
			end if;
			contador <= std_logic_vector(to_unsigned(count, n));
			clk <= clk_state;
		end if;
	end process;
	
--	per_second : process(clk_state)
--	begin
--		clk <= clk_state;
--	end process;
end architecture;