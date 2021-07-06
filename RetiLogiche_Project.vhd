----------------------------------------------------------------------------------
-- 
-- Prova Finale - Progetto Reti Logiche
--
-- Canali Davide
-- Vincenzo Curreri
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.ALL;


entity project_reti_logiche is
  Port (    
        i_clk      : in std_logic;
        i_rst      : in std_logic;
        i_start    : in std_logic;
        i_data     : in std_logic_vector(7 downto 0);
        o_address  : out std_logic_vector(15 downto 0);
        o_done     : out std_logic;
        o_en       : out std_logic;
        o_we       : out std_logic;
        o_data      : out std_logic_vector (7 downto 0) );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

    signal o_addr_sel : std_logic_vector(1 downto 0);
    
    signal reset : std_logic;
    signal inner_reset : std_logic;


-- signal for col and row
    -- signals end col/row
    signal o_end_col : std_logic;
    signal o_end_row : std_logic;
    
    -- signals exception
    signal check_zero : std_logic;
    signal check_one : std_logic;
    
    -- signals load register col/row
    signal r_col_load : std_logic;
    signal r_row_load : std_logic;
    
    --signals output register col/row
    signal o_r_col : std_logic_vector (7 downto 0);
    signal o_r_row : std_logic_vector (7 downto 0);
    
    --signals load register temp col/row
    signal r_temp_col_load : std_logic;
    signal r_temp_row_load : std_logic;
    
    -- signal select row or sub_row
    signal r_temp_row_sel : std_logic;
    
    -- signal select if sub 0 or 1
    signal row_sub_sel : std_logic;
    
    --signals update temp col
    signal mux_r_temp_col : std_logic_vector (7 downto 0);
    signal o_r_temp_col : std_logic_vector (7 downto 0);
    signal sub_col : std_logic_vector (7 downto 0);   
    
    --signals update temp row
    signal mux_r_temp_row : std_logic_vector (7 downto 0);
    signal mux_sub_row : std_logic_vector (7 downto 0);
    signal o_r_temp_row : std_logic_vector (7 downto 0);
    signal sub_row : std_logic_vector (7 downto 0);  
    
    --signals update jump address    
    signal r_jump_addr_load : std_logic;
    signal o_r_jump_addr : std_logic_vector(15 downto 0);
    signal sum_jump_addr : std_logic_vector(15 downto 0);
    
    signal o_r_addr_check : std_logic_vector(15 downto 0);
    signal r_addr_check_load : std_logic;
    signal check_addr_update : std_logic;
    
    --signals update o_address
    signal check_address : std_logic;
    signal o_mux_jump_addr : std_logic_vector(15 downto 0);
    signal mux_addr_sel : std_logic;
    signal o_mux_addr : std_logic;
    signal sum_addr : std_logic_Vector (15 downto 0);
    
    --signal load registers pixel
    signal r_px_load : std_logic;
    
    --signals register pixel in
    signal o_r_px : std_logic_vector(7 downto 0);
    signal o_r_px_2 : std_logic_vector(7 downto 0);
    signal o_mux_px : std_logic_vector(7 downto 0);
    signal o_mux_px_2 : std_logic_vector(7 downto 0);
    signal check_addr_px : std_logic;
    
    --signals px max
    signal o_r_px_max : std_logic_vector(7 downto 0);
    signal r_px_max_load : std_logic;
    signal o_mux_px_max : std_logic_vector(7 downto 0);
    signal check_max : std_logic;
    
    --signals px min
    signal o_r_px_min : std_logic_vector(7 downto 0);
    signal r_px_min_load : std_logic;
    signal o_mux_px_min : std_logic_vector(7 downto 0);
    signal check_min : std_logic;

    --signals delta
    signal o_r_delta : std_logic_vector(7 downto 0);
    signal o_mux_delta : std_logic_vector(7 downto 0);
    signal check_row_col : std_logic;
    signal sub_delta : std_logic_vector(7 downto 0);
    signal r_delta_load : std_logic;
    
    --signals shift
    signal o_log : std_logic_vector (3 downto 0);
    signal sub_shift : std_logic_vector (3 downto 0);
    signal o_r_shift : std_logic_vector (3 downto 0);
    signal r_shift_load : std_logic;
    
    --signals px addr
    signal row_col_sel : std_logic;
    signal o_mux_row_col : std_logic_Vector (15 downto 0);
    signal o_r_row_col : std_logic_Vector (15 downto 0);
    signal r_row_col_load : std_logic;
    signal sub_row_col : std_logic_Vector (15 downto 0);
    signal sum_px_addr_second : std_logic;
    signal o_r_px_addr : std_logic_vector (15 downto 0);
    signal r_px_addr_load : std_logic;
    signal sum_px_addr : std_logic_vector (15 downto 0);
    
    -- signals new pixel value
    signal sub_to_shift : unsigned(15 downto 0);
    signal shifted_value : std_logic_vector(15 downto 0);
    signal check_shift : std_logic;
    signal check_end : std_logic;
    
    --signals new px addr
    signal sum_new_px_addr : std_logic_vector(15 downto 0);
    
    type state is (IDLE, COL_UP, ROW_UP, TEMP_UP, COL_SUB, ROW_SUB, CHECK_PX, CHECK_LAST, DELTA, SHIFT, PX_IN, PX_OUT, THE_END, RST);
    signal cur_state, next_state : state;
   
