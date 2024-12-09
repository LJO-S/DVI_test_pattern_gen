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

    signal r_red_video  : unsigned(7 downto 0)  := (others => '0');
    signal r_grn_video  : unsigned(7 downto 0)  := (others => '0');
    signal r_blu_video  : unsigned(7 downto 0)  := (others => '0');
    signal r_red_decr   : std_logic             := '0';
    signal r_grn_decr   : std_logic             := '0';
    signal r_blu_decr   : std_logic             := '0';
    signal r_speed_incr : unsigned(1 downto 0)  := (others => '0');
    signal r_speed_cntr : unsigned(15 downto 0) := (others => '0');

    signal w_TMDS_red : std_logic_vector(9 downto 0) := (others => '0');
    signal w_TMDS_grn : std_logic_vector(9 downto 0) := (others => '0');
    signal w_TMDS_blu : std_logic_vector(9 downto 0) := (others => '0');

    signal r_TMDS_mod10      : unsigned(3 downto 0)         := (others => '0');
    signal r_TMDS_shift_red  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_grn  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_blu  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_load : std_logic                    := '0';
    -- TODO instantiate pll
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
            -- A HI signal notifies the TMDS_encoder that we're syncing
            -- (instead of turning off the electron beam in a CRT monitor)
            r_HSYNC <= '1' when ((r_counter_X >= 656) and (r_counter_X < 752)) else
                '0';
            r_VSYNC <= '1' when ((r_counter_Y >= 490) and (r_counter_Y < 492)) else
                '0';
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Video pattern generator
    -- TODO: se över detta
    p_video_pattern : process (w_pixclk)
    begin
        if rising_edge(w_pixclk) then
            ------------------------------------------------------------
            r_red_decr <= not r_red_decr when ((r_red_video = x"FF") or (r_red_video = 0)) else
                r_red_decr;
            r_grn_decr <= not r_grn_decr when ((r_grn_video = x"FF") or (r_grn_video = 0)) else
                r_grn_decr;
            r_blu_decr <= not r_blu_decr when ((r_blu_video = x"FF") or (r_blu_video = 0)) else
                r_blu_decr;
            ------------------------------------------------------------
            r_speed_cntr <= r_speed_cntr + 1;
            if (r_speed_cntr = x"FFFF") then
                ------------------------------------------------------------
                r_speed_incr <= r_speed_incr + 1;
                ------------------------------------------------------------
                if (r_speed_incr = 0) then
                    r_red_video <= (r_red_video - 10) when (r_red_decr = '1') else
                        (r_red_video + 10);
                else
                    r_red_video <= (r_red_video - 1) when (r_red_decr = '1') else
                        (r_red_video + 1);
                end if;
                ------------------------------------------------------------
                if (r_speed_incr = 1) then
                    r_grn_video <= (r_grn_video - 10) when (r_grn_decr = '1') else
                        (r_grn_video + 10);
                else
                    r_grn_video <= (r_grn_video - 1) when (r_grn_decr = '1') else
                        (r_grn_video + 1);
                end if;
                ------------------------------------------------------------
                if (r_speed_incr = 2) then
                    r_blu_video <= (r_blu_video - 10) when (r_blu_decr = '1') else
                        (r_grn_video + 10);
                else
                    r_blu_video <= (r_blu_video - 1) when (r_blu_decr = '1') else
                        (r_blu_video + 1);
                end if;
                ------------------------------------------------------------
            end if;
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- TMDS encoders
    TMDS_encoder_inst_0 : entity work.TMDS_encoder
        port map
        (
            clk          => w_pixclk,
            i_video_en   => r_draw,
            i_CD         => "00",
            i_video_data => r_red_video,
            o_TMDS       => o_TMDS
        );

    TMDS_encoder_inst_1 : entity work.TMDS_encoder
        port map
        (
            clk          => w_pixclk,
            i_video_en   => r_draw,
            i_CD         => "00",
            i_video_data => r_grn_video,
            o_TMDS       => o_TMDS
        );

    TMDS_encoder_inst_2 : entity work.TMDS_encoder
        port map
        (
            clk          => w_pixclk,
            i_video_en   => r_draw,
            i_CD         => r_VSYNC & r_HSYNC,
            i_video_data => r_blu_video,
            o_TMDS       => o_TMDS
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- TMDS shift-out registers
    process (w_clk_TMDS)
    begin
        if rising_edge(w_clk_TMDS) then
            if (r_TMDS_mod10 = 9) then
                r_TMDS_shift_load <= '1';
                r_TMDS_mod10      <= (others => '0');
            else
                r_TMDS_shift_load <= '0';
                r_TMDS_mod10      <= r_TMDS_mod10 + 1;
            end if;

            if (r_TMDS_shift_load = '1') then
                r_TMDS_shift_red <= w_TMDS_red;
                r_TMDS_shift_grn <= w_TMDS_grn;
                r_TMDS_shift_blu <= w_TMDS_blu;
            else
                -- TODO
                r_TMDS_shift_red <= XXX;
                r_TMDS_shift_grn <= XXX;
                r_TMDS_shift_blu <= XXX;
            end if;
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Combinatorial
    o_HDMI_HPD <= '1';
    --------------------------------------------------------------------
    --------------------------------------------------------------------
end architecture;