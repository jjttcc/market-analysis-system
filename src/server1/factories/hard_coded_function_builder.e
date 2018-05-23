note
    description: "Builder of a list of hard-coded tradable functions"
    note1: "Hard-coded standard indicators"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

class HARD_CODED_FUNCTION_BUILDER inherit

    GLOBAL_SERVICES
        export {NONE}
            all
            {ANY} deep_twin, is_deep_equal, standard_is_equal
        end

    TRADABLE_FUNCTION_EDITOR
        export {NONE}
            all
        end

creation

    make

feature

    make
        do
            create innermost_function.make ("dummy", Void, Void)
            innermost_function.set_trading_period_type (
                period_types @ (period_type_names @ Daily))
        ensure
            not_void: innermost_function /= Void
        end

feature -- Access

    product: LIST [TRADABLE_FUNCTION]

    innermost_function: STOCK
            -- Dummy for innermost function for complex functions

    Simple_MA_n: INTEGER = 10
    EMA_n: INTEGER = 10
    Smaller_MACD_EMA_n: INTEGER = 12
    Larger_MACD_EMA_n: INTEGER = 26
    MACD_Signal_Line_EMA_n: INTEGER = 9
    Momentum_n: INTEGER = 7
    Rate_of_Change_n: INTEGER = 10
    StochasticK_n: INTEGER = 5
    StochasticD_n: INTEGER = 3
    Williams_n: INTEGER = 7
    RSI_n: INTEGER = 7
    Wilder_MA_n: INTEGER = 5
    WMA_n: INTEGER = 5
    SD_n: INTEGER = 5

feature -- Basic operations

    execute
        local
            l: LINKED_LIST [TRADABLE_FUNCTION]
            f: SIMPLE_FUNCTION [BASIC_TRADABLE_TUPLE]
            cf1, cf2: COMPLEX_FUNCTION
        do
            f := innermost_function
            create l.make
            l.extend (simple_ma (f, Simple_MA_n, "Simple Moving Average"))
            l.extend (ema (f, EMA_n, "Exponential Moving Average"))
            cf1 := ma_diff (ema (f, Smaller_MACD_EMA_n, "EMA, Short"),
                                ema (f, Larger_MACD_EMA_n, "EMA, Long"),
                                "MACD Difference")
            l.extend (cf1)
            cf2 := ema (l.last, MACD_Signal_Line_EMA_n,
                        "MACD Signal Line (EMA of MACD Difference)")
            l.extend (cf2)
            l.extend (ma_diff (cf1, cf2, "MACD Histogram"))
            l.extend (momentum (f, Momentum_n, "Momentum", "SUBTRACTION"))
            l.extend (momentum (f, Rate_of_Change_n, "Rate of Change",
                        "DIVISION"))
            l.extend (williams_percent_R (f, Williams_n, "Williams %%R"))
            l.extend (stochastic_percent_K (f, StochasticK_n, "Stochastic %%K"))
            l.extend (stochastic_percent_D (f, StochasticK_n, StochasticD_n,
                                            "Stochastic %%D"))
            l.extend (simple_ma (l.last, StochasticD_n, "Slow Stochastic %%D"))
            l.extend (rsi (f, RSI_n, "Relative Strength Index"))
            l.extend (wilder_ma (f, Wilder_MA_n, "Wilder Moving Average"))
            l.extend (wma (f, WMA_n, "Weighted Moving Average"))
            l.extend (standard_deviation (f, SD_n, "Standard Deviation"))
            l.extend (market_data (f, "Market Data"))
            l.extend (tradable_function_line (f, "Line"))
            product := l
        end

