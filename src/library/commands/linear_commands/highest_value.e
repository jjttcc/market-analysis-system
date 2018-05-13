note
    description: "N-record commands that find the highest value in the %
        %last n trading periods"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- settings: vim: expandtab

class HIGHEST_VALUE inherit

    N_RECORD_LINEAR_COMMAND
        rename
            make as nrlc_make
        redefine
            start_init, sub_action, target
        end

creation

    make

feature -- Initialization

    make (t: LIST [TRADABLE_TUPLE]; o: like operand; i: like n)
        require
            not_void: t /= Void and o /= Void
            i_gt_0: i > 0
        do
            nrlc_make (t, i)
            set_operand (o)
        ensure
            set: target = t and operand = o and n = i
            parents_set: operand.parents.has(Current)
        end

feature {NONE} -- Implementation

    start_init
        do
            value := 0
        end

    sub_action (current_index: INTEGER)
        do
            operand.execute (target @ current_index)
            if operand.value > value then
                value := operand.value
            end
        end

feature {NONE}

    target: LIST [TRADABLE_TUPLE]

end -- class HIGHEST_VALUE
