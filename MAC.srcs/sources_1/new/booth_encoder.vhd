
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity booth_encoder is
    Port (
        A          : in  signed(31 downto 0);
        booth_bits : in  std_logic_vector(2 downto 0);
        result     : out signed(33 downto 0)
    );
end booth_encoder;

architecture Behavioral of booth_encoder is

    signal A_ext : signed(33 downto 0);
    signal A2    : signed(33 downto 0);

begin

    -- Sign extension from 32 bits to 34 bits
    A_ext <= A(31) & A(31) & A;

    -- Multiply A by 2 (shift left by 1)
    A2 <= A(31) & A & '0';

    process(A_ext, A2, booth_bits)
    begin
        case booth_bits is

            when "000" | "111" =>
                result <= (others => '0');

            when "001" | "010" =>
                result <= A_ext;

            when "011" =>
                result <= A2;

            when "100" =>
                result <= (not A2) + 1;

            when "101" | "110" =>
                result <= (not A_ext) + 1;

            when others =>
                result <= (others => '0');

        end case;
    end process;

end Behavioral;
