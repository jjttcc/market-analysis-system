indexing
	description: "Abstraction for a user with an email address, etc."
	status: "Copyright 1998 Jim Cochrane and others, see file forum.txt"
	date: "$Date$";
	revision: "$Revision$"

class USER inherit

	EXECUTION_ENVIRONMENT
		export {NONE}
			all
		end

	OPERATING_ENVIRONMENT
		export {NONE}
			all
		end

	PRINTING
		export {NONE}
			all
		end

creation

	make

feature {NONE} -- Initialization

	make is
		do
			!!email_addresses.make
		end

feature -- Access

	name: STRING
			-- User name

	mailer: STRING
			-- Name of program to use for sending email

	email_subject_flag: STRING
			-- Flag to use with mailer to specify subject line

	email_addresses: LINKED_LIST [STRING]
			-- email addresses

	primary_email_address: STRING is
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

	set_mailer (arg: STRING) is
			-- Set mailer to `arg'.
		require
			arg_not_void: arg /= Void
		do
			mailer := arg
		ensure
			mailer_set: mailer = arg and mailer /= Void
		end

	set_email_subject_flag (arg: STRING) is
			-- Set email_subject_flag to `arg'.
		require
			arg_not_void: arg /= Void
		do
			email_subject_flag := arg
		ensure
			email_subject_flag_set: email_subject_flag = arg and
									email_subject_flag /= Void
		end

feature -- Basic operations

	notify_by_email (s, subject: STRING) is
			-- Send message `s' to the user by email with `subject' as the
			-- subject.
		require
			s_not_void: s /= Void
			at_least_one_address: not email_addresses.empty
			mailer_not_void: mailer /= Void
		local
			msg_file: PLAIN_TEXT_FILE
			mail_cmd: STRING
		do
			msg_file := temporary_file (email_addresses @ 1)
			if not tmp_file_failed then
				msg_file.put_string (s)
				!!mail_cmd.make (25)
				mail_cmd.append (mailer)
				mail_cmd.extend (' ')
				if
					email_subject_flag /= Void and then subject /= Void
					and then not subject.empty
				then
					mail_cmd.append (email_subject_flag)
					mail_cmd.append (" '")
					mail_cmd.append (subject)
					mail_cmd.append ("' ")
				end
				mail_cmd.append (email_addresses @ 1)
				-- !!!OS-specific construct here:
				mail_cmd.append (" <")
				mail_cmd.append (msg_file.name)
				msg_file.flush
				system (mail_cmd)
				msg_file.delete
			end
		end

feature {NONE}

	temporary_file (s: STRING): PLAIN_TEXT_FILE is
			-- Temporary file for writing - new file
		require
			not_void: s /= Void
		local
			tmpdir: DIRECTORY
			i: INTEGER
			fname, dirname: STRING
		do
			tmp_file_failed := false
			!!dirname.make (4)
			dirname.append_character (Directory_separator)
			dirname.append ("tmp")
			!!tmpdir.make (dirname)
			if not tmpdir.exists then
				!!tmpdir.make (".")
			end
			from
				fname := clone (s)
				fname.append_integer (s.hash_code)
				tmpdir.open_read
				i := 1
			until
				not tmpdir.has_entry (fname) or i > 20
			loop
				fname.append_integer (i)
				i := i + 1
			end
			if tmpdir.has_entry (fname) then
				tmp_file_failed := true
			else
				!!Result.make_open_write (fname)
			end
		ensure
			failed_or_writable: tmp_file_failed or else Result.is_open_write
		rescue
			tmp_file_failed := true
			print_list (<<"Error: Failed to open temporary file: ",
				tmpdir, Directory_separator, fname, ".%N">>)
		end

	tmp_file_failed: BOOLEAN

	output_field_separator, output_record_separator,
	output_date_field_separator: STRING is ""

invariant

	eaddrs_not_void: email_addresses /= Void
	primary_eaddr_definition: not email_addresses.empty implies
			primary_email_address = email_addresses @ 1

end -- USER
