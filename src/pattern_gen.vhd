library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern_generator is
    port (
        i_pixclk : in std_logic;

        i_pattern_0_db : in std_logic;
        i_pattern_1_db : in std_logic;
        i_pattern_2_db : in std_logic;
        i_pattern_3_db : in std_logic;

        o_counter_X : out unsigned(9 downto 0);
        o_counter_Y : out unsigned(9 downto 0);

        o_video_red : out std_logic_vector(7 downto 0);
        o_video_grn : out std_logic_vector(7 downto 0);
        o_video_blu : out std_logic_vector(7 downto 0)
    );
end entity pattern_generator;

architecture rtl of pattern_generator is
    type t_state is (IDLE, pattern_0, pattern_1, pattern_2, pattern_3);

    signal s_state : t_state := IDLE;

    signal w_button_press : std_logic := '0';

    signal r_counter_X : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y : UNSIGNED(9 downto 0) := (others => '0');

    signal r_life_count : std_logic_vector(i_life_count'left downto 0) := (others => '0');
    signal r_ROM_data   : std_logic_vector(7 downto 0)                 := (others => '0');
    signal r_bit_draw   : std_logic                                    := '0';
    signal r_ROM_addr   : std_logic_vector(7 downto 0);

begin
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    -- Concurrent assignments
    w_button_press <= i_pattern_0_db or i_pattern_1_db or i_pattern_2_db or i_pattern_3_db;
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    p_video_draw : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            if (r_counter_X = 799) then
                r_counter_X <= (others => '0');
                if (r_counter_Y = 524) then
                    r_counter_Y <= (others => '0');
                else
                    r_counter_Y <= r_counter_Y + 1;
                end if;
            else
                r_counter_X <= r_counter_X + 1;
            end if;
        end if;
    end process p_video_draw;
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    p_pattern_state : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            case s_state is
                    ----------------------------------------
                when IDLE =>
                    if (i_pattern_0_db) then
                        s_state <= pattern_0;
                    elsif (i_pattern_1_db) then
                        s_state <= pattern_1;
                    elsif (i_pattern_2_db) then
                        s_state <= pattern_2;
                    elsif (i_pattern_3_db) then
                        s_state <= pattern_3;
                    else
                        s_state <= IDLE;
                    end if;
                    ----------------------------------------
                when pattern_0 =>
                    if (w_button_press) and (not i_pattern_0_db) then
                        s_state <= IDLE;
                    end if;
                    ----------------------------------------
                when pattern_1 =>
                    if (w_button_press) and (not i_pattern_1_db) then
                        s_state <= IDLE;
                    end if;
                    ----------------------------------------
                when pattern_2 =>
                    if (w_button_press) and (not i_pattern_2_db) then
                        s_state <= IDLE;
                    end if;
                    ----------------------------------------
                when pattern_3 =>
                    if (w_button_press) and (not i_pattern_3_db) then
                        s_state <= IDLE;
                    end if;
                    ----------------------------------------
                when others =>
                    s_state <= IDLE;
                    ----------------------------------------
            end case;
        end if;
    end process p_pattern_state;
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    -- Pattern Gen
    -- TODO:
    -- 1. Sweden Flag
    -- 2. Smiley Face
    -- 3. Text
    -- 4. Test pattern (LFSR)

    -- 1. 
    p_pattern_video : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            if (s_state = pattern_0) then
                -- Flag of Sweden
                if (r_counter_X(r_counter_X'left downto 5) >= 7 and r_counter_X(r_counter_X'left downto 5) < 10) or
                    (r_counter_Y(r_counter_Y'left downto 5) >= 7 and r_counter_Y(r_counter_Y'left downto 5) < 10) then
                    o_video_blu <= (others => '1');
                    o_video_red <= (others => '0');
                    o_video_grn <= (others => '1');
                else
                    o_video_blu <= (others => '1');
                    o_video_red <= (others => '0');
                    o_video_grn <= (others => '0');
                end if;
            elsif (s_state = pattern_1) then
                -- Smiley Face

            elsif (s_state = pattern_2) then
                -- Text

            elsif (s_state = pattern_3) then
                -- LFSR random generator (to look like noise) 
                
            else
                o_video_blu <= (others => '0');
                o_video_red <= (others => '0');
                o_video_grn <= (others => '0');
            end if;
        end if;
    end process p_pattern_video;
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    -- BRAM
    -- ROM
    -- 1:1 tile scaling = 8x16 ROM 
    p_ROM : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            case r_ROM_addr is
                    -- L
                when x"00" => r_ROM_data <= "00000000";
                when x"01" => r_ROM_data <= "00000000";
                when x"02" => r_ROM_data <= "00001111";
                when x"03" => r_ROM_data <= "00111111";
                when x"04" => r_ROM_data <= "01111111";
                when x"05" => r_ROM_data <= "11111001";
                when x"06" => r_ROM_data <= "11111111";
                when x"07" => r_ROM_data <= "11111111";
                when x"08" => r_ROM_data <= "11111001";
                when x"09" => r_ROM_data <= "01111100";
                when x"0A" => r_ROM_data <= "00011111";
                when x"0B" => r_ROM_data <= "00001111";
                when x"0C" => r_ROM_data <= "00000000";
                when x"0D" => r_ROM_data <= "00000000";
                when x"0E" => r_ROM_data <= "00000000";
                when x"0F" => r_ROM_data <= "00000000";
                    -- I
                when x"10" => r_ROM_data <= "00000000";
                when x"11" => r_ROM_data <= "00000000";
                when x"12" => r_ROM_data <= "11110000";
                when x"13" => r_ROM_data <= "11111100";
                when x"14" => r_ROM_data <= "11111110";
                when x"15" => r_ROM_data <= "10011111";
                when x"16" => r_ROM_data <= "11111111";
                when x"17" => r_ROM_data <= "11111111";
                when x"18" => r_ROM_data <= "10011111";
                when x"19" => r_ROM_data <= "00111110";
                when x"1A" => r_ROM_data <= "11111000";
                when x"1B" => r_ROM_data <= "11110000";
                when x"1C" => r_ROM_data <= "00000000";
                when x"1D" => r_ROM_data <= "00000000";
                when x"1E" => r_ROM_data <= "00000000";
                when x"1F" => r_ROM_data <= "00000000";
                    -- others
                when others => r_ROM_data <= (others => '0');
            end case;
        end if;
    end process;

    ----------------------------------------------------------------
    ----------------------------------------------------------------
    
end architecture;