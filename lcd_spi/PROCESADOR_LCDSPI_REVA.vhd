----------------------------------------
----------PROCESADOR LCD----------------
----------¡NO MODIFICAR!----------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity PROCESADOR_LCDSPI_REVA is

PORT( CLK : IN STD_LOGIC;
		RST : OUT STD_LOGIC;	
		RS  : OUT STD_LOGIC;
		CSB : OUT STD_LOGIC;
		SCL : OUT STD_LOGIC;
		SI  : OUT STD_LOGIC;
		VECTOR_MEM : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		INC_DIR : OUT INTEGER RANGE 0 TO 1024;
  	   BD_LCD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)			         
		);

end PROCESADOR_LCDSPI_REVA;

architecture Behavioral of PROCESADOR_LCDSPI_REVA is

------------------------COM SPI PARA LCD-------------------------
------------------------(LIB SPIMaestro)-------------------------
COMPONENT COM_SPI_LCD is													--
																					--
	Port	  (CLK 			:	in		STD_LOGIC;							--
				SCLK			: 	out 	STD_LOGIC;							--
				MISO			:	in		STD_LOGIC;							--
				MOSI			:	out	STD_LOGIC;							--
				SS				:	out	STD_LOGIC;							--
				DATAIN		:	in		STD_LOGIC_VECTOR(7 downto 0);	--
				DATAOUT		:	out	STD_LOGIC_VECTOR(7 downto 0);	--
				INICIOTX		: 	in		STD_LOGIC;							--
				INICIORX		:	in		STD_LOGIC;							--
				FINTX			:	out	STD_LOGIC;							--
				FINRX			:	out	STD_LOGIC;							--
				BUSOCUPADO	:	out	STD_LOGIC;							--
				SPI_MODE		:	in integer range 0 to 3 				--
				);																	--
																					--
end COMPONENT COM_SPI_LCD;													--
-----------------------------------------------------------------

TYPE MAQUINA IS (CHECAR,INI_LCD1,INI_LCD2,CURSOR_LCD,CURSOR_HOME,CLEAR_DISPLAY,CHAR,CHAR_ASCII,POS,BUCLE_INI,BUCLE_FIN,
					  LIMPIAR_PANTALLA,NADA,POS_RAM,CREAR_CHAR,LEER_RAM,CLEAR_DISPLAY_CHAR,CURSOR_HOME_CHAR,FIN,
					  
					  CARGAR_DATOINI, DELAY_RESET, DELAY_INILCD, RESET_LCD, CARGAR_DATOWRITE, CARGAR_DATOWRITE_ASCII,
					  CARGAR_DATOPOS, CARGAR_DATOLP, CARGAR_POSRAM, CARGAR_CHAR, CARGAR_CLEARDISPLAYCHAR, CARGAR_CURSORHOME,
					  DELAY_CHAR, CARGAR_LEERRAM, DELAY_DATO, ESPERA_FINTX);
					  
SIGNAL ESTADO : MAQUINA := RESET_LCD;

SIGNAL FUTURO : MAQUINA;
SIGNAL PRESENTE :MAQUINA;

CONSTANT DELAY_FIN : INTEGER := 9_999;
SIGNAL CONTA_DELAY,DATO_AMANDAR : INTEGER RANGE 0 TO DELAY_FIN := 0;

SIGNAL CONF_CURSOR : STD_LOGIC_VECTOR(1 DOWNTO 0);

SIGNAL DATA_CHAR,VEC_POS : STD_LOGIC_VECTOR(11 DOWNTO 0);

SIGNAL INC_DIR_S,DIR_BI : INTEGER RANGE 0 TO 1024 := 0;

SIGNAL CONTA_CHAR : INTEGER RANGE 1 TO 8 := 1;

SIGNAL VEC_C_CHAR : STD_LOGIC_VECTOR(39 DOWNTO 0);

