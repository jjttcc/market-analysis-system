note
	description: "Basic tools for GUI components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
    copyright: "Copyright (c) 1998-2014, Jim Cochrane"
    license:   "GPL version 2 - http://www.gnu.org/licenses/gpl-2.0.html"

class GUI_TOOLS inherit

feature -- Basic operations

	close_on_esc (k: EV_KEY; window: EV_WINDOW)
			-- Close `window' if `k' is the escape key.
		local
			key_constants: expanded EV_KEY_CONSTANTS
		do
			if k.code = key_constants.key_escape then
				window.destroy
			end
		end

	add_close_window_accelerator (window: EV_TITLED_WINDOW)
			-- Add a "close-window" acceleartor to `window'.
		local
			wbldr: expanded WIDGET_BUILDER
			key_const: expanded EV_KEY_CONSTANTS
			accel: EV_ACCELERATOR
		do
			accel := wbldr.default_accelerator (key_const.key_w)
			window.accelerators.extend (accel)
			accel.actions.extend (agent window.destroy)
		end

	set_busy_cursor (w: EV_WIDGET): EV_CURSOR
			-- Set `w's cursor to a busy cursor and return the previous
			-- cursor.
		do
			Result := w.pointer_style
			w.set_pointer_style ((create {EV_STOCK_PIXMAPS}).Busy_cursor)
		end

	restore_cursor (w: EV_WIDGET; c: EV_CURSOR)
			-- Restore `w's cursor to `c'.
		do
			w.set_pointer_style (c)
		end

end
