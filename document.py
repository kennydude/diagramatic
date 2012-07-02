# Document class
from gi.repository import Gtk, PangoCairo, Gdk, Pango
import cairo
import rsvg
from bs4.element import Tag

def lrepr(l, tab=1):
	r = "["
	for item in l:
		r += "\n" + (tab*"\t") + repr(item)
	r += "\n" +((tab-1)*"\t")+ "]"
	return r

try:
	if doctypes == None:
		pass
except NameError:
	doctypes = {}

def register_doctype(doctype, label):
	global doctypes
	doctypes[label] = doctype

class DiagramDocument(object):
	def __repr__(self):
		return self.__class__.__name__ + "[\n\tSheets = %s\n]" % lrepr(self.sheets, 2)
	
	def get_shapes(self):
		raise Exception("DiagramDocument is an abstract class and requires get_shapes() is implemented")
		return {}	
	
	@staticmethod
	def fromXML(doc):
		global doctypes
		root = doc.Document
		if(root == None): return None
		if root['type'] in doctypes:
			r = doctypes[root['type']]()
			r.readXML(doc)
			return r
		else:
			raise Exception("The doctype '%s' is not registered" % root['type'])
	
	def readXML(self, doc):
		root = doc.Document
		if(root == None):
			print("No root element in file!\n")
			return
		
		self.sheets = []
		for child in root.children:
			# Spaces between tags are also nodes, discard them
			if(type(child) != Tag):
				continue
			
			if(child.name == "Sheet"):
				sheet = Sheet()
				sheet.readXML(child)
				self.sheets.append(sheet)

class Sheet(object):
	def __repr__(self):
		return "Sheet[ Name='%s'\n\t\t\tShapes = %s,\n\t\t\tLinks = %s\n\t\t]" % ( self.name, lrepr(self.shapes, 4), lrepr(self.links, 4) )
	def readXML(self, node):
		self.name = node["name"]
		
		self.shapes = []
		self.links = []
		for child in node.children:
			# Spaces between tags are also nodes, discard them
			if (type(child) != Tag):
				continue
			
			if(child.name == "Shape"):
				shape = Shape.fromXML(child)
				self.shapes.append(shape)
			elif(child.name == "Link"):
				link = Link()
				link.fromXML(child)
				self.links.append(link)

class Link(object):
	def __repr__(self):
		return "Link[ A = %i, B = %i ]" % (self.linkA, self.linkB)
	linkA = 0
	linkB = 0
	linkAPoint = "c"
	linkBPoint = "c"
	
	def fromXML(self, node):
		self.linkA = int(node['a'])
		self.linkB = int(node['b'])

class ShapeDescriptor(object):
	'''
	A shape descriptor is used to describe insertable shapes
	'''
	title = "Element"
	icon = "p.png"
	image = "no.svg"

	def __init__(self, title='', icon='', image=''):
		self.tilte = title
		self.icon = icon
		self.image = image
	
	def build(self):
		r = Shape()
		r.text = "New Shape"
		r.obj_url = self.image
		return r

class Shape(object):
	def __repr__(self):
		return "StdShape[ Type='%s', Text='%s' ]" % (self.obj_url, self.text)
	font = "Ubuntu 12"
	
	@staticmethod
	def getWhite():
		return Gdk.color_parse( "white" )
	
	@staticmethod
	def fromXML(node):
		r = Shape()
		r.obj_url = node["type"]
		# TODO: Some kind of check to see what type to use
		
		r.x = int(node['x'])
		r.y = int(node['y']) 
		r.width = int(node['width'])
		r.height = int(node['height'])
		r.text = node['text']
		return r
	
	def draw(self,sender, c, data=None):
		c.set_source_rgb(0,0,0)
		self.svg.render_cairo(c)
				
		pc = PangoCairo.create_context(c)
		#c.set_antialias( cairo.Antialias.SUBPIXEL )
		l = Pango.Layout(pc)
		l.set_font_description( Pango.FontDescription(self.font))
		l.set_text( self.text, -1)
		l.set_alignment( Pango.Alignment.CENTER )
		
		w = 0
		h = 0
		w,h = l.get_pixel_size()
		c.move_to( self.width/2 - w/2, self.height/2 - h/2)			
		
		c.set_source_rgb(0, 0, 0)
		PangoCairo.update_layout(c, l)
		PangoCairo.show_layout(c, l)

		if(self.view.has_focus):
			c.set_source_rgb(0,0,200)
			c.move_to(0,0)
			c.rectangle(0,0,self.width-1,self.height-1)
		
		return False
	
	in_motion = False
	def bp(self, t, me, d=None):
		self.click_at = [ me.x, me.y ]
		self.in_motion = True
		self.view.grab_focus()

	def bpr(self, t, me, d=None):
		self.in_motion = False

	def move(self, t, me, d= None):
		if self.in_motion:
			x = self.x + me.x - self.click_at[0]
			y = self.y + me.y - self.click_at[1]
			d.move(t, x, y)
			self.x = x
			self.y = y
	
	def getWidget(self, parent):
		self.view = Gtk.DrawingArea()
		self.view.set_size_request(self.width, self.height)
		self.view.can_focus = True
		self.view.modify_bg( Gtk.StateType.NORMAL, self.getWhite())
		self.view.set_events(Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK | Gdk.EventMask.BUTTON_MOTION_MASK)
		self.view.connect("button_press_event", self.bp)
		self.view.connect("motion_notify_event", self.move, parent)
		self.view.connect("button_release_event", self.bpr)
		
		try:
			self.svg = rsvg.Handle("shapes/" + self.obj_url + ".svg")
			self.view.connect( "draw", self.draw )
		except Exception as e:
			print "Error opening file!", e
		
		return self.view
	

