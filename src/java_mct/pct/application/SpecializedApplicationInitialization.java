package pct.application;

import pct.*;

// ApplicationInitialization class specialed for the MAS Control Terminal
public class SpecializedApplicationInitialization
		extends ApplicationInitialization {
	public SpecializedApplicationInitialization() {
	}

	static {
		_context = new MCT_ApplicationContext();
	}
}
