library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pattern_generator is
    port (
        i_pixclk : in std_logic;

        i_pattern_0_db : in std_logic;
        i_pattern_1_db : in std_logic;
        i_pattern_2_db : in std_logic;
        i_pattern_3_db : in std_logic;

        o_counter_X : out unsigned(9 downto 0);
        o_counter_Y : out unsigned(9 downto 0);
        o_HSYNC     : out std_logic;
        o_VSYNC     : out std_logic;
        o_draw      : out std_logic;
        o_video_red : out std_logic_vector(7 downto 0);
        o_video_grn : out std_logic_vector(7 downto 0);
        o_video_blu : out std_logic_vector(7 downto 0);

        temp : out unsigned(6 downto 0)
    );
end entity pattern_generator;

architecture rtl of pattern_generator is
    type t_state is (IDLE, pattern_0, pattern_1, pattern_2, pattern_3);

    signal s_state : t_state := IDLE;

    signal w_button_press : std_logic                    := '0';
    signal w_lfsr         : std_logic_vector(7 downto 0) := (others => '0');
    signal w_lfsr_en      : std_logic                    := '0';

    signal r_counter_X : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC     : std_logic            := '0';
    signal r_VSYNC     : std_logic            := '0';
    signal r_draw      : std_logic            := '0';

    signal w_smiley_en     : std_logic                    := '0';
    signal w_smiley_draw   : std_logic                    := '0';
    signal w_symbol_active : std_logic_vector(3 downto 0) := (others => '0');
    signal w_col_count_div : unsigned(6 downto 0);                            -- 40
    signal w_row_count_div : unsigned(6 downto 0);                            -- 30
    signal w_col_addr      : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X
    signal w_col_addr_d0   : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X
    signal w_col_addr_d1   : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X

    signal w_row_addr      : std_logic_vector(3 downto 0) := (others => '0'); -- 0-15 Y
    signal r_symbol_active : std_logic_vector(3 downto 0) := (others => '0');
    signal r_ROM_data      : std_logic_vector(7 downto 0) := (others => '0');
    signal r_bit_draw      : std_logic                    := '0';
    signal r_ROM_addr      : std_logic_vector(7 downto 0);

    signal w_mem_en            : std_logic                    := '0';
    signal r_mem_addr          : std_logic_vector(5 downto 0) := (others => '0');
    signal r_mem_dout          : std_logic_vector(7 downto 0) := (others => '0');
    signal w_mem_draw          : std_logic                    := '0';
    signal w_mem_symbol_active : unsigned(5 downto 0)         := (others => '0'); -- 0-63
    signal r_mem_bit_draw      : std_logic                    := '0';

