----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:37:20 01/25/2015 
-- Design Name: 
-- Module Name:    display - Behavioral 
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

use work.rgbmatrix.all;

entity display is
    Port (
        clk_pixel : IN std_logic;

        i_red     : IN std_logic_vector(7 downto 0);
        i_green   : IN std_logic_vector(7 downto 0);
        i_blue    : IN std_logic_vector(7 downto 0);
        i_blank   : IN std_logic;
        i_hsync   : IN std_logic;
        i_vsync   : IN std_logic;          

		o_red     : OUT std_logic_vector(7 downto 0);
		o_green   : OUT std_logic_vector(7 downto 0);
		o_blue    : OUT std_logic_vector(7 downto 0);
		o_blank   : OUT std_logic;
		o_hsync   : OUT std_logic;
		o_vsync   : OUT std_logic;  

        wr_enable : OUT std_logic;
        wr_addr   : OUT std_logic_vector(ADDR_WIDTH - 1 downto 0);
        wr_data   : OUT std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end display;

architecture Behavioral of display is

    -------------------------
    -- Part of the pipeline
    -------------------------
    signal a_red     : std_logic_vector(7 downto 0);
    signal a_green   : std_logic_vector(7 downto 0);
    signal a_blue    : std_logic_vector(7 downto 0);
    signal a_blank   : std_logic;
    signal a_hsync   : std_logic;
    signal a_vsync   : std_logic;  

    -------------------------------
    -- Counters for screen position   
    -------------------------------
    signal x : STD_LOGIC_VECTOR (10 downto 0);
    signal y : STD_LOGIC_VECTOR (10 downto 0);

    signal border : std_logic;

    signal addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);

begin

    -- Address for 128x32 display
    addr <= std_logic_vector(unsigned(y(4 downto 0) & x(6 downto 0)) - 1);

    process(clk_pixel)
        variable m_red, m_green, m_blue : std_logic_vector(PIXEL_DEPTH - 1 downto 0);
        variable data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk_pixel) then
            wr_enable <= '0';

            if a_blank = '0' and unsigned(x) <= IMG_WIDTH and unsigned(y) < IMG_HEIGHT then
                m_red := a_red(a_red'high downto a_red'high - PIXEL_DEPTH + 1);
                m_green := a_green(a_green'high downto a_green'high - PIXEL_DEPTH + 1);
                m_blue := a_blue(a_blue'high downto a_blue'high - PIXEL_DEPTH + 1);

                data := m_red & m_green & m_blue;

                wr_enable <= '1';
                wr_addr <= addr;
                wr_data <= data;
            end if;

            if a_blank = '0' and border = '1' then
                o_red     <= (others => '0');
                o_green   <= (others => '1');
                o_blue    <= (others => '0');
            else
                o_red     <= a_red;
                o_green   <= a_green;
                o_blue    <= a_blue;
            end if;

            o_blank   <= a_blank;
            o_hsync   <= a_hsync;
            o_vsync   <= a_vsync;

            a_red     <= i_red;
            a_green   <= i_green;
            a_blue    <= i_blue;
            a_blank   <= i_blank;
            a_hsync   <= i_hsync;
            a_vsync   <= i_vsync;
            
            -- Border around the displayable area
            border <= '0';
--            if unsigned(x) = 0 or
--               unsigned(x) = 127 or
--               unsigned(x) = 639 or
--               unsigned(y) = 0 or
--               unsigned(y) = 31 or
--               unsigned(y) = 479 then
--                border <= '1';
--            end if;

            -- Working out where we are in the screen..
            if i_blank = '1' and i_vsync /= a_vsync then
                y <= (others => '0');
            end if;

            if i_blank = '0' then
                x <= std_logic_vector(unsigned(x) + 1);
            end if;

            -- Start of the blanking interval?
            if a_blank = '0' and i_blank = '1' then
                y <= std_logic_vector(unsigned(y) + 1);
                x <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;

