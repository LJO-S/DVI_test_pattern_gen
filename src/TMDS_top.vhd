library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity TMDS_top is
    port (
        reset : in std_logic;

        i_TMDS_clk : in std_logic;
        i_pixclk   : in std_logic;

        temp : out std_logic;

        o_TMDS     : out std_logic_vector(2 downto 0);
        o_TMDS_clk : out std_logic;
        o_HDMI_HPD : out std_logic
    );
end entity TMDS_top;

architecture rtl of TMDS_top is
    signal r_counter_X : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC     : std_logic            := '0';
    signal r_VSYNC     : std_logic            := '0';
    signal r_draw      : std_logic            := '0';

    type t_video is array (0 to 2) of unsigned(7 downto 0);

    signal r_video      : t_video                      := (others => (others => '0'));
    signal r_decr       : std_logic_vector(2 downto 0) := (others => '0');
    signal r_decrement  : std_logic                    := '0';
    signal r_speed      : std_logic_vector(2 downto 0) := "001";
    signal r_video_cntr : unsigned(15 downto 0)        := (others => '0');
    signal r_speed_cntr : unsigned(15 downto 0)        := (others => '0');

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
    temp       <= r_vsync;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Creating a 640x480p window
    p_gen_video_frame : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
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
    p_video_pattern : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            if (r_video_cntr = 5000) then
                r_video_cntr <= (others => '0');
                for i in 0 to 2 loop
                    r_video(i) <= r_video(i) + 1;
                end loop;
            else
                r_video_cntr <= r_video_cntr + 1;
            end if;
            --r_speed_cntr <= r_speed_cntr + 1;
            ------------------------------------------------------------
            ----if (r_speed_cntr = 50000) then
            --if (r_speed_cntr = 4000) then
            --    if (r_speed = "100") or (r_speed = "000") then
            --        r_speed <= "001";
            --    else
            --        r_speed <= r_speed(1 downto 0) & '0';
            --    end if;
            --end if;
            --------------------------------------------------------------
            ----if (r_video_cntr = 25000) then
            --if (r_video_cntr = 2000) then
            --    for i in 0 to 2 loop
            --        if (r_video(i) = x"FF") or (r_video(i) = 0) then
            --            r_decr(i) <= not r_decr(i);
            --        end if;
            --        ---------------
            --        if (r_decr(i) = '1') then
            --            r_video(i) <= (r_video(i) - 10) when r_speed(i) = '1' else
            --            (r_video(i) - 1);
            --        else
            --            r_video(i) <= (r_video(i) + 10) when r_speed(i) = '1' else
            --            (r_video(i) + 1);
            --        end if;
            --    end loop;
            --end if;
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- TMDS encoders
    TMDS_encoder_inst_0 : entity work.TMDS_encoder
        port map
        (
            clk          => i_pixclk,
            i_video_en   => r_draw,
            i_CD         => "00",
            i_video_data => std_logic_vector(r_video(0)),
            o_TMDS       => w_TMDS_red
        );

    TMDS_encoder_inst_1 : entity work.TMDS_encoder
        port map
        (
            clk          => i_pixclk,
            i_video_en   => r_draw,
            i_CD         => "00",
            i_video_data => std_logic_vector(r_video(1)),
            o_TMDS       => w_TMDS_grn
        );

    TMDS_encoder_inst_2 : entity work.TMDS_encoder
        port map
        (
            clk          => i_pixclk,
            i_video_en   => r_draw,
            i_CD         => r_VSYNC & r_HSYNC,
            i_video_data => std_logic_vector(r_video(2)),
            o_TMDS       => w_TMDS_blu
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- TMDS shift-out registers
    process (i_TMDS_clk)
    begin
        if rising_edge(i_TMDS_clk) then
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
                r_TMDS_shift_red <= '0' & r_TMDS_shift_red(9 downto 1);
                r_TMDS_shift_grn <= '0' & r_TMDS_shift_red(9 downto 1);
                r_TMDS_shift_blu <= '0' & r_TMDS_shift_red(9 downto 1);
            end if;
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Combinatorial
    o_HDMI_HPD <= '1';
    o_TMDS_clk <= i_pixclk;
    o_TMDS(2)  <= r_TMDS_shift_red(0);
    o_TMDS(1)  <= r_TMDS_shift_grn(0);
    o_TMDS(0)  <= r_TMDS_shift_blu(0);
    --------------------------------------------------------------------
    --------------------------------------------------------------------
end architecture;