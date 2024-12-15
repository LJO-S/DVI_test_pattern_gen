
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity SPmem_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of SPmem_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    -- Ports
    signal i_pixclk : std_logic                    := '0';
    signal i_addra  : std_logic_vector(5 downto 0) := (others => '0');
    signal i_dina   : std_logic_vector(7 downto 0) := (others => '0');
    signal i_wea    : std_logic                    := '0';
    signal i_ena    : std_logic                    := '1';
    signal o_douta  : std_logic_vector(7 downto 0);
begin

    SPmem_inst : entity work.SPmem
        port map
        (
            i_pixclk => i_pixclk,
            i_addra  => i_addra,
            i_dina   => i_dina,
            i_wea    => i_wea,
            i_ena    => i_ena,
            o_douta  => o_douta
        );
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("test_alive") then
                info("Hello world test_alive");
                wait for 100 * clk_period;
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;

    i_pixclk <= not i_pixclk after clk_period/2;

end;