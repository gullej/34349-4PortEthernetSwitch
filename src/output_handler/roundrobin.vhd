LIBRARY ieee;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY roundrobin IS
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
END roundrobin;

ARCHITECTURE roundrobin_arc OF roundrobin IS

	TYPE states IS (search_buff1, serve_buff1, wait_buff1, search_buff2, serve_buff2, wait_buff2, search_buff3, serve_buff3, wait_buff3);
	SIGNAL RRstate : states;

	COMPONENT buffer32k IS
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
			usedw : OUT STD_LOGIC_VECTOR (14 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL emp1, emp2, emp3 : STD_LOGIC;
	SIGNAL buf1, buf2, buf3 : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL req1, req2, req3 : STD_LOGIC;
	SIGNAL count : INTEGER RANGE 0 TO 9;
	SIGNAL clear : STD_LOGIC;

BEGIN

	buffer1 : buffer32k PORT MAP(clk, dat1, req1, clear, val1, OPEN, emp1, OPEN, buf1, OPEN);

	buffer2 : buffer32k PORT MAP(clk, dat2, req2, clear, val2, OPEN, emp2, OPEN, buf2, OPEN);

	buffer3 : buffer32k PORT MAP(clk, dat3, req3, clear, val3, OPEN, emp3, OPEN, buf3, OPEN);

	dato <= buf1(7 DOWNTO 0) WHEN (RRstate = serve_buff1) ELSE
		buf2(7 DOWNTO 0) WHEN (RRstate = serve_buff2) ELSE
		buf3(7 DOWNTO 0) WHEN (RRstate = serve_buff3) ELSE
		(OTHERS => '0');

	valo <= '1' WHEN (RRstate = serve_buff1) OR (RRstate = serve_buff2) OR (RRstate = serve_buff3) ELSE
		'0';

	RR_stateMachine : PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (RRstate = search_buff1) THEN
				req1 <= '0';
				req2 <= '0';
				req3 <= '0';
				IF (emp1 = '1') THEN
					RRstate <= search_buff2;
				ELSE
					RRstate <= serve_buff1;
				END IF;
			ELSIF (RRstate = serve_buff1) THEN
				req1 <= '1';
				IF (buf1(8) = '1' OR emp1 = '1') THEN
					RRstate <= wait_buff1;
					count <= 0;
				END IF;
			ELSIF (RRstate = wait_buff1) THEN
				IF (count = 9) THEN
					RRstate <= search_buff2;
				ELSE
					count <= count + 1;
				END IF;
			ELSIF (RRstate = search_buff2) THEN
				req1 <= '0';
				req2 <= '0';
				req3 <= '0';
				IF (emp2 = '1') THEN
					RRstate <= search_buff3;
				ELSE
					RRstate <= serve_buff2;
				END IF;
			ELSIF (RRstate = serve_buff2) THEN
				req2 <= '1';
				IF (buf2(8) = '1' OR emp2 = '1') THEN
					RRstate <= wait_buff2;
					count <= 0;
				END IF;
			ELSIF (RRstate = wait_buff2) THEN
				IF (count = 9) THEN
					RRstate <= search_buff3;
				ELSE
					count <= count + 1;
				END IF;
			ELSIF (RRstate = search_buff3) THEN
				req1 <= '0';
				req2 <= '0';
				req3 <= '0';
				IF (emp3 = '1') THEN
					RRstate <= search_buff1;
				ELSE
					RRstate <= serve_buff3;
				END IF;
			ELSIF (RRstate = serve_buff3) THEN
				req3 <= '1';
				IF (buf3(8) = '1' OR emp3 = '1') THEN
					RRstate <= wait_buff3;
					count <= 0;
				END IF;
			ELSIF (RRstate = wait_buff3) THEN
				IF (count = 9) THEN
					RRstate <= search_buff1;
				ELSE
					count <= count + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

END roundrobin_arc;