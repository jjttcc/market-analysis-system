note
    description:
        "A MAS server command that responds to a client request"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    --settings: vim: expandtab:

deferred class MAS_REQUEST_COMMAND inherit

    IO_BASED_CLIENT_REQUEST_COMMAND
        redefine
            session
        end

    GUI_COMMUNICATION_PROTOCOL
        export
            {NONE} all
        end

    DATE_TIME_PROTOCOL
        export
            {NONE} all
        end

feature -- Access

    session: MAS_SESSION

feature -- Status report

    arg_mandatory: BOOLEAN = True

    close_connection: BOOLEAN assign set_close_connection
            -- Should the connection to the client be closed after the
            -- response is set?

feature -- Status setting

    set_close_connection(value: BOOLEAN)
        do
            close_connection := value
        end

feature {NONE}

    error_string: STRING
            -- "error" message ID and field separator
        note
            once_status: global
        do
            if close_connection then
                Result := error.out + message_component_separator
            else
                Result := error_will_not_close.out +
                    message_component_separator
            end
        end

    ok_string: STRING
            -- "OK" message ID and field separator
        note
            once_status: global
        do
            if close_connection then
                Result := ok.out + message_component_separator
            else
                Result := ok_will_not_close.out + message_component_separator
            end
        end

    invalid_sym_string: STRING
            -- "invalid symbol" message ID and field separator
        note
            once_status: global
        do
            if close_connection then
                Result := invalid_symbol.out + message_component_separator
            else
                Result := invalid_symbol_will_not_close.out +
                    message_component_separator
            end
        end

    warning_string: STRING
            -- "warning" message ID and field separator
        note
            once_status: global
        do
            if close_connection then
                Result := warning.out + message_component_separator
            else
                Result := warning_will_not_close.out +
                    message_component_separator
            end
        end

    invalid_period_string: STRING
            -- "invalid period" message ID and field separator
        note
            once_status: global
        do
            if close_connection then
                Result := invalid_period_type.out + message_component_separator
            else
                Result := invalid_period_type_will_not_close.out +
                    message_component_separator
            end
        end

end
