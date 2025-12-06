library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab4_c is
    Port ( 
        clk : in STD_LOGIC;                      -- Clock de 100 MHz
        btnu : in STD_LOGIC;                     -- Sumar punto local
        btnl : in STD_LOGIC;                     -- Sumar punto visitante
        btnr : in STD_LOGIC;                     -- Iniciar/pausar tiempo
        btnd : in STD_LOGIC;                     -- Reset tiempo
        btnc : in STD_LOGIC;                     -- Reset ambos puntajes
        sw_local : in STD_LOGIC;                 -- SW0: Reset puntos local
        sw_visita : in STD_LOGIC;                -- SW1: Reset puntos visitante
        sw_test : in STD_LOGIC;                  -- SW2: Avanzar 2 minutos
        catodo : out STD_LOGIC_VECTOR(6 downto 0);  -- Segmentos del display
        anodo : out STD_LOGIC_VECTOR(7 downto 0);   -- Ánodos para seleccionar display
        led_fin_tiempo : out STD_LOGIC           -- LED indicador tiempo terminado
    );
end lab4_c;

architecture Behavioral of lab4_c is
    -- Constantes
    constant INIT_MINUTES : integer := 12;
    constant CLK_FREQ : integer := 100_000_000;  -- 100 MHz
    constant DEBOUNCE_TIME : integer := 10_000_000; -- 100ms para debounce
    
    -- Señales para el divisor de frecuencia (1 Hz)
    signal clk_1hz : STD_LOGIC := '0';
    signal counter_1hz : integer range 0 to CLK_FREQ-1 := 0;
    
    -- Señales para el tiempo
    signal seconds : integer range 0 to 59 := 0;
    signal minutes : integer range 0 to 99 := INIT_MINUTES;
    signal timer_running : STD_LOGIC := '0';
    signal timer_done : STD_LOGIC := '0';
    
    -- Señales para los marcadores
    signal score_local : integer range 0 to 99 := 0;
    signal score_visitante : integer range 0 to 99 := 0;
    
    -- Señales para los dígitos individuales (8 displays)
    type digit_array is array(0 to 7) of integer range 0 to 9;
    signal digits : digit_array := (others => 0);
    
    -- Señales para el multiplexado de displays
    signal refresh_counter : integer range 0 to 250000 := 0;
    signal display_select : integer range 0 to 7 := 0;
    signal current_digit : integer range 0 to 9 := 0;
    
    -- Señales para debounce de botones
    signal btn_prev : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal btn_stable : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal btn_pulse : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    type debounce_array is array(0 to 4) of integer range 0 to DEBOUNCE_TIME;
    signal debounce_counters : debounce_array := (others => 0);
    
    -- Señales para los switches (test y resets)
    signal sw_test_prev : STD_LOGIC := '0';
    signal sw_test_pulse : STD_LOGIC := '0';
    signal sw_local_prev : STD_LOGIC := '0';
    signal sw_local_pulse : STD_LOGIC := '0';
    signal sw_visita_prev : STD_LOGIC := '0';
    signal sw_visita_pulse : STD_LOGIC := '0';
    