begin
-- reset and change state
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
                    cur_state <= IDLE;
                elsif i_clk'event and i_clk = '1' then
                    cur_state <= next_state;
                end if;
    end process;

    
-- select next state
    process(cur_state, i_start, o_end_col, o_end_row, check_zero, check_one, check_addr_update, check_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when IDLE =>
                if i_start = '1' then
                    next_state <= COL_UP;
                end if;
            when COL_UP =>
                next_state <= ROW_UP;
            when ROW_UP =>
                next_state <= TEMP_UP;
            when TEMP_UP =>
                if check_zero = '1' then
                    next_state <= THE_END;
                elsif check_one = '1' then
                    next_state <= ROW_SUB;
                else
                   next_state <= COL_SUB;
                end if;                   
            when COL_SUB =>
                if o_end_col = '1' then
                    next_state <= ROW_SUB;
                end if;
                if  o_end_col = '1' and o_end_row = '1' then
                        next_state <= CHECK_PX;
                end if;
            when ROW_SUB =>
                if o_end_row = '1' then
                    next_state <= CHECK_PX;
                elsif o_end_col = '1' then
                    next_state <= ROW_SUB;
                else
                    next_state <= COL_SUB;
                end if;
            when CHECK_PX =>
                if check_addr_update = '1' then
                    next_state <= CHECK_LAST;
                end if;
            when CHECK_LAST =>
                next_state <= DELTA;
            when DELTA =>
                next_state <= SHIFT;
            when SHIFT =>
                next_state <= PX_IN;
            when PX_IN =>
                next_state <= PX_OUT;
            when PX_OUT =>
                if check_end = '1' then
                    next_state <= THE_END;
                else next_state <= PX_IN;
                end if;
             when THE_END =>
                if i_start = '0' then
                    next_state <= RST;
                end if;
             when RST =>
                next_state <= IDLE;
        end case;
    end process;
    
-- output each state
    process(cur_state)
    begin
    
    o_addr_sel <= "10";
    
    r_addr_check_load <= '0';
    
    
    r_jump_addr_load <= '0';
    mux_addr_sel <= '1';
    o_en <= '1';
    o_we <= '0';
    o_done <= '0';
    
    r_col_load <= '0';
    r_row_load <= '0';
    r_px_load <= '0';
    r_px_max_load <= '0';
    r_px_min_load <= '0';
    
    r_delta_load <= '0';
    
    r_shift_load <= '0';
    
    r_temp_col_load <= '0';
    r_temp_row_load <= '0';
    
    r_temp_row_sel <= '0';
    
    row_sub_sel <= '0';
    
    row_col_sel <= '0';
    r_row_col_load <= '0';
    
    r_px_addr_load <= '0';
    
    inner_reset <= '0';
    
        case cur_state is
            when IDLE =>
                mux_addr_sel <= '0';
                o_en <= '1';
                o_we <= '0';
                
            when COL_UP =>
                o_en <= '1';
                o_we <= '0';
                r_col_load <= '1';
                r_row_load <= '0';
                
            when ROW_UP =>
                o_en <= '1';
                o_we <= '0';
                r_col_load <= '0';
                r_row_load <= '1';
                r_temp_col_load <= '0';

            when TEMP_UP =>
                r_temp_col_load <= '1';
                row_sub_sel <= '0';
                r_temp_row_sel <= '0';
                r_temp_row_load <= '1';
               

            when COl_SUB =>
                r_temp_col_load <= '1';
                r_jump_addr_load <= '1';
                r_px_load <= '1';
                r_px_max_load <= '1';
                r_px_min_load <= '1';

            when ROW_SUB =>
                row_sub_sel <= '1';
                r_temp_row_sel <= '1';
                r_temp_row_load <= '1';
                r_temp_col_load <= '1';
                r_jump_addr_load <= '1';
                r_px_load <= '1';
                r_px_max_load <= '1';
                r_px_min_load <= '1';
                
            when CHECK_PX =>
                r_addr_check_load <= '1';
                r_jump_addr_load <= '0';
                r_px_load <= '1';
                r_px_max_load <= '1';
                r_px_min_load <= '1';
                 
            when CHECK_LAST =>
                r_px_load <= '1';
                r_px_max_load <= '1';
                r_px_min_load <= '1';
                
            when DELTA =>
                r_delta_load <= '1';  
                
            when SHIFT =>
                r_shift_load <= '1';
                row_col_sel <= '1';
                r_row_col_load <= '1';
                
            when PX_IN =>
                o_addr_sel <= "00";
                r_row_col_load <= '1';
                r_px_addr_load <= '1';
                
            when PX_OUT =>
                o_addr_sel <= "01";
                o_en <= '1';
                o_we <= '1';
                
            when THE_END =>
                o_done <= '1';
            
            when RST =>
                o_done <= '1';
                inner_reset <= '1';
        end case;
    end process;


-- RESET

reset <= i_rst or inner_reset;


-- mux to choose o_address
with o_addr_sel select
        o_address <= sum_addr when "10",
                     sum_px_addr when "00",
                     sum_new_px_addr when "01",
                     "XXXXXXXXXXXXXXXX" when others;
 


-- Check if rows or columns = 0
check_zero <= '1' when (o_r_row = "00000000" or o_r_col = "00000000") else '0';

-- Check if columns = 1
check_one <= '1' when (o_r_col = "00000001") else '0';

-- COLUMN
-- load column register
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_col <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_col_load = '1') then
                o_r_col <= i_data;
            end if;
        end if;
    end process;

