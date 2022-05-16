LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY mac_learning IS
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		mac_dst_1 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		mac_src_1 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		port_in_1 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_in_1 : IN STD_LOGIC;
		mac_dst_2 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		mac_src_2 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		port_in_2 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_in_2 : IN STD_LOGIC;
		mac_dst_3 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		mac_src_3 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		port_in_3 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_in_3 : IN STD_LOGIC;
		mac_dst_4 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		mac_src_4 : IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		port_in_4 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_in_4 : IN STD_LOGIC;
		dest_out_1 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_out_1 : OUT STD_LOGIC;
		dest_out_2 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_out_2 : OUT STD_LOGIC;
		dest_out_3 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_out_3 : OUT STD_LOGIC;
		dest_out_4 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		read_out_4 : OUT STD_LOGIC
	);
END mac_learning;

ARCHITECTURE mac_learning_arc OF mac_learning IS

	TYPE State_type IS (waiting, reading, writing, hashing, sending, wait1);
	SIGNAL state : State_Type;
	SIGNAL Data : STD_LOGIC_VECTOR (51 DOWNTO 0);
	SIGNAL write_add : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL read_add : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL write_en : STD_LOGIC;
	SIGNAL read_en : STD_LOGIC;
	SIGNAL data_ram : STD_LOGIC_VECTOR (51 DOWNTO 0);
	SIGNAL R : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL D : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL R2 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL D2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL count : INTEGER RANGE 0 TO 100;

	SIGNAL mac_dst : STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL mac_src : STD_LOGIC_VECTOR (47 DOWNTO 0);
	SIGNAL port_in : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL read_in : STD_LOGIC;
	SIGNAL dest_out : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL read_out : STD_LOGIC;

	TYPE states IS (search_input1, serve_input1, output_1, search_input2, serve_input2, output_2, search_input3, serve_input3, output_3, search_input4, serve_input4, output_4);
	SIGNAL RRstate : states;
	COMPONENT mac_memory
		PORT (
			clock : IN STD_LOGIC;
			data_in : IN STD_LOGIC_VECTOR (51 DOWNTO 0);
			write_address : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
			read_address : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
			we : IN STD_LOGIC;
			re : IN STD_LOGIC;
			data_out : OUT STD_LOGIC_VECTOR (51 DOWNTO 0)
		);
	END COMPONENT;

