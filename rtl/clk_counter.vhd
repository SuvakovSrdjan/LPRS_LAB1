-------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije
--  Autor: LPRS2  <lprs2@rt-rk.com>                                           
--                                                                             
--  Ime modula: timer_counter                                                          
--                                                                             
--  Opis:                                                               
--                                                                             
--    Modul odogvaran za indikaciju o proteku sekunde
--                                                                             
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY clk_counter IS GENERIC(
                              -- maksimalna vrednost broja do kojeg brojac broji
                              max_cnt : STD_LOGIC_VECTOR(25 DOWNTO 0) := "10111110101111000010000000" -- 50 000 000
                             );
                      PORT   (
                               clk_i     : IN  STD_LOGIC; -- ulazni takt
                               rst_i     : IN  STD_LOGIC; -- reset signal
                               cnt_en_i  : IN  STD_LOGIC; -- signal dozvole brojanja
                               cnt_rst_i : IN  STD_LOGIC; -- signal resetovanja brojaca (clear signal)
                               one_sec_o : OUT STD_LOGIC  -- izlaz koji predstavlja proteklu jednu sekundu vremena
                             );
END clk_counter;

ARCHITECTURE rtl OF clk_counter IS
signal add_cnt 				: STD_LOGIC_VECTOR (25 downto 0);
signal cnt_50mh_reached 	: STD_LOGIC;
signal cnt_left				: STD_LOGIC_VECTOR(25 downto 0);
signal cnt_mid					: STD_LOGIC_VECTOR(25 downto 0);
signal cnt_right				: STD_LOGIC_VECTOR(25 downto 0);
signal cnt						: STD_LOGIC_VECTOR(25 downto 0);
SIGNAL counter_r 				: STD_LOGIC_VECTOR(25 DOWNTO 0);

component reg is
	generic(
		WIDTH    : positive := 26;
		RST_INIT : integer := 0
	);
	port(
		i_clk  : in  std_logic;
		in_rst : in  std_logic;
		i_d    : in  std_logic_vector(WIDTH-1 downto 0);
		o_q    : out std_logic_vector(WIDTH-1 downto 0)
	);
end component reg;




BEGIN
reg1: reg PORT MAP (
		i_clk => clk_i,
		in_rst=> not(rst_i),
		i_d => cnt_right,
		o_q => cnt
);


	


--Brojac:
	
	add_cnt <= cnt + 1;
	with add_cnt select cnt_50mh_reached <= 
	'1' when "10111110101111000001111111",
	'0' when others;

--MUX1--	

	with cnt_50mh_reached select cnt_left <=
	add_cnt when '0',
	"00000000000000000000000000" when others;


--MUX2--
	
	with cnt_en_i select cnt_mid <=
	cnt_left when '1',
	cnt when others;
	
--MUX3--
	
	with cnt_rst_i select cnt_right <=
	cnt_mid when '0',
	"00000000000000000000000000" when others;
	
--Izlaz--

	one_sec_o <= cnt_50mh_reached;

END rtl;