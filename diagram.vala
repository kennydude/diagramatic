using Gtk;
using Xml;

// Main Class
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

		foreach(Sheet s in this.doc.sheets){
			addSheet(s);
		}
	}

	public void addSheet(Sheet s){
		// Setup sheet
		
		var xDoc = new ScrolledWindow( new Adjustment(0,0,0,0,0,0), new Adjustment(0,0,0,0,0,0) );
		var viewport = new Viewport(new Adjustment(0,0,0,0,0,0), new Adjustment(0,0,0,0,0,0));
		xDoc.child = viewport;
		var fixed = new Fixed();
		viewport.child = fixed;
		viewport.modify_bg( StateType.NORMAL, Shape.getWhite());
		fixed.draw.connect( (c) => {
			c.set_line_width(1);
			foreach( Link l in s.links) {
				// Draw line between them
				Shape a = s.shapes.nth_data(l.linkA);
				Shape b = s.shapes.nth_data(l.linkB);
				
				if(l.linkAPoint == "c"){ // Left or Right is best?
					if( a.x > b.x ){ // Come out of left
						c.move_to(a.x, a.y + (a.height/2) );
					} else{ // Come out of right
						c.move_to(a.x + a.width, a.y + (a.height/2) );
					}
				}
				
				// c.move_to(a.x, a.y);
				
				c.line_to(b.x, b.y);
				c.stroke();
			}
			return false;
		});

		// Add Shapes
		foreach(Shape shape in s.shapes){
			var view = shape.getWidget();
			view.set_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.BUTTON_MOTION_MASK);
			view.button_press_event.connect( (bp) => {
				view.set_data("in_motion", true);
				
				int pointX = 0; int pointY = 0;
				fixed.get_pointer(out pointX, out pointY);
				int origX = 0; int origY = 0;
				view.translate_coordinates(fixed, 0,0, out origX, out origY);
				
				view.set_data("startx", origX + origX);
				view.set_data("starty", origY + origY);
				view.set_data("startsx", pointX);
				view.set_data("startsy", pointY);
				view.is_focus = true;
				view.has_focus = true;
				return false;
			});
			view.button_release_event.connect( (bp) => {
				view.set_data("in_motion", false);
				return false;
			});
			view.motion_notify_event.connect( (me) => {
				// TODO: Make this less glitchy somehow
				if(view.get_data<bool>("in_motion") == true){
					int x = view.get_data<int>("startx") + (int)me.x - view.get_data<int>("startsx");
					int y = view.get_data<int>("starty") + (int)me.y - view.get_data<int>("startsy");
					((Fixed)view.parent).move(view, x,y );
					Shape sh = s.shapes.nth_data(view.get_data<int>("pos"));
					sh.x = x; sh.y = y;
				}
				return false;
			});
			view.set_data("pos", s.shapes.index(shape));
			view.focus_in_event.connect( (c) => {
				view.queue_draw();
				return false;
			});
				
			view.show();
			fixed.put(view, shape.x, shape.y);
		}

		// Add to sheets		
		xDoc.show_all();
		var label = new Label(s.name);
		// TODO: Context menu to change name etc.
		this.xSheets.insert_page( xDoc, label, -1 );

		
		stdout.printf("S: " + s.name  + "\n");
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
