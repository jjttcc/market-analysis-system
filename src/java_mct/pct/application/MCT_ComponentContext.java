package pct.application;

// Data associated with a MAS Control Terminal component
class MCT_ComponentContext {
	public MCT_ComponentContext(Process proc, String hostname,
			int port_number) {
		_server_process = proc;
		_server_host_name = hostname;
		_server_port_number = port_number;
	}

	public Process server_process() {
		return _server_process;
	}

	public String server_host_name() {
		return _server_host_name;
	}

	public int server_port_number() {
		return _server_port_number;
	}

	protected Process _server_process;
	protected String _server_host_name;
	protected int _server_port_number;
}
