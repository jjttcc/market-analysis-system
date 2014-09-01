note

    description:
        "Basic constants and queries specifying communication protocol %
        %components that are used by more than one application"
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    -- vim: expandtab

deferred class

    BASIC_COMMUNICATION_PROTOCOL

feature -- String constants

    message_component_separator: STRING = "%T"
        -- Character used to separate top-level message components

    message_record_separator: STRING = "%N"
        -- Character used to separate "records" or "lines" within
        -- a message component

    message_sub_field_separator:STRING = ","
        -- Character used to separate field sub-components

    message_key_value_separator:STRING = ":"
        -- Character used to separate a key/value pair

invariant

end
