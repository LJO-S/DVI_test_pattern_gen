
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity pattern_generator_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of pattern_generator_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    -- Ports
    signal i_pixclk       : std_logic := '0';
    signal i_pattern_0_db : std_logic := '0';
    signal i_pattern_1_db : std_logic := '0';
    signal i_pattern_2_db : std_logic := '0';
    signal i_pattern_3_db : std_logic := '0';
    signal o_counter_X    : unsigned(9 downto 0);
    signal o_counter_Y    : unsigned(9 downto 0);
    signal o_video_red    : std_logic_vector(7 downto 0);
    signal o_video_grn    : std_logic_vector(7 downto 0);
    signal o_video_blu    : std_logic_vector(7 downto 0);

    signal temp : UNSIGNED(6 downto 0) := (others => '0');
begin

    pattern_generator_inst : entity work.pattern_generator
        port map
        (
            i_pixclk       => i_pixclk,
            i_pattern_0_db => i_pattern_0_db,
            i_pattern_1_db => i_pattern_1_db,
            i_pattern_2_db => i_pattern_2_db,
            i_pattern_3_db => i_pattern_3_db,
            o_counter_X    => o_counter_X,
            o_counter_Y    => o_counter_Y,
            o_video_red    => o_video_red,
            o_video_grn    => o_video_grn,
            o_video_blu    => o_video_blu,
            temp           => temp
        );
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("state_switch") then
                wait until i_pixclk = '1';
                i_pattern_0_db <= '1';
                wait for 10 * clk_period;
                i_pattern_0_db <= '0';
                i_pattern_1_db <= '1';
                wait for 10 * clk_period;
                i_pattern_1_db <= '0';
                i_pattern_2_db <= '1';
                wait for 10 * clk_period;
                i_pattern_2_db <= '0';
                i_pattern_3_db <= '1';
                wait for 200 * clk_period;
                test_runner_cleanup(runner);
            elsif run("sweden") then
                wait until i_pixclk = '1';
                i_pattern_0_db <= '1';
                i_pattern_1_db <= '0';
                i_pattern_2_db <= '0';
                i_pattern_3_db <= '0';
                wait for 200 * clk_period;
                test_runner_cleanup(runner);
            elsif run("smiley") then
                wait until i_pixclk = '1';
                i_pattern_0_db <= '0';
                i_pattern_1_db <= '1';
                i_pattern_2_db <= '0';
                i_pattern_3_db <= '0';
                wait until temp = 60;
                test_runner_cleanup(runner);
            elsif run("text") then
                wait until i_pixclk = '1';
                i_pattern_0_db <= '0';
                i_pattern_1_db <= '0';
                i_pattern_2_db <= '1';
                i_pattern_3_db <= '0';
                wait until temp = 60;
                test_runner_cleanup(runner);
            elsif run("lfsr") then
                wait until i_pixclk = '1';
                i_pattern_0_db <= '0';
                i_pattern_1_db <= '0';
                i_pattern_2_db <= '0';
                i_pattern_3_db <= '1';
                wait for 200 * clk_period;
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;

    i_pixclk <= not i_pixclk after clk_period/2;

end;