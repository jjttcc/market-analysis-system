indexing
	description: "Windows used to locate a running, 'unowned' MAS session"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class LOCATE_SESSION_WINDOW inherit

	SESSION_WINDOW
		export
			{NONE} set_port_number
		end

	LOCATE_SESSION_SUPPLIER
		undefine
			default_create, copy
		end

create

	make

feature {NONE} -- Initialization

	make is
		do
			make_with_title (Locate_session_window_title)
			create_contents
		end

feature -- Client services

	register_client (c: LOCATE_SESSION_CLIENT; actn_code: INTEGER) is
			-- Register `c' as a "session-location" client with `actn_code'
			-- spcifying what action for the client to take on callback.
		require
			arg_exists: c /= Void
		do
			client := c
			action_code := actn_code
			ok.select_actions.extend (agent ok_response)
			cancel.select_actions.extend (agent cancel_response)
		ensure
			client_set: client = c
			code_set: action_code = actn_code
		end

feature {NONE} -- Implementation - initialization

	create_contents is
		do
			-- Avoid flicker on some platforms.
			lock_update
			extend (components)
			-- Allow screen refresh on some platoforms.
			unlock_update
		end

	components: EV_CONTAINER is
		local
			hnbox, portbox, button_box, ok_box, cancel_box: EV_HORIZONTAL_BOX
			host_label, port_label: EV_LABEL
		do
			create {EV_VERTICAL_BOX} Result
			create hnbox
			create portbox
			create button_box
			create {EV_LABEL} host_label.make_with_text ("host name:")
			hnbox.extend (host_label)
			create host_field.make_with_text ("localhost")
			hnbox.extend (host_field)
			create {EV_LABEL} port_label.make_with_text ("port number:")
			portbox.extend (port_label)
			create port_number_field
			portbox.extend (port_number_field)
			Result.extend (hnbox)
			Result.extend (portbox)
			-- Make host and port labels the same size.
			host_label.set_minimum_size (port_label.width + 12,
				port_label.height + 12)
			port_label.set_minimum_size (host_label.width, host_label.height)
			hnbox.set_border_width (8)
			portbox.set_border_width (hnbox.border_width)
			hnbox.show portbox.show
			create ok.make_with_text ("OK")
			create cancel.make_with_text ("Cancel")
			create ok_box; create cancel_box
			ok_box.set_border_width (6)
			cancel_box.set_border_width (ok_box.border_width)
			ok_box.extend (ok)
			cancel_box.extend (cancel)
			button_box.extend (ok_box)
			button_box.extend (cancel_box)
			-- Make "OK" and "Cancel" the same size:
			ok_box.set_minimum_width (cancel_box.minimum_width)
			Result.extend (button_box)
			button_box.show
		end

feature {NONE} -- Implementation - attributes

	client: LOCATE_SESSION_CLIENT

	ok, cancel: EV_BUTTON

	host_field: EV_TEXT_FIELD

	port_number_field: EV_TEXT_FIELD

feature {NONE} -- Implementation - constants

	Locate_session_window_title: STRING is "Locate MAS session"
			-- Title of locate-mas-session windows

feature {NONE} -- Implementation - GUI callback routines

	ok_response is
			-- Response to pressing of "OK" button
		do
			host_name := host_field.text
			port_number := port_number_field.text
			destroy
			client.respond_to_session_location (Current)
		end

	cancel_response is
			-- Response to pressing of "Cancel" button
		do
			host_name := host_field.text
			port_number := port_number_field.text
			destroy
			client.respond_to_session_location_cancellation (Current)
		end

invariant

	ok_cancel_exist: ok /= Void and cancel /= Void

end
