LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY crc_parallel IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		sof : IN STD_LOGIC;
		eof : IN STD_LOGIC;
		data_in : IN STD_LOGIC_VECTOR(0 TO 7);
		out_val : OUT STD_LOGIC;
		fcs_error : OUT STD_LOGIC
	);
END crc_parallel;

ARCHITECTURE crc_parallel_arc OF crc_parallel IS

	SIGNAL R : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	TYPE state_type IS (REST, RUN, FCS, FIN);
	SIGNAL state : state_type := REST;
	SIGNAL data : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL sof_reg, eof_reg : STD_LOGIC;
	SIGNAL count : INTEGER RANGE 0 TO 4 := 0;
BEGIN

	feeder : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			sof_reg <= sof;
			eof_reg <= eof;

			IF (count < 3 OR eof = '1' OR sof = '1') THEN
				data <= NOT data_in;
			ELSE
				data <= data_in;
			END IF;
		END IF;
	END PROCESS;

	state_machine : PROCESS (state, count, eof_reg, sof_reg, reset, clk)
	BEGIN
		IF (reset = '1') THEN
			state <= REST;
		ELSIF (sof_reg = '1') THEN
			state <= RUN;
		ELSIF (eof_reg = '1') THEN
			state <= FCS;
		ELSIF (state = FCS AND count = 4) THEN
			state <= FIN;
		ELSIF (state = FIN AND rising_edge(clk)) THEN
			state <= REST;
		END IF;
	END PROCESS;

	regs : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (state = RUN OR STATE = FCS) THEN
				R(0)  <= R(5) XOR R(6) XOR R(9) XOR R(10) XOR R(11) XOR R(12) XOR D(7);
				R(1)  <= R(6) XOR R(7) XOR R(10) XOR R(11) XOR R(12) XOR D(6);
				R(2)  <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR D(5);
				R(3)  <= R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR D(4);
				R(4)  <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR D(3);
				R(5)  <= R(5) XOR R(7) XOR R(8) XOR R(10) XOR R(11) XOR R(12) XOR D(2);
				R(6)  <= R(5) XOR R(8) XOR R(10) XOR D(1);
				R(7)  <= R(5) XOR R(10) XOR R(12) XOR D(0);
				R(8)  <= R(0) XOR R(6) XOR R(11);
				R(9)  <= R(1) XOR R(7) XOR R(12);
				R(10) <= R(2) XOR R(5) XOR R(6) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);
				R(11) <= R(3) XOR R(5) XOR R(7);
				R(12) <= R(4) XOR R(5) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);
			ELSIF (state = FIN) THEN
				IF (R = x"00000000") THEN
					fcs_error <= '0';
				ELSE
					fcs_error <= '1';
				END IF;
				out_val <= '1';
			ELSIF (reset = '1') THEN
				R <= x"00000000";
			ELSE
				out_val <= '0';
				fcs_error <= '0';
			END IF;
		END IF;
	END PROCESS;

	counter : PROCESS (clk, sof, eof)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF sof = '1' OR eof = '1' THEN
				count <= 0;
			ELSIF count < 4 THEN
				count <= count + 1;
			ELSIF reset = '1' THEN
				count <= 0;
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;
