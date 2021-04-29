--***************************************************************************
--
-- Filename:    Analog_Sensor_Input.vhd
--
-- Description: Processes the analog input from the KeYes soil moisture sensor.
--              
--              Outputs a 13-bit voltage reading that corresponds to moisture
--              levels.
--
--              Uses the ADC IP Module configuration created in the DE10-Lite
--              User's Guide demo, ADC_RTL. This is incorporated by adding the
--              .qip and .qsys files found in this project.
--
--
-- Author:      Josie Lyon
-- Date:        April 23, 2021
--
--***************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_Sensor_Input is
   port (MAX10_CLK1_50     : in std_logic;
	      LEDX : out std_logic_vector(9 downto 0);
			Vout : out std_logic_vector(9 downto 0));
end ADC_Sensor_Input;

architecture BEHAV_ADC of ADC_Sensor_Input is
    signal reset_n : std_logic := '1';
	 signal sys_clk : std_logic;
	 
	 -- command / continused send command
    signal command_valid : std_logic := '1';
    signal command_channel : std_logic_vector(4 downto 0) := "00001"; -- [UNSURE VHDL CONVERSION] SW2/SW1/SW0 down: map to arduino ADC_IN0
    signal command_startofpacket : std_logic := '1'; -- ignore in altera_adc_control core
    signal command_endofpacket : std_logic := '1';   -- ignore in altera_adc_control core
    signal command_ready : std_logic;
	 
	 -- response
	 signal response_valid : std_logic; -- synthesis keep 
    signal response_channel : std_logic_vector(4 downto 0);
    signal response_data : std_logic_vector(11 downto 0);
    signal response_startofpacket : std_logic;
    signal response_endofpacket : std_logic;
    signal cur_adc_ch : std_logic_vector(4 downto 0); -- synthesis noprune 
    signal adc_sample_data : std_logic_vector(11 downto 0); -- synthesis noprune 
    signal vol : std_logic_vector(12 downto 0); -- synthesis noprune 
	 
	 -- For ADC IP Module Instantiation
	 component adc_qsys is
		port (
			clk_clk                              : in  std_logic := 'X';             -- clk
			clock_bridge_sys_out_clk_clk         : out std_logic;                    -- clk
			modular_adc_0_command_valid          : in  std_logic := 'X';             -- valid
			modular_adc_0_command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
			modular_adc_0_command_startofpacket  : in  std_logic := 'X';             -- startofpacket
			modular_adc_0_command_endofpacket    : in  std_logic := 'X';             -- endofpacket
			modular_adc_0_command_ready          : out std_logic;                    -- ready
			modular_adc_0_response_valid         : out std_logic;                    -- valid
			modular_adc_0_response_channel       : out std_logic_vector(4 downto 0); -- channel
			modular_adc_0_response_data          : out std_logic_vector(11 downto 0);-- data
			modular_adc_0_response_startofpacket : out std_logic;                    -- startofpacket
			modular_adc_0_response_endofpacket   : out std_logic;                    -- endofpacket
			reset_reset_n                        : in  std_logic := 'X'              -- reset_n
		);
	 end component adc_qsys;
	
begin
   -- ADC IP Module Instantiation
   u0 : component adc_qsys
		port map (
			clk_clk                              => MAX10_CLK1_50,          --                      clk.clk
			clock_bridge_sys_out_clk_clk         => sys_clk,                -- clock_bridge_sys_out_clk.clk
			modular_adc_0_command_valid          => command_valid,          --    modular_adc_0_command.valid
			modular_adc_0_command_channel        => command_channel,        --                         .channel
			modular_adc_0_command_startofpacket  => command_startofpacket,  --                         .startofpacket
			modular_adc_0_command_endofpacket    => command_endofpacket,    --                         .endofpacket
			modular_adc_0_command_ready          => command_ready,          --                         .ready
			modular_adc_0_response_valid         => response_valid,         --   modular_adc_0_response.valid
			modular_adc_0_response_channel       => response_channel,       --                         .channel
			modular_adc_0_response_data          => response_data,          --                         .data
			modular_adc_0_response_startofpacket => response_startofpacket, --                         .startofpacket
			modular_adc_0_response_endofpacket   => response_endofpacket,   --                         .endofpacket
			reset_reset_n                        => reset_n                 --                    reset.reset_n
		);
		
   -- Read Analog Input from Sensor
	-- adc_sample_data: hold 12-bit adc sample value
   -- Vout = Vin (12-bit x2 x 2500 / 4095)
	ADC_Input: process(sys_clk)
	   variable response_data_tmp : integer;   -- Added to allow arithmetic operations
		variable vol_tmp : integer;   -- Added to allow arithmetic operations	
	begin
	   if (sys_clk'event and sys_clk = '1') then
		   response_data_tmp := to_integer(unsigned(response_data));   -- Added to allow arithmetic operations
		   if (response_valid = '1') then
			   adc_sample_data <= response_data;
		      cur_adc_ch <= response_channel;
				vol_tmp := response_data_tmp * 2 * 2500 / 4095; -- Added to allow arithmetic operations
		      vol <= std_logic_vector(to_unsigned(vol_tmp, 13)); -- Added to allow arithmetic operations
			end if;
		end if;
	end process;

	-- Output analog voltage reading
   Output_Voltage: process(vol)
	begin
	   LEDX <= vol(12 downto 3);
	   Vout <= vol(12 downto 3);
	end process;

end BEHAV_ADC;