LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY four_port_switch IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		vali : IN STD_LOGIC_VECTOR(3 downto 0);
		dati : IN STD_LOGIC_VECTOR(31 downto 0);
		valo : OUT STD_LOGIC_VECTOR(3 downto 0);
		dato : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
END four_port_switch;

ARCHITECTURE four_port_switch_arc OF four_port_switch IS

COMPONENT input_handler IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		val : IN STD_LOGIC;
		dat : IN STD_LOGIC_VECTOR(0 TO 7);
		por : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		valo1 : OUT STD_LOGIC;
		dato1 : OUT STD_LOGIC_VECTOR(0 TO 7);
		valo2 : OUT STD_LOGIC;
		dato2 : OUT STD_LOGIC_VECTOR(0 TO 7);
		valo3 : OUT STD_LOGIC;
		dato3 : OUT STD_LOGIC_VECTOR(0 TO 7);
		valo4 : OUT STD_LOGIC;
		dato4 : OUT STD_LOGIC_VECTOR(0 TO 7)
	);
END COMPONENT;

COMPONENT roundrobin IS
	PORT (
		clk : IN STD_LOGIC;
		dat1 : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		val1 : IN STD_LOGIC;
		dat2 : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		val2 : IN STD_LOGIC;
		dat3 : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		val3 : IN STD_LOGIC;
		dato : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		valo : OUT STD_LOGIC
	);
END COMPONENT;

BEGIN


	

END ARCHITECTURE;