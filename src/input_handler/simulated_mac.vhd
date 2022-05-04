LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY simulated_mac IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		val : IN STD_LOGIC;
		src : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
		dst : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
		por : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		porto : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		valo : OUT STD_LOGIC
	);
END simulated_mac;

ARCHITECTURE simulated_mac_arc OF simulated_mac IS

	SIGNAL count : INTEGER RANGE 0 TO 10;

BEGIN

	sim_mac : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (val = '1') THEN
				IF (count = 10) THEN
					valo <= '1';
					count <= 0;
					porto <= src(24) & dst(9) & src(47) & dst(11);
				ELSE
					count <= count + 1;
					valo <= '0';
				END IF;
			
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;