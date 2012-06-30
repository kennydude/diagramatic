// Point
// http://git.eclipse.org/c/gef/org.eclipse.gef.git/tree/org.eclipse.draw2d/src/org/eclipse/draw2d/geometry/Point.java

namespace Geometry{
	public class Point : Object{
		/**
		 * A singleton for use in short calculations
		 */
		public static Point SINGLETON = new Point();

		/**
		 * Creates a new Point representing the MAX of two provided Points.
		 * 
		 * @param p1
		 *            first point
		 * @param p2
		 *            second point
		 * @return A new Point representing the Max()
		 */
		public static Point max(Point p1, Point p2) {
			return new Rectangle(p1, p2).getBottomRight().translate(-1, -1);
		}

		/**
		 * Creates a new Point representing the MIN of two provided Points.
		 * 
		 * @param p1
		 *            first point
		 * @param p2
		 *            second point
		 * @return A new Point representing the Min()
		 */
		public static Point min(Point p1, Point p2) {
			return new Rectangle(p1, p2).getTopLeft();
		}

		/**
		 * x value
		 */
		public int x;

		/**
		 * y value
		 */
		public int y;

		/**
		 * Constructs a Point at location (0,0).
		 * 
		 * @since 2.0
		 */
		public Point() {
		}

		/**
		 * Constructs a Point at the specified x and y locations.
		 * 
		 * @param x
		 *            x value
		 * @param y
		 *            y value
		 * @since 2.0
		 * @deprecated Use {@link PrecisionPoint} or {@link #Point(int, int)}
		 *             instead.
		 */
		public static Point from_doubles(double x, double y) {
			Point e = new Point();
			e.x = (int) x;
			e.y = (int) y;
			return e;
		}

		/**
		 * Constructs a Point at the specified x and y locations.
		 * 
		 * @param x
		 *            x value
		 * @param y
		 *            y value
		 * @since 2.0
		 */
		public static Point from_integers(int x, int y) {
			Point e = new Point();
			e.x = x;
			e.y = y;
			return e;
		}

		/**
		 * Constructs a Point at the same location as the given Point.
		 * 
		 * @param p
		 *            Point from which the initial values are taken.
		 * @since 2.0
		 */
		public static Point from_point(Point p) {
			Point e = new Point();
			e.x = p.x;
			e.y = p.y;
			return e;
		}

		/**
		 * Returns <code>true</code> if this Points x and y are equal to the given x
		 * and y.
		 * 
		 * @param x
		 *            the x value
		 * @param y
		 *            the y value
		 * @return <code>true</code> if this point's x and y are equal to those
		 *         given.
		 * @since 3.7
		 */
		public bool equals(int x, int y) {
			return this.x == x && this.y == y;
		}

		/**
		 * @return a copy of this Point
		 * @since 2.0
		 */
		public Point getCopy() {
			return new Point(this);
		}

		/**
		 * Calculates the difference in between this Point and the one specified.
		 * 
		 * @param p
		 *            The Point being subtracted from this Point
		 * @return A new Dimension representing the difference
		 * @since 2.0
		 */
		public Dimension getDifference(Point p) {
			return new Dimension(this.x - p.x, this.y - p.y);
		}

		/**
		 * Calculates the distance from this Point to the one specified.
		 * 
		 * @param p
		 *            The Point being compared to this
		 * @return The distance
		 * @since 2.0
		 */
		public double getDistance(Point p) {
			double i = p.preciseX() - preciseX();
			double j = p.preciseY() - preciseY();
			return Math.sqrt(i * i + j * j);
		}

		/**
		 * Calculates the distance squared between this Point and the one specified.
		 * If the distance squared is larger than the maximum integer value, then
		 * <code>Integer.MAX_VALUE</code> will be returned.
		 * 
		 * @param p
		 *            The reference Point
		 * @return distance<sup>2</sup>
		 * @since 2.0
		 * @deprecated Use {@link #getDistance(Point)} and square the result
		 *             instead.
		 */
		public int getDistance2(Point p) {
			long i = p.x - x;
			long j = p.y - y;
			long result = i * i + j * j;
			if (result > Integer.MAX_VALUE)
				return Integer.MAX_VALUE;
			return (int) result;
		}

