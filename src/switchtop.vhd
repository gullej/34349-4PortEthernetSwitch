LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY switchtop IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		vali : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		dati : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		valo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		dato : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END switchtop;

ARCHITECTURE switchtop_arc OF switchtop IS

COMPONENT switchlogic IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		vali : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		dati : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		valo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		dato : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL line1, line3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL line2, line4  : STD_LOGIC_VECTOR(31 DOWNTO 0);




BEGIN

PROCESS (clk)
BEGIN
    IF (rising_edge(clk)) THEN
        line1 <= vali;
        line2 <= dati;
        valo <= line3;
        dato <= line4;
    END IF;
END PROCESS;

	switch : switchlogic port MAP(clk, reset, line1, line2, line3, line4);

END ARCHITECTURE;