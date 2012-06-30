// Manhattan Linker
// Vala/GTK Transformation of http://git.eclipse.org/c/gef/org.eclipse.gef.git/tree/org.eclipse.draw2d/src/org/eclipse/draw2d/ManhattanConnectionRouter.java
using Gee;

namespace Geometry{
	public class ManhattanLinker : Object{
		Map rowsUsed = new HashMap();
		Map colsUsed = new HashMap();

		Map reservedInfo = new HashMap();
		private class ReservedInfo {
			public GLib.List reservedRows = new GLib.List();
			public GLib.List reservedCols = new GLib.List();
		}

		private static Ray UP = new Ray(0, -1);
		private static Ray DOWN = new Ray(0, 1);
		private static Ray LEFT = new Ray(-1, 0);
		private static Ray RIGHT = new Ray(1, 0);

		/**
		 * @see ConnectionRouter#invalidate(Connection)
		 */
		public void invalidate(Connection connection) {
			removeReservedLines(connection);
		}

		private int getColumnNear(Connection connection, int r, int n, int x) {
			int min = Math.min(n, x), max = Math.max(n, x);
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
				if (!colsUsed.containsKey(i)) {
					colsUsed.put(i, i);
					reserveColumn(connection, i);
					return i.intValue();
				}
				int j = i.intValue();
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
			int i, distance = Math.abs(r.x - p.x);
			Ray direction;

			direction = LEFT;

			i = Math.abs(r.y - p.y);
			if (i <= distance) {
				distance = i;
				direction = UP;
			}

			i = Math.abs(r.bottom() - p.y);
			if (i <= distance) {
				distance = i;
				direction = DOWN;
			}

			i = Math.abs(r.right() - p.x);
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
			if (anchor.getOwner() == null)
				rect = new Rectangle(p.x - 1, p.y - 1, 2, 2);
			else {
				rect = conn.TargetAnchor.Bounds.getCopy();
				// conn.getTargetAnchor().getOwner().translateToAbsolute(rect);
			}
			return getDirection(rect, p);
		}

		protected int getRowNear(Connection connection, int r, int n, int x) {
			int min = Math.min(n, x), max = Math.max(n, x);
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
				if (!rowsUsed.containsKey(i)) {
					rowsUsed.put(i, i);
					reserveRow(connection, i);
					return i.intValue();
				}
				int j = i.intValue();
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
			if (anchor.getOwner() == null)
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

			int pos[] = new int[positions.size() + 2];
			if (horizontal)
				pos[0] = start.x;
			else
				pos[0] = start.y;
			int i;
			for (i = 0; i < positions.size(); i++) {
				pos[i + 1] = positions.nth_data(i);
			}
			if (horizontal == (positions.size() % 2 == 1))
				pos[++i] = end.x;
			else
				pos[++i] = end.y;

			GLib.List<Point> points = new GLib.List<Point>();
			points.append(new Point(start.x, start.y));
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
					p = new Point(prev, current);
				} else {
					if (adjust) {
						min = pos[i - 2];
						max = pos[i + 2];
						pos[i] = current = getColumnNear(conn, current, min, max);
					}
					p = new Point(current, prev);
				}
				points.append(p);
			}
			points.append(new Point(end.x, end.y));
			conn.PointList = points;
		}

		/**
		 * @see ConnectionRouter#remove(Connection)
		 */
		public void remove(Connection connection) {
			removeReservedLines(connection);
		}

		protected void removeReservedLines(Connection connection) {
			ReservedInfo rInfo = (ReservedInfo) reservedInfo.get(connection);
			if (rInfo == null)
				return;

			for (int i = 0; i < rInfo.reservedRows.size(); i++) {
				rowsUsed.remove(rInfo.reservedRows.get(i));
			}
			for (int i = 0; i < rInfo.reservedCols.size(); i++) {
				colsUsed.remove(rInfo.reservedCols.get(i));
			}
			reservedInfo.remove(connection);
		}

		protected void reserveColumn(Connection connection, int column) {
			ReservedInfo info = (ReservedInfo) reservedInfo.get(connection);
			if (info == null) {
				info = new ReservedInfo();
				reservedInfo.put(connection, info);
			}
			info.reservedCols.add(column);
		}

		protected void reserveRow(Connection connection, int row) {
			ReservedInfo info = (ReservedInfo) reservedInfo.get(connection);
			if (info == null) {
				info = new ReservedInfo();
				reservedInfo.put(connection, info);
			}
			info.reservedRows.add(row);
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

			Ray start = new Ray(startPoint);
			Ray end = new Ray(endPoint);
			Ray average = start.getAveraged(end);

			Ray direction = new Ray(start, end);
			Ray startNormal = getStartDirection(conn);
			Ray endNormal = getEndDirection(conn);

			GLib.List<int> positions = new GLib.List<int>(5);
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
