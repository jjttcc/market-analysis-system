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
        redefine
            modify_parameters
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

feature {NONE}

    retrieve_parameters
        local
            ind: TRADABLE_FUNCTION
        do
            ind := tradables.indicator_with_name(tradable_processor_name)
            parameters := session.parameters_for_processor(ind)
        end

    name: STRING = "Indicator parameters set request"

end
