--***********************************************************
--
-- Filename:    Output_Suggestion.vhd
--
-- Description: Inputs the read analog voltage from the sensor
--              and outputs the suggested watering suggestion
--              in the form of 0 - no, 1 - yes.
--
--              V=IR 
--              low voltage => low resistance => more water!
--              high voltage => high resistance => less water!
--
--              Vout ~ 413 when standing (VERY DRY)
--              Vout ~ 168 when in water (VERY WET)
--
--              To get five ranges, (413-168)/5 ~= 49
--
--              - Very Dry = 430 to 381
--              - Dry = 380 to 331
--              - Medium Dry = 330 to 281
--              - Moist = 280 to 231
--              - Very Moist = 230 to 168 
--
--              *** Intentially made Very Moist region big - typically better to not over water!
--            
-- Author:      Josie Lyon
-- Date:        April 23, 2021
--
--***********************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Seven_Seg_Conversion.all;

entity Output_Suggestion is
   port(      clk : in std_logic;
	           Vin : in std_logic_vector(9 downto 0); 
	     PlantType : in std_logic_vector (2 downto 0); 
	    suggestion : out std_logic;
		 sugg_ready : out std_logic;
		 sugg_pending : out std_logic);
end entity; 

architecture SUGGEST_BHV of Output_Suggestion is
	signal soil_dampness  : std_logic_vector (4 downto 0);
   signal now_very_dry   : std_logic_vector (4 downto 0)   := "00001";
	signal now_dry        : std_logic_vector (4 downto 0)   := "00010";
	signal now_medium_moist : std_logic_vector (4 downto 0) := "00100";
	signal now_moist      : std_logic_vector (4 downto 0)   := "01000";
	signal now_very_moist : std_logic_vector (4 downto 0)   := "10000";
   signal none : std_logic;
	
begin

   -- Only consider sensor input when Vin changes
   SENSE: process(Vin,clk)
	   variable cnt : integer := 0;
		variable Vfrozen : integer;
	begin
	   if (clk'event and clk = '1') then 
			sugg_pending <= '1';
			sugg_ready <= '0';

			-- Snag voltage reading
			Vfrozen := to_integer(unsigned(Vin));
			
			-- Translate voltage range to soil dampness classification
			if (Vfrozen >= 381) then
				soil_dampness <= now_very_dry;
			elsif (Vfrozen <= 380 and Vfrozen >= 331) then
				soil_dampness <= now_dry;
			elsif (Vfrozen <= 330 and Vfrozen >= 281) then
				soil_dampness <= now_medium_moist;
			elsif (Vfrozen <= 280 and Vfrozen >= 231) then
				soil_dampness <= now_moist;
			elsif (Vfrozen <= 230) then
				soil_dampness <= now_very_moist;
			end if;	      			
			
			-- Calculate suggestion based off plant type and soil dampness
			case PlantType is
				
				-- Plants that like dryness.
				-- ONLY water these plants when they are very dry.
				when "001" =>
					if (soil_dampness = now_very_dry) then
						suggestion <= '1';
					else
						suggestion <= '0';
					end if;	
				
				-- Plants that like medium moistness.
				-- Water these plants when they sense any dryness.
				when "010" =>
					if (soil_dampness = now_very_dry or 
						 soil_dampness = now_dry) then
						suggestion <= '1';
					else 
						suggestion <= '0';
					end if;			
		
				-- Plants that like moistness.
				-- Water these plants when they sense medium moisture or less.
				when "100" =>
					if (soil_dampness = now_very_dry or 
						 soil_dampness = now_dry or
						 soil_dampness = now_medium_moist) then
						suggestion <= '1';
					else 
						suggestion <= '0';
					end if;
					
				-- Should never reach this, but when in doubt,
				-- DON'T WATER IT.
				when others => suggestion <= '0';
			end case;
			
			-- Reset pending flag and alert the state machine that the suggestion is ready!
			sugg_pending <= '0';
			sugg_ready <= '1';
      end if;
end process SENSE;
	
end architecture;