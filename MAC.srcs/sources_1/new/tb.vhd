
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_booth_multiplier_32 is
end tb_booth_multiplier_32;

architecture Behavioral of tb_booth_multiplier_32 is

    signal A       : signed(31 downto 0) := (others => '0');
    signal B       : signed(31 downto 0) := (others => '0');
    signal Product : signed(63 downto 0);

begin

    -- Device Under Test
    DUT : entity work.booth_multiplier_32
        port map (
            A       => A,
            B       => B,
            Product => Product
        );

    process

        variable expected : signed(63 downto 0);
        variable seed1    : positive := 12345;
        variable seed2    : positive := 67890;
        variable rand1    : real;
        variable rand2    : real;

        -- Procedure for checking multiplication
        procedure check_mult(
            constant val_A : in signed(31 downto 0);
            constant val_B : in signed(31 downto 0)
        ) is
            variable exp_result : signed(63 downto 0);
        begin

            A <= val_A;
            B <= val_B;

            -- Allow combinational logic to settle
            wait for 10 ns;

            -- Expected signed 32 x 32 multiplication
            exp_result := val_A * val_B;

            assert Product = exp_result
                report "Multiplication FAILED! A = " &
                       to_hstring(std_logic_vector(val_A)) &
                       " B = " &
                       to_hstring(std_logic_vector(val_B)) &
                       " Expected = " &
                       to_hstring(std_logic_vector(exp_result)) &
                       " Got = " &
                       to_hstring(std_logic_vector(Product))
                severity error;

        end procedure;

    begin

        report "Starting Radix-4 Booth multiplier tests";

        ---------------------------------------------------
        -- 1. BASIC TESTS
        ---------------------------------------------------

        check_mult(to_signed(0, 32), to_signed(0, 32));
        check_mult(to_signed(1, 32), to_signed(1, 32));
        check_mult(to_signed(5, 32), to_signed(3, 32));
        check_mult(to_signed(10, 32), to_signed(20, 32));
        check_mult(to_signed(1234, 32), to_signed(5678, 32));

        report "Basic tests completed";

        ---------------------------------------------------
        -- 2. NEGATIVE NUMBER TESTS
        ---------------------------------------------------

        check_mult(to_signed(-5, 32), to_signed(3, 32));
        check_mult(to_signed(5, 32), to_signed(-3, 32));
        check_mult(to_signed(-5, 32), to_signed(-3, 32));
        check_mult(to_signed(-1234, 32), to_signed(5678, 32));
        check_mult(to_signed(1234, 32), to_signed(-5678, 32));

        report "Negative number tests completed";

        ---------------------------------------------------
        -- 3. EDGE CASES
        ---------------------------------------------------

        -- Maximum positive signed 32-bit value
        check_mult(
            signed'(x"7FFFFFFF"),
            to_signed(2, 32)
        );

        -- Minimum negative signed 32-bit value
        check_mult(
            signed'(x"80000000"),
            to_signed(-1, 32)
        );

        -- Minimum negative multiplied by itself
        check_mult(
            signed'(x"80000000"),
            signed'(x"80000000")
        );

        -- Maximum positive multiplied by maximum positive
        check_mult(
            signed'(x"7FFFFFFF"),
            signed'(x"7FFFFFFF")
        );

        -- Zero multiplication
        check_mult(
            signed'(x"FFFFFFFF"),
            to_signed(0, 32)
        );

        -- Alternating bit patterns
        check_mult(
            signed'(x"AAAAAAAA"),
            signed'(x"55555555")
        );

        report "Edge case tests completed";

        ---------------------------------------------------
        -- 4. RANDOM TESTS
        ---------------------------------------------------

        for i in 0 to 999 loop

            uniform(seed1, seed2, rand1);
            uniform(seed1, seed2, rand2);

            -- Generate signed values within a safe range
            A <= to_signed(integer((rand1 - 0.5) * 2000000000.0), 32);
            B <= to_signed(integer((rand2 - 0.5) * 2000000000.0), 32);

            wait for 10 ns;

            expected := A * B;

            assert Product = expected
                report "Random test FAILED at iteration " &
                       integer'image(i) &
                       " Expected = " &
                       to_hstring(std_logic_vector(expected)) &
                       " Got = " &
                       to_hstring(std_logic_vector(Product))
                severity error;

        end loop;

        report "1000 random tests completed";
        report "ALL TESTS COMPLETED";
        wait;

    end process;

end Behavioral;
