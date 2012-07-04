from gi.repository import Gtk, Gdk, GdkPixbuf
from router import Router, Direction, Point
from document import *
from bs4 import BeautifulSoup
import sys, traceback, string

from doctypes import *

# Main Class
class Diagramatic(object):
	currentView = ''
	def set_child(self, child):
		self.currentView = child
		splash = self.builder.get_object(child)
		for child in self.window.get_children():
			self.window.remove(child)
		self.window.add(splash)	
		return splash
	
	def loadNewView(self, sender=None, data=None):
		self.set_child("boxNewDocument")
	
	def loadSplash(self, sender=None, data=None):
		self.set_child("boxSplash")
		
	def loadDocumentView(self):	
		self.loadFile("new.xml")	
	
	def loadFile(self, filename):
		doc = BeautifulSoup( open( filename, "r"), ["lxml", "xml"] )
		if(doc == None):
			print("File Not Found\n")
			return
		
		self.doc = DiagramDocument.fromXML(doc)		
		self.loadDocUi()
	
		
	def loadDocUi(self):
		for s in self.doc.sheets:
			self.addSheet(s)
		
		# Now load shapes
		self.loadShapes()
		self.xSheets.set_current_page(0)

	def shapeDragData(self, widget, drag_context, data, info, time):
		print "Start Drag"
		tree = self.toolsView.get_selected_items()
		if len(tree) > 0:
			item = self.shapeStore[ tree[0] ][1]
			data.set_text(item, -1)
		
	def loadShapes(self):
		myshapes = self.doc.get_shapes()
		for shapename in myshapes:
			shape = shapes[shapename]

			self.shapeStore.append( [ shape.title, shapename, GdkPixbuf.Pixbuf.new_from_file("shapes/%s-i.png" % shape.image) ] )
			print "SH: %s" % shape
				
			
	
	def drawRoutedRoute(self, c):
		print "Routed with size of %i points!" % len(self.router.lastRoute), self.router.lastRoute
		c.move_to(self.router.lastRoute[0].X, self.router.lastRoute[0].Y)		
		for point in self.router.lastRoute:
			c.line_to(point.X, point.Y)
			c.move_to(point.X, point.Y)
		
	def draw_fixed(self, sender, c, s):
		c.set_line_width(1)
		for l in s.links:
			# Draw line between them
			a = s.shapes[l.linkA]
			b = s.shapes[l.linkB]
			
			ap = Point()
			bp = Point()
			
			# TODO: Allow for the shape object to say where it wants to connect from
			if(l.linkAPoint == "c"): # Left or Right is best?
				if( a.x > b.x ): # Come out of left
					ap.X = a.x
					ap.Y = a.y + (a.height / 2)
					ap.Direction = Direction.West
					
					bp.X = b.x + b.width
					bp.Y = b.y + (b.height/2)
					bp.Direction = Direction.East
				else: # Come out of right
					ap.X = a.x + a.width
					ap.Y = a.y + (a.height / 2)
					ap.Direction = Direction.East
					
					bp.X = b.x
					bp.Y = b.y + (b.height/2)
					bp.Direction = Direction.West
			
			self.router = Router()
			if(self.router.Route( ap, bp ) == True):
				self.drawRoutedRoute(c)
			
			c.stroke()
		
		return True	

	def updateShapeValue( self, sender, option, item, t ):
		if t == int:
			value = int(sender.get_value() )
		elif t == str:
			value = sender.get_text()
		
		setattr( item, option, value )
		item.updated_values()
		print "updateShapeValue on", item, "'s", option, "with", value
	
	def bufferInsertText(self, sender, position,chars, n_chars, option, item, t ):
		self.updateShapeValue(sender, option, item, t)
	
	focusedItem = None
	def clear_properties(self, label=None):
		prop = self.builder.get_object("boxProperties")
		for child in prop.get_children():
			if(child != label):
				prop.remove(child)
	def focus_on(self, item):
		'''
		Shape has been focused
		'''
		self.focusedItem = item
		self.window.queue_draw()
		
		label = self.builder.get_object("lblType")
		label.set_label(item.name)

		self.clear_properties(label)
		prop = self.builder.get_object("boxProperties")
		prop.show()		
		
		for option in item.properties:
			label = Gtk.Label(string.capwords(option))
			prop.pack_start(label, False, False,0)
			
			t = item.properties[option]
			print option, t
			if t == int:
				w = Gtk.SpinButton()
				w.set_range(0,999)
				w.set_value( getattr( item, option ) )
				w.set_numeric( True )
				w.set_increments( 1, 10 )
			elif t == str:
				w = Gtk.Entry()
				w.set_text( getattr( item, option ) )
				w.get_buffer().connect("inserted-text", self.bufferInsertText, option, item, t)
			w.connect("changed", self.updateShapeValue, option, item, t)
			prop.pack_start(w, False, False,0)
		prop.show_all()
	
	def addShapeToDoc(self, widget, drag_context, x, y, drag_data, info, time, data=None):
		text = drag_data.get_text()
		global shapes
		s = shapes[text]
		shape = s.build()
		shape.x = x
		shape.y = y

		shape.window = self
		view = shape.getWidget(data.fixed)
		data.fixed.put(view, int(shape.x), int(shape.y))
		
		data.shapes.append(shape)
		view.show()
		
		print "Dropped ", text

	def unfocus(self, sender=None, me=None):
		self.focusedItem = None
		sender.queue_draw()
		
		prop = self.builder.get_object("boxProperties")
		prop.hide()

	def addSheet(self, s):
		# Setup sheet
		
		xDoc = Gtk.ScrolledWindow( Gtk.Adjustment(0,0,0,0,0,0), Gtk.Adjustment(0,0,0,0,0,0) )
		xDoc.modify_bg( Gtk.StateType.NORMAL, Shape.getWhite())
		viewport = Gtk.Viewport( Gtk.Adjustment(0,0,0,0,0,0), Gtk.Adjustment(0,0,0,0,0,0) )
		xDoc.add(viewport)
		xDoc.set_hexpand( True )
		fixed = Gtk.Fixed()
		viewport.add(fixed)
		viewport.modify_bg( Gtk.StateType.NORMAL, Shape.getWhite())
		fixed.connect( "draw", 	self.draw_fixed, s )

		viewport.set_events( Gdk.EventMask.BUTTON_PRESS_MASK )
		viewport.connect("button-press-event", self.unfocus)

		fixed.drag_dest_set(Gtk.DestDefaults.ALL, [], Gdk.DragAction.COPY )
		fixed.drag_dest_add_text_targets()
		fixed.connect( "drag-data-received", self.addShapeToDoc, s )
		s.fixed = fixed

		# Add Shapes
		for shape in s.shapes:
			shape.window = self
			view = shape.getWidget(fixed)
			fixed.put(view, int(shape.x), int(shape.y))
		
		# Add to sheets
		xDoc.show_all()
		fixed.show()
		label = Gtk.Label(s.name)

		label.set_events( Gdk.EventMask.BUTTON_PRESS_MASK )
		label.connect("button-press-event", self.labelPressed, s)		
		
		print("S: " + s.name )
		return self.xSheets.insert_page( xDoc, label, self.xSheets.get_n_pages() -1 )

	def labelPressed(self, sender, event, sheet):
		#if(event.button != 3): pass
		mnu = self.builder.get_object("sheetMenu")
		
		mnu.popup(None, None, None, None, event.button, event.time)
	
	def templateSelectedChanged(self, selection):
		tree = selection.get_selected_items()
		btn = self.builder.get_object("btnCreateDocument")
		if len(tree) > 0:		
			btn.set_label("Create Document")
			print "You selected", self.templateStore[ tree[0] ][0]
		else:
			btn.set_label("Select a template first")
		btn.set_sensitive( len(tree) > 0 )
	def newDocument(self, sender=None):
		global doctypes
		tree = self.templateIconView.get_selected_items()
		if len(tree) > 0:
			item = self.templateStore[ tree[0] ][1]
			item = doctypes[item]
			self.doc = item()
			
			self.set_child("boxDocument")
			self.loadDocUi()
	
	def changeSheet(self, tabs, view, i):
		if i+1 == tabs.get_n_pages() and self.currentView == "boxDocument":
			s = Sheet()
			self.doc.sheets.append( s )
			self.xSheets.set_current_page( self.addSheet( s ) )

	def run(self, args):
		Gtk.init (args)

		try:
			self.builder = Gtk.Builder ()
			self.builder.add_from_file ("diagram.ui")
			
			btn = self.builder.get_object("btnGoBack")
			btn.connect("clicked", self.loadSplash)
			btn = self.builder.get_object("btnNew")
			btn.connect("clicked", self.loadNewView)
			btn = self.builder.get_object("btnCreateDocument")
			btn.connect("clicked", self.newDocument)
			
			# Load Templates
			self.templateStore = Gtk.ListStore(str, str, GdkPixbuf.Pixbuf)
			self.templateIconView = self.builder.get_object("iconviewTemplates")
			self.templateIconView.set_model(self.templateStore)
			self.templateIconView.set_text_column(0)
			self.templateIconView.set_pixbuf_column(2)
			self.templateIconView.connect("selection-changed", self.templateSelectedChanged)
			global doctypes
			for doc in doctypes:
				self.templateStore.append([ doctypes[doc].title, doc, GdkPixbuf.Pixbuf.new_from_file(doctypes[doc].image)
 ])
			
			# Document UI Setup
			self.xSheets = self.builder.get_object("sheets")
			self.xSheets.connect("switch-page", self.changeSheet)
			l = Gtk.Image()
			l.set_from_stock("gtk-add", Gtk.IconSize.MENU)
			c = Gtk.Label("Nothing to see here")
			l.show()
			c.show()
			self.xSheets.insert_page(c, l, -1)

			self.toolsView = self.builder.get_object("ivTools")
			self.shapeStore = Gtk.ListStore(str, str, GdkPixbuf.Pixbuf)
			self.toolsView.set_model(self.shapeStore)
			self.toolsView.set_text_column(0)
			self.toolsView.set_pixbuf_column(2)
			self.toolsView.enable_model_drag_source(Gdk.ModifierType.BUTTON1_MASK, [], Gdk.DragAction.COPY)
			self.toolsView.drag_source_add_text_targets()
			self.toolsView.connect("drag-data-get", self.shapeDragData )
			
			self.window = self.builder.get_object ("window")
			self.window.show_all ()
			prop = self.builder.get_object("boxProperties")
			prop.hide()

			self.window.connect("destroy",Gtk.main_quit)
			self.loadSplash()

			Gtk.main ()
		except Exception as e:
			print "Could not load UI: ", e, sys.exc_info()
			traceback.print_exc()

if __name__ == "__main__":
	print("Diagramatic.")
	print("--------")
	print("Created by @kennydude aka Joe Simpson\n")   
	
	import sys, storage
	args = sys.argv
	storage.window = Diagramatic()
	storage.window.run(args)

