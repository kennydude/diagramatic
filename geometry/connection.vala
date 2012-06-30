// Connection
// Rewrite by Joe Simpson

namespace Geometry{
	public class Connection : Object{
		public GLib.List<Point> PointList = new GLib.List<Point>();
		public ConnectionAnchor SourceAnchor;
		public ConnectionAnchor TargetAnchor;
	}
	
	public class ConnectionAnchor : Object{
		public Point Location;
		public Point ReferencePoint;
		public Rectangle Bounds;
	}
}
