note
    description: "Commands that respond to a request to modify a set of %
        %parameters for a specified indicator"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class MODIFY_INDICATOR_PARAMETERS_REQUEST_CMD inherit

    PARAMETER_BASED_REQUEST_CMD
        rename
            tradable_processor as indicator,
            set_tradable_processor as set_indicator
        redefine
            modify_parameters, indicator
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

feature {NONE} -- Implementation

    modify_parameters: BOOLEAN = True

feature {NONE} -- Hook method implementations

    object_type: STRING
        do
            Result := "indicator"
        end

feature {NONE}

    set_indicator
        do
            indicator := tradables.indicator_with_name(
                tradable_processor_name)
        end

    retrieve_parameters
        do
            parameters := session.parameters_for_processor(indicator)
        end

    name: STRING = "Indicator parameters set request"

    indicator: TRADABLE_FUNCTION

end
