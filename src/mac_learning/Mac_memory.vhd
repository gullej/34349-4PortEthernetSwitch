LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;


ENTITY mac_memory IS
   PORT
   (
      clock: 		IN   std_logic;
      data_in:  	IN   std_logic_vector (50 DOWNTO 0);
      write_address : 	IN   STD_LOGIC_VECTOR(12 DOWNTO 0);
      read_address : 	IN   STD_LOGIC_VECTOR(12 DOWNTO 0);
      we:    		IN   std_logic;
      re:		IN   std_logic;
      data_out:     	OUT  std_logic_vector (50 DOWNTO 0)
   );
END mac_memory;


ARCHITECTURE mac_memory_arc OF mac_memory IS
   TYPE mem IS ARRAY(0 TO 8192) OF std_logic_vector(50 DOWNTO 0);
   SIGNAL ram_block : mem := (others => (others => '0'));
BEGIN
   PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (we = '1') THEN
            	ram_block(to_integer(unsigned(write_address))) <= data_in;
         elsif(re = '1') then
         	data_out <= ram_block(to_integer(unsigned(read_address)));
	 else
		data_out<=(others=>'0');
	 END IF;
      END IF;
   END PROCESS;
END mac_memory_arc;
