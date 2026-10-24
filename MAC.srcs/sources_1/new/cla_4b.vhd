library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cla_4bit is
    Port (
        A    : in  std_logic_vector(3 downto 0);
        B    : in  std_logic_vector(3 downto 0);
        Cin  : in  std_logic;
        S    : out std_logic_vector(3 downto 0);
        Pout : out std_logic;
        Gout : out std_logic
    );
end cla_4bit;

architecture Structural of cla_4bit is

    signal P, G : std_logic_vector(3 downto 0);
    signal C    : std_logic_vector(3 downto 0);

begin

    P <= A xor B;
    G <= A and B;

    C(0) <= Cin;

    C(1) <= G(0) or
            (P(0) and Cin);

    C(2) <= G(1) or
            (P(1) and G(0)) or
            (P(1) and P(0) and Cin);

    C(3) <= G(2) or
            (P(2) and G(1)) or
            (P(2) and P(1) and G(0)) or
            (P(2) and P(1) and P(0) and Cin);

    S <= P xor C;

    -- Group propagate
    Pout <= P(3) and P(2) and P(1) and P(0);

    -- Group generate
    Gout <= G(3) or
            (P(3) and G(2)) or
            (P(3) and P(2) and G(1)) or
            (P(3) and P(2) and P(1) and G(0));

end Structural;