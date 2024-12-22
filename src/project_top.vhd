library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_top is
    port (
        clk : in std_logic; -- 125 MHz clk

        i_pattern_0 : in std_logic;
        i_pattern_1 : in std_logic;
        i_pattern_2 : in std_logic;
        i_pattern_3 : in std_logic;

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
    signal w_pixclk   : std_logic;
    signal w_TMDS_clk : std_logic;
    signal w_HDMI_HPD : std_logic;

    signal w_pattern_0_db : std_logic;
    signal w_pattern_1_db : std_logic;
    signal w_pattern_2_db : std_logic;
    signal w_pattern_3_db : std_logic;
    signal w_counter_X    : unsigned(9 downto 0);
    signal w_counter_Y    : unsigned(9 downto 0);
    signal w_HSYNC        : std_logic;
    signal w_VSYNC        : std_logic;
    signal w_draw         : std_logic;
    signal w_video_red    : std_logic_vector(7 downto 0);
    signal w_video_grn    : std_logic_vector(7 downto 0);
    signal w_video_blu    : std_logic_vector(7 downto 0);
    signal w_temp         : unsigned(6 downto 0);

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
            o_pixclk => w_pixclk,
            o_TMDS_clk => w_TMDS_clk
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    TMDS_top_inst : entity work.TMDS_top
        port map
        (
            i_TMDS_clk  => w_TMDS_clk,
            i_pixclk    => w_pixclk,
            i_HSYNC     => w_HSYNC,
            i_VSYNC     => w_VSYNC,
            i_draw      => w_draw,
            i_video_red => w_video_red,
            i_video_grn => w_video_grn,
            i_video_blu => w_video_blu,
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
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    PB_debounce_inst_0 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_pixclk,
            i_PB          => i_pattern_0,
            o_PB_debounce => w_pattern_0_db
        );
    PB_debounce_inst_1 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_pixclk,
            i_PB          => i_pattern_1,
            o_PB_debounce => w_pattern_1_db
        );
    PB_debounce_inst_2 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_pixclk,
            i_PB          => i_pattern_2,
            o_PB_debounce => w_pattern_2_db
        );
    PB_debounce_inst_3 : entity work.PB_debounce
        port map
        (
            i_CLK         => w_pixclk,
            i_PB          => i_pattern_3,
            o_PB_debounce => w_pattern_3_db
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