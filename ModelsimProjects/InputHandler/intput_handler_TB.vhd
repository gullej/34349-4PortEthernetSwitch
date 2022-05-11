LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY input_tb IS
END ENTITY;

ARCHITECTURE input_arc OF input_tb IS

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
			dato4 : OUT STD_LOGIC_VECTOR(0 TO 7);
			macr : OUT STD_LOGIC;
			src_addr : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
			dst_addr : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
			poro : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			dest : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			macv : IN STD_LOGIC
		);
	END COMPONENT;

	COMPONENT mac_learning IS
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
	END COMPONENT;

	SIGNAL clk, reset_TB : STD_LOGIC;
	SIGNAL src_addr_TB_1, dst_addr_TB_1 : STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL src_addr_TB_2, dst_addr_TB_2 : STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL src_addr_TB_3, dst_addr_TB_3 : STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL src_addr_TB_4, dst_addr_TB_4 : STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL val_TB_1, out_val1_TB_1, out_val2_TB_1, out_val3_TB_1, out_val4_TB_1, macr_TB_1, macv_TB_1 : STD_LOGIC;
	SIGNAL val_TB_2, out_val1_TB_2, out_val2_TB_2, out_val3_TB_2, out_val4_TB_2, macr_TB_2, macv_TB_2 : STD_LOGIC;
	SIGNAL val_TB_3, out_val1_TB_3, out_val2_TB_3, out_val3_TB_3, out_val4_TB_3, macr_TB_3, macv_TB_3 : STD_LOGIC;
	SIGNAL val_TB_4, out_val1_TB_4, out_val2_TB_4, out_val3_TB_4, out_val4_TB_4, macr_TB_4, macv_TB_4 : STD_LOGIC;
	SIGNAL data_in_TB_1, out_dat1_TB_1, out_dat2_TB_1, out_dat3_TB_1, out_dat4_TB_1 : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL data_in_TB_2, out_dat1_TB_2, out_dat2_TB_2, out_dat3_TB_2, out_dat4_TB_2 : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL data_in_TB_3, out_dat1_TB_3, out_dat2_TB_3, out_dat3_TB_3, out_dat4_TB_3 : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL data_in_TB_4, out_dat1_TB_4, out_dat2_TB_4, out_dat3_TB_4, out_dat4_TB_4 : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL port_TB_1, dest_TB_1, desto_TB_1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL port_TB_2, dest_TB_2, desto_TB_2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL port_TB_3, dest_TB_3, desto_TB_3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL port_TB_4, dest_TB_4, desto_TB_4 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL COUNTER : INTEGER RANGE 0 TO 2048 := 0;
	SIGNAL sent_data : STD_LOGIC_VECTOR(0 TO 511) := x"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
	SIGNAL sent_data2 : STD_LOGIC_VECTOR(0 TO 511) := x"7BEA800010A400123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";

BEGIN
	stimulus : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 3 ns;
		clk <= '1';
		WAIT FOR 3 ns;
	END PROCESS;

	DUT1 : input_handler PORT MAP(clk, reset_TB, val_TB_1, data_in_TB_1, port_TB_1, out_val1_TB_1, out_dat1_TB_1, out_val2_TB_1, out_dat2_TB_1, out_val3_TB_1, out_dat3_TB_1, out_val4_TB_1, out_dat4_TB_1, macr_TB_1, src_addr_TB_1, dst_addr_TB_1, dest_TB_1, desto_TB_1, macv_TB_1);
	DUT2 : input_handler PORT MAP(clk, reset_TB, val_TB_2, data_in_TB_2, port_TB_2, out_val1_TB_2, out_dat1_TB_2, out_val2_TB_2, out_dat2_TB_2, out_val3_TB_2, out_dat3_TB_2, out_val4_TB_2, out_dat4_TB_2, macr_TB_2, src_addr_TB_2, dst_addr_TB_2, dest_TB_2, desto_TB_2, macv_TB_2);
	DUT3 : input_handler PORT MAP(clk, reset_TB, val_TB_3, data_in_TB_3, port_TB_3, out_val1_TB_3, out_dat1_TB_3, out_val2_TB_3, out_dat2_TB_3, out_val3_TB_3, out_dat3_TB_3, out_val4_TB_3, out_dat4_TB_3, macr_TB_3, src_addr_TB_3, dst_addr_TB_3, dest_TB_3, desto_TB_3, macv_TB_3);
	DUT4 : input_handler PORT MAP(clk, reset_TB, val_TB_4, data_in_TB_4, port_TB_4, out_val1_TB_4, out_dat1_TB_4, out_val2_TB_4, out_dat2_TB_4, out_val3_TB_4, out_dat3_TB_4, out_val4_TB_4, out_dat4_TB_4, macr_TB_4, src_addr_TB_4, dst_addr_TB_4, dest_TB_4, desto_TB_4, macv_TB_4);

	MAC : mac_learning PORT MAP(
		clk, reset_TB,
		dst_addr_TB_1,
		src_addr_TB_1,
		port_TB_1,
		macr_TB_1,
		dst_addr_TB_2,
		src_addr_TB_2,
		port_TB_2,
		macr_TB_2,
		dst_addr_TB_3,
		src_addr_TB_3,
		port_TB_3,
		macr_TB_3,
		dst_addr_TB_4,
		src_addr_TB_4,
		port_TB_4,
		macr_TB_4,
		desto_TB_1,
		macv_TB_1,
		desto_TB_2,
		macv_TB_2,
		desto_TB_3,
		macv_TB_3,
		desto_TB_4,
		macv_TB_4
	);

	port_TB_1 <= "1000";
	port_TB_2 <= "0100";
	port_TB_3 <= "0010";
	port_TB_4 <= "0001";

	feeder_TBarallel : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (COUNTER < 512) THEN
				data_in_TB_1 <= sent_data(COUNTER TO COUNTER + 7);
				COUNTER <= COUNTER + 8;
				val_TB_1 <= '1';
			ELSIF (COUNTER < 624) THEN
				data_in_TB_1 <= "XXXXXXXX";
				COUNTER <= COUNTER + 8;
				val_TB_1 <= '0';
			ELSIF (COUNTER < 1136) THEN
				data_in_TB_1 <= sent_data(COUNTER - 624 TO COUNTER - 624 + 7);
				COUNTER <= COUNTER + 8;
				val_TB_1 <= '1';
			ELSE
				data_in_TB_1 <= "XXXXXXXX";
				val_TB_1 <= '0';
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;