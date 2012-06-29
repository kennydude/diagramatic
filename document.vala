// Document class
using Xml, Gtk, Rsvg, Cairo, Pango;

class DiagramDocument : Object{
	public List<Sheet> sheets = new List<Sheet>();
	
	public void readXML(Xml.Doc* doc){
		Xml.Node* root = doc->get_root_element ();
		if(root == null){
			stdout.printf("No root element in file!\n");
			return;
		}
		
		for (Xml.Node* iter = root->children; iter != null; iter = iter->next) {
			// Spaces between tags are also nodes, discard them
			if (iter->type != ElementType.ELEMENT_NODE) {
				continue;
			}
			if(iter->name == "Sheet"){
				Sheet sheet = new Sheet();
				sheet.readXML(iter);
				sheets.append(sheet);
			}
		}
		
	}
}

class Sheet : Object{
	public string name;
	public List<Shape> shapes = new List<Shape>();
	public List<Link> links = new List<Link>();
	
	public void readXML(Xml.Node node){
		this.name = node.get_prop("name");
		
		for (Xml.Node* iter = node.children; iter != null; iter = iter->next) {
			// Spaces between tags are also nodes, discard them
			if (iter->type != ElementType.ELEMENT_NODE) {
				continue;
			}
			if(iter->name == "Shape"){
				Shape shape = Shape.fromXML(iter);
				shapes.append(shape);
			} else if(iter->name == "Link"){
				Link link = new Link();
				link.fromXML(iter);
				links.append(link);
			}
		}
	}
}

class Link : Object{
	public int linkA = 0;
	public int linkB = 0;
	
	public void fromXML(Xml.Node node){
		linkA = int.parse(node.get_prop("a"));
		linkB = int.parse(node.get_prop("b"));
	}
}

class Shape : Object{
	public string obj_url;
	public int x;
	public int y;
	public int width;
	public int height;	
	public string text;
	public string font = "Ubuntu 12";
	
	public static Gdk.Color getWhite(){
		Gdk.Color c;
		Gdk.Color.parse("white", out c);
		return c;
	}
	
	public static Shape fromXML(Xml.Node node){
		Shape r = new Shape();
		r.obj_url = node.get_prop("type");
		// TODO: Some kind of check to see what type to use
		
		r.x = int.parse(node.get_prop("x"));
		r.y = int.parse(node.get_prop("y"));
		r.width = int.parse(node.get_prop("width"));
		r.height = int.parse(node.get_prop("height"));
		r.text = node.get_prop("text");
		return r;
	}

	public Widget getWidget(){
		DrawingArea view = new DrawingArea();
		view.width_request = this.width;
		view.height_request = this.height;
		view.can_focus = true;
		view.modify_bg( StateType.NORMAL, getWhite());
		try{
			Rsvg.Handle file = new Rsvg.Handle.from_file("shapes/" + obj_url + ".svg");
			view.draw.connect( (c) => {
				file.render_cairo(c);
				
				Pango.Context pc = Pango.cairo_create_context(c);
				c.set_antialias( Cairo.Antialias.SUBPIXEL );
				Pango.Layout l = new Pango.Layout(pc);
				l.set_font_description( Pango.FontDescription.from_string(this.font));
				l.set_text(this.text, -1);
				l.set_alignment( Pango.Alignment.CENTER );
				int w = 0, h = 0;
				l.get_pixel_size(out w, out h);
				c.move_to( this.width/2 - w/2, this.height/2 - h/2);			
				
				c.set_source_rgb(0, 0, 0);
				Pango.cairo_update_layout(c, l);
				Pango.cairo_show_layout(c, l);

				if(view.has_focus){
					c.set_source_rgb(0,0,200);
					c.move_to(0,0);
					c.rectangle(0,0,this.width-1,this.height-1);
				}
				
				return false;
			});
		} catch(GLib.Error e){
			stderr.printf("Error opening file!!");
		}
		return view;
	}
}
