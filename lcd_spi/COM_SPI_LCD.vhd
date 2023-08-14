----------------------------------------------------------------------------------
-- Company: INTESC
-- Engineer: Emmanuel Rojas Briseño
-- 
-- Create Date:    17:13:42 10/14/2013 
-- Design Name: SPI Maestro
-- Module Name: SPIMaster - Behavioral 
-- Project Name: AVANXE 	
-- Target Devices: AVANXE - Spartan 6 
-- Tool versions: ISE Design Suite 14.5
-- Description: Módulo SPI Maestro
--
-- Dependencies: 
--
-- Revision: 2.0
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
--	Módulo de SPI Maestro
-- Características:
-- * Frecuencia ajustable
-- * Número de bits ajustable
-- * Retardo entre el flanco de bajada y el primer bit de transmisión ajustable
-- * Transmite y recibe primero del bit más significativo
----------------------------------------------------------------------------------
-- Ejemplo de transmisión (8 bits)(Dato transmitido y recibido "AA")

--		SCLK	_____/---\___/---\___/---\___/---\___/---\___/---\___/---\___/---\_______
--		SS		--\________________________________________________________________/-----
						-- 1 -- -- 0 -- -- 1 -- -- 0 -- -- 1 -- -- 0 -- -- 1 -- --0 -- 
--		MISO	_____/-------\_______/-------\_______/-------\_______/-------\____________
--		MOSI	_____/-------\_______/-------\_______/-------\_______/-------\____________

--	La salida de datos del módulo (MOSI) hace el cambio de dato en los flancos de subida
-- La entrada de datos del módulo (MISO) hace el muestreo del dato en los flancos de bajada

-- Si se quiere iniciar una transmisión de datos se siguen los siguientes pasos:
-- 	1.- Se coloca el dato que se quiere enviar en la entrada paralela del módulo (DATAIN)
--		2.- Se pone a '1' la señal de inicio de transmisión (INICIOTX)
--		3.- Si el módulo ya está recibiendo o transmitiendo datos se pondrá a '1' la bandera de ocupado (BUSOCUPADO)
--		4.- Cuando se concluya la transmisión se notificará con un pulso un pulso (FINTX)
--		5.- El módulo se pondrá en espera para iniciar una nueva transferencia

-- Si se quieren iniciar una recepción de datos se siguen los siguientes pasos:
--		1.- Se pone a '1' la señal de inicio de recepción (INICIORX)
--		2.- Si el módulo ya está recibiendo o transmitiendo datos se pondrá a '1' la bandera de ocupado (BUSOCUPADO)
-- 	3.- Cuando se concluya la recepción se notificará con un pulso (FINRX)
--		4.- Se pondrá a la salida paralela del módulo (DATAOUT) el dato recibido
--		5.- El módulo se pondrá en espera para iniciar una nueva transferencia

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity COM_SPI_LCD is								
			
	Port	  (CLK 			:	in		STD_LOGIC;								-- Clock interno 
				SCLK			: 	out 	STD_LOGIC;								-- Clock de la interfaz SPI
				MISO			:	in		STD_LOGIC;								-- Master Input Slave Output
				MOSI			:	out	STD_LOGIC;								-- Master Output Slave Input
				SS				:	out	STD_LOGIC;								-- Slave Select
				DATAIN		:	in		STD_LOGIC_VECTOR(7 downto 0);	-- Entrada de datos para transmisión serial
				DATAOUT		:	out	STD_LOGIC_VECTOR(7 downto 0);	--	Salida de datos para transmisión serial
				INICIOTX		: 	in		STD_LOGIC;								-- Inicio de transferencia
				INICIORX		:	in		STD_LOGIC;								-- Inicio RX
				FINTX			:	out	STD_LOGIC;								-- Finalización de transferencia
				FINRX			:	out	STD_LOGIC;
				BUSOCUPADO	:	out	STD_LOGIC;
				SPI_MODE		:	in integer range 0 to 3 					-- Modo de operacion de SPI. Por default Modo 0
				);
				
