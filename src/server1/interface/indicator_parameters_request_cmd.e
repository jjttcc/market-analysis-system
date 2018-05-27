note
    description: "Commands that respond to a request for the changeable %
        %parameters for a specified indicator"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class INDICATOR_PARAMETERS_REQUEST_CMD inherit

    PARAMETER_BASED_REQUEST_CMD
        rename
            tradable_processor as indicator,
            set_tradable_processor as set_indicator
        redefine
            iteration, set_iteration, indicator
        end

inherit {NONE}

    STRING_UTILITIES
        rename
            make as su_make_unused
        export
            {NONE} all
        end

creation

    make

feature {NONE}

    set_indicator
        do
            indicator := tradables.indicator_with_name(
                tradable_processor_name)
        end

    retrieve_parameters
        do
            parameters := session.parameters_for_processor(indicator, Void)
        end

    iteration: INTEGER

    set_iteration(i: INTEGER)
        do
            iteration := i
        end

    name: STRING = "Indicator parameters request"

    indicator: TRADABLE_FUNCTION

feature {NONE} -- Hook method implementations

    object_type: STRING
        do
            Result := "indicator"
        end

invariant

    params_not_modified: not modify_parameters

end
