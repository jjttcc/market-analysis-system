note
    description: "Commands that respond to a request for the changeable %
        %parameters for a specified event generator"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

class EVENT_GENERATOR_PARAMETERS_REQUEST_CMD inherit
    PARAMETER_BASED_REQUEST_CMD
        redefine
            iteration, set_iteration
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

feature {NONE}

    retrieve_parameters
        local
            meg: MARKET_EVENT_GENERATOR
        do
            meg := event_generator_with_name(tradable_processor_name)
            parameters := session.parameters_for_processor(meg)
        end

    iteration: INTEGER

    set_iteration(i: INTEGER)
        do
            iteration := i
        end

    name: STRING = "Event-generator parameters request"

invariant

    params_not_modified: not modify_parameters

end
