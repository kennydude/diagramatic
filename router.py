# Routing
# 2nd Attempt at making something work
# based on Dia this time

class Direction:
	North = 1
	East = 2
	South = 4
	West = 8

class Point(object):
	X = 0
	Y = 0
	Direction = Direction.North
	
	def __repr__(self):
		return "Point[ %i, %i ]" % ( self.X, self.Y)	

	def rotateClockwise(self):
		t = self.X
		self.X = -self.Y
		self.Y = t
	
	def rotateCounterClockwise(self):
		t = self.X
		self.X = self.Y
		self.Y = -t
	
	def rotate180(self):
		self.X = -self.X
		self.Y = -self.Y
	
	def DistanceBetween_Manhattan(self, other):
		dx = long(self.X) - long(other.X)
		dy = long(self.Y) - long(other.Y)
		return abs(dx - dy)
	
	def Add(self, other):
		self.X += other.X
		self.Y += other.Y
	
	def clone(self):
		r = Point()
		r.X = self.X
		r.Y = self.Y
		return r

def if_eq( i, t, f ):
	if i == True:
		return t
	return f

debug_on = False
def debug( s ):
	global debug_on
	if __name__ == "__main__" or debug_on == True:
		print "DEBUG: %s" % s

class Router(object):
	MIN_DIST = 1.0
	
	def Normalize(self, startDirection, endDirection,  start,  end):
		newend = Point()
		newend.X = end.X - start.X
		newend.Y = end.Y - start.Y
		print newend
		if(startDirection== Direction.North):
			return (endDirection, newend)
		elif(startDirection== Direction.East):
			newend.rotateCounterClockwise()
			if(endDirection== Direction.North): return (Direction.West, newend)
			return (endDirection / 2, newend)
		elif(startDirection== Direction.West):
			newend.rotateClockwise()
			if(endDirection== Direction.West): return (Direction.North, newend)
			return (endDirection * 2, newend)
		else: # if(start== Direction.South)
			newend.rotate180()	
			if(endDirection< Direction.South): return (endDirection* 4, newend)
			else: return (endDirection / 4, newend)
		
		
		return (endDirection, newend)
	
	def LayoutOrthogonal( self,  to,  enddir ):
		dirmult = if_eq(enddir == Direction.West, 1.0, -1.0)
		if(to.X < -self.MIN_DIST):
			if(dirmult * to.X > self.MIN_DIST ):
				ps = self.newArray(3)
				ps[1].Y = to.Y
				ps[2] = to
			else:
				if(dirmult * to.X > 0): off = -dirmult*self.MIN_DIST
				else: off =  -dirmult * (self.MIN_DIST * abs(to.X )) 
				
				ps = self.newArray(5)
				ps[1].Y = -self.MIN_DIST
				ps[2].X = off
				ps[2].Y = -self.MIN_DIST
				ps[3].X = off
				ps[3].Y = to.Y
				ps[4] = to
			
		else:
			if( dirmult * to.X > 2*self.MIN_DIST ):
				mid = to.X/2
				ps = self.newArray(5)
				ps[1].Y = -self.MIN_DIST
				ps[2].X = mid
				ps[2].Y = -self.MIN_DIST
				ps[3].X = mid
				ps[3].Y = to.Y
				ps[4] = to
			else:
				if(dirmult * to.X > 0): off = -dirmult*self.MIN_DIST
				else: off = -dirmult * (self.MIN_DIST * abs(to.X ))
				
				ps = self.newArray(5)
				ps[1].Y = -self.MIN_DIST
				ps[2].X = off
				ps[2].Y = -self.MIN_DIST
				ps[3].X = off
				ps[3].Y = to.Y
				ps[4] = to
			
		
		
		return (self.CalculateBadness(ps), ps)
	
	
	def LayoutOpposite(self, to ):
		print to, self.MIN_DIST
		if(to.Y < -self.MIN_DIST ):
			ps = self.newArray(4)
			if(abs(to.X) < 0.00000001):
				ps[2] = ps[3] = to
				return (self.LengthBadness( abs(to.X) ) + 2 * self.EXTRA_SEGMENT_BADNESS, ps)
			else: # Threeway
				debug("Threeway")
				mid = to.Y / 2
				ps[1].Y = mid
				ps[2].X = to.X
				ps[2].Y = mid
				ps[3] = to
				return (2 * self.LengthBadness( abs( mid ) ) + 2 * self.EXTRA_SEGMENT_BADNESS, ps)
			
		elif( abs( to.X ) > (2 * self.MIN_DIST) ):  # Doorhanger?
			debug("Doorhanger")
			mid = to.X / 2
			ps = self.newArray(6)
			ps[1].Y = -self.MIN_DIST
			ps[2].X = mid
			ps[2].Y = -self.MIN_DIST
			ps[3].X = mid
			ps[3].Y = to.Y+self.MIN_DIST
			ps[4].X = to.X
			ps[4].Y = to.Y+self.MIN_DIST
			ps[5] = to
		else:  # Overlap
			debug("Overlap")
			off = float(self.MIN_DIST) * if_eq(to.X > 0, -1.0, 1.0) 
			
			ps = self.newArray(6)
			ps[1].Y = -self.MIN_DIST
			ps[2].X = off
			ps[2].Y = -self.MIN_DIST
			ps[3].X = off
			ps[3].Y = to.Y + self.MIN_DIST
			ps[4].X = to.X
			ps[4].Y = to.Y + self.MIN_DIST
			ps[5] = to
		
		return (self.CalculateBadness(ps), ps)
	
	
	def LayoutParallel( self, to ):
		if( abs(to.X) > self.MIN_DIST ): # Wide
			top = min( -self.MIN_DIST, to.Y - self.MIN_DIST)
			
			ps = self.newArray(4)
			ps[1].Y = top
			ps[2].X = to.X
			ps[2].Y = top
			ps[3] = to
		elif( to.Y > 0 ):
			top = -self.MIN_DIST
			off = to.X + self.MIN_DIST * if_eq( to.X > 0, 1.0, -1.0 )
			bottom = to.Y - self.MIN_DIST

			ps = self.newArray(6)
			ps[1].Y = top
			ps[2].X = off
			ps[2].Y = top
			ps[3].X = off
			ps[3].Y = bottom
			ps[4].X = to.X
			ps[4].Y = bottom
			ps[5] = to
		else:  # Narrow
			top = to.Y - self.MIN_DIST
			off = self.MIN_DIST * if_eq(to.X > 0, -1.0, 1.0)
			bottom = -self.MIN_DIST

			ps = self.newArray(6)
			# s[0] is 0,0
			ps[1].Y = bottom
			ps[2].X = off
			ps[2].Y = bottom
			ps[3].X = off
			ps[3].Y = top
			ps[4].X = to.X
			ps[4].Y = top
			ps[5] = to
		
		return (CalculateBadness(ps), ps)
	
	
	# Badness  */
	EXTRA_SEGMENT_BADNESS = 10.0
	MAX_SMALL_BADNESS = 10.0
	MAX_BADNESS =  10000.0
	
	def CalculateBadness(self, s):
		badness = (len(s) - 1)*self.EXTRA_SEGMENT_BADNESS
		i=0
		while( i < len(s)-1 ):
			badness += self.LengthBadness( s[i].DistanceBetween_Manhattan( s[i+1] ) )
			i+=1
		return badness
	
	def LengthBadness(self, length):
		if(length < self.MIN_DIST ):
			# This should be zero at self.MIN_DIST and MAX_SMALL_BADNESS at 0 
			d = float(1.0+length/self.MIN_DIST)
			debug("%i" % length)
			if d == 0:
				debug("Faulty Length %i" % length)
				d = -10
			return 2*self.MAX_SMALL_BADNESS/ d - self.MAX_SMALL_BADNESS
		else:
		 	return length-self.MIN_DIST
		
	
	
	def UnnormalizePoints( self, startDirection,  start, s ):
		i = 0
		news = []
		while( i < len(s) ):
			point = s[i]
			
			if(startDirection == Direction.East):
				point.rotateClockwise()
			elif(startDirection == Direction.South):
				point.rotate180()
			elif(startDirection == Direction.West):
				point.rotateCounterClockwise()
			
			point.Add(start)
			
			news.append(point)
			i+=1
		
		return news
	
	def newArray(self, size):
		r = []
		i = 0
		while(i < size):
			r.append( Point() )
 			i+=1
		
		return r
	
	
	lastRoute = []
	def Route( self, start,  end ):
		fromDirection = start.Direction
		toDirection = end.Direction
		
		minBadness = self.MAX_BADNESS
		bestLayout = []
		
		startDirection = Direction.North
		while(startDirection <= Direction.West):
			endDirection = Direction.North
			while(endDirection <= Direction.West):
				if( (fromDirection == startDirection) and (toDirection == endDirection) ):
					this_layout = None
					otherPoint = Point()
					this_badness = 0.0
					
					normal_enddir, otherPoint = self.Normalize(startDirection, endDirection, start, end)
					debug("%s"%otherPoint)					
					if(normal_enddir == Direction.North):
						debug( "Parallel" )
						this_badness, this_layout = self.LayoutParallel( otherPoint )
					elif( normal_enddir == Direction.South ):
						debug( "Opposite" )
						this_badness, this_layout = self.LayoutOpposite( otherPoint )
					else:
						debug( "Orthogonal" )
						this_badness, this_layout = self.LayoutOrthogonal( otherPoint, normal_enddir )
					
					if(this_layout != None):
						if(this_badness - minBadness < -0.00001):
							minBadness = this_badness
							this_layout = self.UnnormalizePoints( startDirection, start, this_layout )
							bestLayout = this_layout
				endDirection *= 2
			startDirection *= 2			
		
		if( minBadness < self.MAX_BADNESS):
			self.lastRoute = bestLayout
			return True
		else:
			return False
		
if __name__ == "__main__":
	print "TEST"
	r = Router()
	a = Point()
	a.X = 22
	a.Y = 10
	a.Direction = Direction.East

	b = Point()
	b.X = 40
	b.Y = 50
	b.Direction = Direction.West

	print "We are going from", a, "to", b
	print r.Route(a, b)
	print r.lastRoute
