library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity automata is
    Port (
        ck     : in  std_logic;   -- Reloj 100 MHz
        inicio : in  std_logic;   -- Botón BTN0 -> genera pulso
        x      : in  std_logic;   -- Entrada desde SW0
        z      : out std_logic    -- Salida a LED0
    );
end automata;

architecture Behavioral of automata is

    -- Enumeración de estados
    type nombres_estados is (Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9);
    signal estado : nombres_estados := Q0;

    -- === NUEVAS SEÑALES PARA SINCRONIZAR EL BOTÓN ===
    signal btn_sync_0, btn_sync_1 : std_logic := '0';
    signal pulso_btn : std_logic := '0';

begin

    ---------------------------------------------------------------------
    -- 1) Sincronización del botón y generación de un pulso limpio
    ---------------------------------------------------------------------
    process(ck)
    begin
        if rising_edge(ck) then
            btn_sync_0 <= inicio;               -- leer botón
            btn_sync_1 <= btn_sync_0;           -- segunda etapa
            pulso_btn  <= btn_sync_0 and not btn_sync_1; -- pulso de 1 ciclo
        end if;
    end process;

    ---------------------------------------------------------------------
    -- 2) PROCESO PRINCIPAL DE LA FSM
    ---------------------------------------------------------------------
    process(ck)
    begin
        if rising_edge(ck) then
            if pulso_btn = '1' then  -- Avanza solo cuando hay un pulso de botón

                case estado is
                    when Q0 => if x = '0' then estado <= Q0; else estado <= Q1; end if;
                    when Q1 => if x = '0' then estado <= Q2; else estado <= Q1; end if;
                    when Q2 => if x = '0' then estado <= Q0; else estado <= Q3; end if;
                    when Q3 => if x = '0' then estado <= Q4; else estado <= Q1; end if;
                    when Q4 => if x = '0' then estado <= Q0; else estado <= Q5; end if;
                    when Q5 => if x = '0' then estado <= Q4; else estado <= Q6; end if;
                    when Q6 => if x = '0' then estado <= Q2; else estado <= Q7; end if;
                    when Q7 => if x = '0' then estado <= Q8; else estado <= Q1; end if;
                    when Q8 => if x = '0' then estado <= Q0; else estado <= Q9; end if;
                    when Q9 => if x = '0' then estado <= Q0; else estado <= Q1; end if;
                    when others => estado <= Q0;
                end case;

            end if;
        end if;
    end process;

    ---------------------------------------------------------------------
    -- 3) SALIDA SEGÚN ESTADO (COMBINACIONAL)
    ---------------------------------------------------------------------
    with estado select
        z <= '1' when Q9,
             '0' when others;

end Behavioral;
