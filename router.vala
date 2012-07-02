// Routing
// 2nd Attempt at making something work
// based on Dia this time

enum Direction{
	North = 1,
	East = 2,
	South = 4,
	West = 8
}

class Point : Object{
	public float X = 0;
	public float Y = 0;
	public Direction Direction;
	
	public Point(){}
	
	public void rotateClockwise(){
		float t = X;
		X = -Y;
		Y = t;
	}
	
	public void rotateCounterClockwise(){
		float t = X;
		X = Y;
		Y = -t;
	}
	
	public void rotate180(){
		X = -X;
		Y = -Y;
	}
	
	public double DistanceBetween_Manhattan(Point other){
		float dx = X - other.X;
		float dy = Y - other.Y;
		return Math.fabs(dx) - Math.fabs(dy);
	}
	
	public void AddPoint(Point other){
		X += other.X;
		Y += other.Y;
	}
	public Point clone(){
		Point r = new Point();
		r.X = X;
		r.Y = Y;
		return r;
	}
}

class Router : Object{
	static float MIN_DIST = 1.0F;
	
	static int Normalize( Direction startDirection, Direction endDirection, Point start, Point end, out Point newend){
		newend.X = end.X - start.X;
		newend.Y = end.Y - start.Y;
		if(startDirection == Direction.North){
			return endDirection;
		} else if(startDirection == Direction.East){
			newend.rotateCounterClockwise();
			if(endDirection == Direction.North) return Direction.West;
			return endDirection / 2;
		} else if(startDirection == Direction.West){
			newend.rotateClockwise();
			if(endDirection == Direction.West) return Direction.North;
			return endDirection * 2;
		} else { // if(startDirection == Direction.South){
			newend.rotate180();	
			if(endDirection < Direction.South) return endDirection * 4;
			else return endDirection / 4;
		}
		
		return endDirection;
	}
	static float LayoutOrthogonal( Point to, int enddir, out Point[] ps ){
		float dirmult = (enddir == Direction.West ? 1.0F : -1.0F);
		if(to.X < -MIN_DIST) {
			if(dirmult * to.X > MIN_DIST ) {
				ps = newArray(3);
				ps[1].Y = to.Y;
				ps[2] = to;
			} else{
				float off;
				if(dirmult * to.X > 0) off = -dirmult*MIN_DIST;
				else off = (float)( -dirmult * (MIN_DIST * Math.fabs(to.X )) );
				
				ps = newArray(5);
				ps[1].Y = -MIN_DIST;
				ps[2].X = off;
				ps[2].Y = -MIN_DIST;
				ps[3].X = off;
				ps[3].Y = to.Y;
				ps[4] = to;
			}
		} else{
			if( dirmult * to.X > 2*MIN_DIST ){
				float mid = to.X/2;
				ps = newArray(5);
				ps[1].Y = -MIN_DIST;
				ps[2].X = mid;
				ps[2].Y = -MIN_DIST;
				ps[3].X = mid;
				ps[3].Y = to.Y;
				ps[4] = to;
			} else{
				float off;
				if(dirmult * to.X > 0) off = -dirmult*MIN_DIST;
				else off = (float)( -dirmult * (MIN_DIST * Math.fabs(to.X )) );
				
				ps = newArray(5);
				ps[1].Y = -MIN_DIST;
				ps[2].X = off;
				ps[2].Y = -MIN_DIST;
				ps[3].X = off;
				ps[3].Y = to.Y;
				ps[4] = to;
			}
		}
		
		return CalculateBadness(ps);
	}
	
	static float LayoutOpposite( Point to, out Point[] ps ){
		if(to.Y < -MIN_DIST ){
			ps = newArray(4);
			if(Math.fabs(to.X) < 0.00000001) {
				ps[2] = ps[3] = to;
				return LengthBadness( Math.fabsf(to.X) ) + 2 * EXTRA_SEGMENT_BADNESS; 
			} else{ // Threeway
				float mid = to.Y / 2;
				ps[1].Y = mid;
				ps[2].X = to.X;
				ps[2].Y = mid;
				ps[3] = to;
				return 2 * LengthBadness( Math.fabsf( mid ) ) + 2 * EXTRA_SEGMENT_BADNESS;
			}
		} else if( Math.fabs( to.X ) > 2 * MIN_DIST ) { // Doorhanger?
			float mid = to.Y / 2;
			ps = newArray(6);
			ps[1].Y = -MIN_DIST;
			ps[2].X = mid;
			ps[2].Y = -MIN_DIST;
			ps[3].X = mid;
			ps[3].Y = to.Y+MIN_DIST;
			ps[4].X = to.X;
			ps[4].Y = to.Y+MIN_DIST;
			ps[5] = to;
		} else { // Overlap
			float off = MIN_DIST*(to.X > 0 ? -1.0F : 1.0F) ;
			
			ps = newArray(6);
			ps[1].Y = -MIN_DIST;
			ps[2].X = off;
			ps[2].Y = -MIN_DIST;
			ps[3].X = off;
			ps[3].Y = to.Y+MIN_DIST;
			ps[4].X = to.X;
			ps[4].Y = to.Y+MIN_DIST;
			ps[5] = to;
		}
		return CalculateBadness(ps);
	}
	
