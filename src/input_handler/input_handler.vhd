LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY input_handler IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		val : IN STD_LOGIC;
		dat : IN STD_LOGIC_VECTOR(0 TO 7);
		valo1 : OUT STD_LOGIC;
		dato1 : OUT STD_LOGIC_VECTOR(0 TO 7);
		valo2 : OUT STD_LOGIC;
		dato2 : OUT STD_LOGIC_VECTOR(0 TO 7);
		valo3 : OUT STD_LOGIC;
		dato3 : OUT STD_LOGIC_VECTOR(0 TO 7)
	);
END input_handler;

ARCHITECTURE input_handler_arc OF input_handler IS

	COMPONENT crc_parallel IS
		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			val : IN STD_LOGIC;
			dat : IN STD_LOGIC_VECTOR(0 TO 7);
			out_val : OUT STD_LOGIC;
			out_err : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT buffer2K IS
		PORT (
			clock : IN STD_LOGIC;
			data : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			rdreq : IN STD_LOGIC;
			sclr : IN STD_LOGIC;
			wrreq : IN STD_LOGIC;
			almost_full : OUT STD_LOGIC;
			empty : OUT STD_LOGIC;
			full : OUT STD_LOGIC;
			q : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			usedw : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL out_val, out_err, valr, req, fin, macr, macv : STD_LOGIC;
	SIGNAL dst_addr, src_addr : STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL datr : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dest : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL dato, datb : STD_LOGIC_VECTOR(8 DOWNTO 0);
	TYPE state_type IS (REST, DST, SRC, CHK, MAC, PUSH);
	SIGNAL state : state_type := REST;
	SIGNAL count : INTEGER RANGE 0 TO 10;

BEGIN

	CRC : crc_parallel PORT MAP(clk, reset, val, dat, out_val, out_err);
	BUF : buffer2k PORT MAP(clk, datb, req, reset, valr, OPEN, OPEN, OPEN, dato, OPEN);

	valo1 <= dest(0);
	valo2 <= dest(1);
	valo3 <= dest(2);

	dato1 <=  dato(7 downto 0) WHEN dest(0) = '1';
	dato2 <=  dato(7 downto 0) WHEN dest(1) = '1';
	dato3 <=  dato(7 downto 0) WHEN dest(2) = '1';

	datr <= dat WHEN (rising_edge(clk));
	datb <= fin & datr;
	valr <= val WHEN (rising_edge(clk));

	dst_addr(47 DOWNTO 40) <= datr WHEN (state = DST AND count = 0);
	dst_addr(39 DOWNTO 32) <= datr WHEN (state = DST AND count = 1);
	dst_addr(31 DOWNTO 24) <= datr WHEN (state = DST AND count = 2);
	dst_addr(23 DOWNTO 16) <= datr WHEN (state = DST AND count = 3);
	dst_addr(15 DOWNTO 8) <= datr WHEN (state = DST AND count = 4);
	dst_addr(7 DOWNTO 0) <= datr WHEN (state = DST AND count = 5);

	src_addr(47 DOWNTO 40) <= datr WHEN (state = SRC AND count = 0);
	src_addr(39 DOWNTO 32) <= datr WHEN (state = SRC AND count = 1);
	src_addr(31 DOWNTO 24) <= datr WHEN (state = SRC AND count = 2);
	src_addr(23 DOWNTO 16) <= datr WHEN (state = SRC AND count = 3);
	src_addr(15 DOWNTO 8) <= datr WHEN (state = SRC AND count = 4);
	src_addr(7 DOWNTO 0) <= datr WHEN (state = SRC AND count = 5);

	fin <= '1' WHEN (val = '0' AND valr = '1') ELSE
		'0';

	STATE_MACHINE : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (state = REST) THEN
				IF (val = '1') THEN
					state <= DST;
				END IF;
			ELSIF (state = DST) THEN
				IF (COUNT = 5) THEN
					state <= SRC;
					count <= 0;
				ELSE
					count <= count + 1;
				END IF;
			ELSIF (state = SRC) THEN
				IF (COUNT = 5) THEN
					state <= CHK;
					count <= 0;
				ELSE
					count <= count + 1;
				END IF;
			ELSIF (state = CHK) THEN
				IF (out_val = '1') THEN
					IF (out_err = '1') THEN
						state <= REST;
						-- RESET SHIT
					ELSE
						state <= MAC;
						count <= 0;
					END IF;
				END IF;
			ELSIF (state = MAC) THEN
				macr <= '1';
				IF (macv = '1') THEN
					state <= PUSH;
				END IF;
			ELSIF (state = PUSH) THEN
				IF (dato(8) = '1') THEN
					state <= REST;
				END IF;
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;