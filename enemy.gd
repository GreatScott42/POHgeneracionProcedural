extends Sprite2D

var map = []
var pos = Vector2(2,2)
var lastpos
var jugador
var target
func _ready():
	jugador = get_parent().get_child(0)
	target = jugador.playerpos 
	print(target)
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", Callable(self, "timer"))	
	add_child(timer)

func timer():
	moveRandom()
	#moveFind(55,55)
	#target = jugador.playerpos 
	#print(target)
	#moveFind(target.x,target.y)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func moveFind(x,y):
	var x2=x
	var y2=y
	var distanceToX = pos.x-x2
	var distanceToY = pos.y-y2
	if lastpos == distanceToX+distanceToY:
		#if distanceToX+distanceToY<lastpos:
		moveRandom()
	lastpos = distanceToX+distanceToY
	print(distanceToX,"/",distanceToY)
	#if distanceToX>distanceToY:
	if distanceToX>0:
		moveXY(-1,0)
		return
	elif distanceToX<0:
		moveXY(1,0)
		return
	#if distanceToY>=distanceToX:
	if distanceToY>0:
		moveXY(0,-1)
		return
	elif distanceToY<0:
		moveXY(0,1)
		return
	#if lastpos == distanceToX+distanceToY:
		#moveRandom()
		#var z = distanceToX
		#distanceToX=distanceToY
		#distanceToY=z 
	
	pass
func moveRandom():
	var rng = RandomNumberGenerator.new()
	var xy = rng.randi_range(0,3)
	var d = Vector2(0,0);
	if xy==0:
		d = Vector2(1,0)
	elif xy==1:
		d = Vector2(-1,0)
	elif xy==2:
		d = Vector2(0,-1)
	elif xy==3:
		d = Vector2(0,1)
	if map[pos.y+d.y][pos.x+d.x]==0:
		position+=50*d
		map[pos.y][pos.x]=0
		map[pos.y+d.y][pos.x+d.x]=3
		pos+=d
	pass
func moveXY(x,y):
	if map[pos.y+y][pos.x+x]==0:
		position+=50*Vector2(x,y)
		map[pos.y][pos.x]=0
		map[pos.y+y][pos.x+x]=3
		pos+=Vector2(x,y)
	pass
func setEnemy(newmap, newpos):
	map = newmap
	pos = newpos	
	pass
