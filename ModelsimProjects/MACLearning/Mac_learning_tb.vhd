LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;



Entity mac_learning_tb IS
end Entity mac_learning_tb;




Architecture mac_learning_arc_tb of mac_learning_tb IS

component mac_learning IS


PORT
   (
    clock: 		IN   std_logic;
    reset: 		IN   std_logic;
    mac_dst:  		IN   std_logic_vector (47 DOWNTO 0);
    mac_src:  		IN   std_logic_vector (47 DOWNTO 0);
    port_in:		IN   std_logic_vector (3 DOWNTO 0);
    read_in:		IN   std_logic;
    port_out:     	OUT  std_logic_vector (3 DOWNTO 0);
    read_out:		OUT  std_logic
   );
END component;

signal i : integer:=0;
signal clock_tb 	: std_logic;
signal reset_tb 	: std_logic;
signal mac_dst_tb	: std_logic_vector(47 DOWNTO 0);
signal mac_src_tb	: std_logic_vector(47 DOWNTO 0);
signal port_in_tb  	: std_logic_vector(3 DOWNTO 0);
signal port_out_tb 	: std_logic_vector(3 DOWNTO 0);
signal read_in_tb	: std_logic;
signal read_out_tb 	: std_logic;
constant clock_period 	: TIME:= 4 ns;


Begin

DUT : mac_learning PORT MAP(clock_tb,reset_tb,mac_dst_tb,mac_src_tb,port_in_tb,read_in_tb,port_out_tb,read_out_tb);


 clock_process: PROCESS
 BEGIN
	clock_tb <= '0';

	WAIT FOR clock_period/2;

	clock_tb <= '1';

	WAIT FOR clock_period/2;
END PROCESS;
reset_tb <= '1', '0' after  clock_period;


simu_process : PROCESS(clock_tb, reset_tb) is
BEGIN
	IF(reset_tb='1') then
		i<=0;
		mac_dst_tb<=(others=>'0');
		mac_src_tb<=(others=>'0');
		port_in_tb<=(others=>'0');
		read_in_tb<='0';

	elsif(rising_edge(clock_tb))then

		if(i=1) then
			mac_dst_tb<=x"10005e0053af";
			mac_src_tb<=x"10005e0053af";
			port_in_tb<="1000";
			read_in_tb<='1';
		elsif(i=2) then
			read_in_tb<='0';
		elsif(i=11) then
			mac_dst_tb<=x"10005e0053bf";
			mac_src_tb<=x"10005e0053bf";
			port_in_tb<="0010";
			read_in_tb<='1';
		elsif(i=12) then
			read_in_tb<='0';
		end if;
		i <=i+1;
	END IF;
END PROCESS;
end mac_learning_arc_tb;