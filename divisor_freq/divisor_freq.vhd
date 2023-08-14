library ieee;
use ieee.std_logic_1164.all;

entity divisor_freq is
port(
	-- ENTRADAS
	clk : in std_logic;
	reset: in std_logic;
	div_freq: out std_logic
);
end entity;

architecture arch of divisor_freq is
signal salida : std_logic;
--signal contador : integer range 0 to 24999999 := 0; 
signal contador : integer range 0 to 1 := 0; 
-- contador : Varia entre 0 la frecuencia de salida que se quiere
-- freq_div = freq_entrada / freq_que se quiere - 1
-- Ejemplo: freq_div = 50M/2hz - 1 = 24999999
-- Esto dividirá la frecuencia de entrada de 50M a una de 2Hz de salida
begin
	divisor_freq : process(clk, reset)
	begin
		-- Las placas por defecto tienen un valor de 1 logico
		-- Entonces si ese valor cambia a cero, se presiono un botón o realizo algo
		if reset = '0' then
			salida <= '0';
			contador <= 0;
		elsif rising_edge(clk) then
			if contador = 1 then
				contador <= 0;
				salida <= not salida;
			else 
				contador <= contador + 1;
			end if;
		end if;
	end process;
	div_freq <= salida;
end architecture;