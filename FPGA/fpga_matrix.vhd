----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:30 01/03/2015 
-- Design Name: 
-- Module Name:    dvid_thru - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

use work.rgbmatrix.all; -- Constants & Configuration

entity fpga_matrix is
    Port (
        --clk50      : in     std_logic;
        hdmi_in_p    : in     std_logic_vector(3 downto 0);
        hdmi_in_n    : in     std_logic_vector(3 downto 0);
        hdmi_in_sclk : inout  std_logic;
        hdmi_in_sdat : inout  std_logic;

        hdmi_out_p   : out    std_logic_vector(3 downto 0);
        hdmi_out_n   : out    std_logic_vector(3 downto 0);

        port_a       : out    std_logic_vector(11 downto 0);
        port_b       : out    std_logic_vector(5 downto 0);
                  
        leds         : out    std_logic_vector(7 downto 0);
        switch       : in     std_logic_vector(0 downto 0)
    );
end fpga_matrix;

architecture Behavioral of fpga_matrix is

	signal rst       : std_logic;

    -- Video clocks
	signal clk_x1    : std_logic;
	signal clk_x2    : std_logic;
	signal clk_x10   : std_logic;
	signal strobe    : std_logic;

    -- Video signals
    signal i_red     : std_logic_vector(7 downto 0);
    signal i_green   : std_logic_vector(7 downto 0);
    signal i_blue    : std_logic_vector(7 downto 0);
    signal i_blank   : std_logic;
    signal i_hsync   : std_logic;
    signal i_vsync   : std_logic;          

    signal o_red     : std_logic_vector(7 downto 0);
    signal o_green   : std_logic_vector(7 downto 0);
    signal o_blue    : std_logic_vector(7 downto 0);
    signal o_blank   : std_logic;
    signal o_hsync   : std_logic;
    signal o_vsync   : std_logic;          

    -- Memory signals
    signal wr_enable : std_logic;
    signal wr_addr   : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal wr_data   : std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal rd_addr   : std_logic_vector(ADDR_WIDTH - 2 downto 0);
    signal rd_data   : std_logic_vector(DATA_WIDTH * 2 - 1 downto 0);

    -- Debug signals
    signal channel_a : std_logic;
    signal channel_b : std_logic;
    signal clk_count : unsigned(2 downto 0) := (others => '0');
    signal clk_out   : std_logic;
    
begin

    rst <= switch(0);
    port_a(10) <= '0';
    port_a(11) <= '0';

    ----------------
    -- Debug outputs
    ----------------
    port_b(3) <= channel_a;
    port_b(4) <= channel_b;
    port_b(5) <= clk_out;

    channel_a <= i_hsync;
    channel_b <= i_vsync;

    -------------------------------------
    -- EDID I2C signals (not implemented)
    -------------------------------------
    hdmi_in_sclk <= 'Z';
    hdmi_in_sdat <= 'Z';

    -------------------------------------------------
    -- Read the VGA signals from the DVI-D/TMDS input 
    -------------------------------------------------
    Inst_dvid_in: entity work.dvid_in port map (
        tmds_in_p => hdmi_in_p,
        tmds_in_n => hdmi_in_n,

        leds      => leds,

        clk_x1    => clk_x1,
        clk_x2    => clk_x2,
        clk_x10   => clk_x10,
        strobe    => strobe,

        red_p     => i_red,
        green_p   => i_green,
        blue_p    => i_blue,
        blank     => i_blank,
        hsync     => i_hsync,
        vsync     => i_vsync
    );

    --------------------------------------------
    -- Fill the framebuffer from the HDMI signal
    --------------------------------------------
	Inst_display: entity work.display port map (
        clk_pixel => clk_x1,
        i_red     => i_red,
        i_green   => i_green,
        i_blue    => i_blue,
        i_blank   => i_blank,
        i_hsync   => i_hsync,
        i_vsync   => i_vsync,

        o_red     => o_red,
        o_green   => o_green,
        o_blue    => o_blue,
        o_blank   => o_blank,
        o_hsync   => o_hsync,
        o_vsync   => o_vsync,

        wr_enable => wr_enable,
        wr_addr   => wr_addr,
        wr_data   => wr_data
    );

    ---------------------------------------------------
    -- Convert the VGA signals to the DVI-D/TMDS output 
    ---------------------------------------------------
    Inst_dvid_out: entity work.dvid_out port map (
        clk_pixel  => clk_x1,

        red_p      => o_red,
        green_p    => o_green,
        blue_p     => o_blue,
        blank      => o_blank,
        hsync      => o_hsync,
        vsync      => o_vsync,

        tmds_out_p => hdmi_out_p,
        tmds_out_n => hdmi_out_n
    );

    -------------------------------------
    -- Special memory for the framebuffer
    -------------------------------------
    Inst_memory: entity work.memory port map (
        -- Writing side
        wr_clk    => clk_x1,
        wr_enable => wr_enable,
        wr_addr   => wr_addr,
        wr_data   => wr_data,

        -- Reading side
        rd_clk    => clk_x1,
        rd_addr   => rd_addr,
        rd_data   => rd_data
    );

    -----------------------
    -- LED panel controller
    -----------------------
    Inst_ledctrl: entity work.ledctrl port map (
        rst      => rst,
        clk_in   => clk_x1,

        -- Connection to LED panel
        rgb1(2)  => port_a(0),
        rgb1(1)  => port_a(2),
        rgb1(0)  => port_a(4),
        rgb2(2)  => port_a(1),
        rgb2(1)  => port_a(3),
        rgb2(0)  => port_a(5),
        led_addr(3 downto 0) => port_a(9 downto 6),
        clk_out  => port_b(0),
        lat      => port_b(1),
        oe       => port_b(2),

        -- Connection with framebuffer
        rd_addr  => rd_addr,
        rd_data  => rd_data
    );

    ------------------------
    -- Output clk_pixel / 16
    ------------------------
    process(clk_x1)
    begin
        if rising_edge(clk_x1) then
            clk_count <= clk_count + 1;
            if clk_count = "000" then
                clk_out <= not clk_out;
            end if;
        end if;
    end process;

end Behavioral;

