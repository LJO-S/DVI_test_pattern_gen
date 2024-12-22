-- Galois LFSR Pseudo-random Number Generator
-- The 8-bit LFSR uses the polynomial x^8 + x^6 + x^5 + x^4 + 1.
-- Output is on the right-most bit.

library ieee;
use ieee.std_logic_1164.all;

entity galois_lfsr is
    port (
        i_pixclk : in std_logic;
        i_en     : in std_logic;
        o_lfsr   : out std_logic_vector(7 downto 0)
    );
end entity galois_lfsr;

architecture rtl of galois_lfsr is
    --signal r_lfsr : std_logic_vector(8 downto 1) := x"80";

    signal w_poly    : std_logic_vector(32 downto 1) := x"80000057";
    signal w_mask    : std_logic_vector(32 downto 1) := (others => '0');
    signal r_lfsr    : std_logic_vector(32 downto 1) := x"80000000";
    signal r_counter : integer range 0 to 250_000    := 0;

begin

    g_mask : for i in 32 downto 1 generate
        w_mask(i) <= r_lfsr(1) and w_poly(i);
    end generate;

    p_lfsr : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            if (i_en = '1') then
                if (r_counter = 250_000) then
                    -- r_lfsr(32) <= 0 xor r_lfsr(1) = r_lfsr(1);
                    -- r_lfsr(31) <= r_lfsr(32);
                    -- r_lfsr(30) <= r_lfsr(31);
                    -- r_lfsr(29) <= r_lfsr(30);
                    -- ...
                    -- r_lfsr(2) <= r_lfsr(3);
                    -- r_lfsr(1) <= r_lfsr(2);
                    r_lfsr <= ('0' & r_lfsr(r_lfsr'left downto 2)) xor w_mask;
                else
                    r_counter <= r_counter + 1;
                end if;
            else
                r_counter <= 0;
                r_lfsr    <= x"DEADBEEF";
            end if;
        end if;
    end process;

    o_lfsr <= r_lfsr(8 downto 1);
end architecture;