BEGIN

	mac_dst <= mac_dst_1 WHEN (RRstate = serve_input1) ELSE
		mac_dst_2 WHEN (RRstate = serve_input2) ELSE
		mac_dst_3 WHEN (RRstate = serve_input3) ELSE
		mac_dst_4 WHEN (RRstate = serve_input4) ELSE
		(OTHERS => '0');

	mac_src <= mac_src_1 WHEN (RRstate = serve_input1) ELSE
		mac_src_2 WHEN (RRstate = serve_input2) ELSE
		mac_src_3 WHEN (RRstate = serve_input3) ELSE
		mac_src_4 WHEN (RRstate = serve_input4) ELSE
		(OTHERS => '0');

	port_in <= port_in_1 WHEN (RRstate = serve_input1) ELSE
		port_in_2 WHEN (RRstate = serve_input2) ELSE
		port_in_3 WHEN (RRstate = serve_input3) ELSE
		port_in_4 WHEN (RRstate = serve_input4) ELSE
		(OTHERS => '0');

	read_in <= read_in_1 WHEN (RRstate = serve_input1) ELSE
		read_in_2 WHEN (RRstate = serve_input2) ELSE
		read_in_3 WHEN (RRstate = serve_input3) ELSE
		read_in_4 WHEN (RRstate = serve_input4) ELSE
		'0';

	dest_out_1 <= dest_out WHEN (RRstate = output_1) ELSE 		(OTHERS => '0');
	dest_out_2 <= dest_out WHEN (RRstate = output_2) ELSE		(OTHERS => '0');
	dest_out_3 <= dest_out WHEN (RRstate = output_3) ELSE		(OTHERS => '0');
	dest_out_4 <= dest_out WHEN (RRstate = output_4) ELSE		(OTHERS => '0');
	read_out_1 <= read_out WHEN (RRstate = output_1) ELSE		'0';
	read_out_2 <= read_out WHEN (RRstate = output_2) ELSE		'0';
	read_out_3 <= read_out WHEN (RRstate = output_3) ELSE		'0';
	read_out_4 <= read_out WHEN (RRstate = output_4) ELSE		'0';

	mac_mem : mac_memory
	PORT MAP
	(
		clock => clock,
		data_in => data,
		write_address => write_add,
		read_address => read_add,
		we => write_en,
		re => read_en,
		data_out => data_ram
	);

	PROCESS (clock, reset)
	BEGIN
		IF reset = '1' THEN
			state <= waiting;

		ELSIF (clock'EVENT AND clock = '1') THEN
			CASE state IS
				WHEN waiting =>

					IF (read_in = '1') THEN
						state <= hashing;
						count <= 0;
					ELSE
						state <= waiting;
					END IF;
				WHEN hashing =>
					count <= count + 1;
					IF (count = 5) THEN
						state <= writing;
					ELSE
						state <= hashing;
					END IF;
				WHEN writing =>
					state <= reading;
				WHEN reading =>
					state <= wait1;
				WHEN wait1 =>
					state <= sending;
				WHEN sending =>
					state <= waiting;
			END CASE;
		END IF;
	END PROCESS;

	PROCESS (clock)
	BEGIN
		IF (rising_edge(clock)) THEN
			IF state = waiting THEN
				dest_out <= "0000";
				read_out <= '0';
				R <= (OTHERS => '0');
				D <= (OTHERS => '0');
				R2 <= (OTHERS => '0');
				D2 <= (OTHERS => '0');
				write_en <= '0';
				write_add <= (OTHERS => '0');
				read_en <= '0';
				read_add <= (OTHERS => '0');
				Data <= (OTHERS => '0');

			ELSIF state = hashing THEN

				-- FOR k IN 0 TO 7 LOOP
				-- 	D(k) <= mac_src(k + count * 8);
				-- 	D2(k) <= mac_dst(k + count * 8);
				-- END LOOP;
				D <= mac_src(count * 8 + 7 DOWNTO count * 8);
				D2 <= mac_dst(count * 8 + 7 DOWNTO count * 8);
				R(0) <= R(5) XOR R(6) XOR R(9) XOR R(10) XOR R(11) XOR R(12) XOR D(7);
				R(1) <= R(6) XOR R(7) XOR R(10) XOR R(11) XOR R(12) XOR D(6);
				R(2) <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR D(5);
				R(3) <= R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR D(4);
				R(4) <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR D(3);
				R(5) <= R(5) XOR R(7) XOR R(8) XOR R(10) XOR R(11) XOR R(12) XOR D(2);
				R(6) <= R(5) XOR R(8) XOR R(10) XOR D(1);
				R(7) <= R(5) XOR R(10) XOR R(12) XOR D(0);
				R(8) <= R(0) XOR R(6) XOR R(11);
				R(9) <= R(1) XOR R(7) XOR R(12);
				R(10) <= R(2) XOR R(5) XOR R(6) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);
				R(11) <= R(3) XOR R(5) XOR R(7);
				R(12) <= R(4) XOR R(5) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);

				R2(0) <= R2(5) XOR R2(6) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(7);
				R2(1) <= R2(6) XOR R2(7) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(6);
				R2(2) <= R2(5) XOR R2(6) XOR R2(7) XOR R2(8) XOR R2(9) XOR R2(10) XOR D2(5);
				R2(3) <= R2(6) XOR R2(7) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR D2(4);
				R2(4) <= R2(5) XOR R2(6) XOR R2(7) XOR R2(8) XOR D2(3);
				R2(5) <= R2(5) XOR R2(7) XOR R2(8) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(2);
				R2(6) <= R2(5) XOR R2(8) XOR R2(10) XOR D2(1);
				R2(7) <= R2(5) XOR R2(10) XOR R2(12) XOR D2(0);
				R2(8) <= R2(0) XOR R2(6) XOR R2(11);
				R2(9) <= R2(1) XOR R2(7) XOR R2(12);
				R2(10) <= R2(2) XOR R2(5) XOR R2(6) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12);
				R2(11) <= R2(3) XOR R2(5) XOR R2(7);
				R2(12) <= R2(4) XOR R2(5) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12);
			ELSIF state = writing THEN
				data <= mac_src & port_in;
				write_en <= '1';
				write_add <= R;

			ELSIF state = reading THEN
				write_en <= '0';
				read_en <= '1';
				read_add <= R2;

			ELSIF state = sending THEN
				--logic for sending data. broadcast if only zero. 
				--Compare the mac address in data with dst_address if it is the same use the port in data for port out 
				--otherwise broadcast
				read_en <= '0';
				read_out <= '1';
				IF (data_ram = x"00") THEN
					dest_out <= "1111";
				ELSE
					IF (data_ram(51 DOWNTO 4) = mac_dst(47 DOWNTO 0)) THEN
						dest_out <= data_ram(3 DOWNTO 0);
					ELSE
						dest_out <= "1111";
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	-- PROCESS (state, count, mac_src, mac_dst, R, R2, D, D2)
	-- BEGIN
	-- 	CASE state IS
	-- 		WHEN waiting =>
	-- 			dest_out <= "0000";
	-- 			read_out <= '0';
	-- 			R <= (OTHERS => '0');
	-- 			D <= (OTHERS => '0');
	-- 			R2 <= (OTHERS => '0');
	-- 			D2 <= (OTHERS => '0');
	-- 			write_en <= '0';
	-- 			write_add <= (OTHERS => '0');
	-- 			read_en <= '0';
	-- 			read_add <= (OTHERS => '0');
	-- 			Data <= (OTHERS => '0');

	-- 		WHEN hashing =>

	-- 			-- FOR k IN 0 TO 7 LOOP
	-- 			-- 	D(k) <= mac_src(k + count * 8);
	-- 			-- 	D2(k) <= mac_dst(k + count * 8);
	-- 			-- END LOOP;
	-- 			D <= mac_src(count *8+7 downto count *8);
	-- 			D2 <= mac_dst(count *8+7 downto count *8);
	-- 			R(0) <= R(5) XOR R(6) XOR R(9) XOR R(10) XOR R(11) XOR R(12) XOR D(7);
	-- 			R(1) <= R(6) XOR R(7) XOR R(10) XOR R(11) XOR R(12) XOR D(6);
	-- 			R(2) <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR D(5);
	-- 			R(3) <= R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR D(4);
	-- 			R(4) <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR D(3);
	-- 			R(5) <= R(5) XOR R(7) XOR R(8) XOR R(10) XOR R(11) XOR R(12) XOR D(2);
	-- 			R(6) <= R(5) XOR R(8) XOR R(10) XOR D(1);
	-- 			R(7) <= R(5) XOR R(10) XOR R(12) XOR D(0);
	-- 			R(8) <= R(0) XOR R(6) XOR R(11);
	-- 			R(9) <= R(1) XOR R(7) XOR R(12);
	-- 			R(10) <= R(2) XOR R(5) XOR R(6) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);
	-- 			R(11) <= R(3) XOR R(5) XOR R(7);
	-- 			R(12) <= R(4) XOR R(5) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);

	-- 			R2(0) <= R2(5) XOR R2(6) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(7);
	-- 			R2(1) <= R2(6) XOR R2(7) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(6);
	-- 			R2(2) <= R2(5) XOR R2(6) XOR R2(7) XOR R2(8) XOR R2(9) XOR R2(10) XOR D2(5);
	-- 			R2(3) <= R2(6) XOR R2(7) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR D2(4);
	-- 			R2(4) <= R2(5) XOR R2(6) XOR R2(7) XOR R2(8) XOR D2(3);
	-- 			R2(5) <= R2(5) XOR R2(7) XOR R2(8) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(2);
	-- 			R2(6) <= R2(5) XOR R2(8) XOR R2(10) XOR D2(1);
	-- 			R2(7) <= R2(5) XOR R2(10) XOR R2(12) XOR D2(0);
	-- 			R2(8) <= R2(0) XOR R2(6) XOR R2(11);
	-- 			R2(9) <= R2(1) XOR R2(7) XOR R2(12);
	-- 			R2(10) <= R2(2) XOR R2(5) XOR R2(6) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12);
	-- 			R2(11) <= R2(3) XOR R2(5) XOR R2(7);
	-- 			R2(12) <= R2(4) XOR R2(5) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12);
	-- 		WHEN writing =>
	-- 			data <= mac_src & port_in;
	-- 			write_en <= '1';
	-- 			write_add <= R;

	-- 		WHEN reading =>
	-- 			write_en <= '0';
	-- 			read_en <= '1';
	-- 			read_add <= R2;

	-- 		WHEN sending =>
	-- 			--logic for sending data. broadcast if only zero. 
	-- 			--Compare the mac address in data with dst_address if it is the same use the port in data for port out 
	-- 			--otherwise broadcast
	-- 			read_en <= '0';
	-- 			read_out <= '1';
	-- 			IF (data_ram = x"00") THEN
	-- 				dest_out <= "1111";
	-- 			ELSE
	-- 				IF (data_ram(51 DOWNTO 4) = mac_dst(47 DOWNTO 0)) THEN
	-- 					dest_out <= data_ram(3 DOWNTO 0);
	-- 				ELSE
	-- 					dest_out <= "1111";
	-- 				END IF;
	-- 			END IF;
	-- 	END CASE;
	-- END PROCESS;

	RR : PROCESS (clock)
	BEGIN
		IF (rising_edge(clock)) THEN
			IF (RRstate = search_input1) THEN
				IF (read_in_1 = '1') THEN
					RRstate <= serve_input1;
				ELSE
					RRstate <= search_input2;
				END IF;
			ELSIF (RRstate = serve_input1) THEN
				IF (state = sending) THEN
					RRstate <= output_1;
				END IF;
			ELSIF (RRstate = output_1) THEN
				RRstate <= search_input2;
			ELSIF (RRstate = search_input2) THEN
				IF (read_in_2 = '1') THEN
					RRstate <= serve_input2;
				ELSE
					RRstate <= search_input3;
				END IF;
			ELSIF (RRstate = serve_input2) THEN
				IF (state = sending) THEN
					RRstate <= output_2;
				END IF;
			ELSIF (RRstate = output_2) THEN
				RRstate <= search_input3;
			ELSIF (RRstate = search_input3) THEN
				IF (read_in_3 = '1') THEN
					RRstate <= serve_input3;
				ELSE
					RRstate <= search_input4;
				END IF;
			ELSIF (RRstate = serve_input3) THEN
				IF (state = sending) THEN
					RRstate <= output_3;
				END IF;
			ELSIF (RRstate = output_3) THEN
				RRstate <= search_input4;
			ELSIF (RRstate = search_input4) THEN
				IF (read_in_4 = '1') THEN
					RRstate <= serve_input4;
				ELSE
					RRstate <= search_input1;
				END IF;
			ELSIF (RRstate = serve_input4) THEN
				IF (state = sending) THEN
					RRstate <= output_4;
				END IF;
			ELSIF (RRstate = output_4) THEN
				RRstate <= search_input1;
			END IF;
		END IF;
	END PROCESS;

END mac_learning_arc;