-- multiplexer register temp column 
    with o_end_col select
        mux_r_temp_col <= o_r_col when '1',
                          sub_col when '0',
                          "XXXXXXXX" when others;
 
 -- load temp column register         
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_temp_col <= "00000001";
        elsif i_clk'event and i_clk = '1' then
            if(r_temp_col_load = '1') then
                o_r_temp_col <= mux_r_temp_col;
            end if;
        end if;
    end process;  

-- check if temp col is '0'
    o_end_col <= '1' when (o_r_temp_col = "0000001") else '0';

-- subtraction of columns
    sub_col <= o_r_temp_col - "00000001";    
   
--ROW   
-- load row register
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_row <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_row_load = '1') then
                o_r_row <= i_data;
            end if;
        end if;
    end process;

-- multiplexer register temp row 
    with r_temp_row_sel select
        mux_r_temp_row <= o_r_row when '0',
                          sub_row when '1',
                          "XXXXXXXX" when others;
 
 -- load temp row register         
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_temp_row <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_temp_row_load = '1') then
                o_r_temp_row <= mux_r_temp_row;
            end if;
        end if;
    end process;  

-- check if temp row is '0'
    o_end_row <= '1' when (o_r_temp_row = "00000001") else '0';

--multiplexer sub row
    with row_sub_sel select
        mux_sub_row <= "00000000" when '0',
                       "00000001" when '1',
                       "XXXXXXXX" when others;

-- subtraction of rows
    sub_row <= o_r_temp_row - mux_sub_row;                      


--ADDRESS
-- jump_address register
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_jump_addr <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_jump_addr_load = '1') then
                o_r_jump_addr <= sum_jump_addr;
            end if;
        end if;
    end process;  

-- jump address sum
    sum_jump_addr <= o_r_jump_addr + '1';
    
-- check r_jump_address >= 1
   check_address <= '1' when(o_r_jump_addr >= "0000000000000001") else '0';
   
-- multiplexer to select o_adress
    with check_address select
    o_mux_jump_addr <= o_r_jump_addr when '1',
                       "0000000000000000" when '0',
                       "XXXXXXXXXXXXXXXX" when others;
                 
-- multiplexer to select first sum's term                  
    with mux_addr_sel select
    o_mux_addr <= '1' when '1',
                  '0' when '0',
                  'X' when others;
                 
-- address sum
    sum_addr <= o_mux_jump_addr + o_mux_addr;

-- check if address update
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_addr_check <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_addr_check_load = '1') then
                o_r_addr_check <= sum_addr;
            end if;
        end if;
    end process;  

    check_addr_update <= '1' when o_r_addr_check = sum_addr else '0';

--PIXEL
--check if o_addr >=2
    check_addr_px <= '1' when(o_r_jump_addr >= "0000000000000010") else '0';
    
--multiplexer to select px value
    with check_addr_px select
    o_mux_px <= i_data when '1',
                "00000000" when '0',
                "XXXXXXXX" when others;

--current pixel register    
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_px <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_px_load = '1') then
                o_r_px <= o_mux_px;
            end if;
        end if;
    end process;  

--max pixel value register
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_px_max <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_px_max_load = '1') then
                o_r_px_max <= o_mux_px_max;
            end if;
        end if;
    end process;