		/**
		 * Calculates the orthogonal distance to the specified point. The orthogonal
		 * distance is the sum of the horizontal and vertical differences.
		 * 
		 * @param p
		 *            The reference Point
		 * @return the orthogonal distance
		 * @deprecated May not be guaranteed by precision subclasses and should thus
		 *             not be used any more.
		 */
		public int getDistanceOrthogonal(Point p) {
			return Math.abs(y - p.y) + Math.abs(x - p.x);
		}

		/**
		 * Creates a Point with negated x and y values.
		 * 
		 * @return A new Point
		 * @since 2.0
		 */
		public Point getNegated() {
			return getCopy().negate();
		}

		/**
		 * Calculates the relative position of the specified Point to this Point.
		 * 
		 * @param p
		 *            The reference Point
		 * @return NORTH, SOUTH, EAST, or WEST, as defined in
		 *         {@link PositionConstants}
		 */
		public int getPosition(Point p) {
			int dx = p.x - x;
			int dy = p.y - y;
			if (Math.abs(dx) > Math.abs(dy)) {
				if (dx < 0)
					return PositionConstants.WEST;
				return PositionConstants.EAST;
			}
			if (dy < 0)
				return PositionConstants.NORTH;
			return PositionConstants.SOUTH;
		}

		/**
		 * Creates a new Point from this Point by scaling by the specified amount.
		 * 
		 * @param factor
		 *            scale factor
		 * @return A new Point
		 * @since 2.0
		 */
		public Point getScaled_f(double factor) {
			return getCopy().scale_f(factor);
		}

		/**
		 * Creates a new Point from this Point by scaling by the specified x and y
		 * factors.
		 * 
		 * @param xFactor
		 *            x scale factor
		 * @param yFactor
		 *            y scale factor
		 * @return A new Point
		 * @since 3.8
		 */
		public Point getScaled_d(double xFactor, double yFactor) {
			return getCopy().scale_d(xFactor, yFactor);
		}
		
		/**
		 * Creates a new Point which is translated by the values of the input
		 * Dimension.
		 * 
		 * @param d
		 *            Dimension which provides the translation amounts.
		 * @return A new Point
		 * @since 2.0
		 */
		public Point getTranslated_di(Dimension d) {
			return getCopy().translate_di(d);
		}

		/**
		 * Creates a new Point which is translated by the specified x and y values
		 * 
		 * @param x
		 *            horizontal component
		 * @param y
		 *            vertical component
		 * @return A new Point
		 * @since 3.8
		 */
		public Point getTranslated_d(double x, double y) {
			return getCopy().translate_d(x, y);
		}

		/**
		 * Creates a new Point which is translated by the specified x and y values
		 * 
		 * @param x
		 *            horizontal component
		 * @param y
		 *            vertical component
		 * @return A new Point
		 * @since 2.0
		 */
		public Point getTranslated_i(int x, int y) {
			return getCopy().translate_i(x, y);
		}

		/**
		 * Creates a new Point which is translated by the values of the provided
		 * Point.
		 * 
		 * @param p
		 *            Point which provides the translation amounts.
		 * @return A new Point
		 * @since 2.0
		 */
		public Point getTranslated_p(Point p) {
			return getCopy().translate_p(p);
		}

		/**
		 * Creates a new Point with the transposed values of this Point. Can be
		 * useful in orientation change calculations.
		 * 
		 * @return A new Point
		 * @since 2.0
		 */
		public Point getTransposed() {
			return getCopy().transpose();
		}

		/**
		 * @see java.lang.Object#hashCode()
		 */
		public int hashCode() {
			return (x * y) ^ (x + y);
		}

		/**
		 * Negates the x and y values of this Point.
		 * 
		 * @return <code>this</code> for convenience
		 * @since 2.0
		 */
		public Point negate() {
			x = -x;
			y = -y;
			return this;
		}

		/** @see Translatable#performScale(double) */
		public void performScale(double factor) {
			scale(factor);
		}

		/** @see Translatable#performTranslate(int, int) */
		public void performTranslate(int dx, int dy) {
			translate(dx, dy);
		}

