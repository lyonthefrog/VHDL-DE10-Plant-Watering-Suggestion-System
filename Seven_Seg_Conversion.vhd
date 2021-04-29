--***********************************************************
--
-- Filename:    String_To_7-Segment.vhd
--
-- Description: This packaged procedure outputs the equivalent 
--              alphanumeric character logic for the six 
--              7-segment displays provided an input array of 
--              strings.
--
--              Note: Segment is "on" when logic low.
--
--
-- Author:      Josie Lyon
-- Date:        April 23, 2021
--
--***********************************************************
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------
-- Package to Hold Procedure for Converting String to 7-Segment
----------------------------------------------------------------
package Seven_Seg_Conversion is
   -- This array of characters holds the input string to be converted.
	type CHAR_ARRAY is array (5 downto 0) of character;
	
	-- This procedure can be called when this package is included and 
	-- the input string and the six output 7-segment values are provided.
   procedure AlphaNum_To_7Seg
	   (signal chars : in CHAR_ARRAY; signal hex0, hex1, hex2, hex3, hex4, hex5 : out std_logic_vector(6 downto 0)); 
end package;

------------------------------------------
-- Body of Package
------------------------------------------
package body Seven_Seg_Conversion is
   
	procedure AlphaNum_To_7Seg
	   (signal chars : in CHAR_ARRAY; signal hex0, hex1, hex2, hex3, hex4, hex5 : out std_logic_vector(6 downto 0)) is 
		 variable count : integer := 0;
		 variable hex_tmp : std_logic_vector(6 downto 0);
		 variable len : integer := CHAR_ARRAY'length;
	begin
	   -- Six 7-segment displays
	   while (count < len) loop
		   
			-- Convert character to 7-segment display equivalent
			case chars(count) is
			   when 'a' | 'A' => hex_tmp := "0001000";
				when 'b' | 'B' => hex_tmp := "0000011";
				when 'c' | 'C' => hex_tmp := "1000110";
				when 'd' | 'D' => hex_tmp := "0100001";
				when 'e' | 'E' => hex_tmp := "0000110";
				when 'f' | 'F' => hex_tmp := "0001110";
				when 'g' | 'G' => hex_tmp := "1000010";
				when 'h' | 'H' => hex_tmp := "0001001";
				when 'i' | 'I' => hex_tmp := "1101111";
				when 'j' | 'J' => hex_tmp := "1110001";
				when 'k' | 'K' => hex_tmp := "0001010";
				when 'l' | 'L' => hex_tmp := "1000111";
				when 'm' | 'M' => hex_tmp := "0101010";
				when 'n' | 'N' => hex_tmp := "0101011";
				when 'o' | 'O' => hex_tmp := "0100011";
				when 'p' | 'P' => hex_tmp := "0001100";
				when 'q' | 'Q' => hex_tmp := "0011000";
				when 'r' | 'R' => hex_tmp := "0101111";
				when 's' | 'S' => hex_tmp := "0010010";
				when 't' | 'T' => hex_tmp := "0000111";
				when 'u' | 'U' => hex_tmp := "1100011";
				when 'v' | 'V' => hex_tmp := "1100011";
				when 'w' | 'W' => hex_tmp := "0000001";
				when 'x' | 'X' => hex_tmp := "0110111";
				when 'y' | 'Y' => hex_tmp := "0010001";
				when 'z' | 'Z' => hex_tmp := "0100100";
				when '0' => hex_tmp := "1000000";
				when '1' => hex_tmp := "1001111";
				when '2' => hex_tmp := "0100100";
				when '3' => hex_tmp := "0110000";
				when '4' => hex_tmp := "0011001";
				when '5' => hex_tmp := "0010010";
				when '6' => hex_tmp := "0000010";
				when '7' => hex_tmp := "1011000";
				when '8' => hex_tmp := "0000000";
				when '9' => hex_tmp := "0010000";
				when others => hex_tmp := "1111111";  -- All off
			end case;
			
			-- Assign hex
			case count is
			   when 0 => hex0 <= hex_tmp;
				when 1 => hex1 <= hex_tmp;
				when 2 => hex2 <= hex_tmp;
				when 3 => hex3 <= hex_tmp;
				when 4 => hex4 <= hex_tmp;
				when 5 => hex5 <= hex_tmp;
				
				-- This case should never happen, so if an 
				-- unexpected 8 appears, it might indicate an error.
				when others => hex0 <= "0000000";
			                  hex1 <= "0000000";
								   hex2 <= "0000000";
									hex3 <= "0000000";
									hex4 <= "0000000";
									hex5 <= "0000000";
			end case;
			
			-- Increment count
			count := count + 1;
		end loop;
		
	end procedure;
end Seven_Seg_Conversion;
