indexing
	description: "Basic tools for GUI components"
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 2003: Jim Cochrane - %
		%License to be determined"

class GUI_TOOLS inherit

feature -- Basic operations

	close_on_esc (k: EV_KEY; window: EV_WINDOW) is
			-- Close `window' if `k' is the escape key.
		local
			key_constants: expanded EV_KEY_CONSTANTS
		do
			if k.code = key_constants.key_escape then
				window.destroy
			end
		end

	add_close_window_accelerator (window: EV_TITLED_WINDOW) is
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

end
