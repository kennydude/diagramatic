from gi.repository import Gtk
from router import Router, Direction, Point
import router
router.debug_on = True
from document import *
from bs4 import BeautifulSoup
import sys, traceback

# Main Class
class Diagramatic(object):
	def loadFile(self, filename):
		doc = BeautifulSoup( open( filename, "r"), ["lxml", "xml"] )
		if(doc == None):
			print("File Not Found\n")
			return
		
		self.doc.readXML(doc)		

		for s in self.doc.sheets:
			self.addSheet(s)
		print self.doc
	
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
				print a.x > b.x
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
				
			print "Routing from ", ap, "to", bp
			self.router = Router()
			if(self.router.Route( ap, bp ) == True):
				self.drawRoutedRoute(c)
			else:
				print "Route #2"
				# Could not route, try going up
				
				if(l.linkAPoint == "c"): # Strictly going up north
					old_ap = ap.clone()
					old_bp = bp.clone()
					
					if( a.y < b.y ): # a is above b
						ap.Direction = Direction.South
						bp.Direction = Direction.North
					else: # b is above a
						ap.Direction = Direction.North
						bp.Direction = Direction.South
					
					
					if(a.x > b.x) : # also, a is to the left of b
						ap.X -= 20
						bp.X -= 20
					else:
						ap.X += 20
						bp.X += 20
					
					
					if(self.router.Route(ap, bp) == True):
						self.drawRoutedRoute(c)	
					else:
						print("Could not route __\n")
				
			# c.move_to(a.x, a.y)
			
			# c.line_to(b.x, b.y)
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

		fixed.drag_dest_set( Gtk.DestDefaults.ALL,[Gtk.TargetEntry.new( "shape", Gtk.TargetFlags.SAME_APP, 0 )], Gdk.DragAction.COPY )

		# Add Shapes
		i = 0
		for shape in s.shapes:
			view = shape.getWidget(fixed, i)
			i += 1
			print view
			
			'''
			todo: fix
			view.button_press_event.connect( (bp) => :
				view.set_data("in_motion", true)
				
				int pointX = 0 int pointY = 0
				fixed.get_pointer(out pointX, out pointY)
				int origX = 0 int origY = 0
				view.translate_coordinates(fixed, 0,0, out origX, out origY)
				
				view.set_data("startx", origX + origX)
				view.set_data("starty", origY + origY)
				view.set_data("startsx", pointX)
				view.set_data("startsy", pointY)
				view.is_focus = true
				view.has_focus = true
				return false
			)
			view.button_release_event.connect( (bp) => :
				view.set_data("in_motion", false)
				return false
			)
			view.motion_notify_event.connect( (me) => :
				# TODO: Make this less glitchy somehow
				if(view.get_data<bool>("in_motion") == true):
					int x = view.get_data<int>("startx") + (int)me.x - view.get_data<int>("startsx")
					int y = view.get_data<int>("starty") + (int)me.y - view.get_data<int>("startsy")
					((Fixed)view.parent).move(view, x,y )
					Shape sh = s.shapes.nth_data(view.get_data<int>("pos"))
					sh.x = x sh.y = y
				
				return false
			)
			view.set_data("pos", s.shapes.index(shape))
			view.focus_in_event.connect( (c) => :
				view.queue_draw()
				return false
			)
			'''
			print int(shape.x), int(shape.y)
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

