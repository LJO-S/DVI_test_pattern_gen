library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity project_top is
    port (
        clk   : in std_logic;
        reset : in std_logic
        
    );
end entity project_top;

architecture rtl of project_top is
    signal test : std_logic;
begin
process (clk)
begin
    if rising_edge(clk) then
        test <= '0';
    end if;
end process;
    

end architecture;