	static float LayoutParallel( Point to, out Point[] ps ){
		if( Math.fabs(to.X) > MIN_DIST ){ // Wide
			float top = float.min( -MIN_DIST, to.Y - MIN_DIST);
			
			ps = newArray(4);
			ps[1].Y = top;
			ps[2].X = to.X;
			ps[2].Y = top;
			ps[3] = to;
		} else if( to.Y > 0 ){
			float top = -MIN_DIST;
			float off = to.X + MIN_DIST * ( to.X > 0 ? 1.0F : -1.0F );
			float bottom = to.Y - MIN_DIST;
			
			ps = newArray(6);
			ps[1].Y = top;
		    ps[2].X = off;
		    ps[2].Y = top;
		    ps[3].X = off;
		    ps[3].Y = bottom;
		    ps[4].X = to.X;
		    ps[4].Y = bottom;
		    ps[5] = to;
		}else { /* Narrow */
		    float top = to.Y - MIN_DIST;
		    float off = MIN_DIST * (to.X > 0 ? -1.0F : 1.0F);
		    float bottom = -MIN_DIST;
		    
		    ps = newArray(6);
		    /* points[0] is 0,0 */
		    ps[1].Y = bottom;
		    ps[2].X = off;
		    ps[2].Y = bottom;
		    ps[3].X = off;
		    ps[3].Y = top;
		    ps[4].X = to.X;
		    ps[4].Y = top;
		    ps[5] = to;
		}
		return CalculateBadness(ps);
	}
	
	/* Badness { */
	static float EXTRA_SEGMENT_BADNESS = 10.0F;
	static float MAX_SMALL_BADNESS = 10.0F;
	static float MAX_BADNESS =  10000.0F;
	static float CalculateBadness(Point[] points){
		float badness = (points.length - 1)*EXTRA_SEGMENT_BADNESS;
		for(int i = 0; i < points.length-1; i ++){
			badness += LengthBadness( (float) points[i].DistanceBetween_Manhattan( points[i+1] ) );
		}
		
		return badness;
	}
	static float LengthBadness(float length){
		if(length < MIN_DIST ) {
			/* This should be zero at MIN_DIST and MAX_SMALL_BADNESS at 0 */
			return 2F*MAX_SMALL_BADNESS/(1.0F+length/MIN_DIST) - MAX_SMALL_BADNESS;
		} else {
		    return length-MIN_DIST;
		}
	}
	/* } */
	
	static Point[] UnnormalizePoints( int startDirection, Point start, Point[] points ){
		for(int i = 0; i < points.length; i++){
			Point point = points[i];
			
			if(startDirection == Direction.East){
				point.rotateClockwise();
			} else if(startDirection == Direction.South){
				point.rotate180();
			} else if(startDirection == Direction.West){
				point.rotateCounterClockwise();
			}
			point.AddPoint(start);
			
			points[i] = point;
		}
		return points;
	}
	
	static Point[] copyArray(Point[] input){
		Point[] r = new Point[input.length];
		for(int i = 0; i < input.length; i++){
			r[i] = input[i].clone();
		}
		return r;
	}
	static Point[] newArray(int size){
		Point[] r = new Point[size];
		for(int i = 0; i < size; i++){
			r[i] = new Point();
		}
		return r;
	}
	
	public static Point[] lastRoute;
	public static bool Route( Point start, Point end ){
		Direction fromDirection = start.Direction;
		Direction toDirection = end.Direction;
		
		float minBadness = MAX_BADNESS;
		Point[] bestLayout = {};
		
		Direction startDirection; Direction endDirection;
		for(startDirection = Direction.North; startDirection <= Direction.West; startDirection *= 2){
			for(endDirection = Direction.North; endDirection <= Direction.West; endDirection *= 2){
				if( (fromDirection == startDirection) && (toDirection == endDirection) ){
					Point[] this_layout;
					Point otherPoint = new Point();
					float this_badness;
					
					int normal_enddir = Normalize(startDirection, endDirection, start, end, out otherPoint);
					if(normal_enddir == Direction.North){
						this_badness = LayoutParallel( otherPoint, out this_layout );
					} else if( normal_enddir == Direction.South ){
						this_badness = LayoutOpposite( otherPoint, out this_layout );
					} else{
						this_badness = LayoutOrthogonal( otherPoint, normal_enddir, out this_layout );
					}
					
					if(this_layout != null){
						if(this_badness - minBadness < -0.00001){
							minBadness = this_badness;
							this_layout = UnnormalizePoints( startDirection, start, this_layout );
							bestLayout = copyArray(this_layout);
						}
					}
				}
				
			}
		}
		
		if( minBadness < MAX_BADNESS) {
			lastRoute = copyArray(bestLayout);
			return true;
		} else{
			return false;
		}
	}
}
