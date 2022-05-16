LIBRARY ieee;
--LIBRARY STD;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY switchlogic IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		vali : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		dati : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		valo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		dato : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END switchlogic;

ARCHITECTURE switch_logic_arc OF switchlogic IS

	COMPONENT input_handler IS
		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			val : IN STD_LOGIC;
			dat : IN STD_LOGIC_VECTOR(0 TO 7);
			por : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			valo1 : OUT STD_LOGIC;
			dato1 : OUT STD_LOGIC_VECTOR(0 TO 8);
			valo2 : OUT STD_LOGIC;
			dato2 : OUT STD_LOGIC_VECTOR(0 TO 8);
			valo3 : OUT STD_LOGIC;
			dato3 : OUT STD_LOGIC_VECTOR(0 TO 8);
			valo4 : OUT STD_LOGIC;
			dato4 : OUT STD_LOGIC_VECTOR(0 TO 8);
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

	COMPONENT roundrobin IS
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
	END COMPONENT;

	SIGNAL val_one2two, val_one2three, val_one2four, val_two2one, val_two2three, val_two2four, val_three2one, val_three2two, val_three2four, val_four2one, val_four2two, val_four2three : STD_LOGIC;
	SIGNAL dat_one2two, dat_one2three, dat_one2four, dat_two2one, dat_two2three, dat_two2four, dat_three2one, dat_three2two, dat_three2four, dat_four2one, dat_four2two, dat_four2three : STD_LOGIC_VECTOR(8 DOWNTO 0);

	SIGNAL mac_req1, mac_req2, mac_req3, mac_req4, mac_val2one, mac_val2two, mac_val2three, mac_val2four : STD_LOGIC;
	SIGNAL mac_srcPort1, mac_dst1, mac_srcPort2, mac_dst2, mac_srcPort3, mac_dst3, mac_srcPort4, mac_dst4 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL mac_srcAddr1, mac_dstAddr1, mac_srcAddr2, mac_dstAddr2, mac_srcAddr3, mac_dstAddr3, mac_srcAddr4, mac_dstAddr4 : STD_LOGIC_VECTOR(47 DOWNTO 0);

	SIGNAL dati1, dati2, dati3, dati4, dato1, dato2, dato3, dato4 : STD_LOGIC_VECTOR (8 DOWNTO 0);
	SIGNAL vali1, vali2, vali3, vali4, valo1, valo2, valo3, valo4 : STD_LOGIC;

	SIGNAL port_1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
	SIGNAL port_2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
	SIGNAL port_3 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
	SIGNAL port_4 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";

BEGIN

	In_1 : input_handler PORT MAP(clk, reset, vali(0), dati(7 DOWNTO 0), port_1, OPEN, OPEN, val_one2two, dat_one2two, val_one2three, dat_one2three, val_one2four, dat_one2four, mac_req1, mac_srcAddr1, mac_dstAddr1, mac_srcPort1, mac_dst1, mac_val2one);
	In_2 : input_handler PORT MAP(clk, reset, vali(1), dati(15 DOWNTO 8), port_2, val_two2one, dat_two2one, OPEN, OPEN, val_two2three, dat_two2three, val_two2four, dat_two2four, mac_req2, mac_srcAddr2, mac_dstAddr2, mac_srcPort2, mac_dst2, mac_val2two);
	In_3 : input_handler PORT MAP(clk, reset, vali(2), dati(23 DOWNTO 16), port_3, val_three2one, dat_three2one, val_three2two, dat_three2two, OPEN, OPEN, val_three2four, dat_three2four, mac_req3, mac_srcAddr3, mac_dstAddr3, mac_srcPort3, mac_dst3, mac_val2three);
	In_4 : input_handler PORT MAP(clk, reset, vali(3), dati(31 DOWNTO 24), port_4, val_four2one, dat_four2one, val_four2two, dat_four2two, val_four2three, dat_four2three, OPEN, OPEN, mac_req4, mac_srcAddr4, mac_dstAddr4, mac_srcPort4, mac_dst4, mac_val2four);

	Out_1 : roundrobin PORT MAP(clk, dat_two2one, val_two2one, dat_three2one, val_three2one, dat_four2one, val_four2one, dato(7 DOWNTO 0), valo(0));
	Out_2 : roundrobin PORT MAP(clk, dat_one2two, val_one2two, dat_three2two, val_three2two, dat_four2two, val_four2two, dato(15 DOWNTO 8), valo(1));
	Out_3 : roundrobin PORT MAP(clk, dat_one2three, val_one2three, dat_two2three, val_two2three, dat_four2three, val_four2three, dato(23 DOWNTO 16), valo(2));
	Out_4 : roundrobin PORT MAP(clk, dat_one2four, val_one2four, dat_two2four, val_two2four, dat_three2four, val_three2four, dato(31 DOWNTO 24), valo(3));

	MAC : mac_learning PORT MAP(clk, reset, mac_dstAddr1, mac_srcAddr1, mac_srcPort1, mac_req1, mac_dstAddr2, mac_srcAddr2, mac_srcPort2, mac_req2, mac_dstAddr3, mac_srcAddr3, mac_srcPort3, mac_req3, mac_dstAddr4, mac_srcAddr4, mac_srcPort4, mac_req4, mac_dst1, mac_val2one, mac_dst2, mac_val2two, mac_dst3, mac_val2three, mac_dst4, mac_val2four);

END ARCHITECTURE;