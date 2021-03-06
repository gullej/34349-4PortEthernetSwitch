LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY crc_tb IS
END ENTITY;

ARCHITECTURE crc_tb_arc OF crc_tb IS

	COMPONENT crc_parallel IS
		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			val : IN STD_LOGIC;
			data_in : IN STD_LOGIC_VECTOR(0 TO 7);
			out_val : OUT STD_LOGIC;
			fcs_error : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL clk : STD_LOGIC;
	SIGNAL reset_P, val_P, out_val_P, data_out_P : STD_LOGIC;
	SIGNAL data_in_P : STD_LOGIC_VECTOR(0 TO 7);
	SIGNAL COUNTER : INTEGER RANGE 0 TO 512 := 0;
	SIGNAL sent_data : STD_LOGIC_VECTOR(0 TO 511) := x"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
BEGIN
	stimulus : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 3 ns;
		clk <= '1';
		WAIT FOR 3 ns;
	END PROCESS;

	DUT : crc_parallel PORT MAP(clk, reset_P, val_P, data_in_P, out_val_P, data_out_P);

	feeder_parallel : PROCESS(clk)
	BEGIN
		IF (RISING_EDGE(clk)) THEN
			IF (COUNTER /= 512) THEN
				data_in_P <= sent_data(COUNTER TO COUNTER + 7);
				COUNTER <= COUNTER + 8;
				val_P <= '1';
			else
				data_in_P <= "XXXXXXXX";
				val_P <= '0';
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;