// Document class
using Xml;

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
			if(iter->name != "Sheet") continue;
			Sheet sheet = new Sheet();
			sheet.readXML(iter);
			sheets.append(sheet);
		}
		
	}
}

class Sheet : Object{
	public string name;
	public void readXML(Xml.Node node){
		this.name = node.get_prop("name");
	}
}
