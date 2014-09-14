note
    description: "Commands that respond to a request to modify a set of %
        %parameters for a specified event generator"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class MODIFY_EVENT_GENERATOR_PARAMETERS_REQUEST_CMD inherit
    PARAMETER_BASED_REQUEST_CMD
        redefine
            modify_parameters
        end

    GLOBAL_APPLICATION
        export
            {NONE} all
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
            meg: TRADABLE_EVENT_GENERATOR
        do
            meg := event_generator_with_name(tradable_processor_name)
            parameters := session.parameters_for_processor(meg)
        end

    name: STRING = "Event generator parameters set request"

end
