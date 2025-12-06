library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vectores is
    Port ( in_z     : in  STD_LOGIC;
           in_y     : in  STD_LOGIC;
           in_x     : in  STD_LOGIC;
           segments : out STD_LOGIC_VECTOR(6 downto 0);
           Dout8    : out STD_LOGIC;
           Dout9    : out STD_LOGIC;
           Dout10   : out STD_LOGIC);
end vectores;

architecture Behavioral of vectores is
    signal sel : std_logic_vector(2 downto 0);
begin
    -- concatenamos las entradas en una señal de 3 bits
    sel <= in_x & in_y & in_z;

    process(sel)
    begin                            --6543210
        case sel is                  --0123456
            when "000" => segments <= "1000000"; -- solo G
            when "001" => segments <= "1111001"; -- A,D,E,F,G
            when "010" => segments <= "0100100"; -- C,F
            when "011" => segments <= "0110000"; -- E,F 
            when "100" => segments <= "0011001"; -- A,D,E
            when "101" => segments <= "0010010"; -- B,E 
            when "110" => segments <= "0000010"; -- B
            when "111" => segments <= "1111000"; -- D,E,F,G
            when others => segments <= (others => '0');
        end case;
    end process;

end Behavioral;
