package pct;

// Required initialization of plug-in components - default: do nothing -
// subclass as needed
public class ApplicationInitialization {
	public ApplicationInitialization() {}

	// Global context data for application - redefine as needed
	public static ApplicationContext context() {
		if (_context == null) {
			_context = new ApplicationContext();
		}
		return _context;
	}

	protected static ApplicationContext _context;
}
