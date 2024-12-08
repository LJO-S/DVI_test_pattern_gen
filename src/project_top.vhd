library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity project_top is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        o_TMDS     : out std_logic_vector(2 downto 0);
        o_pixclk   : out std_logic;
        o_HDMI_HPD : out std_logic
    );
end entity project_top;

architecture rtl of project_top is
    signal w_pixclk    : std_logic            := '0';
    signal w_clk_TMDS  : std_logic            := '0';
    signal r_counter_X : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC     : std_logic            := '0';
    signal r_VSYNC     : std_logic            := '0';
    signal r_draw      : std_logic            := '0';

begin
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Creating a 640x480p window
    p_gen_video_frame : process (w_pixclk)
    begin
        if rising_edge(w_pixclk) then
            if (r_counter_X = 799) then
                r_counter_X <= (others => '0');
                if (r_counter_Y = 524) then
                    r_counter_Y <= (others => '0');
                else
                    r_counter_Y <= r_counter_Y + 1;
                end if;
            else
                r_counter_X <= r_counter_X + 1;
            end if;

            if (r_counter_X < 640) and (r_counter_Y < 480) then
                r_draw <= '1';
            else
                r_draw <= '0';
            end if;

            -- Notice how these are inverted compared to regular HS/VS signals
            -- A HI signal notifies the TMDS_encoder that we're syncing,
            -- instead of turning off the electron beam in a CRT monitor
            r_HSYNC <= '1' when ((r_counter_X >= 656) and (r_counter_X < 752)) else
                '0';
            r_VSYNC <= '1' when ((r_counter_Y >= 490) and (r_counter_Y < 492)) else
                '0';
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    p_video_pattern : process (w_pixclk)
    begin
        if rising_edge(w_pixclk) then
            
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Combinatorial
    o_HDMI_HPD <= '1';
    --------------------------------------------------------------------
    --------------------------------------------------------------------
end architecture;