--***************************************************************************
--
-- Filename:    Plant_Type_Setting.vhd
--
-- Description: Sets the type of plant according to its
--              preferred soil moisture levels so watering 
--              suggestion can adjust according to type:
--              
--              - Dry (SW0 = 1) 
--                   Plant prefers dry soil
--                   Ex: succulents
--              - Avg.(SW1 = 1) 
--                   Plant prefers moderately moist soil
--                   Ex: everything else
--              - Moist (SW2 = 1) 
--                   Plant prefers moist soil
--                   Ex: ferns
--
--              The selected setting is displayed in the 7-segment display.
--
--
-- Author:      Josie Lyon
-- Date:        April 23, 2021
--
--***************************************************************************
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Seven_Seg_Conversion.all;

entity Plant_Type_Setting_SW is
   port (      clk : in std_logic;
	             SW : in std_logic_vector(2 downto 0);
			PlantType : out std_logic_vector(2 downto 0));
end entity;

architecture SET_BEHAV of Plant_Type_Setting_SW is
begin
  
	-- Process switch configuration and generate associated 7-segment display output values
   SW_Input : process(SW, clk)
	begin
	   if (clk'event and clk = '1') then
			case SW is
				when "001" => PlantType <= "001"; 							  
				when "010" => PlantType <= "010"; 
				when "100" => PlantType <= "100"; 
				when others => PlantType <= "000"; 
			end case;
		end if;
	end process;

end architecture;