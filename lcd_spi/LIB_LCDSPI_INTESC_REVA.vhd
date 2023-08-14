--
--							LIBRERIA LCD CON PROTOCOLO SPI
--
-- Descripci�n: Con �sta librer�a podr�s implementar c�digos para una LCD con protocolo SPI de manera
-- f�cil y r�pida, con todas las ventajas de utilizar una FPGA.
--
-- Caracter�sticas:
-- 
--	Los comandos que puedes utilizar son los siguientes:
--
-- LCD_INI() -> Inicializa la lcd.
--		 			 NOTA: Dentro de los par�ntesis poner un vector de 2 bits para encender o apagar
--					 		 el cursor y activar o desactivar el parpadeo.
--
--		"1x" -- Cursor ON
--		"0x" -- Cursor OFF
--		"x1" -- Parpadeo ON
--		"x0" -- Parpadeo OFF
--
--   Por ejemplo: LCD_INI("10") -- Inicializar LCD con cursor encendido y sin parpadeo 
--	
--			
-- CHAR() -> Manda una letra may�scula o min�scula
--
--				 IMPORTANTE: 1) Debido a que VHDL no es sensible a may�sculas y min�sculas, si se quiere
--								    escribir una letra may�scula se debe escribir una "M" antes de la letra.
--								 2) Si se quiere escribir la letra "S" may�scula, se declara "MAS"
--								 3) No se pueden mandar cadenas de caracteres debido a que algunas FPGA no son
--									 compatibles con este tipo de variables.
--											
-- 	Por ejemplo: CHAR(A)  -- Escribe en la LCD la letra "a"
--						 CHAR(MA) -- Escribe en la LCD la letra "A"	
--						 CHAR(S)	 -- Escribe en la LCD la letra "s"
--						 CHAR(MAS)	 -- Escribe en la LCD la letra "S"	
--	
--
-- POS() -> Escribir en la posici�n que se indique.
--				NOTA: Dentro de los par�ntesis se dene poner la posici�n de la LCD a la que se quiere escribir, empezando
--						por la fila seguido de la columna, ambos n�meros separados por una coma.
--		
--		Por ejemplo: POS(1,2) -- Manda cursor a la fila 1, columna 2
--						 POS(2,4) -- Manda cursor a la fila 2, columna 4		
--
--
-- CHAR_ASCII() -> Escribe un caracter a partir de su c�digo en ASCII
--						 NOTA: Dentro de los parentesis escribir x"(n�mero hex.)". Tambi�n se pueden usar varibles de
--								 tipo STD_LOGIC_VECTOR.
--
--		Por ejemplo: CHAR_ASCII(x"40") -- Escribe en la LCD el caracter "@"
--
--											�
--
--						 SIGNAL VAL_ASCCI : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"55";
--						 CHAR_ASCII(VAL_ASCII) -- Escribe en la LCD el valor de VAL_ASCCI, en este caso el x"55" que es el
--														  caracter "U"
--
--					
-- CODIGO_FIN() -> Finaliza el c�digo. 
--						 NOTA: Dentro de los par�ntesis poner cualquier n�mero: 1,2,3,4...,8,9.
--
--
-- BUCLE_INI() -> Indica el inicio de un bucle. 
--						NOTA: Dentro de los par�ntesis poner cualquier n�mero: 1,2,3,4...,8,9.
--
--
-- BUCLE_FIN() -> Indica el final del bucle.
--						NOTA: Dentro de los par�ntesis poner cualquier n�mero: 1,2,3,4...,8,9.
--
--
-- INT_NUM() -> Escribe en la LCD un n�mero entero.
--					 NOTA: Dentro de los par�ntesis poner s�lo un n�mero que vaya del 0 al 9,
--						    si se quiere escribir otro n�mero entero se tiene que volver
--							 a llamar la funci�n. Tambi�n podemos utilizar variables de tipo entero
--							 con un rango de 0 a 9.
--
--		Por ejemplo: INT_NUM(6) -- Escribe en la LCD el n�mero 1.
--									
--										�
--
--						 SIGNAL VAR1 : INTEGER RANGE 0 TO 9 := 3;
--                 INT_NUM(VAR1) -- Escribe el la LCD el valor de VAR1, en este caso el 3
--
--
-- LIMPIAR_PANTALLA() -> Manda a limpiar la LCD.
--								 NOTA: �sta funci�n se activa poniendo dentro de los par�ntesis
--										 un '1' y se desactiva con un '0'. 
--
--		Por ejemplo: LIMPIAR_PANTALLA('1') -- Limpiar pantalla est� activado.
--						 LIMPIAR_PANTALLA('0') -- Limpiar pantalla est� desactivado.
--
--
-- Algunas funci�nes generan un vector ("BLCD") cuando se termin� de ejecutar dicha funci�n y
--	que puede ser utilizado como una bandera, el vector solo dura un ciclo de reloj de la FPGA (50Mhz).
--	   
--		LCD_INI() ---------- BLCD <= x"01"
--		CHAR() ------------- BLCD <= x"02"
--		POS() -------------- BLCD <= x"03"
--	   CHAR_ASCII() ------- BLCD <= x"05"
-- 	INT_NUM() ---------- BLCD <= x"05"
--	   BUCLE_INI() -------- BLCD <= x"06"
--		BUCLE_FIN() -------- BLCD <= x"07"
--		LIMPIAR_PANTALLA() - BLCD <= x"08"
--
--
--		�IMPORTANTE!
--
--		Cada funci�n se acompa�a con " INSTRUCCION(NUM) <= (FUNCI�N) " como lo muestra el siguiente c�digo
-- 	demostrativo.
--
--
--                CÓDIGO DEMOSTRATIVO
--
-- INSTRUCCION(0) <= LCD_INI("11"); --INICIALIZAMOS LCD, CURSOR A HOME, CURSOR ON, PARPADEO ON.
-- INSTRUCCION(1) <= POS(1,4);--------EMPEZAMOS A ESCRIBIR EN LA LINEA 1, COLUMNA 4
-- INSTRUCCION(2) <= CHAR(MH);--------ESCRIBIMOS EN LA LCD LA LETRA "H" (MAY�SCULA)
-- INSTRUCCION(3) <= CHAR(O);	--------ESCRIBIMOS EN LA LCD LA LETRA "O" (MIN�SCULA)		
-- INSTRUCCION(4) <= CHAR(L);
-- INSTRUCCION(5) <= CHAR(A);
-- INSTRUCCION(6) <= CHAR_ASCII(x"21");--ESCRIBIMOS EL CARACTER "!"
-- INSTRUCCION(7) <= CODIGO_FIN(1);-----------FINALIZAMOS EL CODIGO
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
USE WORK.COMANDOS_LCDSPI_REVA.ALL;



