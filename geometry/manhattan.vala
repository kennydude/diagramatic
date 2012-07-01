// Manhattan Linker
// Vala/GTK Transformation of http://git.eclipse.org/c/gef/org.eclipse.gef.git/tree/org.eclipse.draw2d/src/org/eclipse/draw2d/ManhattanConnectionRouter.java
using Gee;

namespace Geometry{
	public class ManhattanLinker : Object{
		/* From Abstract class */
		private static Point START = new Point();
		private static Point END = new Point();
		
		protected Point getEndPoint(Connection connection) {
			Point r = connection.SourceAnchor.ReferencePoint;
			return END.setLocation_point(r);
		}
		
		protected Point getStartPoint(Connection conn) {
			Point r = conn.TargetAnchor.ReferencePoint;
			return START.setLocation_point(r);
		}
		/* End From */
		
		Map<int, int> rowsUsed = new HashMap<int, int>();
		Map<int, int> colsUsed = new HashMap<int, int>();

		Map<Connection, ReservedInfo> reservedInfo = new HashMap<Connection, ReservedInfo>();
		private class ReservedInfo {
			public GLib.List<int> reservedRows = new GLib.List<int>();
			public GLib.List<int> reservedCols = new GLib.List<int>();
		}

		private static Ray UP = Ray.from_ints(0, -1);
		private static Ray DOWN = Ray.from_ints(0, 1);
		private static Ray LEFT = Ray.from_ints(-1, 0);
		private static Ray RIGHT = Ray.from_ints(1, 0);

		/**
		 * @see ConnectionRouter#invalidate(Connection)
		 */
		public void invalidate(Connection connection) {
			removeReservedLines(connection);
		}

		private int getColumnNear(Connection connection, int r, int n, int x) {
			int min = int.min(n, x), max = int.max(n, x);
			if (min > r) {
				max = min;
				min = r - (min - r);
			}
			if (max < r) {
				min = max;
				max = r + (r - max);
			}
			int proximity = 0;
			int direction = -1;
			if (r % 2 == 1)
				r--;
			int i;
			while (proximity < r) {
				i = r + proximity * direction;
				if (!colsUsed.has_key(i)) {
					colsUsed.set(i, i);
					reserveColumn(connection, i);
					return i;
				}
				int j = i;
				if (j <= min)
					return j + 2;
				if (j >= max)
					return j - 2;
				if (direction == 1)
					direction = -1;
				else {
					direction = 1;
					proximity += 2;
				}
			}
			return r;
		}

		/**
		 * Returns the direction the point <i>p</i> is in relation to the given
		 * rectangle. Possible values are LEFT (-1,0), RIGHT (1,0), UP (0,-1) and
		 * DOWN (0,1).
		 * 
		 * @param r
		 *            the rectangle
		 * @param p
		 *            the point
		 * @return the direction from <i>r</i> to <i>p</i>
		 */
		protected Ray getDirection(Rectangle r, Point p) {
			int i, distance = (int)Math.fabs(r.x - p.x);
			Ray direction;

			direction = LEFT;

			i = (int)Math.fabs(r.y - p.y);
			if (i <= distance) {
				distance = i;
				direction = UP;
			}

			i = (int)Math.fabs(r.bottom() - p.y);
			if (i <= distance) {
				distance = i;
				direction = DOWN;
			}

			i = (int)Math.fabs(r.right() - p.x);
			if (i < distance) {
				distance = i;
				direction = RIGHT;
			}

			return direction;
		}

		protected Ray getEndDirection(Connection conn) {
			ConnectionAnchor anchor = conn.TargetAnchor;
			Point p = getEndPoint(conn);
			Rectangle rect;
			if (anchor.Bounds == null)
				rect = new Rectangle(p.x - 1, p.y - 1, 2, 2);
			else {
				rect = conn.TargetAnchor.Bounds.getCopy();
				// conn.getTargetAnchor().getOwner().translateToAbsolute(rect);
			}
			return getDirection(rect, p);
		}

		protected int getRowNear(Connection connection, int r, int n, int x) {
			int min = int.min(n, x), max = int.max(n, x);
			if (min > r) {
				max = min;
				min = r - (min - r);
			}
			if (max < r) {
				min = max;
				max = r + (r - max);
			}

			int proximity = 0;
			int direction = -1;
			if (r % 2 == 1)
				r--;
			int i;
			while (proximity < r) {
				i = r + proximity * direction;
				if (!rowsUsed.has_key(i)) {
					rowsUsed.set(i, i);
					reserveRow(connection, i);
					return i;
				}
				int j = i;
				if (j <= min)
					return j + 2;
				if (j >= max)
					return j - 2;
				if (direction == 1)
					direction = -1;
				else {
					direction = 1;
					proximity += 2;
				}
			}
			return r;
		}

		protected Ray getStartDirection(Connection conn) {
			ConnectionAnchor anchor = conn.SourceAnchor;
			Point p = getStartPoint(conn);
			Rectangle rect;
			if (anchor.Bounds == null)
				rect = new Rectangle(p.x - 1, p.y - 1, 2, 2);
			else {
				rect = conn.SourceAnchor.Bounds.getCopy();
				// conn.SourceAnchor.getOwner().translateToAbsolute(rect);
			}
			return getDirection(rect, p);
		}

