package application_library;

import java.util.*;
import java_library.support.*;
import common.*;
import graph_library.DataSet;

/**
* Objects that manage requesting and obtaining tradable data from the
* server in a thread-safe manner, using the given data builder's lock/unlock
* facilities
**/
public class SynchronizedDataRequester extends Logic
	implements NetworkProtocol {

// Initialization

	/**
	* Initialize data builder, symbol, period type, and number of times
	* to attempt the lock.
	**/
	public SynchronizedDataRequester(AbstractDataSetBuilder b, String sym,
			String pertype) {

		data_builder = b;
		symbol = sym;
		period_type = pertype;
	}

// Access

	/**
	* Symbol of the current tradable for which data is being requested
	**/
	public String current_symbol() {
		return symbol;
	}

	/**
	* Maximum number of times to try to lock the data builder before
	* giving up
	**/
	public int maximum_number_of_lock_attempts() {
		return maximum_number_of_lock_attempts;
	}

	/**
	* The result of the last tradable data request
	**/
	public DataSet tradable_result() {
		return tradable_result;
	}

	/**
	* The result of the last indicator data request
	**/
	public DataSet indicator_result() {
		return indicator_result;
	}

	/**
	* The result of the last indicator list request
	**/
	public Vector indicator_list_result() {
		return indicator_list_result;
	}

	/**
	* The volume from the last tradable data request
	**/
	public DataSet volume_result() {
		return volume_result;
	}

	/**
	* The open interest from the last tradable data request
	**/
	public DataSet open_interest_result() {
		return open_interest_result;
	}

	/**
	* Latest date-time from last call of `execute_tradable_request'
	**/
	public Calendar latest_date_time() {
		return latest_date_time;
	}

	/**
	* Request result ID from last call of `execute_tradable_request'
	**/
	public int request_result_id() {
		return request_result_id;
	}

// Status report

	/**
	* Did the data request fail?
	**/
	public boolean request_failed() {
		return request_failed;
	}

	/**
	* If `request_failed', information about the failure
	**/
	public String request_failure_message() {
		return request_failure_message;
	}

// Element change

	// Set the maximum number of times to attempt a lock to `arg'.
	public void set_maximum_number_of_lock_attempts(int arg) {
		maximum_number_of_lock_attempts = arg;
	}

// Basic operations

	/**
	* Perform a request for the main data of the tradable with the specified
	* symbol.
	**/
	public void execute_tradable_request() throws Exception {
		request_failed = false;
		request_failure_message = "";
		lock_data_builder();
		if (data_builder.is_locked_by(this)) {
			data_builder.send_market_data_request(symbol, period_type);
			request_result_id = data_builder.request_result_id();
			if (! data_builder.request_succeeded()) {
				request_failed = true;
//!!!!Obsolete - remove:
////@@@Check if throwing an exception is appropriate here.
//throw new Exception(main_request_failed_message);
			} else {
				// 'send_market_data_request' was successful.
				tradable_result = data_builder.last_market_data();
				volume_result = data_builder.last_volume();
				open_interest_result = data_builder.last_open_interest();
				latest_date_time = data_builder.last_latest_date_time();
				assert ! request_failed(): "data request succeeded";
			}
			data_builder.unlock(this);
		} else {
			request_failed = true;
			// Lock attempts failed.
			request_failure_message = main_lock_request_failed_message;
//!!!: System.out.println("Would previously have thrown an exception here [main data]");
		}
		assert ! data_builder.is_locked_by(this): "builder not locked";
		assert implies(! data_builder.request_succeeded(), request_failed());
	}

	/**
	* Perform a request for the specified indicator data of the tradable
	* with the specified symbol.
	**/
	public void execute_indicator_request(int indicator_id) throws Exception {
		request_failed = false;
		request_failure_message = "";
		lock_data_builder();
		if (data_builder.is_locked_by(this)) {
			data_builder.send_indicator_data_request(indicator_id, symbol,
				period_type);
			request_result_id = data_builder.request_result_id();
			if (! data_builder.request_succeeded()) {
				request_failed = true;
//!!!!Obsolete - remove:
////@@@Check if throwing an exception is appropriate here.
//throw new Exception(indicator_request_failed_message);
			} else {
				indicator_result = data_builder.last_indicator_data();
				assert ! request_failed(): "data request succeeded";
			}
			data_builder.unlock(this);
		} else {
			request_failed = true;
			// Lock attempts failed.
			request_failure_message = indicator_lock_request_failed_message;
//!!!: System.out.println("Would previously have thrown an exception here [indicator data]");
		}
		assert ! data_builder.is_locked_by(this): "builder not locked";
		assert implies(! data_builder.request_succeeded(), request_failed());
	}

	/**
	* Perform a request for the list of available indicators for the
	* associated tradable and period type.
	**/
	public void execute_indicator_list_request() throws Exception {
		request_failed = false;
		request_failure_message = "";
		lock_data_builder();
		if (data_builder.is_locked_by(this)) {
			data_builder.send_indicator_list_request(symbol, period_type);
			request_result_id = data_builder.request_result_id();
			if (! data_builder.request_succeeded()) {
				request_failed = true;
//!!!!Obsolete - remove:
////@@@Check if throwing an exception is appropriate here.
//throw new Exception(indicator_list_request_failed_message);
			} else {
				indicator_list_result = data_builder.last_indicator_list();
				assert ! request_failed(): "data request succeeded";
			}
			data_builder.unlock(this);
		} else {
			request_failed = true;
			// Lock attempts failed.
			request_failure_message =
				indicator_list_lock_request_failed_message;
//!!!: System.out.println("Would previously have thrown an exception here [indicator list data]");
		}
		assert ! data_builder.is_locked_by(this): "builder not locked";
		assert implies(! data_builder.request_succeeded(), request_failed());
	}

// Implementation

	// Attempt - no more than `maximum_number_of_lock_attempts' times -
	// to lock `data_builder'.
	private void lock_data_builder() throws InterruptedException {
		int i = 1;
		data_builder.lock(this);
		while (! data_builder.is_locked_by(this) &&
				i < maximum_number_of_lock_attempts) {

			Thread.sleep(sleep_time);
			data_builder.lock(this);
			++i;
		}
	}

// Implementation - Constants

	private static final int DEFAULT_MAX_LOCK_TRIES = 5;

// Implementation - Attributes

	private AbstractDataSetBuilder data_builder;
	private int maximum_number_of_lock_attempts = DEFAULT_MAX_LOCK_TRIES;
	private boolean request_failed = false;
	private String symbol;
	private String period_type;
	private int sleep_time = 300;

	private DataSet tradable_result = null;
	private DataSet indicator_result = null;
	private DataSet volume_result = null;
	private DataSet open_interest_result = null;
	private Vector indicator_list_result = null;
	private Calendar latest_date_time = null;
	private int request_result_id = -1;
	public String request_failure_message = "";

	private final String indicator_request_failed_message =
		"Indicator request failed";
	private final String main_request_failed_message =
		"Main data request failed";
	private final String indicator_list_request_failed_message =
		"Indicator list request failed";
	private final String indicator_lock_request_failed_message =
		"Indicator lock request failed";
	private final String main_lock_request_failed_message =
		"Main data lock request failed";
	private final String indicator_list_lock_request_failed_message =
		"Indicator list lock request failed";
}