feature {NONE} -- Hard-coded tradable function building procedures

    simple_ma (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                        STANDARD_MOVING_AVERAGE
            -- Make a simple moving average function.
        local
            cmd: BASIC_NUMERIC_COMMAND
        do
            create cmd
            create Result.make (f, cmd, n)
            Result.set_name (name)
        ensure
            initialized: Result /= Void and Result.name = name
        end

    ema (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                EXPONENTIAL_MOVING_AVERAGE
            -- Make an exponential moving average function.
        local
            cmd: BASIC_NUMERIC_COMMAND
            exp: MA_EXPONENTIAL
        do
            create exp.make (n)
            create cmd
            create Result.make (f, cmd, exp, n)
            Result.set_name (name)
        ensure
            initialized: Result /= Void and Result.n = n and Result.name = name
        end

    ma_diff (f1, f2: COMPLEX_FUNCTION; name: STRING): TWO_VARIABLE_FUNCTION
            -- A function that gives the difference between `f1' and `f2'
            -- Uses a BASIC_LINEAR_COMMAND to obtain the values from `f1'
            -- and `f2' to be subtracted.
        require
            not_void: f1 /= Void and f2 /= Void
            o_not_void: f1.output /= Void and f2.output /= Void
        local
            sub: SUBTRACTION
            cmd1: BASIC_LINEAR_COMMAND
            cmd2: BASIC_LINEAR_COMMAND
        do
            create cmd1.make (f1.output)
            create cmd2.make (f2.output)
            create sub.make (cmd1, cmd2)
            create Result.make (f1, f2, sub)
            Result.set_name (name)
        ensure
            initialized: Result /= Void and Result.name = name
        end

    momentum (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING;
                operator_type: STRING): N_RECORD_ONE_VARIABLE_FUNCTION
            -- A momentum function
        local
            operator: BINARY_OPERATOR [DOUBLE, DOUBLE]
            close: BASIC_NUMERIC_COMMAND
            close_minus_n: MINUS_N_COMMAND
        do
            create close; create close_minus_n.make (f.output, close, n)
            if operator_type.is_equal ("SUBTRACTION") then
                create {SUBTRACTION} operator.make (close, close_minus_n)
            else
                check operator_type.is_equal ("DIVISION") end
                create {DIVISION} operator.make (close, close_minus_n)
            end
            create Result.make (f, operator, n)
            -- For momentum, effective_n needs to be 1 larger than n.
            Result.set_effective_offset (1)
            Result.set_name (name)
        ensure
            initialized: Result /= Void and Result.n = n and Result.name = name
        end

    rsi (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                TWO_VARIABLE_FUNCTION
            -- RSI:  100 - (100 / (1 + RS))
            -- RS:  (average n up closes ) / (average n down closes)
        local
            one, one_hundred: NUMERIC_VALUE_COMMAND
            outer_div, inner_div, add, sub: BINARY_OPERATOR [DOUBLE, DOUBLE]
            positive_average, negative_average: BASIC_LINEAR_COMMAND
            pos_ema, neg_ema: EXPONENTIAL_MOVING_AVERAGE
        do
            create one.make (1); create one_hundred.make (100)
            one.set_is_editable (False); one_hundred.set_is_editable (False)
            pos_ema := rs_average (f, n, True)
            neg_ema := rs_average (f, n, False)
            create positive_average.make (pos_ema.output)
            create negative_average.make (neg_ema.output)
            create {DIVISION} inner_div.make (positive_average,
                negative_average)
            create {ADDITION} add.make (one, inner_div)
            create {DIVISION} outer_div.make (one_hundred, add)
            create {SUBTRACTION} sub.make (one_hundred, outer_div)
            create Result.make (pos_ema, neg_ema, sub)
            Result.set_name (name)
        end

    wilder_ma (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                CONFIGURABLE_N_RECORD_FUNCTION
        local
            plus: ADDITION
            minus: SUBTRACTION
            leftdiv, rightdiv, firstop: DIVISION
            ncmd: N_VALUE_COMMAND
            bnc: BASIC_NUMERIC_COMMAND
            prevcmd: UNARY_LINEAR_OPERATOR
            sum: LINEAR_SUM
            close: BASIC_NUMERIC_COMMAND
        do
            create ncmd.make (n)
            create bnc
            create leftdiv.make (bnc, ncmd)
            create minus.make (bnc, leftdiv)
            create prevcmd.make (f.output, minus)
            create close
            create rightdiv.make (close, ncmd)
            create plus.make (prevcmd, rightdiv)
            create sum.make (f.output, close, n)
            create firstop.make (sum, ncmd)
            create Result.make (f, plus, firstop, n)
            Result.set_name (name)
            Result.set_operators (plus, prevcmd, firstop)
        end

    wma (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                N_RECORD_ONE_VARIABLE_FUNCTION
        local
            plus: ADDITION
            leftmult, rightmult: MULTIPLICATION
            outerdiv, innerdiv: DIVISION
            ncmd: N_VALUE_COMMAND
            sum: LINEAR_SUM
            close: BASIC_NUMERIC_COMMAND
            minus_n: MINUS_N_COMMAND
            k: N_BASED_UNARY_OPERATOR
            one, two: NUMERIC_VALUE_COMMAND
            ix: INDEX_EXTRACTOR
        do
            create one.make (1); create two.make (2)
            one.set_is_editable (False); two.set_is_editable (False)
            create ncmd.make (n)
            create close
            create ix.make (Void)
            create leftmult.make (close, ix)
            create sum.make (f.output, leftmult, n)
            ix.set_indexable (sum)
            create minus_n.make (f.output, sum, n)
            -- minus_n's offset needs to be adjusted to 1 less than n
            -- because the cursor needs to move back 4 (n-1) periods in
            -- order to sum the last 5 periods (relative to the
            -- current period - i.e., target.item).
            minus_n.set_n_adjustment (-1)
            create plus.make (ncmd, one)
            create rightmult.make (ncmd, plus)
            create innerdiv.make (rightmult, two)
            create k.make (innerdiv, n)
            create outerdiv.make (minus_n, k)
            create Result.make (f, outerdiv, n)
            Result.set_name (name)
        end

    obsolete_rsi (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                N_RECORD_ONE_VARIABLE_FUNCTION
            -- RSI = 100 - (100 / (1 + RS))
            -- RS = (average n up closes ) / (average n down closes)
        local
            up_closes, down_closes: MINUS_N_COMMAND
            up_adder, down_adder: LINEAR_SUM
            up_boolclient, down_boolclient: NUMERIC_CONDITIONAL_COMMAND
            lt_op: LT_OPERATOR
            gt_op: GT_OPERATOR
            offset1, offset2: SETTABLE_OFFSET_COMMAND
            close: CLOSING_PRICE
            zero, one_hundred, one: NUMERIC_VALUE_COMMAND
            nvalue: N_VALUE_COMMAND
            upsub, downsub, outer_sub: SUBTRACTION
            rs_div, maindiv, upavg, downavg: DIVISION
            one_plus_rs: ADDITION
        do
            create close; create zero.make (0)
            create one_hundred.make (100); create one.make (1);
            zero.set_is_editable (False)
            one_hundred.set_is_editable (False); one.set_is_editable (False);
            create nvalue.make (n); create offset1.make (f.output, close);
            create nvalue.make (n); create offset1.make (f.output, close);
            create offset2.make (f.output, close)
            offset2.set_offset (1)
            create lt_op.make (offset1, offset2)
            create upsub.make (offset2, offset1)
            create up_boolclient.make (lt_op, upsub, zero)
            create up_adder.make (f.output, up_boolclient, n)
            create up_closes.make (f.output, up_adder, n)
            create upavg.make (up_closes, nvalue)

            create gt_op.make (offset1, offset2)
            -- Notice that order of arguments is different from upsub.make:
            create downsub.make (offset1, offset2)
            create down_boolclient.make (gt_op, downsub, zero)
            create down_adder.make (f.output, down_boolclient, n)
            create down_closes.make (f.output, down_adder, n)
            create downavg.make (down_closes, nvalue)

            create rs_div.make (upavg, downavg) -- RS: up avg / down avg
            create one_plus_rs.make (rs_div, one) -- 1 + RS
            create maindiv.make (one_hundred, one_plus_rs) -- 100 / (1 + RS)
            create outer_sub.make (one_hundred, maindiv) -- 100 - (100/(1+RS))
            create Result.make (f, outer_sub, n)
            Result.set_effective_offset (1)
            Result.set_name (name)
        end

    williams_percent_R (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                N_RECORD_ONE_VARIABLE_FUNCTION
            -- A Williams %R function
        local
            m: MULTIPLICATION -- Used to convert value to percent.
            d: DIVISION
            s1: SUBTRACTION
            s2: SUBTRACTION
            highest: HIGHEST_VALUE
            lowest: LOWEST_VALUE
            high: HIGH_PRICE
            low: LOW_PRICE
            close: CLOSING_PRICE
            one_hundred: NUMERIC_VALUE_COMMAND
        do
            create close; create low; create high
            create one_hundred.make (100) -- factor for conversion to percentage
            one_hundred.set_is_editable (False)
            create highest.make (f.output, high, n)
            create lowest.make (f.output, low, n)
            create s1.make (highest, close)
            create s2.make (highest, lowest)
            create d.make (s1, s2)
            create m.make (d, one_hundred)
            create Result.make (f, m, n)
            Result.set_name (name)
            check Result.n = highest.n and Result.n = lowest.n end
        ensure
            initialized: Result /= Void and Result.n = n and Result.name = name
        end

    stochastic_percent_K (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                N_RECORD_ONE_VARIABLE_FUNCTION
            -- A Stochastic %K function
        local
            d: DIVISION
            m: MULTIPLICATION -- Used to convert value to percent.
            s1: SUBTRACTION
            s2: SUBTRACTION
            highest: HIGHEST_VALUE
            lowest: LOWEST_VALUE
            high: HIGH_PRICE
            low: LOW_PRICE
            close: CLOSING_PRICE
            one_hundred: NUMERIC_VALUE_COMMAND
        do
            create close; create low; create high
            create one_hundred.make (100) -- factor for conversion to percentage
            one_hundred.set_is_editable (False)
            create highest.make (f.output, high, n)
            create lowest.make (f.output, low, n)
            create s1.make (close, lowest);
            create s2.make (highest, lowest)
            create d.make (s1, s2)
            create m.make (d, one_hundred)
            create Result.make (f, m, n)
            Result.set_name (name)
            check Result.n = lowest.n and Result.n = highest.n end
        ensure
            initialized: Result /= Void and Result.n = n and Result.name = name
        end

    stochastic_percent_D (f: TRADABLE_FUNCTION; inner_n, outer_n: INTEGER;
                name: STRING): TWO_VARIABLE_FUNCTION
            -- Make a Stochastic %D calculation function.
        local
            div: DIVISION
            mult: MULTIPLICATION -- Used to convert value to percent.
            sub1: SUBTRACTION
            sub2: SUBTRACTION
            basic1: BASIC_LINEAR_COMMAND
            basic2: BASIC_LINEAR_COMMAND
            close_low_function: N_RECORD_ONE_VARIABLE_FUNCTION
            high_low_function: N_RECORD_ONE_VARIABLE_FUNCTION
            ma1, ma2: STANDARD_MOVING_AVERAGE
            cmd: BASIC_NUMERIC_COMMAND
            highest: HIGHEST_VALUE
            lowest: LOWEST_VALUE
            high: HIGH_PRICE
            low: LOW_PRICE
            close: CLOSING_PRICE
            one_hundred: NUMERIC_VALUE_COMMAND
        do
            create cmd
            create close; create low; create high
            create one_hundred.make (100) -- factor for conversion to percentage
            one_hundred.set_is_editable (False)
            create highest.make (f.output, high, inner_n)
            create lowest.make (f.output, low, inner_n)
            create sub1.make (close, lowest);
            create sub2.make (highest, lowest)
            create close_low_function.make (f, sub1, inner_n)
            create high_low_function.make (f, sub2, inner_n)
            close_low_function.set_name (
                "Stochastic: 'close' - 'n-period low'")
            high_low_function.set_name (
                "Stochastic: 'n-period high' - 'n-period low'")
            create ma1.make (close_low_function, cmd, outer_n)
            create ma2.make (high_low_function, cmd, outer_n)
            ma1.set_name (
                "Stochastic: moving average of 'close' - 'n-period low'")
            ma2.set_name ("Stochastic: moving average of %
                %'n-period high' - 'n-period low'")
            create basic1.make (ma1.output)
            create basic2.make (ma2.output)
            create div.make (basic1, basic2)
            create mult.make (div, one_hundred)
            create Result.make (ma1, ma2, mult)
            Result.set_name (name)
        ensure
            initialized: Result /= Void and Result.name = name
        end

    market_data (f: SIMPLE_FUNCTION [BASIC_TRADABLE_TUPLE]; name: STRING):
                        TRADABLE_DATA_FUNCTION
            -- Make a function that simply gives the closing price of
            -- each tuple.
        do
            create Result.make (f)
            Result.set_name (name)
        ensure
            initialized: Result /= Void and Result.name = name
        end

    standard_deviation (f: TRADABLE_FUNCTION; n: INTEGER;
            name: STRING): AGENT_BASED_FUNCTION
        local
            agents: expanded MARKET_AGENTS
            l: LINKED_LIST [TRADABLE_FUNCTION]
        do
            if f /= Void then
                create l.make
                l.extend (f)
            end
            create Result.make (agents.Standard_deviation_key, Void, l)
            Result.set_name (name)
            Result.add_parameter (create {INTEGER_FUNCTION_PARAMETER}.make (n,
                Result))
        end

    abf_test (f: TRADABLE_FUNCTION; n: INTEGER;
            name: STRING): AGENT_BASED_FUNCTION
        local
            agents: expanded MARKET_AGENTS
            l: LINKED_LIST [TRADABLE_FUNCTION]
            log2, bnc: RESULT_COMMAND [DOUBLE]
        do
            create {BASIC_NUMERIC_COMMAND} bnc
            create {LOG2} log2.make (bnc)
            if f /= Void then
                create l.make
                l.extend (f)
            end
            create Result.make (agents.Standard_deviation_key, log2, l)
            Result.set_name (name)
            Result.add_parameter (create {INTEGER_FUNCTION_PARAMETER}.make (n,
                Result))
        end

    tradable_function_line (f: TRADABLE_FUNCTION; name: STRING):
                TRADABLE_FUNCTION_LINE
            -- Dummy line
        local
            p1, p2: TRADABLE_POINT
            earlier, later: DATE_TIME
        do
            create earlier.make (1998, 1, 1, 0, 0, 0)
            create later.make (1998, 1, 23, 0, 0, 0)
            create p1.make
            p1.set_x_y_date (earlier.day, 1, earlier)
            create p2.make
            p2.set_x_y_date (later.day, 1, later)
            create Result.make_from_2_points (p1, p2, f)
            Result.set_name (name)
        end

    rs_average (f: TRADABLE_FUNCTION; n: INTEGER; positive: BOOLEAN):
                EXPONENTIAL_MOVING_AVERAGE
            -- Positive (`positive') or negative (not `positive') average
            -- used in the quotient for RS for the RSI formula
        local
            one, zero: NUMERIC_VALUE_COMMAND
            exp: N_BASED_UNARY_OPERATOR
            div, sub: BINARY_OPERATOR [DOUBLE, DOUBLE]
            main_op: NUMERIC_CONDITIONAL_COMMAND
            n_cmd: N_VALUE_COMMAND
            relational_op: BINARY_OPERATOR [BOOLEAN, DOUBLE]
            offset_minus_1, offset_0: SETTABLE_OFFSET_COMMAND
            close: BASIC_NUMERIC_COMMAND
            fname: STRING
        do
            create one.make (1); create zero.make (0)
            one.set_is_editable (False); zero.set_is_editable (False)
            create close
            create offset_minus_1.make (f.output, close)
            offset_minus_1.set_offset (-1)
            create offset_0.make (f.output, close)
            create n_cmd.make (n)
            create {DIVISION} div.make (one, n_cmd)
            create exp.make (div, n)
            if positive then
                -- Set up the bool operand for main_op so that the result
                -- is the current close minus the previous close if that
                -- is positive - otherwise, 0.
                fname := "Positive average for RSI"
                create {LT_OPERATOR} relational_op.make (offset_minus_1,
                    offset_0)
                create {SUBTRACTION} sub.make (offset_0, offset_minus_1)
            else
                -- Set up the bool operand for main_op so that the result
                -- is the previous close minus the current close if that
                -- is positive - otherwise, 0.
                fname := "Negative average for RSI"
                create {GT_OPERATOR} relational_op.make (offset_minus_1,
                    offset_0)
                create {SUBTRACTION} sub.make (offset_minus_1, offset_0)
            end
            create main_op.make (relational_op, sub, zero)
            create Result.make (f, main_op, exp, n)
            Result.set_name (fname)
            -- Because a SETTABLE_OFFSET_COMMAND with an offset of -1 is
            -- one of the operators used (indirectly) by Result, the
            -- effective offset must be set to the opposite value (1) to
            -- compensate - ensure that the left-most element of the input
            -- being processed is the first element.
            Result.set_effective_offset (1)
        end

    agent_experiment (name: STRING): AGENT_BASED_FUNCTION
        local
            agents: expanded MARKET_AGENTS
        do
            create Result.make (agents.Sma_key, Void, Void)
            Result.set_name (name)
            Result.add_parameter (create {INTEGER_FUNCTION_PARAMETER}.make (13,
                Result))
        end

feature {NONE} -- Functions currently not used

    wma_of_midpoint (f: TRADABLE_FUNCTION; n: INTEGER; name: STRING):
                N_RECORD_ONE_VARIABLE_FUNCTION
        do
            Result := wma (midpoint (f), n, name)
        end

    midpoint (f: TRADABLE_FUNCTION): ONE_VARIABLE_FUNCTION
            -- Midpoint
        local
            div: DIVISION
            add: ADDITION
            high: HIGH_PRICE
            low: LOW_PRICE
            two: NUMERIC_VALUE_COMMAND
        do
            create high; create low; create two.make (2)
            two.set_is_editable (False)
            create add.make (high, low)
            create div.make (add, two)
            create Result.make (f, div)
            Result.set_name ("Midpoint")
        end

    print_ancestors(tn: TREE_NODE)
    local
        tag: STRING
     do
        tag:= tn.name
        if tag = Void then
            tag:= "[" + tn.generating_type + "]"
        end
        print("%Nancestors of " + tag + " [" + tn.out +
        "]:%N")
        print_tree(tn.ancestors, 1)
     end

    margin: STRING = "   "

    print_tree (t: TREE [TREE_NODE]; level: INTEGER)
        local
            i: INTEGER
        do
            from
                i := 1
            until
                i > level
            loop
                print(margin)
                i := i + 1
            end
            print(t.item.name + "%N")
            from
                t.child_start
            until
                t.child_off
            loop
                print_tree(t.child, level + 1)
                t.child_forth
            end
        end

invariant

    innermost_function_not_void: innermost_function /= Void

end -- HARD_CODED_FUNCTION_BUILDER
