// Ray! :D

namespace Geometry{

	public class Ray : Object{
		/** the X value */
		public int x;
		/** the Y value */
		public int y;

		/**
		 * Constructs a Ray &lt;0, 0&gt; with no direction and magnitude.
		 * 
		 * @since 2.0
		 */
		public Ray() {
		}

		/**
		 * Constructs a Ray pointed in the specified direction.
		 * 
		 * @param x
		 *            X value.
		 * @param y
		 *            Y value.
		 * @since 2.0
		 */
		public static Ray from_ints(int x, int y) {
			Ray r = new Ray();
			r.x = x;
			r.y = y;
			return r;
		}

		/**
		 * Constructs a Ray pointed in the direction specified by a Point.
		 * 
		 * @param p
		 *            the Point
		 * @since 2.0
		 */
		public static Ray from_point(Point p) {
			Ray r = new Ray();
			r.x = p.x;
			r.y = p.y;
			return r;
		}

		/**
		 * Constructs a Ray representing the direction and magnitude between to
		 * provided Points.
		 * 
		 * @param start
		 *            Strarting Point
		 * @param end
		 *            End Point
		 * @since 2.0
		 */
		public static Ray from_points(Point start, Point end) {
			Ray r = new Ray();
			r.x = end.x - start.x;
			r.y = end.y - start.y;
			return r;
		}

		/**
		 * Constructs a Ray representing the difference between two provided Rays.
		 * 
		 * @param start
		 *            The start Ray
		 * @param end
		 *            The end Ray
		 * @since 2.0
		 */
		public static Ray from_rays(Ray start, Ray end) {
			Ray r = new Ray();
			r.x = end.x - start.x;
			r.y = end.y - start.y;
			return r;
		}

		/**
		 * Calculates the magnitude of the cross product of this Ray with another.
		 * Represents the amount by which two Rays are directionally different.
		 * Parallel Rays return a value of 0.
		 * 
		 * @param r
		 *            Ray being compared
		 * @return The assimilarity
		 * @see #similarity(Ray)
		 * @since 2.0
		 */
		public int assimilarity(Ray r) {
			return x * r.y - y * r.x;
		}

		/**
		 * Calculates the dot product of this Ray with another.
		 * 
		 * @param r
		 *            the Ray used to perform the dot product
		 * @return The dot product
		 * @since 2.0
		 */
		public int dotProduct(Ray r) {
			return x * r.x + y * r.y;
		}

		/**
		 * Calculates the dot product of this Ray with another.
		 * 
		 * @param r
		 *            the Ray used to perform the dot product
		 * @return The dot product as <code>long</code> to avoid possible integer
		 *         overflow
		 * @since 3.4.1
		 */
		long dotProductL(Ray r) {
			return (long) x * r.x + (long) y * r.y;
		}

		public bool equals(Ray r) {
			return x == r.x && y == r.y;
		}

		/**
		 * Creates a new Ray which is the sum of this Ray with another.
		 * 
		 * @param r
		 *            Ray to be added with this Ray
		 * @return a new Ray
		 * @since 2.0
		 */
		public Ray getAdded(Ray r) {
			return Ray.from_ints(r.x + x, r.y + y);
		}

		/**
		 * Creates a new Ray which represents the average of this Ray with another.
		 * 
		 * @param r
		 *            Ray to calculate the average.
		 * @return a new Ray
		 * @since 2.0
		 */
		public Ray getAveraged(Ray r) {
			return Ray.from_ints((x + r.x) / 2, (y + r.y) / 2);
		}

		/**
		 * Creates a new Ray which represents this Ray scaled by the amount
		 * provided.
		 * 
		 * @param s
		 *            Value providing the amount to scale.
		 * @return a new Ray
		 * @since 2.0
		 */
		public Ray getScaled(int s) {
			return Ray.from_ints(x * s, y * s);
		}

		/**
		 * @see java.lang.Object#hashCode()
		 */
		public int hashCode() {
			return (x * y) ^ (x + y);
		}

		/**
		 * Returns true if this Ray has a non-zero horizontal comonent.
		 * 
		 * @return true if this Ray has a non-zero horizontal comonent
		 * @since 2.0
		 */
		public bool isHorizontal() {
			return x != 0;
		}

		/**
		 * Returns the length of this Ray.
		 * 
		 * @return Length of this Ray
		 * @since 2.0
		 */
		public double length() {
			return Math.sqrt(dotProductL(this));
		}

		/**
		 * Calculates the similarity of this Ray with another. Similarity is defined
		 * as the absolute value of the dotProduct()
		 * 
		 * @param r
		 *            Ray being tested for similarity
		 * @return the Similarity
		 * @see #assimilarity(Ray)
		 * @since 2.0
		 */
		public int similarity(Ray r) {
			return dotProduct(r);
		}
	}
}
