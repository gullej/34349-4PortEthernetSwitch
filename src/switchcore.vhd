library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity switchcore is

	port
			(
				clk:			in	std_logic;
				reset:			in	std_logic;
				
				--Activity indicators
				link_sync:		in	std_logic_vector(3 downto 0);	--High indicates a peer connection at the physical layer. 
				
				--Four GMII interfaces
				tx_data:			out	std_logic_vector(31 downto 0);	--(7 downto 0)=TXD0...(31 downto 24=TXD3)
				tx_ctrl:			out	std_logic_vector(3 downto 0);	--(0)=TXC0...(3=TXC3)
				rx_data:			in	std_logic_vector(31 downto 0);	--(7 downto 0)=RXD0...(31 downto 24=RXD3)
				rx_ctrl:			in	std_logic_vector(3 downto 0)	--(0)=RXC0...(3=RXC3)
			);

end switchcore;

architecture arch of switchcore is

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

BEGIN

DUT : switch_logic PORT MAP(clk, reset, rx_ctrl, rx_data, tx_ctrl, tx_data);


END arch;