end COM_SPI_LCD;


architecture Behavioral of COM_SPI_LCD is

CONSTANT cicloTrabajoSclk : integer := 1000/2;

CONSTANT BITS			:	integer	:= 8;
CONSTANT CICLOSSS		:	integer	:= 0;
CONSTANT	CICLOSSCLK 	: 	integer	:= 1000;

-------------------------------- Máquinas de estado ---------------------------------------
type	EDO_SCLK is (espera,inicioSS,flancoPositivo,flancoNegativo,finalizacion); 	-- Máquina de estados de SCLK
type 	EDO_TX is(inicializacion,transmision,finalizacion);								-- Máquina de estados para transmisor
type	EDO_RX is (inicializacion,recepcion,finalizacion);									-- Máquina de estados para receptor
signal	edoPresenteSCLK: 	EDO_SCLK		:= espera;
signal	edoPresenteTX	:	EDO_TX		:= inicializacion;
signal 	edoPresenteRX	: 	EDO_RX		:= inicializacion;

------------------------------------- Señales ---------------------------------------------
signal 	inicioSCLKRX	:	STD_LOGIC := '0';										-- Señal para iniciar la señal de reloj para la recepción
signal	inicioSCLKTX	:	STD_LOGIC := '0';										-- Señal para iniciar la señal de reloj para la transmisión
signal 	inicioSCLK		:	STD_LOGIC	:= '0';							-- Salida de una compuerta OR entre las anteriores señales de reloj
signal	risingSCLK		:	STD_LOGIC	:= '0';							-- Señal del flanco de subida del reloj
signal	fallingSCLK		:	STD_LOGIC	:= '0';							-- Señal del flanco de bajada del reloj 
signal	ssCont			:	integer 	range 0 to CICLOSSS	:= 0;		-- Contador para el retardo entre  el flanco de bajada de SS y el primer bit de datos
signal	sclkCont			: 	integer	range 0 to CICLOSSCLK := 0;	-- Contador para crear el reloj para la comunicación
signal	sclkBitCont		:	integer range 0 to BITS := 0;				-- Contador de bits transmitidos
signal	intDataIn		: 	STD_LOGIC_VECTOR(BITS-1 downto 0);		-- búfer de entrada de datos para su salida serial
signal 	intDataOut		:	STD_LOGIC_VECTOR(BITS-1 downto 0);		-- búfer de salida de datos de la entrada serial
signal	txBitCont		:	integer	range 0 to BITS-1 := BITS-1;	-- Contador de bits del transmisor
signal 	rxBitCont		:	integer	range 0 to BITS-1 := BITS-1;	-- Contador de bits del receptor
signal	sclkOcupado		:	STD_LOGIC	:= '0';							-- Señal que indica que el módulo está transmitiendo o recibiendo datos
signal	sclkOcupadoRX	:	STD_LOGIC	:= '0';							-- Señal que indica que el reloj está siendo usado por el receptor
signal	sclkOcupadoTX	: 	STD_LOGIC	:= '0';							-- Señal que indica que el reloj está siendo usado por el transmisor
signal	busOcupadoRX	:	STD_LOGIC	:= '0';							-- Señal que indica que el módulo está recibiendo
signal	busOcupadoTX	:	STD_LOGIC	:= '0';							-- Señal que indica que el módulo está transmitiendo
signal	SCLK_sig 		:	STD_LOGIC	:= '0';							-- Señal de reloj SPI. Se mapea a SCLK de acuerdo al modo usado en SPI

begin

inicioSCLK <= inicioSCLKRX or inicioSCLKTX;
sclkOcupado <= sclkOcupadoRX or sclkOcupadoTX;
BUSOCUPADO <= busOcupadoRX or busOcupadoTX;
SCLK <= SCLK_sig when SPI_MODE = 0 or SPI_MODE = 2 else
			not SCLK_sig ;

--------------------------------- Recepción -----------------------------------------

