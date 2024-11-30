library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- https://mjseemjdo.com/2021/04/02/tutorial-6-hdmi-display-output/

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
    signal w_XOR              : std_logic                    := '0';
    signal w_qm               : std_logic_vector(8 downto 0) := (others => '0');
    signal w_invert_qm        : std_logic                    := '0';
    signal w_balance          : signed(4 downto 0)           := (others => '0');
    signal w_balance_sign_eq  : std_logic                    := '0';
    signal w_balance_acc      : signed(4 downto 0)           := (others => '0');
    signal w_balance_acc_incr : signed(4 downto 0)           := (others => '0');
    signal w_balance_acc_new  : signed(4 downto 0)           := (others => '0');
    signal r_cntr             : integer range -8 to 8        := 0;
    signal w_TMDS_data        : std_logic_vector(9 downto 0) := (others => '0');
    signal w_balance_zero     : std_logic                    := '0';
    signal w_C1_C0            : std_logic_vector(1 downto 0) := (others => '0');

begin
    --------------------------------------------------------------------
    -- Combinatorial
    -- 1. Need to check how many ones we have in video_data:
    p_XOR_XNOR : process (all)
        variable v_number_of_zeros : UNSIGNED(3 downto 0) := (others => '0');
    begin
        v_number_of_zeros := (others => '0');
        for i in i_video_data'range loop
            v_number_of_zeros := v_number_of_zeros + i_video_data(i);
        end loop;
        if (v_number_of_zeros < 4) or ((v_number_of_zeros = 4) and (i_video_data(0) = '1')) then
            w_XOR <= '1'; -- XOR
        else
            w_XOR <= '0'; -- XNOR
        end if;
    end process p_XOR_XNOR;

    -- 2. Encode
    p_qm : process (all)
    begin
        if (w_XOR = '1') then
            w_qm <= '1' & (w_qm(6 downto 0) xor i_video_data(7 downto 1)) & i_video_data(0);
        else
            w_qm <= '0' & (w_qm(6 downto 0) xnor i_video_data(7 downto 1)) & i_video_data(0);
        end if;
    end process p_qm;

    -- 3. Need to check DC bias
    p_DC_bias : process (all)
    begin
        -----------------------
        w_balance <= (others => '0') - to_signed(4, w_balance'length); -- 4 zeros, 4 ones
        -- if balance == 0 it is balanced
        --    balance == -4 no ones
        --    balance == 4 no zeros
        for i in w_qm'range loop
            w_balance <= w_balance + w_qm(i);
        end loop;
        -----------------------
        if (w_balance = 0) or (w_balance_acc = 0) then
            w_invert_qm <= not w_qm(8);
        else
            w_invert_qm <= w_balance_sign_eq;
        end if;
        -----------------------
        if (w_balance = 0) or (w_balance_acc = 0) then
            w_balance_zero <= '1';
        else
            w_balance_zero <= '0';
        end if;
        -----------------------
        if (w_invert_qm = '1') then
            w_balance_acc_new <= signed('0' & w_balance_acc) - w_balance_acc_incr;
        else
            w_balance_acc_new <= w_balance_acc + w_balance_acc_incr;
        end if;
        -----------------------
    end process p_DC_bias;
    w_balance_sign_eq <= w_balance(w_balance'high) and w_balance_acc(w_balance_acc'high); -- might need extra bit for sign

    w_balance_acc_incr <= w_balance - ((w_qm(8) xor not w_balance_sign_eq) and not w_balance_zero); -- TODO

    w_TMDS_data <= w_invert_qm & w_qm(8) & (w_qm(7 downto 0) xor (others => w_invert_qm)); -- TODO

    -- 4. Output (clocked)
    process (clk)
    begin
        if rising_edge(clk) then
            if (i_video_en = '1') then
                o_TMDS        <= w_TMDS_data;
                w_balance_acc <= w_balance_acc_new;
            else
                w_balance_acc <= (others => '0');
                case w_C1_C0 is
                    when "00" =>
                        o_TMDS <= "1101010100";
                    when "01" =>
                        o_TMDS <= "0010101011";
                    when "10" =>
                        o_TMDS <= "0101010100";
                    when "11" =>
                        o_TMDS <= "1010101011";
                    when others =>
                        o_TMDS <= "1101010100"; -- 00 case
                end case;
            end if;
        end if;
    end process;

end architecture;