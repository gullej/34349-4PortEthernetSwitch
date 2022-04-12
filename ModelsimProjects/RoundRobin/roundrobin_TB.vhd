LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY roundrobin_tb IS
END ENTITY;

ARCHITECTURE roundrobin_tb_arc OF roundrobin_tb IS

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

	SIGNAL clk : STD_LOGIC;

	SIGNAL dat1_TB, dat2_TB, dat3_TB : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL val1_TB, val2_TB, val3_TB, valo_TB : STD_LOGIC;
	SIGNAL dato_TB : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL COUNTER : INTEGER RANGE 0 TO 1024 := 0;

	SIGNAL valids : STD_LOGIC_VECTOR(0 TO 127) := "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
BEGIN

	stimulus : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 5 ns;
		clk <= '1';
		WAIT FOR 5 ns;
	END PROCESS;

	DUT : roundrobin PORT MAP(clk, dat1_TB, val1_TB, dat2_TB, val2_TB, dat3_TB, val3_TB, dato_TB, valo_TB);

	feeder : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (COUNTER < 128) THEN
				dat1_TB <= valids(COUNTER) & x"11";
				val1_TB <= '1';
				dat2_TB <= valids(COUNTER) & x"22";
				val2_TB <= '1';
				dat3_TB <= valids(COUNTER) & x"33";
				val3_TB <= '1';
				COUNTER <= COUNTER + 1;
			ELSIF (COUNTER < 256) THEN
				dat1_TB <= valids(COUNTER - 128) & x"44";
				val1_TB <= '1';
				dat2_TB <= valids(COUNTER - 128) & x"55";
				val2_TB <= '1';
				dat3_TB <= valids(COUNTER - 128) & x"66";
				val3_TB <= '1';
				COUNTER <= COUNTER + 1;
			ELSIF (COUNTER < 384) THEN
				val1_TB <= '0';
				dat2_TB <= valids(COUNTER - 256) & x"77";
				val2_TB <= '1';
				val3_TB <= '0';
				COUNTER <= COUNTER + 1;
			ELSE
				val1_TB <= '0';
				val2_TB <= '0';
				val3_TB <= '0';
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;