begin
    --**************************************************************************************************
    --**************************************************************************************************
    galois_lfsr_inst : entity work.galois_lfsr
        port map
        (
            i_pixclk => i_pixclk,
            i_en     => w_lfsr_en,
            o_lfsr   => w_lfsr
        );

    -- TODO: 1 CLOCK CYCLE LATENCY ON DATA
    SPmem_inst : entity work.SPmem
        port map
        (
            i_pixclk => i_pixclk,
            i_addra  => r_mem_addr,
            i_dina => (others => '0'),
            i_wea    => '0',
            i_ena    => w_mem_en,
            o_douta  => r_mem_dout
        );
    --**************************************************************************************************
    --**************************************************************************************************
    -- Concurrent assignments 
    --
    o_draw      <= r_draw;
    o_HSYNC     <= r_HSYNC;
    o_VSYNC     <= r_VSYNC;
    o_counter_X <= r_counter_X;
    o_counter_Y <= r_counter_Y;

    --------------------------------------------------------------------
    w_button_press <= i_pattern_0_db or i_pattern_1_db or i_pattern_2_db or i_pattern_3_db;
    --------------------------------------------------------------------
    w_smiley_en <= '1' when (s_state = pattern_1) else
        '0';
    --------------------------------------------------------------------
    w_lfsr_en <= '1' when (s_state = pattern_3) else
        '0';
    --------------------------------------------------------------------
    -- 1:8 Tile scaling
    w_col_addr      <= std_logic_vector(r_counter_X(5 downto 3));
    w_row_addr      <= std_logic_vector(r_counter_Y(6 downto 3));
    w_col_count_div <= r_counter_X(r_counter_X'left downto 3);
    w_row_count_div <= r_counter_Y(r_counter_Y'left downto 3);
    --------------------------------------------------------------------
    w_smiley_draw <= '1' when (w_col_count_div >= 33) and (w_col_count_div <= 46)
        and (w_row_count_div >= 16) and (w_row_count_div <= 31) else
        '0';
    w_symbol_active <= x"1" when (w_col_count_div >= 40) and (w_col_count_div <= 47) else
        x"0";
    --------------------------------------------------------------------
    temp <= w_row_count_div;
    --**************************************************************************************************
    --**************************************************************************************************
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

            if (r_counter_X < 640) and (r_counter_Y < 480) then
                r_draw <= '1';
            else
                r_draw <= '0';
            end if;

            -- Notice how these are inverted compared to regular HS/VS signals
            -- A HI signal notifies the TMDS_encoder that we're syncing
            -- (instead of turning off the electron beam in a CRT monitor)
            r_HSYNC <= '1' when ((r_counter_X >= 656) and (r_counter_X < 752)) else
                '0';
            r_VSYNC <= '1' when ((r_counter_Y >= 490) and (r_counter_Y < 492)) else
                '0';
        end if;
    end process p_video_draw;
    --**************************************************************************************************
    --**************************************************************************************************
    p_pattern_state : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            case s_state is
                    --------------------------------------------------------------------
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
                    --------------------------------------------------------------------
                when pattern_0 =>
                    if (w_button_press) and (not i_pattern_0_db) then
                        s_state <= IDLE;
                    end if;
                    --------------------------------------------------------------------
                when pattern_1 =>
                    if (w_button_press) and (not i_pattern_1_db) then
                        s_state <= IDLE;
                    end if;
                    --------------------------------------------------------------------
                when pattern_2 =>
                    if (w_button_press) and (not i_pattern_2_db) then
                        s_state <= IDLE;
                    end if;
                    --------------------------------------------------------------------
                when pattern_3 =>
                    if (w_button_press) and (not i_pattern_3_db) then
                        s_state <= IDLE;
                    end if;
                    --------------------------------------------------------------------
                when others =>
                    s_state <= IDLE;
                    --------------------------------------------------------------------
            end case;
        end if;
    end process p_pattern_state;
    --**************************************************************************************************
    --**************************************************************************************************
    p_pattern_video : process (all)
    begin
        if (s_state = pattern_0) then
            -- Flag of Sweden
            if (r_counter_X(r_counter_X'left downto 5) >= 7 and r_counter_X(r_counter_X'left downto 5) < 10) or
                (r_counter_Y(r_counter_Y'left downto 4) >= 12 and r_counter_Y(r_counter_Y'left downto 4) <= 17) then
                o_video_blu                                                                              <= (others => '0');
                o_video_red                                                                              <= (others => '1');
                o_video_grn                                                                              <= (others => '1');
            else
                o_video_blu <= (others => '1');
                o_video_red <= (others => '0');
                o_video_grn <= (others => '0');
            end if;
        elsif (s_state = pattern_1) then
            -- Smiley Face (Use familiar ROM instantiation)
            o_video_blu <= (others => '0');
            o_video_red <= (others => r_bit_draw);
            o_video_grn <= (others => r_bit_draw);

        elsif (s_state = pattern_2) then
            -- Text (Use Xilinx template for single port BRAM instantiated with file)
            o_video_blu <= (others => r_mem_bit_draw);
            o_video_red <= (others => r_mem_bit_draw);
            o_video_grn <= (others => r_mem_bit_draw);

        elsif (s_state = pattern_3) then
            -- Galois LFSR Pseudo-random Noise Gen
            o_video_blu <= w_lfsr;
            o_video_grn <= w_lfsr;
            o_video_red <= w_lfsr;
        else
            o_video_blu <= (others => '0');
            o_video_red <= (others => '0');
            o_video_grn <= (others => '0');
        end if;
    end process p_pattern_video;
    --**************************************************************************************************
    --**************************************************************************************************
    -- X: 16-24(8)  32-40(8)   48-56(8)   64-72(8)
    -- Y: 24-40(16)
    -- SPmem logic
    w_mem_en <= '1' when (s_state = pattern_2) else
        '0';
    process (all)
    begin
        if ((w_row_count_div >= 32) and (w_row_count_div <= 47)) or
            ((w_row_count_div >= 16) and (w_row_count_div    <= 31)) then

            w_mem_draw <= '1';

            if (w_col_count_div >= 16 and w_col_count_div < 24) then
                -- T
                w_mem_symbol_active <= to_unsigned(63, w_mem_symbol_active'length);
            elsif (w_col_count_div >= 32 and w_col_count_div < 40) then
                -- E
                w_mem_symbol_active <= to_unsigned(47, w_mem_symbol_active'length);
            elsif (w_col_count_div >= 48 and w_col_count_div < 56) then
                -- S
                w_mem_symbol_active <= to_unsigned(31, w_mem_symbol_active'length);
            elsif (w_col_count_div >= 64 and w_col_count_div < 72) then
                -- T
                w_mem_symbol_active <= to_unsigned(15, w_mem_symbol_active'length);
            else
                -- NULL
                w_mem_symbol_active <= (others => '0');
                w_mem_draw          <= '0';
            end if;
        else
            -- NULL
            w_mem_symbol_active <= (others => '0');
            w_mem_draw          <= '0';
        end if;
    end process;
    --------------------------------------------------------------------
    process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            if (w_mem_en = '1') then
                r_mem_addr <= std_logic_vector(w_mem_symbol_active - unsigned(w_row_addr));

                if (w_mem_draw = '1') then
                    r_mem_bit_draw <= r_mem_dout(to_integer(unsigned(not w_col_addr)));
                else
                    r_mem_bit_draw <= '0';
                end if;
            else
                r_mem_bit_draw <= '0';
            end if;
        end if;
    end process;

    --**************************************************************************************************
    --**************************************************************************************************
    -- BRAM
    -- 1:1 tile scaling = 8x16 ROM 
    -- 1:4 tile scaling = 64x128
    p_ROM : process (i_pixclk)
    begin
        if rising_edge(i_pixclk) then
            if (w_smiley_en = '1') then
                w_col_addr_d0 <= w_col_addr;
                w_col_addr_d1 <= w_col_addr_d0;
                r_ROM_addr    <= w_symbol_active & w_row_addr;

                if (w_smiley_draw = '1') then
                    r_bit_draw <= r_ROM_data(to_integer(unsigned(not w_col_addr_d1)));
                else
                    r_bit_draw <= '0';
                end if;

                case r_ROM_addr is
                        -- L
                    when x"00" => r_ROM_data <= "00000000";
                    when x"01" => r_ROM_data <= "00000111";
                    when x"02" => r_ROM_data <= "00001111";
                    when x"03" => r_ROM_data <= "00011111";
                    when x"04" => r_ROM_data <= "00111101";
                    when x"05" => r_ROM_data <= "01111101";
                    when x"06" => r_ROM_data <= "01111101";
                    when x"07" => r_ROM_data <= "01111101";
                    when x"08" => r_ROM_data <= "01111111";
                    when x"09" => r_ROM_data <= "01111111";
                    when x"0A" => r_ROM_data <= "01110111";
                    when x"0B" => r_ROM_data <= "00110000";
                    when x"0C" => r_ROM_data <= "00011111";
                    when x"0D" => r_ROM_data <= "00001111";
                    when x"0E" => r_ROM_data <= "00000111";
                    when x"0F" => r_ROM_data <= "00000000";
                        -- I
                    when x"10" => r_ROM_data <= "00000000";
                    when x"11" => r_ROM_data <= "11100000";
                    when x"12" => r_ROM_data <= "11110000";
                    when x"13" => r_ROM_data <= "11111000";
                    when x"14" => r_ROM_data <= "10111100";
                    when x"15" => r_ROM_data <= "10111110";
                    when x"16" => r_ROM_data <= "10111110";
                    when x"17" => r_ROM_data <= "10111110";
                    when x"18" => r_ROM_data <= "11111110";
                    when x"19" => r_ROM_data <= "11111110";
                    when x"1A" => r_ROM_data <= "11101110";
                    when x"1B" => r_ROM_data <= "00001100";
                    when x"1C" => r_ROM_data <= "11111000";
                    when x"1D" => r_ROM_data <= "11110000";
                    when x"1E" => r_ROM_data <= "11100000";
                    when x"1F" => r_ROM_data <= "00000000";
                        -- others
                    when others => r_ROM_data <= (others => '0');
                end case;
            else
                r_ROM_data <= (others => '0');
            end if;
        end if;
    end process;
    --**************************************************************************************************
    --**************************************************************************************************
end architecture;