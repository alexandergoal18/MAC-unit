
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity booth_multiplier_32 is
    Port (
        A       : in  signed(31 downto 0);
        B       : in  signed(31 downto 0);
        Product : out signed(63 downto 0)
    );
end booth_multiplier_32;

architecture Structural of booth_multiplier_32 is

    -- Array of 16 unshifted 34-bit Booth partial products
    type pp_array is array (0 to 15)
        of signed(33 downto 0);

    signal pp_raw : pp_array;

    -- Arrays for the CSA tree
    type row_array is array (natural range <>)
        of std_logic_vector(63 downto 0);

    signal pp      : row_array(0 to 15);
    signal stage1  : row_array(0 to 10);
    signal stage2  : row_array(0 to 7);
    signal stage3  : row_array(0 to 5);
    signal stage4  : row_array(0 to 3);
    signal stage5  : row_array(0 to 2);
    signal stage6  : row_array(0 to 1);

    signal final_product : std_logic_vector(63 downto 0);

begin

    -------------------------------------------------------
    -- 1. BOOTH ENCODING
    -- 16 encoders, each generating one partial product
    -------------------------------------------------------

    GEN_BOOTH : for i in 0 to 15 generate

        FIRST_ENCODER : if i = 0 generate
            BOOTH0 : entity work.booth_encoder
                port map (
                    A          => A,
                    booth_bits => std_logic_vector(B(1 downto 0)) & '0',
                    result     => pp_raw(i)
                );
        end generate FIRST_ENCODER;

        OTHER_ENCODERS : if i > 0 generate
            BOOTHi : entity work.booth_encoder
                port map (
                    A          => A,
                    booth_bits => std_logic_vector(B(2*i+1 downto 2*i-1)),
                    result     => pp_raw(i)
                );
        end generate OTHER_ENCODERS;

    end generate GEN_BOOTH;

    -------------------------------------------------------
    -- 2. SIGN EXTENSION AND FIXED SHIFTS
    -- Each partial product is shifted by 2*i bits
    -------------------------------------------------------

    GEN_SHIFT : for i in 0 to 15 generate
        pp(i) <= std_logic_vector(
            shift_left(resize(pp_raw(i), 64), 2*i)
        );
    end generate GEN_SHIFT;

    -------------------------------------------------------
    -- 3. CSA LEVEL 1
    -- 16 input rows -> 11 output rows
    -- 5 CSAs, 1 row passed through
    -------------------------------------------------------

    GEN_CSA_L1 : for i in 0 to 4 generate
        CSA_L1 : entity work.csa
            generic map (width => 64)
            port map (
                A => pp(3*i),
                B => pp(3*i+1),
                D => pp(3*i+2),
                S => stage1(2*i),
                C => stage1(2*i+1)
            );
    end generate GEN_CSA_L1;

    stage1(10) <= pp(15);

    -------------------------------------------------------
    -- 4. CSA LEVEL 2
    -- 11 input rows -> 8 output rows
    -- 3 CSAs, 2 rows passed through
    -------------------------------------------------------

    GEN_CSA_L2 : for i in 0 to 2 generate
        CSA_L2 : entity work.csa
            generic map (width => 64)
            port map (
                A => stage1(3*i),
                B => stage1(3*i+1),
                D => stage1(3*i+2),
                S => stage2(2*i),
                C => stage2(2*i+1)
            );
    end generate GEN_CSA_L2;

    stage2(6) <= stage1(9);
    stage2(7) <= stage1(10);

    -------------------------------------------------------
    -- 5. CSA LEVEL 3
    -- 8 input rows -> 6 output rows
    -- 2 CSAs, 2 rows passed through
    -------------------------------------------------------

    GEN_CSA_L3 : for i in 0 to 1 generate
        CSA_L3 : entity work.csa
            generic map (width => 64)
            port map (
                A => stage2(3*i),
                B => stage2(3*i+1),
                D => stage2(3*i+2),
                S => stage3(2*i),
                C => stage3(2*i+1)
            );
    end generate GEN_CSA_L3;

    stage3(4) <= stage2(6);
    stage3(5) <= stage2(7);

    -------------------------------------------------------
    -- 6. CSA LEVEL 4
    -- 6 input rows -> 4 output rows
    -- 2 CSAs
    -------------------------------------------------------

    GEN_CSA_L4 : for i in 0 to 1 generate
        CSA_L4 : entity work.csa
            generic map (width => 64)
            port map (
                A => stage3(3*i),
                B => stage3(3*i+1),
                D => stage3(3*i+2),
                S => stage4(2*i),
                C => stage4(2*i+1)
            );
    end generate GEN_CSA_L4;

    -------------------------------------------------------
    -- 7. CSA LEVEL 5
    -- 4 input rows -> 3 output rows
    -- 1 CSA, 1 row passed through
    -------------------------------------------------------

    CSA_L5 : entity work.csa
        generic map (width => 64)
        port map (
            A => stage4(0),
            B => stage4(1),
            D => stage4(2),
            S => stage5(0),
            C => stage5(1)
        );

    stage5(2) <= stage4(3);

    -------------------------------------------------------
    -- 8. CSA LEVEL 6
    -- 3 input rows -> 2 output rows
    -- 1 CSA
    -------------------------------------------------------

    CSA_L6 : entity work.csa
        generic map (width => 64)
        port map (
            A => stage5(0),
            B => stage5(1),
            D => stage5(2),
            S => stage6(0),
            C => stage6(1)
        );

    -------------------------------------------------------
    -- 9. FINAL 64-BIT CARRY-LOOKAHEAD ADDER
    -------------------------------------------------------

    FINAL_CLA : entity work.cla_64bit
        port map (
            A    => stage6(0),
            B    => stage6(1),
            Cin  => '0',
            S    => final_product,
            Cout => open
        );

    Product <= signed(final_product);

end Structural;