entity LIB_LCDSPI_INTESC_REVA is

PORT( CLK : IN STD_LOGIC;

-------------PUERTOS LCD (NO BORRAR)------------
		RST : OUT STD_LOGIC;		 					 --
		RS  : OUT STD_LOGIC; 	 					 --
		CSB : OUT STD_LOGIC;		 					 --
		SCL : OUT STD_LOGIC;		 					 --
		SI  : OUT STD_LOGIC;	 					 --
		BLCD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- DECLARAR LA BANDERA COMO PUERTO SI SE UTILIZA  
															 --    LA LIBRERIA COMO COMPONENTE 
------------------------------------------------


------------DECLARA AQU� TUS PUERTOS------------

------------------------------------------------

);

end LIB_LCDSPI_INTESC_REVA;

architecture Behavioral of LIB_LCDSPI_INTESC_REVA is

-----------------------COMPONENTES DE LCD-------------------------
-------------------------(NO MODIFICAR)---------------------------
TYPE RAM IS ARRAY (0 TO  60) OF STD_LOGIC_VECTOR(11 DOWNTO 0);  --																					--
SIGNAL INSTRUCCION : RAM;													 --
																					 --
COMPONENT PROCESADOR_LCDSPI_REVA is  					  	  			 --
																					 --
PORT(CLK : IN STD_LOGIC;				 					  	  			 --
																		   		 --
		RST : OUT STD_LOGIC;		 		 					  	  			 --
		RS  : OUT STD_LOGIC; 	 		 					  	  			 --
		CSB : OUT STD_LOGIC;		 		 					  	  			 --
		SCL : OUT STD_LOGIC;		 		 					  	  			 --
		SI  : OUT STD_LOGIC;									  	  			 -- 
		VECTOR_MEM : IN STD_LOGIC_VECTOR(11 DOWNTO 0); 	  			 --
		BD_LCD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);					 --
	   INC_DIR : OUT INTEGER RANGE 0 TO 1024);	 	  	  			 --
																		  			 --
END COMPONENT	PROCESADOR_LCDSPI_REVA;					  	  			 --
																					 --
																	     			 --
