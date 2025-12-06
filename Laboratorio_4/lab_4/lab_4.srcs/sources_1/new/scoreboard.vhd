library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scoreboard is
    Port (
        clk : in STD_LOGIC; -- 100 MHz
        btnH : in STD_LOGIC; -- Sumar HOME (BTNU M18)
        btnG : in STD_LOGIC; -- Sumar GUEST (BTND P18)
        rstH : in STD_LOGIC; -- Reset HOME (SW0 J15)
        rstG : in STD_LOGIC; -- Reset GUEST (SW1 L16)
        rstT : in STD_LOGIC; -- Reset TIMER (BTNC N17)
        seg : out STD_LOGIC_VECTOR (6 downto 0); -- a..g (activo en 0)
        an : out STD_LOGIC_VECTOR (7 downto 0); -- ánodos (activo en 0)
        led : out STD_LOGIC -- 1 cuando tiempo=00:00
    );
end scoreboard;

architecture Behavioral of scoreboard is
    ----------------------------------------------------------------
    -- Constantes
    ----------------------------------------------------------------
    constant CLK_FREQ : integer := 100000000; -- 100 MHz
    constant TICKS_PER_DIG : integer := 12500; -- ~1 kHz/dígito (sin parpadeo)
    constant DEBOUNCE_TICKS : unsigned(19 downto 0) :=
                           to_unsigned(500000, 20); -- 5 ms a 100 MHz

    ----------------------------------------------------------------
    -- Señales internas
    ----------------------------------------------------------------
    -- Multiplexado display
    signal cnt_refresh : unsigned(19 downto 0) := (others=>'0');
    signal mux : unsigned(2 downto 0) := (others=>'0');

    -- 1 Hz para timer
    signal sec_cnt : unsigned(26 downto 0) := (others=>'0');
    signal tick_1hz : std_logic := '0';

    -- Pulsos de control (tras debounce)
    signal pBtnH, pBtnG, pRstH, pRstG, pRstT : std_logic := '0';

    -- Estado y contadores de debounce por cada entrada
    signal db_cnt_H, db_cnt_G, db_cnt_rH, db_cnt_rG, db_cnt_rT :
           unsigned(19 downto 0) := (others=>'0');
    signal st_H, st_G, st_rH, st_rG, st_rT : std_logic := '0';

    -- Marcadores HOME/GUEST (BCD)
    signal h_t, h_u : unsigned(3 downto 0) := (others=>'0'); -- decenas/unidades
    signal g_t, g_u : unsigned(3 downto 0) := (others=>'0');

    -- Timer MM:SS (BCD). ARRANCA EN 12:00
    signal m_t : unsigned(3 downto 0) := "0001"; -- 1 (decenas de minuto)
    signal m_u : unsigned(3 downto 0) := "0010"; -- 2 (unidades de minuto) => 12
    signal s_t : unsigned(3 downto 0) := "0000"; -- 0 (decenas de segundo)
    signal s_u : unsigned(3 downto 0) := "0000"; -- 0 (unidades de segundo) => 00

    -- Dígito a mostrar
    signal digit : unsigned(3 downto 0);
