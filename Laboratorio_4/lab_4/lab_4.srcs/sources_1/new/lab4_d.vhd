library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lab4_d is
    Port ( 
        clk : in STD_LOGIC;                    -- Reloj de la FPGA (100 MHz)
        -- Botones
        btnu : in STD_LOGIC;                   -- sumar punto local
        btnl : in STD_LOGIC;                   -- sumar punto visita  
        btnr : in STD_LOGIC;                   -- iniciar/pausar tiempo
        btnd : in STD_LOGIC;                   -- reset tiempo
        btnc : in STD_LOGIC;                   -- reset puntajes
        -- Switches
        sw_local : in STD_LOGIC;               -- reset puntos local
        sw_visita : in STD_LOGIC;              -- reset puntos visita
        sw_test : in STD_LOGIC;                -- SW2: avanzar 2 minutos en test
        -- Display de 7 segmentos
        anodo : out STD_LOGIC_VECTOR (7 downto 0);
        catodo : out STD_LOGIC_VECTOR (6 downto 0);
        -- LED para tiempo terminado
        led_fin_tiempo : out STD_LOGIC
    );
end lab4_d;

architecture Behavioral of lab4_d is
    
    -- Constantes para divisores de frecuencia
    constant CLK_FREQ : integer := 100000000;  -- 100 MHz
    constant ONE_SECOND : integer := CLK_FREQ;
    constant REFRESH_RATE : integer := 100000; -- 1 kHz para multiplexación
    
    -- Señales del contador de tiempo
    signal counter : integer range 0 to ONE_SECOND := 0;
    signal seconds : integer range 0 to 59 := 0;
    signal minutes : integer range 0 to 10 := 10; -- Empieza en 10 minutos
    signal running : STD_LOGIC := '0';
    signal timer_finished : STD_LOGIC := '0';
    
    -- Señales para puntajes
    signal puntos_local : integer range 0 to 999 := 0;
    signal puntos_visita : integer range 0 to 999 := 0;
    
    -- Señales para display
    signal display_value : STD_LOGIC_VECTOR(31 downto 0); -- 8 dígitos
    signal digit_select : integer range 0 to 7 := 0;
    signal refresh_counter : integer range 0 to REFRESH_RATE := 0;
    
    -- Señales para anti-rebote
    signal btnu_sync, btnl_sync, btnr_sync, btnd_sync, btnc_sync : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal sw_local_sync, sw_visita_sync, sw_test_sync : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal btnu_deb, btnl_deb, btnr_deb, btnd_deb, btnc_deb : STD_LOGIC := '0';
    signal sw_local_deb, sw_visita_deb, sw_test_deb : STD_LOGIC := '0';
    signal debounce_counter : integer range 0 to 1000000 := 0;
    
    -- Señales para control de test
    signal sw_test_prev : STD_LOGIC := '0';
    signal test_activated : STD_LOGIC := '0';
    
