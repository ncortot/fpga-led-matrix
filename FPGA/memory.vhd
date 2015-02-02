-- Adafruit RGB LED Matrix Display Driver
-- Special memory for the framebuffer with separate read/write clocks
-- 
-- Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
-- This software is distributed under the terms of the MIT License shown below.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

-- For more information on how to infer RAMs on Altera devices see this page:
-- http://quartushelp.altera.com/current/mergedProjects/hdl/vhdl/vhdl_pro_ram_inferred.htm

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.rgbmatrix.all;

entity memory is
    port (
        wr_clk      : in  std_logic;
        wr_enable   : in  std_logic;
        wr_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        wr_data     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);

        rd_clk      : in  std_logic;
        rd_addr     : in  std_logic_vector(ADDR_WIDTH - 2 downto 0);
        rd_data     : out std_logic_vector(DATA_WIDTH * 2 - 1 downto 0)
    );
end memory;

architecture bhv of memory is
    -- Inferred RAM storage signal
    type ram is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal ram_block : ram;
begin

    -- Write process for the memory
    process(wr_clk, wr_enable, wr_data)
    begin
        if (rising_edge(wr_clk) and wr_enable = '1') then
          ram_block(conv_integer(wr_addr)) <= wr_data;
        end if;
    end process;
    
    -- Read process for the memory
    process(rd_clk, rd_addr)
        variable rd_data_up : std_logic_vector(DATA_WIDTH - 1 downto 0);
        variable rd_data_low : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        if (rising_edge(rd_clk)) then
            rd_data_up := ram_block(conv_integer("0" & rd_addr));
            rd_data_low := ram_block(conv_integer("1" & rd_addr));
            rd_data <= rd_data_up & rd_data_low;
        end if;
    end process;

end bhv;