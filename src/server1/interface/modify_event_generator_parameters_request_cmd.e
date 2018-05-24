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
        rename
            tradable_processor as event_generator,
            set_tradable_processor as set_event_generator
        redefine
            modify_parameters, event_generator, requires_period_type,
            set_period_type
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

    period_type: STRING

    period_type_valid(pname: STRING): BOOLEAN
            -- Is `typename' a valid period-type name?
        local
            ptype_tools: expanded PERIOD_TYPE_FACILITIES
        do
            Result := ptype_tools.period_types.has(pname)
        end

feature {NONE} -- Hook method implementations

    object_type: STRING
        do
            Result := "event generator"
        end

    requires_period_type: BOOLEAN = True

    set_period_type(pertype: STRING)
            -- Set the period-type (name) attribute (in descendant class).
        do
            period_type := pertype
            if not period_type_valid(period_type) then
                parse_error := True
                error_msg := "Invalid period type: " + pertype
            end
        end

feature {NONE}

    set_event_generator
        do
            event_generator := event_generator_with_name(
                tradable_processor_name)
        end

    retrieve_parameters
        do
            parameters := session.parameters_for_processor(event_generator)
        end

    name: STRING = "Event generator parameters set request"

    event_generator: TRADABLE_EVENT_GENERATOR

end
