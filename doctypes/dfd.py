'''
DFD
'''
from document import DiagramDocument, register_doctype, ShapeDescriptor

class DFDDocument(DiagramDocument):
	def get_shapes(self):
		return {
			"Data Flow Diagram" : [
				ShapeDescriptor( "Data Store", "null.png", "dfd/datastore.svg" )
			]
		}

register_doctype(DFDDocument, "dfd")