// Rectangle
// Implementation for Rectangle by Joe Simpson. This file is not a copy of the original code, but compatible

namespace Geometry{
	public class Rectangle : Object{
		public int x;
		public int y;
		public int width;
		public int height;
		
		public Rectangle(int x, int y, int width, int height){
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public int bottom() {
			return y + height;
		}
		
		public static Rectangle from_points(Point l, Point r){
			return new Rectangle(int.min(l.x, r.x), int.min(l.y, r.y), (l.x - r.x)  + 1, (l.y - r.y) + 1);
		}
		
		public int right() {
			return x + width;
		}
		
		public Point getBottomRight() {
			return Point.from_integers(x + width, y + height);
		}
		public Point getTopLeft(){
			return Point.from_integers(x, y);
		}
		
		public Rectangle getCopy(){
			return new Rectangle(x, y, width, height);
		}
	}
}
