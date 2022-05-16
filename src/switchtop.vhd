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

COMPONENT switch_logic IS
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

valo <= line3;
dato <= line4;

PROCESS (clk)
BEGIN
    IF (rising_edge(clk)) THEN
        IF (vali(0) = '1') THEN
            line2(7 downto 0) <= dati(7 downto 0);
            line1(0) <= '1';
        ELSE
            line2(7 downto 0) <= (others => '0');
            line1(0) <= '0';
        END IF;

        IF (vali(1) = '1') THEN
            line2(15 downto 8) <= dati(15 downto 8);
            line1(1) <= '1';
        ELSE
            line2(15 downto 8) <= (others => '0');
            line1(1) <= '0';
        END IF;        
        
        IF (vali(2) = '1') THEN
            line2(23 downto 16) <= dati(23 downto 16);
            line1(2) <= '1';
        ELSE
            line2(23 downto 16) <= (others => '0');
            line1(2) <= '0';
        END IF;

        IF (vali(3) = '1') THEN
            line2(31 downto 24) <= dati(31 downto 24);
            line1(3) <= '1';
        ELSE
            line2(31 downto 24) <= (others => '0');
            line1(3) <= '0';
        END IF;

    END IF;
END PROCESS;

	switch : switch_logic port MAP(clk, reset, line1, line2, line3, line4);

END ARCHITECTURE;