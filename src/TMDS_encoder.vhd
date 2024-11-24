library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TMDS_encoder is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        i_video_data : out std_logic_vector(7 downto 0) := (others => '0');
        i_ctrl_data  : out std_logic_vector(1 downto 0);
        i_video_en   : out std_logic;

        o_TMDS : out std_logic_vector(9 downto 0)
    );
end entity TMDS_encoder;

architecture rtl of TMDS_encoder is
    signal r_no_ones  : unsigned(3 downto 0)         := (others => '0');
    signal r_XOR_XNOR : std_logic                    := '0';
    signal q_m        : std_logic_vector(8 downto 0) := (others => '0');
begin
    -- 1. Need to check how many ones we have in video_data:
    -- 2. Need to check DC bias
    -- 3. Encode
    
    --for i in 0 to 7 loop
    --    r_no_ones <= r_no_ones + unsigned(i_video_data(i));
    --end loop;

    wire [3 : 0] Nb1s = VD[0] + VD[1] + VD[2] + VD[3] + VD[4] + VD[5] + VD[6] + VD[7];
    wire xnor = (Nb1s > 4'd4) | | (Nb1s == 4'd4 & & VD[0] == 1'b0);
    wire [8 : 0] q_m = {~xnor, q_m[6 : 0] ^ VD[7 : 1] ^ {7{xnor}}, VD[0]};

end architecture;