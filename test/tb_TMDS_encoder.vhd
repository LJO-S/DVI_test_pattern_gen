
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
library vunit_lib;
context vunit_lib.vunit_context;

entity TMDS_encoder_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of TMDS_encoder_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    
    -- Generics
    -- Ports
    signal clk          : std_logic := '0';
    signal i_video_en   : std_logic := (others => '0') ;
    signal i_video_data : std_logic_vector(7 downto 0);
    signal o_TMDS       : std_logic_vector(9 downto 0);
begin

    TMDS_encoder_inst : entity work.TMDS_encoder
        port map
        (
            clk          => clk,
            i_video_en   => i_video_en,
            i_video_data => i_video_data,
            o_TMDS       => o_TMDS
        );
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("test_alive") then
                info("Hello world test_alive");
                wait for 100 * clk_period;
                test_runner_cleanup(runner);

            elsif run("0_ones_input_data") then
                wait for 1 * clk_period;
                wait until clk = '1';
                i_video_en <= '1';
                wait for 30*clk_period;
                test_runner_cleanup(runner);
            elsif run("1_ones_input_data") then
                wait for 1 * clk_period;
                wait until clk = '1';
                i_video_en <= '1';
                i_video_data(7 downto 1) <= (others => '0') ;
                i_video_data(0) <= '1'; 
                wait for 30*clk_period;
                test_runner_cleanup(runner);
            elsif run("4_ones_input_data") then
                wait for 1 * clk_period;
                wait until clk = '1';
                i_video_en <= '1';
                i_video_data <= "01010101";
                wait for 30*clk_period;
                test_runner_cleanup(runner);
            elsif run("8_ones_input_data") then
                wait for 1 * clk_period;
                wait until clk = '1';
                i_video_en <= '1';
                i_video_data <= (others => '1');
                wait for 30*clk_period;
                test_runner_cleanup(runner);
            elsif run("subsequent_input_data") then
                wait for 1 * clk_period;
                wait until clk = '1';
                i_video_en <= '1';
                i_video_data <= "00000001";
                wait for 4*clk_period;
                i_video_data <= "00000010";
                wait for 4*clk_period;
                i_video_data <= "00000011";
                wait for 4*clk_period;
                i_video_data <= "00000110";
                wait for 4*clk_period;
                i_video_data <= "01010101";
                wait for 4*clk_period;
                i_video_data <= "11111110";
                wait for 4*clk_period;
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;

    clk <= not clk after clk_period/2;

end;