library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.breakout_pkg.all;

entity project_top is
    port (
        clk : in std_logic; -- 125 MHz clk

        i_LEFT       : in std_logic;
        i_RIGHT      : in std_logic;
        i_GAME_START : in std_logic;

        --o_HDMI_HPD : out std_logic;

        o_TMDS_clk_p : out std_logic;
        o_TMDS_clk_n : out std_logic;

        o_video_0_p : out std_logic;
        o_video_0_n : out std_logic;

        o_video_1_p : out std_logic;
        o_video_1_n : out std_logic;

        o_video_2_p : out std_logic;
        o_video_2_n : out std_logic
    );
end entity project_top;

architecture rtl of project_top is
    constant c_VIDEO_WIDTH : integer := 8;
    constant c_TOTAL_COLS  : integer := 800;
    constant c_TOTAL_ROWS  : integer := 525;
    constant c_ACTIVE_COLS : integer := 640;
    constant c_ACTIVE_ROWS : integer := 480;

    signal w_pixclk   : std_logic;
    signal w_TMDS_clk : std_logic;
    signal w_HDMI_HPD : std_logic;

    signal w_LEFT                 : std_logic;
    signal w_RIGHT                : std_logic;
    signal w_GAME_START           : std_logic;
    signal w_HSYNC_pre_porch      : std_logic;
    signal w_VSYNC_pre_porch      : std_logic;
    signal w_video_red_pre_porch  : std_logic_vector(7 downto 0);
    signal w_video_grn_pre_porch  : std_logic_vector(7 downto 0);
    signal w_video_blu_pre_porch  : std_logic_vector(7 downto 0);
    signal w_HSYNC_breakout       : std_logic;
    signal w_VSYNC_breakout       : std_logic;
    signal w_HSYNC_post_porch     : std_logic;
    signal w_VSYNC_post_porch     : std_logic;
    signal w_video_red_post_porch : std_logic_vector(7 downto 0);
    signal w_video_grn_post_porch : std_logic_vector(7 downto 0);
    signal w_video_blu_post_porch : std_logic_vector(7 downto 0);

    signal w_HSYNC     : std_logic;
    signal w_VSYNC     : std_logic;
    signal w_draw      : std_logic;
    signal w_video_red : std_logic_vector(7 downto 0);
    signal w_video_grn : std_logic_vector(7 downto 0);
    signal w_video_blu : std_logic_vector(7 downto 0);
    signal w_temp      : unsigned(6 downto 0);

    signal w_video_0_p : std_logic;
    signal w_video_0_n : std_logic;

    signal w_video_1_p : std_logic;
    signal w_video_1_n : std_logic;

    signal w_video_2_p : std_logic;
    signal w_video_2_n : std_logic;

    signal w_TMDS_out_clk   : std_logic;
    signal w_TMDS_out_clk_p : std_logic;
    signal w_TMDS_out_clk_n : std_logic;

    signal w_TMDS : std_logic_vector(2 downto 0);
