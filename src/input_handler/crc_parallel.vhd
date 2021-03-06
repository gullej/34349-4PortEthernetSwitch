LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY crc_parallel IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		val : IN STD_LOGIC;
		dat : IN STD_LOGIC_VECTOR(0 TO 7);
		out_val : OUT STD_LOGIC;
		out_err : OUT STD_LOGIC
	);
END crc_parallel;

ARCHITECTURE crc_parallel_arc OF crc_parallel IS

	SIGNAL R : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	TYPE state_type IS (REST, RUN, FIN);
	SIGNAL state : state_type := REST;
	SIGNAL data : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL val_reg : STD_LOGIC;
	SIGNAL count : INTEGER RANGE 0 TO 5 := 0;
BEGIN

	feeder : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			val_reg <= val;

			IF (count < 4) THEN
				data <= NOT dat;
			ELSE
				data <= dat;
			END IF;
		END IF;
	END PROCESS;

	state_machine : PROCESS (state, count, val, val_reg, reset, clk)
	BEGIN
		IF (reset = '1') THEN
			state <= REST;
		ELSIF (val_reg = '1') THEN
			state <= RUN;
		ELSIF (state = RUN AND val = '0') THEN
			state <= FIN;
		ELSIF (state = FIN AND rising_edge(clk)) THEN
			state <= REST;
		END IF;
	END PROCESS;

	regs : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (state = RUN) THEN
				R(0) <= R(24) XOR R(30) XOR data(7);
				R(1) <= R(24) XOR R(25) XOR R(30) XOR R(31) XOR data(6);
				R(2) <= R(24) XOR R(25) XOR R(26) XOR R(30) XOR R(31) XOR data(5);
				R(3) <= R(25) XOR R(26) XOR R(27) XOR R(31) XOR data(4);
				R(4) <= R(24) XOR R(26) XOR R(27) XOR R(28) XOR R(30) XOR data(3);
				R(5) <= R(24) XOR R(25) XOR R(27) XOR R(28) XOR R(29) XOR R(30) XOR R(31) XOR data(2);
				R(6) <= R(25) XOR R(26) XOR R(28) XOR R(29) XOR R(30) XOR R(31) XOR data(1);
				R(7) <= R(24) XOR R(26) XOR R(27) XOR R(29) XOR R(31) XOR data(0);
				R(8) <= R(0) XOR R(24) XOR R(25) XOR R(27) XOR R(28);
				R(9) <= R(1) XOR R(25) XOR R(26) XOR R(28) XOR R(29);
				R(10) <= R(2) XOR R(24) XOR R(26) XOR R(27) XOR R(29);
				R(11) <= R(3) XOR R(24) XOR R(25) XOR R(27) XOR R(28);
				R(12) <= R(4) XOR R(24) XOR R(25) XOR R(26) XOR R(28) XOR R(29) XOR R(30);
				R(13) <= R(5) XOR R(25) XOR R(26) XOR R(27) XOR R(29) XOR R(30) XOR R(31);
				R(14) <= R(6) XOR R(26) XOR R(27) XOR R(28) XOR R(30) XOR R(31);
				R(15) <= R(7) XOR R(27) XOR R(28) XOR R(29) XOR R(31);
				R(16) <= R(8) XOR R(24) XOR R(28) XOR R(29);
				R(17) <= R(9) XOR R(25) XOR R(29) XOR R(30);
				R(18) <= R(10) XOR R(26) XOR R(30) XOR R(31);
				R(19) <= R(11) XOR R(27) XOR R(31);
				R(20) <= R(12) XOR R(28);
				R(21) <= R(13) XOR R(29);
				R(22) <= R(14) XOR R(24);
				R(23) <= R(15) XOR R(24) XOR R(25) XOR R(30);
				R(24) <= R(16) XOR R(25) XOR R(26) XOR R(31);
				R(25) <= R(17) XOR R(26) XOR R(27);
				R(26) <= R(18) XOR R(24) XOR R(27) XOR R(28) XOR R(30);
				R(27) <= R(19) XOR R(25) XOR R(28) XOR R(29) XOR R(31);
				R(28) <= R(20) XOR R(26) XOR R(29) XOR R(30);
				R(29) <= R(21) XOR R(27) XOR R(30) XOR R(31);
				R(30) <= R(22) XOR R(28) XOR R(31);
				R(31) <= R(23) XOR R(29);
			ELSIF (state = FIN) THEN
				IF (R = x"FFFFFFFF") THEN
					out_err <= '0';
				ELSE
					out_err <= '1';
				END IF;

				R <= x"00000000";
				out_val <= '1';
			ELSIF (reset = '1') THEN
				R <= x"00000000";
			ELSE
				out_val <= '0';
				out_err <= '0';
			END IF;
		END IF;
	END PROCESS;

	counter : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF val = '0' THEN
				count <= 0;
			ELSIF val = '1' and count < 5 THEN
				count <= count + 1;
			ELSIF reset = '1' THEN
				count <= 0;
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;