		/**
		 * Returns <code>double</code> x coordinate
		 * 
		 * @return <code>double</code> x coordinate
		 * @since 3.4
		 */
		public double preciseX() {
			return x;
		}

		/**
		 * Returns <code>double</code> y coordinate
		 * 
		 * @return <code>double</code> y coordinate
		 * @since 3.4
		 */
		public double preciseY() {
			return y;
		}

		/**
		 * Scales this Point by the specified amount.
		 * 
		 * @return <code>this</code> for convenience
		 * @param factor
		 *            scale factor
		 * @since 2.0
		 */
		public Point scale_f(double factor) {
			return scale(factor, factor);
		}

		/**
		 * Scales this Point by the specified values.
		 * 
		 * @param xFactor
		 *            horizontal scale factor
		 * @param yFactor
		 *            vertical scale factor
		 * @return <code>this</code> for convenience
		 * @since 2.0
		 */
		public Point scale_d(double xFactor, double yFactor) {
			x = (int) Math.floor(x * xFactor);
			y = (int) Math.floor(y * yFactor);
			return this;
		}

		/**
		 * Sets the location of this Point to the provided x and y locations.
		 * 
		 * @return <code>this</code> for convenience
		 * @param x
		 *            the x location
		 * @param y
		 *            the y location
		 * @since 2.0
		 */
		public Point setLocation_integers(int x, int y) {
			this.x = x;
			this.y = y;
			return this;
		}

		/**
		 * Sets the location of this Point to the specified Point.
		 * 
		 * @return <code>this</code> for convenience
		 * @param p
		 *            the Location
		 * @since 2.0
		 */
		public Point setLocation_point(Point p) {
			x = p.x;
			y = p.y;
			return this;
		}

		/**
		 * Sets the x value of this Point to the given value.
		 * 
		 * @param x
		 *            The new x value
		 * @return this for convenience
		 * @since 3.7
		 */
		public Point setX(int x) {
			this.x = x;
			return this;
		}

		/**
		 * Sets the y value of this Point to the given value;
		 * 
		 * @param y
		 *            The new y value
		 * @return this for convenience
		 * @since 3.7
		 */
		public Point setY(int y) {
			this.y = y;
			return this;
		}

		/**
		 * @return String representation.
		 * @since 2.0
		 */
		public string toString() {
			return "Point(" + preciseX() + ", " + preciseY() + ")";//$NON-NLS-3$//$NON-NLS-2$//$NON-NLS-1$
		}

		/**
		 * Shifts this Point by the values of the Dimension along each axis, and
		 * returns this for convenience.
		 * 
		 * @param d
		 *            Dimension by which the origin is being shifted.
		 * @return <code>this</code> for convenience
		 * @since 2.0
		 */
		public Point translate_di(Dimension d) {
			return translate_i(d.width(), d.height());
		}

		/**
		 * Shifts this Point by the values supplied along each axes, and returns
		 * this for convenience.
		 * 
		 * @param x
		 *            Amount by which point is shifted along X axis.
		 * @param y
		 *            Amount by which point is shifted along Y axis.
		 * @return <code>this</code> for convenience
		 * @since 3.8
		 */
		public Point translate_d(double x, double y) {
			return translate_i((int) x, (int) y);
		}

		/**
		 * Shifts this Point by the values supplied along each axes, and returns
		 * this for convenience.
		 * 
		 * @param dx
		 *            Amount by which point is shifted along X axis.
		 * @param dy
		 *            Amount by which point is shifted along Y axis.
		 * @return <code>this</code> for convenience
		 * @since 2.0
		 */
		public Point translate_i(int dx, int dy) {
			x += dx;
			y += dy;
			return this;
		}

		/**
		 * Shifts the location of this Point by the location of the input Point
		 * along each of the axes, and returns this for convenience.
		 * 
		 * @param p
		 *            Point to which the origin is being shifted.
		 * @return <code>this</code> for convenience
		 * @since 2.0
		 */
		public Point translate_p(Point p) {
			return translate_i(p.x, p.y);
		}

		/**
		 * Transposes this object. X and Y values are exchanged.
		 * 
		 * @return <code>this</code> for convenience
		 * @since 2.0
		 */
		public Point transpose() {
			int temp = x;
			x = y;
			y = temp;
			return this;
		}
	}

}