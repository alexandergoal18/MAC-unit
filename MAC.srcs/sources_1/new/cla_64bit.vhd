library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cla_64bit is
    Port (
        A    : in  std_logic_vector(63 downto 0);
        B    : in  std_logic_vector(63 downto 0);
        Cin  : in  std_logic;
        S    : out std_logic_vector(63 downto 0);
        Cout : out std_logic
    );
end cla_64bit;

architecture Structural of cla_64bit is

    signal P, G : std_logic_vector(15 downto 0);
    signal C    : std_logic_vector(16 downto 0);

    signal GP, GG : std_logic_vector(3 downto 0);
    signal GC     : std_logic_vector(4 downto 0);

begin

    C(0)  <= Cin;
    GC(0) <= Cin;

    -- Four groups of four 4-bit CLA blocks
    GEN_GROUP : for k in 0 to 3 generate

        -- Group propagate
        GP(k) <= P(4*k+3) and P(4*k+2) and
                 P(4*k+1) and P(4*k);

        -- Group generate
        GG(k) <= G(4*k+3) or
                 (P(4*k+3) and G(4*k+2)) or
                 (P(4*k+3) and P(4*k+2) and G(4*k+1)) or
                 (P(4*k+3) and P(4*k+2) and
                  P(4*k+1) and G(4*k));

        -- Carries within each group
        C(4*k+1) <= G(4*k) or
                    (P(4*k) and GC(k));

        C(4*k+2) <= G(4*k+1) or
                    (P(4*k+1) and G(4*k)) or
                    (P(4*k+1) and P(4*k) and GC(k));

        C(4*k+3) <= G(4*k+2) or
                    (P(4*k+2) and G(4*k+1)) or
                    (P(4*k+2) and P(4*k+1) and G(4*k)) or
                    (P(4*k+2) and P(4*k+1) and
                     P(4*k) and GC(k));

        C(4*k+4) <= GC(k+1);

    end generate GEN_GROUP;

    -- Lookahead carries between 16-bit groups
    GC(1) <= GG(0) or
             (GP(0) and Cin);

    GC(2) <= GG(1) or
             (GP(1) and GG(0)) or
             (GP(1) and GP(0) and Cin);

    GC(3) <= GG(2) or
             (GP(2) and GG(1)) or
             (GP(2) and GP(1) and GG(0)) or
             (GP(2) and GP(1) and GP(0) and Cin);

    GC(4) <= GG(3) or
             (GP(3) and GG(2)) or
             (GP(3) and GP(2) and GG(1)) or
             (GP(3) and GP(2) and GP(1) and GG(0)) or
             (GP(3) and GP(2) and GP(1) and GP(0) and Cin);

    -- Instantiate 16 CLA blocks
    cla4b : for i in 0 to 15 generate
    begin

        cla : entity work.cla_4bit
            port map (
                A    => A(4*i+3 downto 4*i),
                B    => B(4*i+3 downto 4*i),
                Cin  => C(i),
                S    => S(4*i+3 downto 4*i),
                Pout => P(i),
                Gout => G(i)
            );

    end generate cla4b;

    Cout <= GC(4);

end Structural;