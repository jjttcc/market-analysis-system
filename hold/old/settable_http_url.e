class

	SETTABLE_HTTP_URL

inherit

	HTTP_URL

create

	http_make

feature -- Initialization

	http_make (h, p: STRING) is
		require
			args_valid: h /= Void and p /= Void
		do
			host := h
			path := p
			make_address
		ensure
			host_set: host /= Void and host = h
			path_set: path /= Void and path = p
			address_set: address.is_equal ("http://" + host + "/" + path)
		end

feature -- Element change

	set_host (h: STRING) is
		require
			h_valid: h /= Void and not h.is_empty
		do
			host := h
			make_address
		ensure
			host_set: host /= Void and host = h
			address_set: address.is_equal ("http://" + host + "/" + path)
		end

	set_path (p: STRING) is
		require
			p_valid: p /= Void and not p.is_empty
		do
			path := p
			make_address
		ensure
			path_set: path /= Void and path = p
			address_set: address.is_equal ("http://" + host + "/" + path)
		end

feature {NONE} -- Implementation

	make_address is
		do
			make ("http://" + host + "/" + path)
		end

end
