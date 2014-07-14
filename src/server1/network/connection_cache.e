note

    description:
        "Bounded cache of CONNECTED_SOCKET_POLL_COMMANDs with associated open %
        %sockets, used to limit the number of simultaneous open TCP socket %
        %connections"
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
        require
            sane_limit: lim >= 1
        do
            create contents.make(lim)
print("debug/CONNECTION_CACHE: limit: " + limit.out + "%N")
        ensure
            promised_limit: limit = lim
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
print("CONNECTION_CACHE calling cleanup on " + oldest.out + "%N")
                oldest.cleanup
            end
            contents.put(cmd)
        end

feature {NONE} -- Implementation

    contents: BOUNDED_QUEUE [CONNECTED_SOCKET_POLL_COMMAND]

end