begin
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    clk_wiz_inst : entity work.clk_wiz_wrapper
        port map
        (
            i_CLK      => clk,
            o_pixclk   => w_pixclk,
            o_TMDS_clk => w_TMDS_clk
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    TMDS_top_inst : entity work.TMDS_top
        port map
        (
            i_TMDS_clk  => w_TMDS_clk,
            i_pixclk    => w_pixclk,
            i_HSYNC     => not w_HSYNC_post_porch,
            i_VSYNC     => not w_VSYNC_post_porch,
            i_draw      => w_draw,
            i_video_red => w_video_red_post_porch,
            i_video_grn => w_video_grn_post_porch,
            i_video_blu => w_video_blu_post_porch,
            temp        => open,
            o_TMDS      => w_TMDS,
            o_TMDS_clk  => w_TMDS_out_clk,
            o_HDMI_HPD  => w_HDMI_HPD
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    obufds_top_inst_0 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(0),
            d0_out    => w_video_0_p,
            d0_out_ob => w_video_0_n
        );

    obufds_top_inst_1 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(1),
            d0_out    => w_video_1_p,
            d0_out_ob => w_video_1_n
        );

    obufds_top_inst_2 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(2),
            d0_out    => w_video_2_p,
            d0_out_ob => w_video_2_n
        );

    obufds_top_inst_3 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS_out_clk,
            d0_out    => w_TMDS_out_clk_p,
            d0_out_ob => w_TMDS_out_clk_n
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    /*
    pattern_generator_inst : entity work.pattern_generator
        port map
        (
            i_pixclk       => w_pixclk,
            i_pattern_0_db => w_pattern_0_db,
            i_pattern_1_db => w_pattern_1_db,
            i_pattern_2_db => w_pattern_2_db,
            i_pattern_3_db => w_pattern_3_db,
            o_counter_X    => open,
            o_counter_Y    => open,
            o_HSYNC        => w_HSYNC,
            o_VSYNC        => w_VSYNC,
            o_draw         => w_draw,
            o_video_red    => w_video_red,
            o_video_grn    => w_video_grn,
            o_video_blu    => w_video_blu,
            temp           => open
        );
    */

    -- TODO 
    -- 1. Assign generics ports
    -- 2. Port map output from sync_porch into TMDS_top
    -- 3. Fix color output to match our 8-bit instead of 4-bit (g_VIDEO_WIDTH)
    -- 4. Remember to invert HSYNC/VSYNC into TMDS
    -- 5. Fix i_draw to enable when we want in SYNC_PORCH
    breakout_top_inst : entity work.breakout
        generic map(
            g_VIDEO_WIDTH     => c_VIDEO_WIDTH,
            g_TOTAL_COLS      => c_TOTAL_COLS,
            g_TOTAL_ROWS      => c_TOTAL_ROWS,
            g_ACTIVE_COLS     => c_ACTIVE_COLS,
            g_ACTIVE_ROWS     => c_ACTIVE_ROWS,
            g_PLAYER_paddle_Y => c_PLAYER_paddle_Y
        )
        port map
        (
            i_CLK        => w_pixclk,
            i_HSYNC      => w_HSYNC_breakout, -- from SYNC_PULSE
            i_VSYNC      => w_VSYNC_breakout,
            i_RIGHT      => w_RIGHT,
            i_LEFT       => w_LEFT,
            i_game_start => w_game_start,
            o_HSYNC      => w_HSYNC_pre_porch, -- into porch
            o_VSYNC      => w_VSYNC_pre_porch,
            o_RED_VIDEO  => w_video_red_pre_porch, -- into porch
            o_GRN_VIDEO  => w_video_grn_pre_porch,
            o_BLU_VIDEO  => w_video_blu_pre_porch
        );

    -- INTO BREAKOUT
    VGA_sync_pulses_inst : entity work.VGA_sync_pulses
        generic map(
            g_TOTAL_COLS  => c_TOTAL_COLS,
            g_TOTAL_ROWS  => c_TOTAL_ROWS,
            g_ACTIVE_ROWS => c_ACTIVE_ROWS,
            g_ACTIVE_COLS => c_ACTIVE_COLS
        )
        port map
        (
            i_CLK       => w_pixclk,
            o_row_count => open,
            o_col_count => open,
            o_HSYNC     => w_HSYNC_breakout,
            o_VSYNC     => w_VSYNC_breakout
        );

    -- INTO TMDS_encoder
    VGA_sync_porch_inst : entity work.VGA_sync_porch
        generic map(
            g_VIDEO_WIDTH => c_VIDEO_WIDTH,
            g_TOTAL_COLS  => c_TOTAL_COLS,
            g_TOTAL_ROWS  => c_TOTAL_ROWS,
            g_ACTIVE_COLS => c_ACTIVE_COLS,
            g_ACTIVE_ROWS => c_ACTIVE_ROWS
        )
        port map
        (
            i_CLK       => w_pixclk,
            i_HSYNC     => w_HSYNC_pre_porch,
            i_VSYNC     => w_VSYNC_pre_porch,
            o_HSYNC     => w_HSYNC_post_porch,
            o_VSYNC     => w_VSYNC_post_porch,
            i_RED_video => w_video_red_pre_porch,
            i_GRN_video => w_video_grn_pre_porch,
            i_BLU_video => w_video_blu_pre_porch,
            o_RED_video => w_video_red_post_porch,
            o_GRN_video => w_video_grn_post_porch,
            o_BLU_video => w_video_blu_post_porch,
            o_draw      => w_draw
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    PB_debounce_inst_0 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_pixclk,
            i_PB          => i_LEFT,
            o_PB_debounce => w_LEFT
        );
    PB_debounce_inst_1 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_pixclk,
            i_PB          => i_RIGHT,
            o_PB_debounce => w_RIGHT
        );
    PB_debounce_inst_2 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_pixclk,
            i_PB          => i_GAME_START,
            o_PB_debounce => w_GAME_START
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Outputs
    --o_HDMI_HPD <= w_HDMI_HPD;

    o_TMDS_clk_p <= w_TMDS_out_clk_p;
    o_TMDS_clk_n <= w_TMDS_out_clk_n;

    o_video_0_p <= w_video_0_p;
    o_video_0_n <= w_video_0_n;

    o_video_1_p <= w_video_1_p;
    o_video_1_n <= w_video_1_n;

    o_video_2_p <= w_video_2_p;
    o_video_2_n <= w_video_2_n;

end architecture;