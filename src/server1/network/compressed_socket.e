indexing

	description:
		"Network socket whose put_string feature compresses its output %
		%before sending it"
	note: "Object is created with compression off.  It must be turned on %
		%with set_compression in order to invoke output compression."
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2001: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"

class COMPRESSED_SOCKET inherit

	NETWORK_STREAM_SOCKET
		redefine
			putstring, put_string
		end

	GUI_NETWORK_PROTOCOL
		rename
			error as gnp_error
		export
			{NONE} all
		end

creation

	make, make_server_by_port

feature -- Access

	compression: BOOLEAN
			-- Is compression turned on?

	Minimum_size: INTEGER is 0
			-- Minimum size for compression - buffers small than this
			-- will not compress effectively.
			-- Currently 0 - effectively not used - because of the
			-- client/server protocol (client asks for response to be
			-- compressed) - may be more useful in the future.

feature -- Status setting

	set_compression (arg: BOOLEAN) is
			-- Set compression to `arg'.
		require
			arg_not_void: arg /= Void
		do
			compression := arg
		ensure
			compression_set: compression = arg and compression /= Void
		end

feature -- Output

	put_string (s: STRING) is
			-- If compression and s.count >= Minimum_size, output `s'
			-- as compressed; otherwise, output it as is.
		do
			if compression and s.count >= Minimum_size then
				debug ("compression")
					print ("sending string with compression.%N")
				end
				put_compressed (s)
			else
				debug ("compression")
					print ("sending string without compression.%N")
				end
				Precursor (s)
			end
		end

	putstring (s: STRING) is do put_string (s) end

feature {NONE} -- Implementation

	put_compressed (s: STRING) is
		local
			c: ZLIB_COMPRESSION
			buffer: ANY
		do
			create c.make (s)
			c.execute
			buffer := c.raw_product
			c_put_stream (descriptor, $buffer, c.product_count)
		end

end -- class COMPRESSED_SOCKET
