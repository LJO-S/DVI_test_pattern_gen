-- Galois LFSR Pseudo-random Number Generator
-- The 8-bit LFSR uses the polynomial x^8 + x^6 + x^5 + x^4 + 1.
-- Output is on the right-most bit.

library ieee;
use ieee.std_logic_1164.all;

entity galois_lfsr is
    port (
        i_pixclk   : in std_logic;
        
        o_lfsr   : out std_logic_vector(7 downto 0)
    );
end entity galois_lfsr;

architecture rtl of galois_lfsr is
    signal r_lfsr : std_logic_vector(8 downto 1) := x"80";
        
begin
    process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            r_lfsr(8) <= r_lfsr(1); -- Feedback
            r_lfsr(7) <= r_lfsr(8);
            r_lfsr(6) <= r_lfsr(7) xor r_lfsr(1);
            r_lfsr(5) <= r_lfsr(6) xor r_lfsr(1);
            r_lfsr(4) <= r_lfsr(5) xor r_lfsr(1);
            r_lfsr(3) <= r_lfsr(4);
            r_lfsr(2) <= r_lfsr(3);
            r_lfsr(1) <= r_lfsr(2);
        end if;
    end process;
    o_lfsr <= r_lfsr(8 downto 1);

end architecture;