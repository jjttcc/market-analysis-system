/**
	author: "Jim Cochrane"
	date: "$Date$";
	revision: "$Revision$"
	licensing: "Copyright 1998 - 2005: Jim Cochrane - %
		%Released under the Eiffel Forum License; see file forum.txt"
*/

package support;

import java_library.support.*;

/**
* Information about the current version of the GUI client application
**/
public class MasProductInfo extends ProductInfo {

	public String name() {
		return "Market Analysis Charting Client";
	}

	/**
	* The components of the version number
	* Components are strings to allow mixed numbers and letters.
	**/
	public String[] number_components() {
		String[] result = {"1", "6", "1a"};
		return result;
	}

	/**
	* The last date that `number' was updated
	**/
	public String date() {
		return "2005-02-08";
	}

	/**
	* Short description of the current release
	**/
	public String release_description() {
		return number() + " - (development release)";
	}

	public String copyright() {
		return "Copyright 1998 - 2005: Jim Cochrane";
	}

	public String license_information() {
		return "License: To be defined";
	}
}
