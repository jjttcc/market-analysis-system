package application_library;

import java.util.*;

// A client of a TimeDelimitedDataRequest
public interface TimeDelimitedDataRequestClient {

// Access

	// Data set builder used to parse and build data received from the server
	public AbstractDataSetBuilder data_builder();

	// Specification for the data request
	public TradableDataSpecification specification();

	// The start date-time of the data to be requested
	// Precondition: ready_for_request()
	public Calendar start_date();

	// The end date-time of the data to be requested - null represents
	// the current time
	public Calendar end_date();

// Status report

	// Is the system ready for a time-delimited data request?
	public boolean ready_for_request();

// Basic operations

	// Notify the client (this) that its associated data sets have been
	// updated.
	public void notify_of_update();

	// Notify the client (this) that the last data update failed.
	public void notify_of_failure(Exception e);

	// Use the `last_latest_date_time' of `b' to update the "start date".
	public void update_start_date(AbstractDataSetBuilder b);

	// Notify the client (this) that the last data update had an error.
	// `result_id' is the result from `data_builder().request_result_id()'
	// `msg', if not null, provides information about the error.
	public void notify_of_error(int result_id, String msg);
}
