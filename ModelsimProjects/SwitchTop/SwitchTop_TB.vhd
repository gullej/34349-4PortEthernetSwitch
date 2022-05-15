LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY SwitchTop_TB IS
END ENTITY;

ARCHITECTURE SwitchTop_TB_arc OF SwitchTop_TB IS

    COMPONENT switch_logic IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            vali : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            dati : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            valo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            dato : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk, reset_TB : STD_LOGIC;
    SIGNAL vali_TB, valo_TB : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL dati_TB, dato_TB : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL COUNTER : INTEGER RANGE 0 TO 8096 := 0;
    SIGNAL PACKET1 : STD_LOGIC_VECTOR(0 TO 511) := x"0010A47BEA80" & x"001234567890" & x"08004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011" & x"E6C53DB2";
    SIGNAL PACKET2 : STD_LOGIC_VECTOR(0 TO 511) := x"001234567890" & x"0010A47BEA80" & x"08004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011" & x"CC830786";
    SIGNAL PACKET3 : STD_LOGIC_VECTOR(0 TO 631) := x"1DBE83A37A3A" & x"001234567890" & x"08004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20" & x"B4B70FEE";
    SIGNAL PACKET4 : STD_LOGIC_VECTOR(0 TO 631) := x"FD69DF7FFA11" & x"001234567890" & x"08004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20" & x"0ADC8310";
      
BEGIN
    stimulus : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR 3 ns;
        clk <= '1';
        WAIT FOR 3 ns;
    END PROCESS;

    DUT : switch_logic PORT MAP(clk, reset_TB, vali_TB, dati_TB, valo_TB, dato_TB);

    feeder : PROCESS (clk)
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            IF (COUNTER < 512) THEN
                dati_TB(31 DOWNTO 8) <= (OTHERS => '0');
                dati_TB(7 DOWNTO 0) <= PACKET1(COUNTER TO COUNTER + 7);
                vali_TB(3 DOWNTO 1) <= (OTHERS => '0');
                vali_TB(0) <= '1';
                COUNTER <= COUNTER + 8;
            ELSIF (COUNTER < 1024) THEN
                dati_TB(31 DOWNTO 0) <= (OTHERS => '0');
                vali_TB(3 DOWNTO 0) <= (OTHERS => '0');
                COUNTER <= COUNTER + 8;
            ELSIF (COUNTER < 1536) THEN
                dati_TB(31 DOWNTO 16) <= (OTHERS => '0');
                dati_TB(15 DOWNTO 8) <= PACKET2(COUNTER - 1024 TO COUNTER - 1024 + 7);
                dati_TB(7 DOWNTO 0) <= (OTHERS => '0');
                vali_TB(3 DOWNTO 2) <= (OTHERS => '0');
                vali_TB(1) <= '1';
                vali_TB(0) <= '0';
                COUNTER <= COUNTER + 8;
            ELSIF (COUNTER < 2048) THEN
                dati_TB(31 DOWNTO 0) <= (OTHERS => '0');
                vali_TB(3 DOWNTO 0) <= (OTHERS => '0');
                COUNTER <= COUNTER + 8;
            ELSIF (COUNTER < 2048+632) THEN
                dati_TB(31 DOWNTO 24) <= PACKET3(COUNTER - 2048 TO COUNTER - 2048 + 7);
                dati_TB(23 DOWNTO 16) <= PACKET4(COUNTER - 2048 TO COUNTER - 2048 + 7);
                dati_TB(15 DOWNTO 0) <= (OTHERS => '0');
                dati_TB(15 DOWNTO 0) <= (OTHERS => '0');
                vali_TB(3 DOWNTO 2) <= (OTHERS => '1');
                vali_TB(1 DOWNTO 0) <= (OTHERS => '0');
                COUNTER <= COUNTER + 8;
            ELSE
                dati_TB(31 DOWNTO 0) <= (OTHERS => '0');
                vali_TB(3 DOWNTO 0) <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;