SIGNAL DATAIN_S,DATAOUT_S : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL MISO_S,INICIOTX_S,INICIORX_S,FINTX_S,FINRX_S,BUSOCUPADO_S : STD_LOGIC:='0';							--
				
CONSTANT SPI_MODE_S : INTEGER := 3;				

begin

INC_DIR <= INC_DIR_S;

---CONEXIONES SPIMaestro--

COM_SPI:	
COM_SPI_LCD Port MAP(CLK 		=> CLK,
						SCLK			=> SCL,
						MISO			=> MISO_S,
						MOSI			=> SI,
						SS				=> CSB,
						DATAIN		=> DATAIN_S,
						DATAOUT		=> DATAOUT_S,
						INICIOTX		=> INICIOTX_S,
						INICIORX		=> INICIORX_S,
						FINTX			=> FINTX_S,
						FINRX			=> FINRX_S,
						BUSOCUPADO	=> BUSOCUPADO_S,
						SPI_MODE		=> SPI_MODE_S
						);																	--

--------------------------

-------------------------------------------------------------------------------------
PROCESS(CLK)
BEGIN
 IF RISING_EDGE(CLK) THEN
 
				--CURSOR--
				IF VECTOR_MEM = x"101" THEN
					CONF_CURSOR <= "00";
				ELSIF VECTOR_MEM = x"102" THEN
					CONF_CURSOR <= "01";
				ELSIF VECTOR_MEM = x"103" THEN
					CONF_CURSOR <= "10";
				ELSE
					CONF_CURSOR <= "11";
				END IF;
				----------				

		CASE ESTADO IS
		
			WHEN CHECAR =>
					
					BD_LCD <= x"00";
					
					IF VECTOR_MEM >= x"109" AND VECTOR_MEM <= x"13C" THEN
							
							IF VECTOR_MEM >= x"109" AND VECTOR_MEM <= x"122" THEN
								DATA_CHAR <= VECTOR_MEM - x"0A8";
							ELSE
								DATA_CHAR <= VECTOR_MEM - x"0E2";
							END IF;
						ESTADO <= CARGAR_DATOWRITE;
						
					ELSIF VECTOR_MEM >= x"020" AND VECTOR_MEM <= x"0FF" THEN
						
						DATA_CHAR <= VECTOR_MEM;
						ESTADO <= CARGAR_DATOWRITE_ASCII;
						
					ELSIF VECTOR_MEM >=	x"150" AND VECTOR_MEM <=  x"177" THEN
							
							IF VECTOR_MEM >= x"150" AND VECTOR_MEM <= x"163" THEN
								VEC_POS <= VECTOR_MEM - x"0D0";
							ELSIF VECTOR_MEM >= x"164" AND VECTOR_MEM <= x"177" THEN
								VEC_POS <= VECTOR_MEM - x"0A4";
							END IF;
						ESTADO <= CARGAR_DATOPOS;
					
					ELSIF VECTOR_MEM = x"17C" THEN
						ESTADO <= BUCLE_INI;
					
					ELSIF VECTOR_MEM = x"17D" THEN
						ESTADO <= BUCLE_FIN;
					
					ELSIF VECTOR_MEM = x"1FE" THEN
						ESTADO <= CARGAR_DATOLP;
						
					ELSIF VECTOR_MEM = x"1FD" THEN
						ESTADO <= NADA;				
					
					ELSIF VECTOR_MEM =X"1FF" THEN
						ESTADO <= FIN;
						
					END IF;
			
			WHEN RESET_LCD =>
				
				BD_LCD <= x"00";
				RST <= '0';
				ESTADO <= DELAY_RESET;
				FUTURO <= CARGAR_DATOINI;
			
			WHEN CARGAR_DATOINI =>
				
					BD_LCD <= x"00";
					RST <= '1';
					RS <= '0';
					INICIOTX_S <= '1';
					ESTADO <= ESPERA_FINTX;
					
					
					IF 	DATO_AMANDAR = 0 THEN DATAIN_S <= x"30";
					ELSIF	DATO_AMANDAR = 1 THEN DATAIN_S <= x"30";
					ELSIF	DATO_AMANDAR = 2 THEN DATAIN_S <= x"39";
					ELSIF	DATO_AMANDAR = 3 THEN DATAIN_S <= x"14";
					ELSIF	DATO_AMANDAR = 4 THEN DATAIN_S <= x"56";
					ELSIF	DATO_AMANDAR = 5 THEN DATAIN_S <= x"6D";
					ELSIF	DATO_AMANDAR = 6 THEN DATAIN_S <= x"70";
					ELSIF	DATO_AMANDAR = 7 THEN DATAIN_S <= x"0C"+CONF_CURSOR;
					ELSIF	DATO_AMANDAR = 8 THEN DATAIN_S <= x"06";
					ELSIF	DATO_AMANDAR = 9 THEN DATAIN_S <= x"01";
					ELSIF DATO_AMANDAR = 10 THEN DATAIN_S <= x"02";
					END IF;						
			
			WHEN ESPERA_FINTX =>
					
					BD_LCD <= x"00";
					INICIOTX_S <= '0';
					DATAIN_S <= x"00";
					PRESENTE <= ESPERA_FINTX;
					
					IF DATO_AMANDAR = 10 THEN
						FUTURO <= CHECAR;
					ELSE
						FUTURO <= CARGAR_DATOINI;
					END IF;
					
					IF FINTX_S = '1' THEN
						ESTADO <= DELAY_INILCD;
					ELSE
						ESTADO <= ESPERA_FINTX;
					END IF;
					
			WHEN CARGAR_DATOWRITE =>
			
					BD_LCD <= x"00";						
					RS <= '1';
					DATAIN_S <= DATA_CHAR(7 DOWNTO 0);
					FUTURO <= CHECAR;
					ESTADO <= CHAR;
					INICIOTX_S <= '1';					
					
			WHEN CHAR =>
					
					BD_LCD <= x"00";				
					DATAIN_S <= x"00";
					INICIOTX_S <= '0';
					PRESENTE <= CHAR;
						
					IF FINTX_S = '1' THEN
						ESTADO <= DELAY_DATO;
					ELSE
						ESTADO <= CHAR;
					END IF;	

			WHEN CARGAR_DATOWRITE_ASCII =>
			
					BD_LCD <= x"00";					
					RS <= '1';
					DATAIN_S <= DATA_CHAR(7 DOWNTO 0);
					FUTURO <= CHECAR;
					ESTADO <= CHAR_ASCII;
					INICIOTX_S <= '1';					
					
			WHEN CHAR_ASCII =>
					
					BD_LCD <= x"00";					
					DATAIN_S <= x"00";
					INICIOTX_S <= '0';
					PRESENTE <= CHAR_ASCII;
					
					IF FINTX_S = '1' THEN
						ESTADO <= DELAY_DATO;
					ELSE
						ESTADO <= CHAR_ASCII;
					END IF;
			
			WHEN CARGAR_DATOPOS =>
				
					BD_LCD <= x"00";					
					RS <= '0';
					DATAIN_S <= VEC_POS(7 DOWNTO 0);
					FUTURO <= CHECAR;
					ESTADO <= POS;
					INICIOTX_S <= '1';
			
			WHEN POS =>
				
					BD_LCD <= x"00";					
					DATAIN_S <= x"00";
					INICIOTX_S <= '0';
					PRESENTE <= POS;																						
				
					IF FINTX_S = '1' THEN
						ESTADO <= DELAY_DATO;
					ELSE
						ESTADO <= POS;
					END IF;
				
			WHEN CARGAR_DATOLP =>
				
					BD_LCD <= x"00";					
					RS <= '0';
					DATAIN_S <= x"01";
					FUTURO <= CHECAR;
					ESTADO <= LIMPIAR_PANTALLA;
					INICIOTX_S <= '1';
			
			WHEN LIMPIAR_PANTALLA =>
				
				DATAIN_S <= x"00";
				INICIOTX_S <= '0';																						
				PRESENTE <= LIMPIAR_PANTALLA;
				
				
				IF FINTX_S = '1' THEN
					ESTADO <= DELAY_DATO;
				ELSE
					ESTADO <= LIMPIAR_PANTALLA;
				END IF;

			WHEN NADA => 
				
					BD_LCD <= x"00";					
					DATAIN_S <= x"00";
					INICIOTX_S <= '0';																														   								   									
				
					IF CONTA_DELAY = DELAY_FIN THEN				
						CONTA_DELAY <= 0;
						ESTADO <= CHECAR;
						BD_LCD <= x"08";
					ELSE
						CONTA_DELAY <= CONTA_DELAY +1;
						ESTADO <= NADA;
					END IF;
			
			
			WHEN BUCLE_INI	=>
										
					DIR_BI <= INC_DIR_S;
					INC_DIR_S <= INC_DIR_S +1;
					ESTADO <= CHECAR;	
					BD_LCD <= x"06";					
						
			WHEN BUCLE_FIN =>
										
					INC_DIR_S <= DIR_BI;
					ESTADO <= BUCLE_INI;
					BD_LCD <= x"07";
			
			WHEN DELAY_INILCD =>

					BD_LCD <= x"00";
					DATAIN_S <= x"00";
				
					IF CONTA_DELAY = DELAY_FIN THEN
						CONTA_DELAY <= 0;
						ESTADO <= FUTURO;
						DATO_AMANDAR <= DATO_AMANDAR +1;
					
					IF DATO_AMANDAR = 10 THEN
						INC_DIR_S <= INC_DIR_S+1;
					END IF;
						
					ELSE
						CONTA_DELAY <= CONTA_DELAY +1;
						ESTADO <= DELAY_INILCD;
					END IF;
			
			WHEN DELAY_RESET =>

					BD_LCD <= x"00";					
					DATAIN_S <= x"00";
					INICIOTX_S <= '0';
				
					IF CONTA_DELAY = DELAY_FIN THEN
						CONTA_DELAY <= 0;
						ESTADO <= FUTURO;
					ELSE
						CONTA_DELAY <= CONTA_DELAY +1;
						ESTADO <= DELAY_RESET;
					END IF;
			
			WHEN DELAY_DATO =>
									
					IF CONTA_DELAY = DELAY_FIN THEN
						CONTA_DELAY <= 0;
						ESTADO <= FUTURO;
						INC_DIR_S <= INC_DIR_S+1;
						
								--BANDERA--
									IF 	PRESENTE = ESPERA_FINTX		 THEN BD_LCD <= x"01";
									ELSIF PRESENTE = CHAR 		  		 THEN BD_LCD <= x"02";
									ELSIF PRESENTE = POS 		  		 THEN BD_LCD <= x"03";
								   ELSIF PRESENTE = CHAR_ASCII 		 THEN BD_LCD <= x"05";
								   ELSIF PRESENTE = BUCLE_INI  		 THEN BD_LCD <= x"06";
									ELSIF PRESENTE = BUCLE_FIN  		 THEN BD_LCD <= x"07";
									ELSIF PRESENTE = LIMPIAR_PANTALLA THEN BD_LCD <= x"08";
									ELSE  BD_LCD <= x"00";
									END IF;
								-----------
						
						
					ELSE
						CONTA_DELAY <= CONTA_DELAY +1;
						ESTADO <= DELAY_DATO;
					END IF;				
				
			WHEN FIN => ESTADO <= CHECAR;
					
			WHEN OTHERS => null;
		
		END CASE;
	END IF;
END PROCESS;
				

end Behavioral;				

