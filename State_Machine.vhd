--***********************************************************
--
-- Filename:    State_Machine.vhd
--
-- Description: This is a simple state machine that allows 
--              the user to first set the plant type and then
--              access the watering suggestion.
--
--
-- Author:      Josie Lyon
-- Date:        April 23, 2021
--
--***********************************************************
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Seven_Seg_Conversion.all;

entity State_Machine is
   port(clk         : in std_logic;
	     suggestion  : in std_logic;
		  sugg_ready  : in std_logic;
		  sugg_pending: in std_logic;
        SW          : in std_logic_vector(2 downto 0);	
		  PlantType   : in std_logic_vector(2 downto 0);
		  HEX0  : out std_logic_vector(6 downto 0);
		  HEX1  : out std_logic_vector(6 downto 0);
		  HEX2  : out std_logic_vector(6 downto 0);
		  HEX3  : out std_logic_vector(6 downto 0);
		  HEX4  : out std_logic_vector(6 downto 0);
		  HEX5  : out std_logic_vector(6 downto 0));
end entity;

architecture STATE_BHV of State_Machine is
	type STATE_TYPE is (S0_PROMPT, S1_TEST, S2_SUGGEST);
	signal STATE : STATE_TYPE := S0_PROMPT;
	signal hex_tmp_0 : std_logic_vector(6 downto 0) := "1111111" ;
	signal hex_tmp_1 : std_logic_vector(6 downto 0) := "1111111" ;
	signal hex_tmp_2 : std_logic_vector(6 downto 0) := "1111111" ;
	signal hex_tmp_3 : std_logic_vector(6 downto 0) := "1111111" ;
	signal hex_tmp_4 : std_logic_vector(6 downto 0) := "1111111" ;
	signal hex_tmp_5 : std_logic_vector(6 downto 0) := "1111111" ;
   signal set_dry      : CHAR_ARRAY := "dry---";
	signal set_avg      : CHAR_ARRAY := "avg---";
	signal set_moist    : CHAR_ARRAY := "wet---";
	signal set_none     : CHAR_ARRAY := "------";
	signal display_set  : CHAR_ARRAY := "---set";
	signal display_test : CHAR_ARRAY := "test--";
	signal display_yes  : CHAR_ARRAY := "---yes";
   signal display_no   : CHAR_ARRAY := "----no";
   signal display_err  : CHAR_ARRAY := "---err";	
begin

   FSM: process(clk,SW)
	   variable cnt : integer := 0;
	begin
	   -- If all switches are off, reset system once signal is stable
		if ((SW = "000") and (cnt > 10)) then
		   cnt := 0;
			STATE <= S0_PROMPT;
		else
		   cnt := cnt + 1;
		end if;
		
		-- On clock high level
		if (clk = '1') then
		
			-- Otherwise, keep going in FSM loop
			case STATE is
				when S0_PROMPT =>
					-- Prompt for plant type setting
					-- Impose a small dealy to allow signals to stablize.
					-- If a setting is selected, hold setting for 3 second then move on to the next state!
					if ((SW = "001" or SW = "010" or SW = "100") and (cnt > 15)) then
						cnt := 0;
						STATE <= S1_TEST;
					else
						cnt := cnt + 1;
						STATE <= S0_PROMPT;
					end if;
				
				-- Prompt user to test soil and allow signal to stabilize.
				when S1_TEST =>
					if ((sugg_ready = '1') and (cnt > 15)) then
						cnt := 0;
						STATE <= S2_SUGGEST;
					else 
					   cnt := cnt + 1;
						STATE <= S1_TEST;
					end if;
				
				when S2_SUGGEST =>
					-- Output suggestion 
					-- If plant type is unset, the system is reset once signal is stable.
					if ((SW = "000") and (cnt > 10)) then
						cnt := 0;
						STATE <= S0_PROMPT;
					else
					   cnt := cnt + 1;
						STATE <= S2_SUGGEST;
					end if;
			end case;
		end if;
	end process FSM;
	
	-- Process 7-segment display output
	HEX_OUT : process(STATE, clk)
	begin
	   if (clk'event and clk = '1') then
		   case (STATE) is
			   -- Prompt for plant type setting
				when S0_PROMPT => 
					AlphaNum_To_7Seg(display_set, hex_tmp_0, hex_tmp_1, hex_tmp_2, hex_tmp_3, hex_tmp_4, hex_tmp_5);
				   if (SW = "001") then
					   AlphaNum_To_7Seg(set_dry, hex_tmp_0, hex_tmp_1, hex_tmp_2, hex_tmp_3, hex_tmp_4, hex_tmp_5);
					elsif (SW = "010") then
					   AlphaNum_To_7Seg(set_avg, hex_tmp_0, hex_tmp_1, hex_tmp_2, hex_tmp_3, hex_tmp_4, hex_tmp_5);
					elsif (SW = "100") then 
					   AlphaNum_To_7Seg(set_moist, hex_tmp_0, hex_tmp_1, hex_tmp_2, hex_tmp_3, hex_tmp_4, hex_tmp_5);
					end if;
										
				-- Prompt user to test soil
			   when S1_TEST =>
				   --Output nothing.
				
				-- Output suggestion 
				when S2_SUGGEST =>
				   if (suggestion = '0') then
					   AlphaNum_To_7Seg(display_no, hex_tmp_0, hex_tmp_1, hex_tmp_2, hex_tmp_3, hex_tmp_4, hex_tmp_5);
					elsif (suggestion = '1') then
					   AlphaNum_To_7Seg(display_yes, hex_tmp_0, hex_tmp_1, hex_tmp_2, hex_tmp_3, hex_tmp_4, hex_tmp_5);
					end if;
					
				when others => AlphaNum_To_7Seg(display_err, hex_tmp_0, hex_tmp_1, hex_tmp_2, hex_tmp_3, hex_tmp_4, hex_tmp_5);
			end case;
			
			-- Display 7-Segment Message
			HEX0 <= hex_tmp_0;
			HEX1 <= hex_tmp_1;
			HEX2 <= hex_tmp_2;
			HEX3 <= hex_tmp_3;
			HEX4 <= hex_tmp_4;
			HEX5 <= hex_tmp_5;			
		end if;
	end process HEX_OUT;
	
end architecture;