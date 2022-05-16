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
    SIGNAL PACKET1 : STD_LOGIC_VECTOR(0 TO 511) := x"12DEADBEEF21" & x"001234567890" & x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F" & x"803811EF";
    SIGNAL PACKET2 : STD_LOGIC_VECTOR(0 TO 511) := x"001234567890" & x"12DEADBEEF21" & x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F" & x"67343F57";
    SIGNAL PACKET3 : STD_LOGIC_VECTOR(0 TO 639) := x"12DEADBEEF21" & x"3DECA6CCAFE1" & x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F" & x"CDB03982";
    SIGNAL PACKET4 : STD_LOGIC_VECTOR(0 TO 639) := x"12DEADBEEF21" & x"76BAD7F00D61" & x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F" & x"703CC661";
      
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
            ELSIF (COUNTER < 2048+640) THEN
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