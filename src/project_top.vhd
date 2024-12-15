library ieee;
use ieee.std_logic_1164.all;


entity project_top is
    port (
        clk : in std_logic; -- 125 MHz clk

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
    -- TODO REMOVE
    --clk_wiz_inst : entity work.clk_wiz_wrapper
    --    port map
    --    (
    --        i_CLK      => clk,
    --        o_pixclk => w_pixclk,
    --        o_TMDS_clk => w_TMDS_clk
    --    );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    TMDS_top_inst : entity work.TMDS_top
        port map
        (
            i_TMDS_clk => w_TMDS_clk,
            i_pixclk   => w_pixclk,
            temp       => open,
            o_TMDS     => w_TMDS,
            o_TMDS_clk => w_TMDS_out_clk,
            o_HDMI_HPD => w_HDMI_HPD
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