SIGNAL VECTOR_MEM_S : STD_LOGIC_VECTOR(11 DOWNTO 0);	  			 --
SIGNAL DIR : INTEGER RANGE 0 TO 1024:=0;					  			 --
SIGNAL AUX_BLCD : STD_LOGIC_VECTOR(7 DOWNTO 0); --<------------------- DECLARAR LA BANDERA COMO SEÑAL SI SE UTILIZA 
																					 -- 		LA LIBRERIA COMO TOP  
------------------------------------------------------------------



------DECLARA AQU� TUS COMPONENTES-------
													
-----------------------------------------
CONSTANT delay_fin : integer := 24_999_999;

signal conta_delay : integer range 0 to delay_fin;
signal unidades, decenas : integer range 0 to 9 := 0;

begin

------------CONEXIONES INTERNAS LCD-------------
----------------(NO MODIFICAR)------------------
										   				 --
PRO_LCD: 												 --
PROCESADOR_LCDSPI_REVA PORT MAP( 				 --
						CLK => CLK,	   				 --
						RST => RST,	   				 --
						RS  => RS,	   				 --
						CSB => CSB,	   				 --
						SCL => SCL,	   				 --
						SI  => SI,	   				 --
						VECTOR_MEM => VECTOR_MEM_S, --
						BD_LCD => AUX_BLCD,				 --
						INC_DIR => DIR					 --
						);				   				 --
										   				 --
															 --
VECTOR_MEM_S <= INSTRUCCION(DIR); 				 --															
------------------------------------------------						

-------------------------------------------------------------------
-----------------ABAJO ESCRIBE TU C�DIGO EN VHDL-------------------

-------------------------------------------------------------------
process(CLK)
begin
	if rising_edge(CLK) then
		conta_delay <= conta_delay + 1;
		
		if conta_delay = delay_fin then
			conta_delay <= 0;
			unidades <= unidades + 1;
			if unidades = 9 then
				unidades <= 0;
				decenas <= decenas + 1;
				if decenas = 9 then 
					decenas <= 0;
				end if;
			end if;
		end if;
	end if;
end process;


-----------------------------------------------------------------------------------------
-------------------------ABAJO ESCRIBE TU C�DIGO PARA LA LCD-----------------------------

INSTRUCCION(0) <= LCD_INI("00"); -- Inicializar el LCD
INsTRUCCION(1) <= CHAR(MC);
INsTRUCCION(2) <= CHAR(O);
INsTRUCCION(3) <= CHAR(N);
INsTRUCCION(4) <= CHAR(T);
INsTRUCCION(5) <= CHAR(A);
INsTRUCCION(6) <= CHAR(D);
INsTRUCCION(7) <= CHAR(O);
INsTRUCCION(8) <= CHAR(R);
INsTRUCCION(9) <= CHAR_ASCII(x"3A");

INSTRUCCION(10) <= BUCLE_INI(1);
INSTRUCCION(11) <= POS(2, 4);
INSTRUCCION(12) <= INT_NUM(decenas);

INSTRUCCION(13) <= POS(2, 5);
INSTRUCCION(14) <= INT_NUM(unidades);

INSTRUCCION(15) <= BUCLE_FIN(1);
INSTRUCCION(16) <= CODIGO_FIN(1);

--INSTRUCCION(0)  <= LCD_INI("11");
--INSTRUCCION(1)  <= POS(1,3);
--INSTRUCCION(2)  <= CHAR(ML);
--INSTRUCCION(3)  <= CHAR(I);
--INSTRUCCION(4)  <= CHAR(B);
--INSTRUCCION(5)  <= CHAR_ASCII(x"2E");
--INSTRUCCION(6)  <= CHAR_ASCII(x"20");
--INSTRUCCION(7)  <= CHAR(L);
--INSTRUCCION(8)  <= CHAR(C);
--INSTRUCCION(9)  <= CHAR(D);
--INSTRUCCION(10) <= CHAR_ASCII(x"20");
--INSTRUCCION(11) <= CHAR(MAS);
--INSTRUCCION(12) <= CHAR(MP);
--INSTRUCCION(13) <= CHAR(MI);
--INSTRUCCION(14) <= POS(2,6);
--INSTRUCCION(15) <= CHAR(MI);
--INSTRUCCION(16) <= CHAR(MN);
--INSTRUCCION(17) <= CHAR(MT);
--INSTRUCCION(18) <= CHAR(ME);
--INSTRUCCION(19) <= CHAR(MAS);
--INSTRUCCION(20) <= CHAR(MC);
--INSTRUCCION(21) <= CODIGO_FIN(1);

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------


end Behavioral;

