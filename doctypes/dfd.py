'''
DFD
'''
from document import *

class DFDDocument(DiagramDocument):
	image = "doctypes/dfd.svg"
	title = "Data Flow Diagram"
		
	def get_shapes(self):
		return [
			"dfd/datastore",
			"dfd/entity"
		]

class DatastoreShape(Shape):
	def drawBackground(self, c):
		c.set_line_width(1.0)
		
		c.move_to(1,1)
		c.line_to(self.width, 1)
		c.move_to(1,1)
		c.line_to(1, self.height-1)
		c.move_to(0, self.height-1)
		c.line_to(self.width, self.height-1)
		c.stroke()

class EntityShape(Shape):
	def drawBackground(self, c):
		c.set_line_width(1.0)
		
		c.rectangle(1, 1, self.width-2, self.height -2)
		c.stroke()

register_doctype(DFDDocument, "dfd")

register_shape("dfd/entity", ShapeDescriptor( "Entity", "null.png", "dfd/entity", EntityShape ))
register_shape("dfd/datastore", ShapeDescriptor( "Data Store", "null.png", "dfd/datastore", DatastoreShape ))
