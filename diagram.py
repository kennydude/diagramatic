from gi.repository import Gtk
from router import Router, Direction, Point
from document import *
from bs4 import BeautifulSoup
import sys, traceback

from doctypes import *

# Main Class
class Diagramatic(object):
	def loadFile(self, filename):
		doc = BeautifulSoup( open( filename, "r"), ["lxml", "xml"] )
		if(doc == None):
			print("File Not Found\n")
			return
		
		self.doc = DiagramDocument.fromXML(doc)		

		for s in self.doc.sheets:
			self.addSheet(s)
		
		# Now load shapes
		tools = self.builder.get_object("toolpalette")
		shapes = self.doc.get_shapes()
		for cat in shapes:
			print "SHC: %s" % cat
			pallete = Gtk.ToolItemGroup()
			pallete.set_label(cat)
			for shape in shapes[cat]:
				but = Gtk.ToolButton()
				but.set_label(shape.title)
				pallete.add(but)
				print "SH: %s" % shape
				
			tools.add(pallete)
	
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

		# Add Shapes
		for shape in s.shapes:
			view = shape.getWidget(fixed)
			fixed.put(view, int(shape.x), int(shape.y))
		
		# Add to sheets
		xDoc.show_all()
		fixed.show()
		label = Gtk.Label(s.name)
		# TODO: Context menu to change name etc.
		self.xSheets.insert_page( xDoc, label, -1 )
		
		print("S: " + s.name )
	

	def __init__(self, args):
		Gtk.init (args)

		try:
			self.builder = Gtk.Builder ()
			self.builder.add_from_file ("diagram.ui")
			self.builder.connect_signals (None)
			self.window = self.builder.get_object ("window")
			self.window.show_all ()

			self.window.connect("destroy",Gtk.main_quit)
			self.xSheets = self.builder.get_object("sheets")

			self.doc = DiagramDocument()
			self.loadFile("new.xml")

			Gtk.main ()
		except Exception as e:
			print "Could not load UI: ", e, sys.exc_info()
			traceback.print_exc()

if __name__ == "__main__":
	print("Diagramatic.")
	print("--------")
	print("Created by @kennydude aka Joe Simpson\n")   
	
	import sys
	args = sys.argv
	d = Diagramatic(args)

