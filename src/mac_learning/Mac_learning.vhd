LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

Entity mac_learning IS


PORT
   (
    clock: 		IN   std_logic;
    reset: 		IN   std_logic;
    mac_dst:  		IN   std_logic_vector (47 DOWNTO 0);
    mac_src:  		IN   std_logic_vector (47 DOWNTO 0);
    port_in:          	IN   std_logic_vector (2 DOWNTO 0);
    read_in:		IN   std_logic;
    port_out:     	OUT  std_logic_vector (2 DOWNTO 0);
    read_out:		OUT  std_logic
   );
END mac_learning;




Architecture mac_learning_arc of mac_learning IS

	TYPE State_type IS (waiting, reading, writing, hashing,sending);
	signal state : State_Type;
	signal Data : std_logic_vector (50 DOWNTO 0);
	signal write_add : STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal read_add  : STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal write_en  : std_logic;
	signal read_en   : std_logic;
	signal data_ram  : std_logic_vector (50 DOWNTO 0);
	signal R	 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal D 	 : std_logic_vector(7 downto 0);
	signal R2	 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	signal D2 	 : std_logic_vector(7 downto 0);
	signal count 	 : INTEGER range 0 to 100;
	

	component mac_memory
   	PORT
   	(	
      		clock: 		IN   std_logic;
      		data_in:  	IN   std_logic_vector (50 DOWNTO 0);
      		write_address : IN   STD_LOGIC_VECTOR(12 DOWNTO 0);
      		read_address : 	IN   STD_LOGIC_VECTOR(12 DOWNTO 0);
      		we:    		IN   std_logic;
		re:		IN   std_logic;
      		data_out:     	OUT  std_logic_vector (50 DOWNTO 0)
   	);
	END component;

	BEGIN
	
	mac_mem : mac_memory
	port map
	(
		clock=>clock,
		data_in=>data,
		write_address=>write_add,
		read_address=>read_add,
		we=>write_en,
		re=>read_en,
		data_out=>data_ram
	);

	PROCESS (clock, reset)
   	BEGIN
      	IF reset = '1' THEN
         	state<=waiting;
		   	
	ELSIF (clock'EVENT AND clock = '1') THEN
         	CASE state IS
            	WHEN waiting=>
			
               		if(read_in='1') then
				state<=hashing;
				count<=0;
			else
				state<=waiting;
			end if;
            	WHEN hashing=>
               		count<=count+1;
			if(count=5) then
				state<=writing;
			else
				state<=hashing;
			end if;
            	WHEN writing=>
               		state<=reading;
		WHEN reading=>
               		state<=sending;
		WHEN sending=>
               		state<=waiting;
         	END CASE;
      	END IF;
   END PROCESS;
   
   PROCESS (state,count)
   BEGIN
      CASE state IS
            	WHEN waiting=>
               		port_out<="000";
			read_out<='0';
			R<=(others=>'0');
			D<=(others=>'0');
			R2<=(others=>'0');
			D2<=(others=>'0');
			write_en<='0';
			write_add<=(others=>'0');
			read_en<='0';
			read_add<=(others=>'0');
			Data<=(others=>'0'); 
	 
            	WHEN hashing=>
			
			for k in 0 to 7 loop
				D(k)<=mac_src(k+count*8);
				D2(k)<=mac_dst(k+count*8);
			end loop;
			R(0)  <= R(5) XOR R(6) XOR R(9) XOR R(10) XOR R(11) XOR R(12) XOR D(7);
			R(1)  <= R(6) XOR R(7) XOR R(10) XOR R(11) XOR R(12) XOR D(6);
			R(2)  <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR D(5);
			R(3)  <= R(6) XOR R(7) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR D(4);
			R(4)  <= R(5) XOR R(6) XOR R(7) XOR R(8) XOR D(3);
			R(5)  <= R(5) XOR R(7) XOR R(8) XOR R(10) XOR R(11) XOR R(12) XOR D(2);
			R(6)  <= R(5) XOR R(8) XOR R(10) XOR D(1);
			R(7)  <= R(5) XOR R(10) XOR R(12) XOR D(0);
			R(8)  <= R(0) XOR R(6) XOR R(11);
			R(9)  <= R(1) XOR R(7) XOR R(12);
			R(10) <= R(2) XOR R(5) XOR R(6) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);
			R(11) <= R(3) XOR R(5) XOR R(7);
			R(12) <= R(4) XOR R(5) XOR R(8) XOR R(9) XOR R(10) XOR R(11) XOR R(12);
			
			
			R2(0)  <= R2(5) XOR R2(6) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(7);
			R2(1)  <= R2(6) XOR R2(7) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(6);
			R2(2)  <= R2(5) XOR R2(6) XOR R2(7) XOR R2(8) XOR R2(9) XOR R2(10) XOR D2(5);
			R2(3)  <= R2(6) XOR R2(7) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR D2(4);
			R2(4)  <= R2(5) XOR R2(6) XOR R2(7) XOR R2(8) XOR D2(3);
			R2(5)  <= R2(5) XOR R2(7) XOR R2(8) XOR R2(10) XOR R2(11) XOR R2(12) XOR D2(2);
			R2(6)  <= R2(5) XOR R2(8) XOR R2(10) XOR D2(1);
			R2(7)  <= R2(5) XOR R2(10) XOR R2(12) XOR D2(0);
			R2(8)  <= R2(0) XOR R2(6) XOR R2(11);
			R2(9)  <= R2(1) XOR R2(7) XOR R2(12);
			R2(10) <= R2(2) XOR R2(5) XOR R2(6) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12);
			R2(11) <= R2(3) XOR R2(5) XOR R2(7);
			R2(12) <= R2(4) XOR R2(5) XOR R2(8) XOR R2(9) XOR R2(10) XOR R2(11) XOR R2(12);
            	WHEN writing=>
			data <= mac_src & port_in;
			write_en<='1';
			write_add<=R;
			
		WHEN reading=>
			write_en<='0';
			read_en<='1';
			read_add<=R2;
               	
		WHEN sending=>
			--logic for sending data. broadcast if only zero. 
			--Compare the mac address in data with dst_address if it is the same use the port in data for port out 
			--otherwise broadcast
			read_en<='0';
			read_out<='1';
			if(data_ram = x"00")then
				port_out<="111";
			else
				if(data_ram(50 downto 3)=mac_dst(47 downto 0))then
					port_out <=data_ram(2 downto 0);
				else
					port_out<="111";
				end if;
			end if;
         	END CASE;
   END PROCESS;
end mac_learning_arc;