--multiplexer to select if update max pixel value
    with check_max select
    o_mux_px_max <= o_r_px when '1',
                    o_r_px_max when '0',
                    "XXXXXXXX" when others;

--check if current px is greater than max px
    check_max <= '1' when (o_r_px_max < o_r_px) else '0';
    
    
--min pixel value register
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_px_min <= "11111111";
        elsif i_clk'event and i_clk = '1' then
            if(r_px_min_load = '1') then
                o_r_px_min <= o_mux_px_min;
            end if;
        end if;
    end process;
    
--multiplexer to select if update min pixel value
    with check_min select
    o_mux_px_min <= o_r_px_2 when '1',
                    o_r_px_min when '0',
                    "XXXXXXXX" when others;

--check if current px is less than max px
    check_min <= '1' when (o_r_px_min > o_r_px_2) else '0';
    
--current pixel register    
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_px_2 <= "11111111";
        elsif i_clk'event and i_clk = '1' then
            if(r_px_load = '1') then
                o_r_px_2 <= o_mux_px_2;
            end if;
        end if;
    end process;

--multiplexer to select px value
    with check_addr_px select
    o_mux_px_2 <= i_data when '1',
                "11111111" when '0',
                "XXXXXXXX" when others;
 
 
--DELTA_VALUE
    process(i_clk, reset)
    begin
        if(reset = '1') then
            o_r_delta <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r_delta_load = '1') then
                o_r_delta <= sub_delta;
            end if;
        end if;
    end process;
    
  
--sub max and min
    sub_delta <= o_r_px_max - o_r_px_min;
    
-- floor(log2(delta + 1))
process(o_r_delta)
begin
    if o_r_delta = "00000000" then o_log <= "0000";
    elsif o_r_delta < "00000011" then o_log <= "0001";
    elsif o_r_delta < "00000111" then o_log <= "0010";
    elsif o_r_delta < "00001111" then o_log <= "0011";
    elsif o_r_delta < "00011111" then o_log <= "0100";
    elsif o_r_delta < "00111111" then o_log <= "0101";
    elsif o_r_delta < "01111111" then o_log <= "0110";
    elsif o_r_delta < "11111111" then o_log <= "0111";
    elsif o_r_delta = "11111111" then o_log <= "1000";
    else o_log <= "XXXX";
   end if;
end process;

-- shift level
sub_shift <= "1000" - o_log;

process(i_clk, reset)
begin
    if(reset = '1') then
        o_r_shift <= "0000";
    elsif i_clk'event and i_clk = '1' then
        if(r_shift_load = '1') then
            o_r_shift <= sub_shift;
        end if;
    end if;
end process;

-- UPDATE PIXEL - ADDRESS

with row_col_sel select
o_mux_row_col <= o_r_jump_addr when '1',
                 sub_row_col when '0',
                 "XXXXXXXXXXXXXXXX" when others;

process(i_clk, reset)
begin
    if(reset = '1') then
        o_r_row_col <= "0000000000000000";
    elsif i_clk'event and i_clk = '1' then
        if(r_row_col_load = '1') then
            o_r_row_col <= o_mux_row_col;
        end if;
    end if;
end process;

sub_row_col <= o_r_row_col - "0000000000000001";

sum_px_addr_second <= '1' when (o_r_row_col > "0000000000000000") else '0';

process(i_clk, reset)
begin
    if(reset = '1') then
        o_r_px_addr <= "0000000000000001";
    elsif i_clk'event and i_clk = '1' then
        if(r_px_addr_load = '1') then
            o_r_px_addr <= sum_px_addr;
        end if;
    end if;
end process;

sum_px_addr <= o_r_px_addr + sum_px_addr_second;

check_end <= '1' when(o_r_row_col = "0000000000000000") else '0';

-- UPDATE PIXEL - NEW PIXEL

--check if col and row are = 1
    check_row_col <= '1' when (o_r_col = "00000001" and o_r_row = "00000001") else '0';
  

with check_row_col select
sub_to_shift <= "00000000" & unsigned(i_data - o_r_px_min) when '0',
                "0000000000000000" when '1',
                "XXXXXXXXXXXXXXXX" when others;
                
shifted_value <= std_logic_vector(sub_to_shift sll TO_INTEGER(unsigned(o_r_shift)));

check_shift <= '1' when(shifted_value < "0000000011111111") else '0';

with check_shift select
o_data <= shifted_value(7 downto 0) when '1',
          "11111111" when '0',
          "XXXXXXXX" when others;

-- NEW PIXEL ADDRESS

sum_new_px_addr <= o_r_jump_addr + o_r_px_addr;

end Behavioral;