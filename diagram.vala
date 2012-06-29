using Gtk;
using Xml;

class Diagramatic : Object{
	DiagramDocument doc;
	Notebook xSheets;
	Builder builder;

	public void loadFile(string filename){
		Xml.Doc* doc = Parser.parse_file (filename);
		if(doc == null){
			stdout.printf("File Not Found\n");
			return;
		}
	
		this.doc.readXML(doc);
		Gdk.Color c;
		Gdk.Color.parse("white", out c);		

		foreach(Sheet s in this.doc.sheets){
			var adj = new Adjustment(0,0,0,0,0,0);
			
			var xDoc = new ScrolledWindow( new Adjustment(0,0,0,0,0,0), new Adjustment(0,0,0,0,0,0) );
			var viewport = new Viewport(adj,adj);
			xDoc.child = viewport;
			var fixed = new Fixed();
			viewport.child = fixed;
			xDoc.show_all();
			viewport.modify_bg( StateType.NORMAL, c);
			
			var label = new Label(s.name);
			this.xSheets.insert_page( xDoc, label, -1 );
			
			stdout.printf("S: " + s.name  + "\n");
		}
	}

	public Diagramatic(string[] args){
		Gtk.init (ref args);

		try {
			builder = new Builder ();
			builder.add_from_file ("diagram.ui");
			builder.connect_signals (null);
			var window = builder.get_object ("window") as Window;
			window.show_all ();

			window.destroy.connect(Gtk.main_quit);
			this.xSheets = builder.get_object("sheets") as Notebook;

			doc = new DiagramDocument();
			loadFile("new.xml");

			Gtk.main ();
		} catch (GLib.Error e) {
			stderr.printf ("Could not load UI: %s\n", e.message);
		} 
	}

	public static int main (string[] args) {  
		stdout.printf("Diagramatic.\n");
		stdout.printf("--------\n");
		stdout.printf("Created by @kennydude aka Joe Simpson\n");   
		
		new Diagramatic(args);

		return 0;
	}

}