		protected void processPositions(Ray start, Ray end, GLib.List<int> positions,
				bool horizontal, Connection conn) {
			removeReservedLines(conn);

			int[] pos = {};
			if (horizontal)
				pos[0] = start.x;
			else
				pos[0] = start.y;
			int i;
			for (i = 0; i < positions.length(); i++) {
				pos[i + 1] = positions.nth_data(i);
			}
			if (horizontal == (positions.length() % 2 == 1))
				pos[++i] = end.x;
			else
				pos[++i] = end.y;

			GLib.List<Point> points = new GLib.List<Point>();
			points.append(Point.from_integers(start.x, start.y));
			Point p;
			int current, prev, min, max;
			bool adjust;
			for (i = 2; i < pos.length - 1; i++) {
				horizontal = !horizontal;
				prev = pos[i - 1];
				current = pos[i];

				adjust = (i != pos.length - 2);
				if (horizontal) {
					if (adjust) {
						min = pos[i - 2];
						max = pos[i + 2];
						pos[i] = current = getRowNear(conn, current, min, max);
					}
					p = Point.from_integers(prev, current);
				} else {
					if (adjust) {
						min = pos[i - 2];
						max = pos[i + 2];
						pos[i] = current = getColumnNear(conn, current, min, max);
					}
					p = Point.from_integers(current, prev);
				}
				points.append(p);
			}
			points.append( Point.from_integers(end.x, end.y));
			conn.PointList = points.copy();
		}

		/**
		 * @see ConnectionRouter#remove(Connection)
		 */
		public void remove(Connection connection) {
			removeReservedLines(connection);
		}

		protected void removeReservedLines(Connection connection) {
			ReservedInfo rInfo = reservedInfo.get(connection);
			if (rInfo == null)
				return;

			for (int i = 0; i < rInfo.reservedRows.length(); i++) {
				rowsUsed.unset(rInfo.reservedRows.nth_data(i));
			}
			for (int i = 0; i < rInfo.reservedCols.length(); i++) {
				colsUsed.unset(rInfo.reservedCols.nth_data(i));
			}
			reservedInfo.unset(connection);
		}

		protected void reserveColumn(Connection connection, int column) {
			ReservedInfo info = reservedInfo.get(connection);
			if (info == null) {
				info = new ReservedInfo();
				reservedInfo.set(connection, info);
			}
			info.reservedCols.append(column);
		}

		protected void reserveRow(Connection connection, int row) {
			ReservedInfo info = reservedInfo.get(connection);
			if (info == null) {
				info = new ReservedInfo();
				reservedInfo.set(connection, info);
			}
			info.reservedRows.append(row);
		}

		/**
		 * @see ConnectionRouter#route(Connection)
		 */
		public void route(Connection conn) {
			if ((conn.SourceAnchor == null)
					|| (conn.TargetAnchor == null))
				return;
			int i;
			Point startPoint = getStartPoint(conn);
			conn.translateToRelative(startPoint);
			Point endPoint = getEndPoint(conn);
			conn.translateToRelative(endPoint);

			Ray start = Ray.from_point(startPoint);
			Ray end = Ray.from_point(endPoint);
			Ray average = start.getAveraged(end);

			Ray direction = Ray.from_rays(start, end);
			Ray startNormal = getStartDirection(conn);
			Ray endNormal = getEndDirection(conn);

			GLib.List<int> positions = new GLib.List<int>();
			bool horizontal = startNormal.isHorizontal();
			if (horizontal)
				positions.append(start.y);
			else
				positions.append(start.x);
			horizontal = !horizontal;

			if (startNormal.dotProduct(endNormal) == 0) {
				if ((startNormal.dotProduct(direction) >= 0)
						&& (endNormal.dotProduct(direction) <= 0)) {
					// 0
				} else {
					// 2
					if (startNormal.dotProduct(direction) < 0)
						i = startNormal.similarity(start.getAdded(startNormal
								.getScaled(10)));
					else {
						if (horizontal)
							i = average.y;
						else
							i = average.x;
					}
					positions.append(i);
					horizontal = !horizontal;

					if (endNormal.dotProduct(direction) > 0)
						i = endNormal.similarity(end.getAdded(endNormal
								.getScaled(10)));
					else {
						if (horizontal)
							i = average.y;
						else
							i = average.x;
					}
					positions.append(i);
					horizontal = !horizontal;
				}
			} else {
				if (startNormal.dotProduct(endNormal) > 0) {
					// 1
					if (startNormal.dotProduct(direction) >= 0)
						i = startNormal.similarity(start.getAdded(startNormal
								.getScaled(10)));
					else
						i = endNormal.similarity(end.getAdded(endNormal
								.getScaled(10)));
					positions.append(i);
					horizontal = !horizontal;
				} else {
					// 3 or 1
					if (startNormal.dotProduct(direction) < 0) {
						i = startNormal.similarity(start.getAdded(startNormal
								.getScaled(10)));
						positions.append(i);
						horizontal = !horizontal;
					}

					if (horizontal)
						i = average.y;
					else
						i = average.x;
					positions.append(i);
					horizontal = !horizontal;

					if (startNormal.dotProduct(direction) < 0) {
						i = endNormal.similarity(end.getAdded(endNormal
								.getScaled(10)));
						positions.append(i);
						horizontal = !horizontal;
					}
				}
			}
			if (horizontal)
				positions.append(end.y);
			else
				positions.append(end.x);

			processPositions(start, end, positions, startNormal.isHorizontal(),
					conn);
		}
	}
}