begin

    -- Divisor de frecuencia para obtener 1 Hz
    process(clk)
    begin
        if rising_edge(clk) then
            if counter_1hz = CLK_FREQ-1 then
                counter_1hz <= 0;
                clk_1hz <= not clk_1hz;
            else
                counter_1hz <= counter_1hz + 1;
            end if;
        end if;
    end process;
    
    -- Debounce para los botones y detección de flanco para switches
    process(clk)
        variable buttons : STD_LOGIC_VECTOR(4 downto 0);
    begin
        if rising_edge(clk) then
            buttons := btnu & btnl & btnr & btnd & btnc;
            
            for i in 0 to 4 loop
                if buttons(i) = btn_prev(i) then
                    if debounce_counters(i) < DEBOUNCE_TIME then
                        debounce_counters(i) <= debounce_counters(i) + 1;
                    else
                        btn_stable(i) <= buttons(i);
                    end if;
                else
                    debounce_counters(i) <= 0;
                end if;
                
                btn_prev(i) <= buttons(i);
                
                -- Detectar flanco de subida
                if btn_stable(i) = '1' and btn_pulse(i) = '0' then
                    btn_pulse(i) <= '1';
                else
                    btn_pulse(i) <= '0';
                end if;
                
                if btn_stable(i) = '0' then
                    btn_pulse(i) <= '0';
                end if;
            end loop;
            
            -- Detectar flanco de subida del switch de test (SW2)
            sw_test_prev <= sw_test;
            if sw_test = '1' and sw_test_prev = '0' then
                sw_test_pulse <= '1';
            else
                sw_test_pulse <= '0';
            end if;
            
            -- Detectar flanco de subida del switch reset local (SW0)
            sw_local_prev <= sw_local;
            if sw_local = '1' and sw_local_prev = '0' then
                sw_local_pulse <= '1';
            else
                sw_local_pulse <= '0';
            end if;
            
            -- Detectar flanco de subida del switch reset visitante (SW1)
            sw_visita_prev <= sw_visita;
            if sw_visita = '1' and sw_visita_prev = '0' then
                sw_visita_pulse <= '1';
            else
                sw_visita_pulse <= '0';
            end if;
        end if;
    end process;
    
    -- Control del temporizador
    process(clk)
    begin
        if rising_edge(clk) then
            -- Reset del tiempo (btnd)
            if btn_pulse(1) = '1' then
                minutes <= INIT_MINUTES;
                seconds <= 0;
                timer_done <= '0';
                timer_running <= '0';
            -- Avanzar 2 minutos con el switch de test (SW2)
            elsif sw_test_pulse = '1' then
                if minutes >= 2 then
                    minutes <= minutes - 2;
                else
                    minutes <= 0;
                    seconds <= 0;
                    timer_done <= '1';
                    timer_running <= '0';
                end if;
            else
                -- Iniciar/pausar (btnr)
                if btn_pulse(2) = '1' then
                    timer_running <= not timer_running;
                end if;
                
                -- Contador descendente
                if timer_running = '1' and clk_1hz = '1' then
                    if minutes = 0 and seconds = 0 then
                        timer_done <= '1';
                        timer_running <= '0';
                    else
                        if seconds = 0 then
                            seconds <= 59;
                            if minutes > 0 then
                                minutes <= minutes - 1;
                            end if;
                        else
                            seconds <= seconds - 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- Control de marcadores
    process(clk)
    begin
        if rising_edge(clk) then
            -- Reset ambos puntajes (btnc)
            if btn_pulse(0) = '1' then
                score_local <= 0;
                score_visitante <= 0;
            end if;
            
            -- Reset solo equipo local (SW0)
            if sw_local_pulse = '1' then
                score_local <= 0;
            end if;
            
            -- Reset solo equipo visitante (SW1)
            if sw_visita_pulse = '1' then
                score_visitante <= 0;
            end if;
            
            -- Sumar punto local (btnu)
            if btn_pulse(4) = '1' then
                if score_local < 99 then
                    score_local <= score_local + 1;
                end if;
            end if;
            
            -- Sumar punto visitante (btnl)
            if btn_pulse(3) = '1' then
                if score_visitante < 99 then
                    score_visitante <= score_visitante + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Separar dígitos para los 8 displays
    -- Displays 7-6: Marcador Local
    digits(7) <= score_local / 10;
    digits(6) <= score_local mod 10;
    
    -- Displays 5-4: Tiempo (minutos)
    digits(5) <= minutes / 10;
    digits(4) <= minutes mod 10;
    
    -- Displays 3-2: Tiempo (segundos)
    digits(3) <= seconds / 10;
    digits(2) <= seconds mod 10;
    
    -- Displays 1-0: Marcador Visitante
    digits(1) <= score_visitante / 10;
    digits(0) <= score_visitante mod 10;
    
    -- Multiplexado de displays (refresco rápido)
    process(clk)
    begin
        if rising_edge(clk) then
            if refresh_counter = 250000 then  -- ~400 Hz de refresco
                refresh_counter <= 0;
                if display_select = 7 then
                    display_select <= 0;
                else
                    display_select <= display_select + 1;
                end if;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;
    
    -- Selección del dígito a mostrar
    process(display_select, digits)
    begin
        current_digit <= digits(display_select);
        
        case display_select is
            when 0 => anodo <= "11111110"; -- Visitante unidad
            when 1 => anodo <= "11111101"; -- Visitante decena
            when 2 => anodo <= "11111011"; -- Segundos unidad
            when 3 => anodo <= "11110111"; -- Segundos decena
            when 4 => anodo <= "11101111"; -- Minutos unidad
            when 5 => anodo <= "11011111"; -- Minutos decena
            when 6 => anodo <= "10111111"; -- Local unidad
            when 7 => anodo <= "01111111"; -- Local decena
            when others => anodo <= "11111111";
        end case;
    end process;
    
    -- Decodificador de 7 segmentos (cátodo común)
    process(current_digit)
    begin
        case current_digit is
            when 0 => catodo <= "1000000"; -- 0
            when 1 => catodo <= "1111001"; -- 1
            when 2 => catodo <= "0100100"; -- 2
            when 3 => catodo <= "0110000"; -- 3
            when 4 => catodo <= "0011001"; -- 4
            when 5 => catodo <= "0010010"; -- 5
            when 6 => catodo <= "0000010"; -- 6
            when 7 => catodo <= "1111000"; -- 7
            when 8 => catodo <= "0000000"; -- 8
            when 9 => catodo <= "0010000"; -- 9
            when others => catodo <= "1111111"; -- Apagado
        end case;
    end process;
    
    -- Asignar señal al LED de tiempo terminado
    led_fin_tiempo <= timer_done;

end Behavioral;