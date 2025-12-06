library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux21 is
    Port ( Din1 : in STD_LOGIC;
           Din0 : in STD_LOGIC;
           Dout1 : out STD_LOGIC;
           Dout2 : out STD_LOGIC;
           Dout3 : out STD_LOGIC;
           Dout4 : out STD_LOGIC;
           Dout5 : out STD_LOGIC;
           Dout6 : out STD_LOGIC;
           Dout7 : out STD_LOGIC;
           Dout8 : out STD_LOGIC;
           Dout9 : out STD_LOGIC;
           Dout10 : out STD_LOGIC);
end mux21;

architecture Behavioral of mux21 is

begin

Dout1 <= not Din0;
Dout2 <= (Din0 and Din1);
Dout3 <= not (Din0 and Din1);
Dout4 <= (Din0 or Din1);
Dout5 <= not (Din0 or Din1);
Dout6 <= (Din0 and not Din1) or (Din1 and not Din0);
Dout7 <= not ((Din0 and not Din1) or (Din1 and not Din0));
Dout8 <= Din0;

end Behavioral;