RegistroRecepcion : process(CLK)
begin
	if rising_edge(CLK) then
		case edoPresenteRX is
			when inicializacion =>						
				FINRX <= '0';						
				if INICIORX = '1' then					
					if sclkOcupado = '0' then			
						busOcupadoRX <= '1';			
						sclkOcupadoRX <= '1';			
						inicioSCLKRX <= '1';	
						edoPresenteRX <= recepcion;
					end if;
				end if;
			when recepcion =>
				if fallingSCLK = '1' then
					rxBitCont <= rxBitCont - 1;
					intDataOut(rxBitCont) <= MISO;
					if rxBitCont = 0 then
						rxBitCont <= BITS - 1;
						edoPresenteRX <= finalizacion;
					end if;
				end if;
			when finalizacion =>
				busOcupadoRX <= '0';
				sclkOcupadoRX <= '0';
				inicioSCLKRX <= '0';
				FINRX <= '1';
				DATAOUT <= intDataOut;
				edoPresenteRX <= inicializacion;
		end case;
	end if;
end process;

--------------------------------- Transmisión -----------------------------------------

RegistroTransmision : process(CLK)
begin

	if rising_edge(CLK) then
		case edoPresenteTX is
			when inicializacion =>
				FINTX <= '0';
				MOSI <= '0';
				if INICIOTX = '1' then
					if sclkOcupado = '0' then
						busOcupadoTX <= '1';
						sclkOcupadoTX <= '1';
						intDataIn <= DATAIN;
						inicioSCLKTX <= '1';
						edoPresenteTX <= transmision;
					end if;
				end if;
			when transmision =>
				if risingSCLK = '1' then 
					txBitCont <= txBitCont - 1;
					MOSI <= intDataIn(txBitCont);
					if txBitCont = 0 then
						txBitCont <= BITS-1;
						edoPresenteTX <= finalizacion;
					end if;
				end if;
			when finalizacion =>
				if fallingSCLK = '1' then
					busOcupadoTX <= '0';
					sclkOcupadoTX <= '0';
					inicioSCLKTX <= '0';
					FINTX <= '1';
					edoPresenteTX <= inicializacion;
				end if;
		end case;
	end if;
	
end process;

------------------------------------------------------------------------------------------

SerialClock : process(CLK)
begin

	if rising_edge(CLK) then
		case edoPresenteSCLK is
			when espera =>
				SS <= '1';
				if inicioSCLK = '1' then
					edoPresenteSCLK <= inicioSS;
				end if;
			when inicioSS =>
				ssCont <= ssCont + 1;
				SS <= '0';
				if ssCont = CICLOSSS then
					edoPresenteSCLK <= flancoPositivo;
					ssCont <= 0;
				end if;
			when flancoPositivo =>
				SCLK_sig <= '1';
				--SCLK_sig <= '0';
				sclkCont <= sclkCont + 1;
				if sclkCont = 0 then
					risingSCLK <= '1';
				elsif sclkCont = cicloTrabajoSclk - 1 then
					edoPresenteSCLK <= flancoNegativo;
				else
					risingSCLK <= '0';
				end if;
				
			when flancoNegativo =>
				SCLK_sig <= '0';
				--SCLK_sig <= '1';
				sclkCont <= sclkCont + 1;
				if	sclkCont = cicloTrabajoSclk + 1 then
					fallingSCLK <= '1';
				elsif sclkCont = CICLOSSCLK - 1 then
					sclkBitCont <= sclkBitCont + 1;
					sclkCont <= 0;
					if sclkBitCont = BITS-1 then
						edoPresenteSCLK <= finalizacion;
						sclkBitCont <= 0;
					else
						edoPresenteSCLK <= flancoPositivo;
					end if;
				else
					fallingSCLK <= '0';
				end if;

			when finalizacion =>
				ssCont <= ssCont + 1;
				SS <= '0';
				if ssCont = CICLOSSS then
					edoPresenteSCLK <= espera;
					ssCont <= 0;
				end if;
		end case;
	end if;	
end process;

------------------------------------------------------------------------------------------


end Behavioral;
