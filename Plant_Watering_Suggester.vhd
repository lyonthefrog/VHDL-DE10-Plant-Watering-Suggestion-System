--***********************************************************
--
-- Filename:    Plant_Watering_Suggester.vhd
--
-- Description: Top level entity for plant watering project.
--
-- Author:      Josie Lyon
-- Date:        April 23, 2021
--
--***********************************************************
library ieee;
use ieee.std_logic_1164.all;

------------------------------------------
-- Top Level Entity
------------------------------------------
entity PLANT_WATERING_SUGGESTER is 
   port(clk   : in std_logic;
		  SW    : in std_logic_vector(2 downto 0);
		  LEDX  : out std_logic_vector(9 downto 0);
		  HEX0  : out std_logic_vector(6 downto 0);
		  HEX1  : out std_logic_vector(6 downto 0);
		  HEX2  : out std_logic_vector(6 downto 0);
		  HEX3  : out std_logic_vector(6 downto 0);
		  HEX4  : out std_logic_vector(6 downto 0);
		  HEX5  : out std_logic_vector(6 downto 0));
end entity;

------------------------------------------
-- Top Level Architecture
------------------------------------------
architecture TOP_BHV of PLANT_WATERING_SUGGESTER is
   signal Vin : std_logic_vector(9 downto 0);
	signal PlantType : std_logic_vector(2 downto 0);
	signal suggestion, sugg_ready, sugg_pending : std_logic;
begin
	
	-- Processing Analog Sensor Input Entity Instantiation
   U1: entity work.ADC_Sensor_Input(BEHAV_ADC)
	       port map( MAX10_CLK1_50 => clk, Vout => Vin, LEDX => LEDX);
	       --port map( MAX10_CLK1_50 => clk, LEDX => LEDX, Vout => Vin);
	
	-- Plant Type Setting Entity Instantiation
	U2: entity work.Plant_Type_Setting_SW(SET_BEHAV)
	       port map( clk => clk, SW  => SW,   PlantType => PlantType); 
	
	-- Output Suggestion Entity Instantiation
	U3: entity work.Output_Suggestion(SUGGEST_BHV)
	       port map( clk => clk, Vin => Vin, PlantType => PlantType, suggestion => suggestion,
			           sugg_ready => sugg_ready, sugg_pending => sugg_pending);
	
	-- State Machine Entity Instantiation
   U4: entity work.State_Machine(STATE_BHV)
	      port map( clk => clk, suggestion => suggestion, sugg_ready => sugg_ready, PlantType => PlantType,
			          sugg_pending => sugg_pending, SW => SW, 
						 HEX0 => HEX0, HEX1 => HEX1, HEX2 => HEX2,      
						 HEX3 => HEX3, HEX4 => HEX4, HEX5 => HEX5);
	
end architecture;
