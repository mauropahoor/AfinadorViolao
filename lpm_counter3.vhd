LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.all;

ENTITY lpm_counter3 IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		cout		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (19 DOWNTO 0)
	);
END lpm_counter3;

ARCHITECTURE SYN OF lpm_counter3 IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (19 DOWNTO 0);

	COMPONENT lpm_counter
	GENERIC (
		lpm_direction		: STRING;
		lpm_modulus		: NATURAL;
		lpm_port_updown		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL
	);
	PORT (
			clock	: IN STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (19 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	q <= sub_wire0;
	cout <= '1' WHEN unsigned(sub_wire0) = 39999 ELSE '0';

	LPM_COUNTER_component : LPM_COUNTER
	GENERIC MAP (
		lpm_direction => "UP",
		lpm_modulus => 40000,
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 20
	)
	PORT MAP (
		clock => clock,
		q => sub_wire0
	);

END SYN;
