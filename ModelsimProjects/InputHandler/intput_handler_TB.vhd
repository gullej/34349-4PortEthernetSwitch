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
PORT
   (
    clock: 		IN   std_logic;
    reset: 		IN   std_logic;
    mac_dst:  		IN   std_logic_vector (47 DOWNTO 0);
    mac_src:  		IN   std_logic_vector (47 DOWNTO 0);
    port_in:          	IN   std_logic_vector (3 DOWNTO 0);
    read_in:		IN   std_logic;
    port_out:     	OUT  std_logic_vector (3 DOWNTO 0);
    read_out:		OUT  std_logic
   );
END COMPONENT;

	SIGNAL clk : STD_LOGIC;
	SIGNAL src_addr_TB, dst_addr_TB : STD_LOGIC_VECTOR(47 DOWNTO 0);
	SIGNAL reset_TB, val_TB, out_val1_TB, out_val2_TB, out_val3_TB, out_val4_TB, macr_TB, macv_TB : STD_LOGIC;
	SIGNAL data_in_TB, out_dat1_TB, out_dat2_TB, out_dat3_TB, out_dat4_TB : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL port_TB, poro_TB, dest_TB : STD_LOGIC_VECTOR(3 downto 0);
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

	DUT : input_handler PORT MAP(clk, reset_TB, val_TB, data_in_TB, port_TB, out_val1_TB, out_dat1_TB, out_val2_TB, out_dat2_TB, out_val3_TB, out_dat3_TB, out_val4_TB, out_dat4_TB, macr_TB, src_addr_TB, dst_addr_TB, poro_TB, dest_TB, macv_TB);
	MAC : mac_learning PORT MAP(clk, reset_TB, dst_addr_TB, src_addr_TB, poro_TB, macr_TB, dest_TB, macv_TB);

	port_TB <= "1000";

	feeder_TBarallel : PROCESS (clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (COUNTER < 512) THEN
				data_in_TB <= sent_data(COUNTER TO COUNTER + 7);
				COUNTER <= COUNTER + 8;
				val_TB <= '1';
			ELSIF (COUNTER < 624) THEN
				data_in_TB <= "XXXXXXXX";
				COUNTER <= COUNTER + 8;
				val_TB <= '0';
			ELSIF (COUNTER < 1136) THEN
				data_in_TB <= sent_data(COUNTER-624 TO COUNTER-624 + 7);
				COUNTER <= COUNTER + 8;
				val_TB <= '1';
			ELSE
				data_in_TB <= "XXXXXXXX";
				val_TB <= '0';
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;