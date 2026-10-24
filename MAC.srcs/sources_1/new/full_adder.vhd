library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
    Port (
        A    : in  std_logic;
        B    : in  std_logic;
        Cin  : in  std_logic;
        S    : out std_logic;
        Cout : out std_logic
    );
end full_adder;

architecture Behavioral of full_adder is
begin

    S <= A xor B xor Cin;

    Cout <= (A and B) or
            (A and Cin) or
            (B and Cin);

end Behavioral;