library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity lcd_controller is
port(
	clk : in std_logic; -- System clock
	reset_n : in std_logic; -- active low reinitialize lcd
	lcd_enable : in std_logic; -- latches data into lcd controller
	lcd_bus : in std_logic_vector(9 downto 0); -- data and control signals
	
	busy : out std_logic := '1'; -- lcd controller busy/idle feedback
	rw, rs, e : out std_logic; -- read/write, setup/data, and enable for lcd
	lcd_data : out std_logic_vector(7 downto 0); -- data signals for lcd
	lcd_on : out std_logic; -- LCD Power ON/OFF
	lcd_blon : out std_logic -- LCD Back Light ON/OFF
);
end entity;

architecture controller of lcd_controller is
	-- state machine 
	type CONTROL is (power_up, initialize, ready, send);
	signal state : CONTROL;
	constant freq : integer := 50; -- system clock frequency in MHz
begin
	lcd_on <= '1'; -- LCD Power ON 
	lcd_blon <= '0'; -- LCD Black Light OFF
	
	process(clk)
	variable clk_count : integer := 0; -- event counter for timing
	begin
		if clk'event and clk = '1' then
		
			case state is
			-- wait 50 ms to ensure Vdd has risen and required LCD wait is met
			when power_up =>
				busy <= '1';
				if clk_count < (50000*freq) then -- wait 50ms
					clk_count := clk_count + 1;
					state <= power_up;
				else
					clk_count := 0;
					rs <= '0';
					rw <= '0';
					lcd_data <= "00110000"; -- Function Set: 1-line mode, display off lcd_data <= "00110000";
					state <= initialize;
				end if;
			when initialize =>
				busy <= '1';
				clk_count := clk_count + 1;
				if clk_count < (10*freq) then -- function set -- lcd data <= "00111100"; -- 2 line mode, display on
				lcd_data <= "00110100"; -- 1 - line mode, display on
				-- lcd_data <= "00110000"; -- 1 - line mode, display off
				-- lcd_data <= "00111000"; -- 2 - line mode, display off
				e <= '1';
				state <= initialize;
				elsif clk_count < (60*freq) then -- wait 50 us
					lcd_data <= "00000000";
					e <= '0';
					state <= initialize;
				elsif clk_count < (70*freq) then  -- display on/off control
				
					--lcd_data <= "00001100"; --display on, cursor off, blink off
					lcd_data <= "00001101"; --display on, cursor off, blink on
					--lcd_data <= "00001110"; --display on, cursor on, blink off
					--lcd_data <= "00001111"; --display on, cursor on, blink on
					--lcd_data <= "00001000"; --display off, cursor off, blink off
					--lcd_data <= "00001001"; --display off, cursor off,blink on
					--lcd_data <= "00001010"; --display off, cursor on, blink off
					--lcd_data <= "00001011"; --display off, cursor on, blink on
					e <= '1';
					state <= initialize;
				elsif clk_count < (120*freq) then -- wait 50us
					lcd_data <= "00000000";
					e <= '0';
					state <= initialize;
				elsif clk_count < 130*freq then -- display clear
					lcd_data <= "00000000";
					e <= '0';
					state <= initialize;
				elsif clk_count < (2140*freq) then  -- entry mode set
					lcd_data <= "00000110"; -- increment mode, entire shift off
					--lcd_data <= "00000111"; --increment mode, entire shift on
					--lcd_data <= "00000100"; --decrement mode, entire shift off
					--lcd_data <= "00000101"; --decrement mode, entire shift on
					e <= '1';
					state <= initialize;
				elsif clk_count < (2200*freq) then -- wait 60us
					lcd_data <= "00000000";
					e <= '0';
					state <= initialize;
				else  -- initialize complete
					clk_count := 0;
					busy <= '0';
					state <= ready;
				end if;
			when ready => 
				if lcd_enable = '1' then
					busy <= '1';
					rs <= lcd_bus(9); -- rs <= lcd_rs;
					rw <= lcd_bus(8); -- rw <= lcd_rw;
					lcd_data <= lcd_bus(7 downto 0); -- lcd_data <= lcd_bus
					clk_count := 0;
					state <= send;
				else 
					busy <= '0';
					rs <= '0';
					rw <= '0';
					lcd_data <= "00000000";
					clk_count := 0;
					state <= ready;
				end if;
			-- send instructions to lcd
			when send => 
				busy <= '1';
				if clk_count < (50*freq) then  -- don't exit for 50us
					busy <= '1';
					if clk_count < freq then -- negative enable
						 e <= '0';
					elsif clk_count < (14*freq) then -- positive enable half-cycle
						e <= '1';
					elsif clk_count < (27*freq) then -- negative enable half-cycle
						e <= '0';
					end if;
					clk_count := clk_count + 1;
					state <= send;
				else
					clk_count := 0;
					state <= ready;
				end if;
			end case;
			
			-- reset 
			if reset_n = '0' then 
				state <= power_up;
			end if;
		end if;
	end process;
end architecture;