begin

    -- Procesos de sincronización y anti-rebote
    process(clk)
    begin
        if rising_edge(clk) then
            -- Sincronización de botones
            btnu_sync <= btnu_sync(1 downto 0) & btnu;
            btnl_sync <= btnl_sync(1 downto 0) & btnl;
            btnr_sync <= btnr_sync(1 downto 0) & btnr;
            btnd_sync <= btnd_sync(1 downto 0) & btnd;
            btnc_sync <= btnc_sync(1 downto 0) & btnc;
            
            -- Sincronización de switches
            sw_local_sync <= sw_local_sync(1 downto 0) & sw_local;
            sw_visita_sync <= sw_visita_sync(1 downto 0) & sw_visita;
            sw_test_sync <= sw_test_sync(1 downto 0) & sw_test;
            
            -- Anti-rebote (10 ms)
            if debounce_counter < 1000000 then
                debounce_counter <= debounce_counter + 1;
            else
                debounce_counter <= 0;
                btnu_deb <= btnu_sync(2);
                btnl_deb <= btnl_sync(2);
                btnr_deb <= btnr_sync(2);
                btnd_deb <= btnd_sync(2);
                btnc_deb <= btnc_sync(2);
                sw_local_deb <= sw_local_sync(2);
                sw_visita_deb <= sw_visita_sync(2);
                sw_test_deb <= sw_test_sync(2);
            end if;
        end if;
    end process;

    -- Control de tiempo: inicio/pausa con btnr y test con sw_test
    process(clk, btnd_deb)
    begin
        if btnd_deb = '1' then  -- Reset tiempo con botón DOWN
            running <= '0';
            minutes <= 10;
            seconds <= 0;
            timer_finished <= '0';
            test_activated <= '0';
        elsif rising_edge(clk) then
            -- Detectar flanco ascendente del switch de test
            sw_test_prev <= sw_test_deb;
            
            -- Modo test: avanzar 2 minutos cuando se activa el switch
            if sw_test_deb = '1' and sw_test_prev = '0' then  -- Flanco ascendente
                test_activated <= '1';
                if minutes >= 2 then
                    minutes <= minutes - 2;
                else
                    -- Si quedan menos de 2 minutos, llevar a 0
                    minutes <= 0;
                    seconds <= 0;
                    timer_finished <= '1';
                    running <= '0';
                end if;
            end if;
            
            -- Iniciar/pausar con botón RIGHT (solo si no estamos en modo test)
            if btnr_deb = '1' and test_activated = '0' then
                if timer_finished = '0' then
                    running <= not running;
                end if;
            end if;
            
            -- Reset del flag de test cuando se suelta el switch
            if sw_test_deb = '0' then
                test_activated <= '0';
            end if;
        end if;
    end process;

    -- Contador principal de tiempo (solo funciona cuando no está en modo test)
    process(clk, btnd_deb)
    begin
        if btnd_deb = '1' then
            counter <= 0;
            seconds <= 0;
            minutes <= 10;
            timer_finished <= '0';
        elsif rising_edge(clk) then
            if running = '1' and timer_finished = '0' and test_activated = '0' then
                if counter = ONE_SECOND - 1 then
                    counter <= 0;
                    if seconds > 0 then
                        seconds <= seconds - 1;
                    else
                        if minutes > 0 then
                            minutes <= minutes - 1;
                            seconds <= 59;
                        else
                            timer_finished <= '1';
                            running <= '0';
                        end if;
                    end if;
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- Control de puntajes
    process(clk, btnc_deb, sw_local_deb, sw_visita_deb)
    begin
        -- Reset general de puntajes con btnc
        if btnc_deb = '1' then
            puntos_local <= 0;
            puntos_visita <= 0;
        elsif rising_edge(clk) then
            -- Reset individual de puntajes con switches
            if sw_local_deb = '1' then
                puntos_local <= 0;
            end if;
            if sw_visita_deb = '1' then
                puntos_visita <= 0;
            end if;
            
            -- Incrementar puntajes con botones (funciona incluso en modo test)
            if btnu_deb = '1' and timer_finished = '0' then
                if puntos_local < 999 then
                    puntos_local <= puntos_local + 1;
                end if;
            end if;
            
            if btnl_deb = '1' and timer_finished = '0' then
                if puntos_visita < 999 then
                    puntos_visita <= puntos_visita + 1;
                end if;
            end if;
        end if;
    end process;

    -- LED que indica tiempo finalizado
    led_fin_tiempo <= '1' when timer_finished = '1' else '0';

    -- Preparar valores para display (8 dígitos: LOCAL - TIEMPO - VISITA)
    -- Formato: LL MM:SS VV (Local - Tiempo - Visita)
    display_value(31 downto 28) <= std_logic_vector(to_unsigned(puntos_local / 10, 4));     -- Decenas local
    display_value(27 downto 24) <= std_logic_vector(to_unsigned(puntos_local mod 10, 4));   -- Unidades local
    display_value(23 downto 20) <= std_logic_vector(to_unsigned(minutes / 10, 4));          -- Decenas minutos
    display_value(19 downto 16) <= std_logic_vector(to_unsigned(minutes mod 10, 4));        -- Unidades minutos
    display_value(15 downto 12) <= std_logic_vector(to_unsigned(seconds / 10, 4));          -- Decenas segundos
    display_value(11 downto 8)  <= std_logic_vector(to_unsigned(seconds mod 10, 4));        -- Unidades segundos
    display_value(7 downto 4)   <= std_logic_vector(to_unsigned(puntos_visita / 10, 4));    -- Decenas visita
    display_value(3 downto 0)   <= std_logic_vector(to_unsigned(puntos_visita mod 10, 4));  -- Unidades visita

    -- Multiplexación de displays (8 displays)
    process(clk)
    begin
        if rising_edge(clk) then
            if refresh_counter < REFRESH_RATE - 1 then
                refresh_counter <= refresh_counter + 1;
            else
                refresh_counter <= 0;
                if digit_select < 7 then
                    digit_select <= digit_select + 1;
                else
                    digit_select <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Selección de ánodos (activación baja)
    process(digit_select)
    begin
        case digit_select is
            when 0 => anodo <= "11111110";  -- Display 0: Unidades visita
            when 1 => anodo <= "11111101";  -- Display 1: Decenas visita
            when 2 => anodo <= "11111011";  -- Display 2: Unidades segundos
            when 3 => anodo <= "11110111";  -- Display 3: Decenas segundos
            when 4 => anodo <= "11101111";  -- Display 4: Unidades minutos
            when 5 => anodo <= "11011111";  -- Display 5: Decenas minutos
            when 6 => anodo <= "10111111";  -- Display 6: Unidades local
            when 7 => anodo <= "01111111";  -- Display 7: Decenas local
            when others => anodo <= "11111111";
        end case;
    end process;

    -- Lógica del cátodo para display de 7 segmentos
    process(digit_select, display_value)
    begin
        case digit_select is
            when 0 =>  -- Unidades visita
                case display_value(3 downto 0) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when "0010" => catodo <= "0010010"; -- 2
                    when "0011" => catodo <= "0000110"; -- 3
                    when "0100" => catodo <= "1001100"; -- 4
                    when "0101" => catodo <= "0100100"; -- 5
                    when "0110" => catodo <= "0100000"; -- 6
                    when "0111" => catodo <= "0001111"; -- 7
                    when "1000" => catodo <= "0000000"; -- 8
                    when "1001" => catodo <= "0000100"; -- 9
                    when others => catodo <= "1111111";
                end case;
                
            when 1 =>  -- Decenas visita
                case display_value(7 downto 4) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when "0010" => catodo <= "0010010"; -- 2
                    when "0011" => catodo <= "0000110"; -- 3
                    when "0100" => catodo <= "1001100"; -- 4
                    when "0101" => catodo <= "0100100"; -- 5
                    when "0110" => catodo <= "0100000"; -- 6
                    when "0111" => catodo <= "0001111"; -- 7
                    when "1000" => catodo <= "0000000"; -- 8
                    when "1001" => catodo <= "0000100"; -- 9
                    when others => catodo <= "1111111";
                end case;
                
            when 2 =>  -- Unidades segundos
                case display_value(11 downto 8) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when "0010" => catodo <= "0010010"; -- 2
                    when "0011" => catodo <= "0000110"; -- 3
                    when "0100" => catodo <= "1001100"; -- 4
                    when "0101" => catodo <= "0100100"; -- 5
                    when "0110" => catodo <= "0100000"; -- 6
                    when "0111" => catodo <= "0001111"; -- 7
                    when "1000" => catodo <= "0000000"; -- 8
                    when "1001" => catodo <= "0000100"; -- 9
                    when others => catodo <= "1111111";
                end case;
                
            when 3 =>  -- Decenas segundos
                case display_value(15 downto 12) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when "0010" => catodo <= "0010010"; -- 2
                    when "0011" => catodo <= "0000110"; -- 3
                    when "0100" => catodo <= "1001100"; -- 4
                    when "0101" => catodo <= "0100100"; -- 5
                    when others => catodo <= "1111111";
                end case;
                
            when 4 =>  -- Unidades minutos
                case display_value(19 downto 16) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when "0010" => catodo <= "0010010"; -- 2
                    when "0011" => catodo <= "0000110"; -- 3
                    when "0100" => catodo <= "1001100"; -- 4
                    when "0101" => catodo <= "0100100"; -- 5
                    when "0110" => catodo <= "0100000"; -- 6
                    when "0111" => catodo <= "0001111"; -- 7
                    when "1000" => catodo <= "0000000"; -- 8
                    when "1001" => catodo <= "0000100"; -- 9
                    when others => catodo <= "1111111";
                end case;
                
            when 5 =>  -- Decenas minutos
                case display_value(23 downto 20) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when others => catodo <= "1111111";
                end case;
                
            when 6 =>  -- Unidades local
                case display_value(27 downto 24) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when "0010" => catodo <= "0010010"; -- 2
                    when "0011" => catodo <= "0000110"; -- 3
                    when "0100" => catodo <= "1001100"; -- 4
                    when "0101" => catodo <= "0100100"; -- 5
                    when "0110" => catodo <= "0100000"; -- 6
                    when "0111" => catodo <= "0001111"; -- 7
                    when "1000" => catodo <= "0000000"; -- 8
                    when "1001" => catodo <= "0000100"; -- 9
                    when others => catodo <= "1111111";
                end case;
                
            when 7 =>  -- Decenas local
                case display_value(31 downto 28) is
                    when "0000" => catodo <= "0000001"; -- 0
                    when "0001" => catodo <= "1001111"; -- 1
                    when "0010" => catodo <= "0010010"; -- 2
                    when "0011" => catodo <= "0000110"; -- 3
                    when "0100" => catodo <= "1001100"; -- 4
                    when "0101" => catodo <= "0100100"; -- 5
                    when "0110" => catodo <= "0100000"; -- 6
                    when "0111" => catodo <= "0001111"; -- 7
                    when "1000" => catodo <= "0000000"; -- 8
                    when "1001" => catodo <= "0000100"; -- 9
                    when others => catodo <= "1111111";
                end case;
                
            when others => 
                catodo <= "1111111";
        end case;
    end process;

end Behavioral;