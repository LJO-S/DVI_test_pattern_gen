
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity galois_lfsr_tb is
  generic (
    runner_cfg : string
  );
end;

architecture bench of galois_lfsr_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal i_pixclk : std_logic := '0';
  signal i_en : std_logic := '1';
  signal o_lfsr : std_logic_vector(7 downto 0);
begin

  galois_lfsr_inst : entity work.galois_lfsr
  port map (
    i_pixclk => i_pixclk,
    i_en => i_en,
    o_lfsr => o_lfsr
  );
  main : process
  begin
    test_runner_setup(runner, runner_cfg);
    while test_suite loop
      if run("basic_wait") then
        info("Running basic_wait");
        wait for 300 * clk_period;
        test_runner_cleanup(runner);
      end if;
    end loop;
  end process main;

  i_pixclk <= not i_pixclk after clk_period/2;

end;