using Gee;
namespace XSIRC {
	public class PluginManager : Object {
		private ArrayList<Plugin> plugins = new ArrayList<Plugin>();
		
		private delegate void RegisterPluginFunc(Module module);
		
		public PluginManager() {
			// If modules aren't supported, the client shouldn't even have
			// compiled, but checking doesn't hurt
			assert(Module.supported());
		}
		
		public void startup() {
			load_plugins();
			
			// Infodump for plugins, testing stuff
			stdout.printf("Dumping plugin info\n");
			foreach(Plugin plugin in plugins) {
				stdout.printf("Info for plugin %s:\n",plugin.name);
				stdout.printf("\tDescription: %s\n",plugin.description);
				stdout.printf("\tVersion: %s\n",plugin.version);
				stdout.printf("\tAuthor: %s\n",plugin.author);
			}
		}
		
		private LinkedList<string> load_plugins() {
			// Loading "system" plugins, that is, those installed in PREFIX/lib/xsirc
			File sys_plugin_dir = File.new_for_path(PREFIX+"/lib/xsirc");
			assert(sys_plugin_dir.query_exists());
			LinkedList<string> failed_plugins = new LinkedList<string>();
			try {
				FileEnumerator sys_files = sys_plugin_dir.enumerate_children("standard::name",0);
				FileInfo file;
				while((file = sys_files.next_file()) != null) {
					stdout.printf("In loop\n");
					if(true/*file.get_file_type() == FileType.REGULAR*/) {
						string name = file.get_name();
						stdout.printf("%s\n",name);
						if(name.has_suffix("."+Module.SUFFIX)) {
							if(!load_plugin(PREFIX+"/lib/xsirc/"+name)) {
								stderr.printf("Could not load a default plugin. This is, most likely, a bug. File name: %s\n",name);
							}
						}
					}
				}
			} catch(Error e) {
				
			}
			
			File user_plugin_dir = File.new_for_path(Environment.get_user_config_dir()+"/xsirc/plugins");
			try {
				FileEnumerator user_files = user_plugin_dir.enumerate_children("standard::name",0);
				FileInfo file;
				while((file = user_files.next_file()) != null) {
					if(file.get_file_type() == FileType.REGULAR) {
						string name = file.get_attribute_string("standard::name");
						if(name.has_suffix("."+Module.SUFFIX)) {
							if(!load_plugin(Environment.get_user_config_dir()+"/xsirc/plugins/"+name)) {
								failed_plugins.add(name);
							}
						}
					}
				}
			} catch(Error e) {
				
			}
			
			return failed_plugins;
		}
		
		private bool load_plugin(string filename) {
			stdout.printf("Loading module %s\n",filename);
			Module module = Module.open(filename,ModuleFlags.BIND_LAZY);
			if(module == null) {
				stdout.printf("Failed to load module %s: %s\n",filename,Module.error());
				return false;
			}
			
			stdout.printf("Loaded module %s\n",filename);
			
			void* func;
			module.symbol("register_plugin",out func);
			RegisterPluginFunc register_plugin = (RegisterPluginFunc)func;
			
			register_plugin(module);
			return true;
		}
		
		public void add_plugin(Plugin plugin) {
			plugins.add(plugin);
			plugins.sort((CompareFunc)plugincmp);
		}
		
		// APi goes here.
		public internal void on_join(Server server,string usernick,string username,string usermask,string channel) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_part(Server server,string usernick,string username,string usermask,string channel,string message) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_kick(Server server,string kicker,string usernick,string username,string usermask,string channel,string message) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_nick(Server server,string new_nick,string usernick,string username,string usermask) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_privmsg(Server server,string usernick,string username,string usermask,string target,string message) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_notice(Server server,string usernick,string username,string usermask,string target,string message) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_quit(Server server,string usernick,string username,string usermask,string message) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_chan_user_mode(Server server,string usernick,string username,string usermask,string channel,string modes,string targets) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_chan_mode(Server server,string usernick,string username,string usermask,string channel,string modes) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_mode(Server server,string usernick,string mode) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_topic(Server server,string usernick,string username,string usermask,string channel,string topic) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_startup() {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_shutdown() {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_connect(Server server) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_disconnect(Server server) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
		
		public internal void on_connect_error(Server server) {
			foreach(Plugin plugin in plugins) {
				if(!plugin.on_()) {
					break;
				}
			}
		}
	}
	
	int plugincmp(Plugin a,Plugin b) {
		if(a.priority < b.priority) {
			return -1;
		} else if(a.priority == b.priority) {
			return 0;
		} else {
			return 1;
		}
	}
}