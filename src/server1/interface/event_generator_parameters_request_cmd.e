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
        rename
            tradable_processor as event_generator,
            set_tradable_processor as set_event_generator
        redefine
            iteration, set_iteration, event_generator
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

    set_event_generator
        do
            event_generator := event_generator_with_name(
                tradable_processor_name)
        end

    retrieve_parameters
        do
--With respect to the list of parameters being retrieved and reported
--back to the client:
--    If there are parameters with duplicate names and different ids,
--    that is a bug - the names should not be duplicated.
--    If there are parameters with the same id (i.e., referencing the same
--    object), that seems to be a bug with 2 different possibilities:
--      - If these "same-reference" parameters are supposed to be shared,
--        only one of them should be sent to the client; if the client
--        changes it (via MODIFY_*REQUEST_CMD), that one object changes
--        and the change is seen by all objects that refer to it - this
--        is why it is shared, i.e., to share its value.
--      - If these "same-reference" parameters are not supposed to be
--        shared, there is either a bug in the code causing this
--        incorrect sharing, or the user has mistakenly specified that
--        it be shared when creating the owning analyzer/indicator; the
--        first case is a bug to be fixed, the 2nd case seems to be user
--        error, although there may (or may not) be user-interface
--        changes possible that make it less likely for the user to make
--        this mistake.
--    The above also applies to indicator parameter commmands, of course.
-- (Todo: Look at ind: Slope of MACD Signal Line Trend)
            parameters := session.parameters_for_processor(event_generator)
        end

    iteration: INTEGER

    set_iteration(i: INTEGER)
        do
            iteration := i
        end

    name: STRING = "Event-generator parameters request"

    event_generator: TRADABLE_EVENT_GENERATOR

feature {NONE} -- Hook method implementations

    object_type: STRING
        do
            Result := "event generator"
        end

invariant

    params_not_modified: not modify_parameters

end
