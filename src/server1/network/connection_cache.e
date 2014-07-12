note

    description:
        "Cache of connections..."
    author: "Jim Cochrane"
    date: "$Date$";
    revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"
    --settings: vim: expandtab:

class CONNECTION_CACHE inherit

create

    make

feature -- Initialization

    make(lim: INTEGER)
            -- Create the cache such that it's allowed to hold no more than
            -- 'limit' connection.
        do
            create contents.make(lim)
        end

feature -- Access

    limit: INTEGER
            -- Maximum limit on number of cached items
        do
            Result := contents.capacity
        end

feature -- Element change

    add(cmd: CONNECTED_SOCKET_POLL_COMMAND)
            -- Add 'cmd' to the cache.
        local
            oldest: CONNECTED_SOCKET_POLL_COMMAND
        do
            if contents.full then
                oldest := contents.item
                -- Remove the oldest item:
                contents.remove
--!!!!!!!!!!!!!!!!!!
--                oldest.set_close___
--!!!!!!!!!!!!!!!!!!
            end
            contents.put(cmd)
        end

feature {NONE} -- Implementation

    contents: BOUNDED_QUEUE [CONNECTED_SOCKET_POLL_COMMAND]

end