begin
    ----------------------------------------------------------------
    -- Multiplexado: cambio de dígito sin parpadeo
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if cnt_refresh = to_unsigned(TICKS_PER_DIG-1, cnt_refresh'length) then
                cnt_refresh <= (others=>'0');
                mux <= mux + 1;
            else
                cnt_refresh <= cnt_refresh + 1;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Divisor 1 Hz para el temporizador
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            tick_1hz <= '0';
            if sec_cnt = to_unsigned(CLK_FREQ-1, sec_cnt'length) then
                sec_cnt <= (others=>'0');
                tick_1hz <= '1';
            else
                sec_cnt <= sec_cnt + 1;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Debounce y generación de pulsos de control
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            -- por defecto no hay pulso
            pBtnH <= '0'; pBtnG <= '0';
            pRstH <= '0'; pRstG <= '0'; pRstT <= '0';

            -- BTN Home
            if btnH = '1' then
                if db_cnt_H < DEBOUNCE_TICKS then
                    db_cnt_H <= db_cnt_H + 1;
                elsif st_H = '0' then
                    st_H <= '1';
                    pBtnH <= '1';
                end if;
            else
                db_cnt_H <= (others=>'0'); st_H <= '0';
            end if;

            -- BTN Guest
            if btnG = '1' then
                if db_cnt_G < DEBOUNCE_TICKS then
                    db_cnt_G <= db_cnt_G + 1;
                elsif st_G = '0' then
                    st_G <= '1';
                    pBtnG <= '1';
                end if;
            else
                db_cnt_G <= (others=>'0'); st_G <= '0';
            end if;

            -- RST Home (SW0)
            if rstH = '1' then
                if db_cnt_rH < DEBOUNCE_TICKS then
                    db_cnt_rH <= db_cnt_rH + 1;
                elsif st_rH = '0' then
                    st_rH <= '1';
                    pRstH <= '1';
                end if;
            else
                db_cnt_rH <= (others=>'0'); st_rH <= '0';
            end if;

            -- RST Guest (SW1)
            if rstG = '1' then
                if db_cnt_rG < DEBOUNCE_TICKS then
                    db_cnt_rG <= db_cnt_rG + 1;
                elsif st_rG = '0' then
                    st_rG <= '1';
                    pRstG <= '1';
                end if;
            else
                db_cnt_rG <= (others=>'0'); st_rG <= '0';
            end if;

            -- RST Timer (BTNC)
            if rstT = '1' then
                if db_cnt_rT < DEBOUNCE_TICKS then
                    db_cnt_rT <= db_cnt_rT + 1;
                elsif st_rT = '0' then
                    st_rT <= '1';
                    pRstT <= '1';
                end if;
            else
                db_cnt_rT <= (others=>'0'); st_rT <= '0';
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Marcadores HOME
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if pRstH = '1' then
                h_t <= (others=>'0'); h_u <= (others=>'0');
            elsif pBtnH = '1' then
                if h_t="1001" and h_u="1001" then
                    h_t <= (others=>'0'); h_u <= (others=>'0');
                elsif h_u="1001" then
                    h_u <= (others=>'0'); h_t <= h_t + 1;
                else
                    h_u <= h_u + 1;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Marcadores GUEST
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if pRstG = '1' then
                g_t <= (others=>'0'); g_u <= (others=>'0');
            elsif pBtnG = '1' then
                if g_t="1001" and g_u="1001" then
                    g_t <= (others=>'0'); g_u <= (others=>'0');
                elsif g_u="1001" then
                    g_u <= (others=>'0'); g_t <= g_t + 1;
                else
                    g_u <= g_u + 1;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Temporizador MM:SS (cuenta regresiva) - arranca en 12:00
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if pRstT = '1' then
                -- reinicia a 12:00
                m_t <= "0001"; m_u <= "0010"; -- 12
                s_t <= "0000"; s_u <= "0000"; -- 00
                led <= '0';
            elsif tick_1hz = '1' then
                if (m_t="0000" and m_u="0000" and s_t="0000" and s_u="0000") then
                    led <= '1';
                else
                    led <= '0';
                    if s_u /= "0000" then
                        s_u <= s_u - 1;
                    else
                        s_u <= "1001"; -- 9
                        if s_t /= "0000" then
                            s_t <= s_t - 1;
                        else
                            s_t <= "0101"; s_u <= "1001"; -- 59
                            if m_u /= "0000" then
                                m_u <= m_u - 1;
                            else
                                m_u <= "1001"; -- 9
                                if m_t /= "0000" then
                                    m_t <= m_t - 1;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- Selección de dígito a mostrar (orden de ánodos mapeado abajo)
    ----------------------------------------------------------------
    with mux select digit <=
        g_u when "000", -- an[0] (derecha): Guest unidades
        g_t when "001",
        s_u when "010",
        s_t when "011",
        m_u when "100", -- an[4]: Min unidades (timer)
        m_t when "101",
        h_u when "110",
        h_t when others;

    ----------------------------------------------------------------
    -- Decoder 7 segmentos activo en bajo
    ----------------------------------------------------------------
    process(digit)
    begin
        case digit is
            when "0000" => seg <= "0000001"; -- 0
            when "0001" => seg <= "1001111"; -- 1
            when "0010" => seg <= "0010010"; -- 2
            when "0011" => seg <= "0000110"; -- 3
            when "0100" => seg <= "1001100"; -- 4
            when "0101" => seg <= "0100100"; -- 5
            when "0110" => seg <= "0100000"; -- 6
            when "0111" => seg <= "0001111"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0000100"; -- 9
            when others => seg <= "1111111"; -- off
        end case;
    end process;

    ----------------------------------------------------------------
    -- Ánodos (activo en 0) - an[0] derecha total, an[7] izquierda total
    ----------------------------------------------------------------
    with mux select an <=
        "11111110" when "000", -- dígito 0 (derecha): Guest unidades (an[0])
        "11111101" when "001", -- dígito 1: Guest decenas (an[1])
        "11111011" when "010", -- dígito 2: Seg unidades (an[2])
        "11110111" when "011", -- dígito 3: Seg decenas (an[3])
        "11101111" when "100", -- dígito 4: Min unidades (an[4])
        "11011111" when "101", -- dígito 5: Min decenas (an[5])
        "10111111" when "110", -- dígito 6: Home unidades (an[6])
        "01111111" when others; -- dígito 7 (izquierda): Home decenas (an[7])
end Behavioral;