package application_library;

import java.util.*;
import java_library.support.*;
import graph_library.DataSet;

/**
* General specification for a tradable data request to the server
**/
abstract public class DataSpecification implements AssertionConstants {

// Access

	/**
	* The current data
	**/
	public abstract DataSet current_data();

// Status report

	// Did the last call to `append_data' actually add any records?
	public boolean last_append_changed_state() {
		return last_append_changed_state;
	}

// Removal

	/**
	* Clear `current_data'.
	**/
	public abstract void clear_data();

// Implementation - Attributes

	protected boolean last_append_changed_state;
}
