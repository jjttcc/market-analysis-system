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
	public Calendar start_date();

	// The end date-time of the data to be requested
	public Calendar end_date();

// Basic operations

	// Notify the client (this) that its associated data sets have been
	// updated.
	public void notify_of_update();

	// Notify the client (this) that the last data update failed.
	public void notify_of_failure(Exception e);
}
