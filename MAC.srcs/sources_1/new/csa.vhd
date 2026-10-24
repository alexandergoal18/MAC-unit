library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity csa is
    generic (width: integer);
    Port (
        A : in  std_logic_vector(width-1 downto 0);
        B : in  std_logic_vector(width-1 downto 0);
        D : in  std_logic_vector(width-1 downto 0);
        S : out std_logic_vector(width-1 downto 0);
        C : out std_logic_vector(width-1 downto 0)
    );
end csa;

architecture Structural of csa is

    signal carry_temp : std_logic_vector(width-1 downto 0);

begin

    GEN_FA : for i in 0 to width-1 generate
    begin

        FA_inst : entity work.full_adder
            port map (
                A    => A(i),
                B    => B(i),
                Cin  => D(i),
                S    => S(i),
                Cout => carry_temp(i)
            );

    end generate GEN_FA;

    -- Shift carry left by one position
    C <= carry_temp(width-2 downto 0) & '0';

end Structural;