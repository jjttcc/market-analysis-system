class

	SETTABLE_HTTP_URL

inherit

	HTTP_URL

create

	make, http_make

feature -- Initialization

	http_make (h, p: STRING) is
		require
			args_valid: h /= Void and p /= Void and not h.is_empty and
				not p.is_empty
		do
			host := h
			path := p
			make ("http://" + host + "/" + path)
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
		ensure
			host_set: host /= Void and host = h
		end

	set_path (p: STRING) is
		require
			p_valid: p /= Void and not p.is_empty
		do
			path := p
		ensure
			path_set: path /= Void and path = p
		end

end
