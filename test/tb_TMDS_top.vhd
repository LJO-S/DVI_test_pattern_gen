
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
library vunit_lib;
context vunit_lib.vunit_context;

entity TMDS_top_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of TMDS_top_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    -- Ports
    signal reset      : std_logic := '0';
    signal i_pixclk   : std_logic := '0';
    signal i_TMDS_clk : std_logic := '0';
    signal temp       : std_logic := '0';
    signal o_TMDS     : std_logic_vector(2 downto 0);
    signal o_TMDS_clk : std_logic;
    signal o_pixclk   : std_logic;
    signal o_HDMI_HPD : std_logic;

    signal i_HSYNC     : std_logic                    := '0';
    signal i_VSYNC     : std_logic                    := '0';
    signal i_draw      : std_logic                    := '0';
    signal i_video_red : std_logic_vector(7 downto 0) := (others => '0');
    signal i_video_grn : std_logic_vector(7 downto 0) := (others => '0');
    signal i_video_blu : std_logic_vector(7 downto 0) := (others => '0');

    procedure wait_VSYNC (temp : in std_logic) is
    begin
        if (temp = '1') then
            wait until temp = '0';
        else
            wait until temp = '1';
            wait until temp = '0';
        end if;
    end procedure;
begin

    TMDS_top_inst : entity work.TMDS_top
        port map
        (
            i_TMDS_clk  => i_TMDS_clk,
            i_pixclk    => i_pixclk,
            i_HSYNC     => i_HSYNC,
            i_VSYNC     => i_VSYNC,
            i_draw      => i_draw,
            i_video_red => i_video_red,
            i_video_grn => i_video_grn,
            i_video_blu => i_video_blu,
            temp        => temp,
            o_TMDS      => o_TMDS,
            o_TMDS_clk  => o_TMDS_clk,
            o_HDMI_HPD  => o_HDMI_HPD
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("test_alive") then
                info("Hello world test_alive");
                wait for 100 * clk_period;
                test_runner_cleanup(runner);

            elsif run("wait_VSYNC") then
                wait for 10 * clk_period;
                wait_VSYNC(temp);
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;

    i_pixclk   <= not i_pixclk after clk_period/2;
    i_TMDS_clk <= not i_TMDS_clk after clk_period/8;

end;