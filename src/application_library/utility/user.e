indexing
	description: "Abstraction for a user with an email address, etc."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class USER inherit

	EXECUTION_ENVIRONMENT

creation

	make

feature {NONE} -- Initialization

	make is
		do
			!!email_addresses.make
		end

feature -- Access

	name: STRING

	email_addresses: LINKED_LIST [STRING]
			-- email addresses

	primary_email_addresss: STRING is
		do
			if not email_addresses.empty then
				Result := email_addresses @ 1
			end
		end

feature -- Element change

	add_email_address (arg: STRING) is
			-- Add the email address `arg'.
		require
			arg_not_void: arg /= Void
		do
			email_addresses.extend (arg)
		ensure
			one_more: email_addresses.count = old email_addresses.count + 1
		end

	set_name (arg: STRING) is
			-- Set name to `arg'.
		require
			arg_not_void: arg /= Void
		do
			name := arg
		ensure
			name_set: name = arg and name /= Void
		end

feature -- Basic operations

	notify_by_email (s, subject: STRING) is
			-- Send message `s' to the user by email with `subject' as the
			-- subject.  If environment variable MAILER is not defined, no
			-- action is taken.
		require
			s_not_void: s /= Void
			at_least_one_address: not email_addresses.empty
		local
			msg_file: PLAIN_TEXT_FILE
			mail_cmd, mailer: STRING
		do
			mailer := get ("MAILER")
			msg_file := temporary_file (email_addresses @ 1)
			if not tmp_file_failed and mailer /= Void then
				msg_file.put_string (s)
				!!mail_cmd.make (25)
				mail_cmd.append (mailer)
				mail_cmd.extend (' ')
				if subject /= Void and then not subject.empty then
					mail_cmd.append (subject_flag)
					mail_cmd.append (" '")
					mail_cmd.append (subject)
					mail_cmd.append ("' ")
				end
				mail_cmd.append (email_addresses @ 1)
				mail_cmd.append (" <")
				mail_cmd.append (msg_file.name)
				msg_file.flush
				system (mail_cmd)
				msg_file.delete
			end
		end

feature {NONE}

	subject_flag: STRING is "-s"
			-- Flag to use to specify subject with the user's mailer
			-- Hard-coded for now - needs to be configurable.

	temporary_file (s: STRING): PLAIN_TEXT_FILE is
			-- Temporary file for writing - new file
		require
			not_void: s /= Void
		local
			d: DIRECTORY
			i: INTEGER
			fname: STRING
		do
			tmp_file_failed := false
			from
				fname := clone (s)
				fname.append_integer (s.hash_code)
				!!d.make_open_read (".")
				i := 1
			until
				not d.has_entry (fname) or i > 20
			loop
				fname.append_integer (i)
				i := i + 1
			end
			if d.has_entry (fname) then
				tmp_file_failed := true
			else
				!!Result.make_open_write (fname)
			end
		ensure
			failed_or_writable: tmp_file_failed or else Result.is_open_write
		end

	tmp_file_failed: BOOLEAN

invariant

	eaddrs_not_void: email_addresses /= Void
	primary_eaddr_definition: not email_addresses.empty implies
			primary_email_addresss = email_addresses @ 1

end -- USER
