library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity normal is
    Port ( in_z : in STD_LOGIC;
           in_y : in STD_LOGIC;
           in_x : in STD_LOGIC;
           seg_a : out STD_LOGIC;
           seg_b : out STD_LOGIC;
           seg_c : out STD_LOGIC;
           seg_d : out STD_LOGIC;
           seg_e : out STD_LOGIC;
           seg_f : out STD_LOGIC;
           seg_g : out STD_LOGIC;
           Dout8 : out STD_LOGIC;
           Dout9 : out STD_LOGIC;
           Dout10 : out STD_LOGIC);
end normal;


architecture Behavioral of normal is

begin

seg_e <= (in_z) or ( in_x and not in_y);
seg_a <= ((not in_x) and (not in_y) and in_z) or (in_x and (not in_y) and (not in_z));
seg_b <= (in_x and (not in_y) and in_z) or (in_x and in_y and (not in_z));
seg_c <= not in_x and in_y and not in_z;
seg_d <= (in_x and not in_y and not in_z) or (not in_x and not in_y and in_z) or (in_x and in_y and in_z);
seg_f <= (not in_x and in_z) or (in_y and in_z) or (not in_x and in_y);
seg_g <= (not in_x and not in_y) or (in_x and in_y and in_z);

end Behavioral;
