/* Copyright 1998 - 2003: Jim Cochrane - see file forum.txt */

package common;

/** Constants shared by several MAS Java applications */
public interface Constants {

	// Maximum expected size of data received from the server
	//!!!!Probably no longer needed
	final int Max_input_count = 1000000;

	// Supposedly optimum message buffer size for efficiency
	final int Optimal_msg_buffer_size = 60000;

	// Java's end-of-file value
	final int End_of_file = -1;
}
