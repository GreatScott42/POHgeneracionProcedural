extends Area2D
var map1 =    [[0,0,0,0,0,0,0,0,0,0],
			   [0,2,1,1,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0],
			   [0,0,0,0,0,0,0,0,0,0]]
#var map =     [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
			   #[1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			   #[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			   #[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			   #[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			   #[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			   #[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			   #[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
			   #[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]
var map = []
var rows = 200
var columns = rows
var block = preload("res://floor.tscn")
var grass = preload("res://grass.tscn")
var enemy = preload("res://enemy.tscn")
var portalk = preload("res://portalk.tscn")
var portall = preload("res://portall.tscn")
var makemap = false
var playerpos = Vector2(int(rows/2),int(columns/2))
var lastDirection = Vector2(1,0)
var enemies = []
var solidNumbers = [1,3,6]
var kPos
var lPos
var playerchunk
var mundoDimensiones
var http : HTTPRequest
func _ready():	
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(Callable(self, "_on_request_completed"))
	var url = "https://raw.githubusercontent.com/GreatScott42/ot3/master/integer2.q"
	http.request(url)
	pass
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var content = body.get_string_from_utf8()
		var number = int(content.strip_edges())
		print("Número obtenido del repositorio: ", number)
	else:
		print("Error al descargar el archivo. Código de respuesta: ", response_code)
	pass
func _init():	
	pass
func updateCam():
	var viewport_size = Vector2(get_viewport().size.x,get_viewport().size.y);
	get_viewport().canvas_transform.origin = -position + viewport_size / 2
	pass
func _draw():
	#draw_rect(Rect2(Vector2(playerpos.x,playerpos.y),Vector2(1000,1000)),Color.BLUE)
	pass

func _process(delta):	
	#generar mapa	
	#await get_tree().create_timer(1).timeout
	if(!makemap):
		var camara = get_node("Camera2D")
		camara.zoom = Vector2(0.1,0.1)
		#crea la matriz
		CreateMap()
		#genera limites y bloques randoms
		generateLand();
		#genera ruido en la matriz
		generateLandPerlin()
		#placeBlockRAND(55,55)
		createBorder()
		placePlayer()
		#pone los bloques
		#spawnEnemy()
		#for i in range(10):
			#spawnEnemy()
		generateMap()
		calcularDimensiones()
		mundoDimensiones = Vector2(10,10)
		#generateWorld()
		makemap=true
		pass
	playerchunk = Vector2(int((playerpos.x - 1) / 10 + 1),int((playerpos.y - 1) / 10 + 1))
	if Input.is_action_just_pressed("action"):		
		placeBlock()
		#generateMap();
	if Input.is_action_just_pressed("action2"):
		destroyBlock()
	if Input.is_action_just_pressed("move_left"):			
			if lastDirection != Vector2(-1,0):
				lastDirection = Vector2(-1,0);
				return
			if map[playerpos.y][playerpos.x-1] in solidNumbers:
				return
			if map[playerpos.y][playerpos.x-1]==4:
				teleport(4)				
				return
			if map[playerpos.y][playerpos.x-1]==5:
				teleport(5)				
				return
			position.x-=50
			map[playerpos.y][playerpos.x]=0			
			map[playerpos.y][playerpos.x-1]=2
			
			playerpos.x-=1
			print("position: ",position.x,"/positionM: ",playerpos.x,"newPOS: ",position.x*0.02)
			#printmap()
	if Input.is_action_just_pressed("move_right"):
			if lastDirection != Vector2(1,0):
				lastDirection = Vector2(1,0);
				return
			if map[playerpos.y][playerpos.x+1] in solidNumbers:
				return
			if map[playerpos.y][playerpos.x+1]==4:
				teleport(4)				
				return
			if map[playerpos.y][playerpos.x+1]==5:
				teleport(5)				
				return
			position.x+=50
			map[playerpos.y][playerpos.x]=0
			map[playerpos.y][playerpos.x+1]=2
			playerpos.x+=1
			#printmap()
	if Input.is_action_just_pressed("move_down"):			
			if lastDirection != Vector2(0,1):
				lastDirection = Vector2(0,1);
				return
			if map[playerpos.y+1][playerpos.x] in solidNumbers:
				return
			if map[playerpos.y+1][playerpos.x]==4:
				teleport(4)				
				return
			if map[playerpos.y+1][playerpos.x]==5:
				teleport(5)				
				return
			position.y+=50
			map[playerpos.y][playerpos.x]=0			
			map[playerpos.y+1][playerpos.x]=2
			playerpos.y+=1
			#printmap()
	if Input.is_action_just_pressed("move_up"):			
			if lastDirection != Vector2(0,-1):
				lastDirection = Vector2(0,-1);
				return
			if map[playerpos.y-1][playerpos.x] in solidNumbers:
				return
			if map[playerpos.y-1][playerpos.x]==4:
				teleport(4)				
				return
			if map[playerpos.y-1][playerpos.x]==5:
				teleport(5)				
				return
			position.y-=50
			map[playerpos.y][playerpos.x]=0			
			map[playerpos.y-1][playerpos.x]=2
			playerpos.y-=1
	if Input.is_action_pressed("map"):
		var camara = get_node("Camera2D")
		camara.zoom = Vector2(0.1,0.1)
		#printmap()
		#generateMap()
	if Input.is_action_just_released("map"):
		var camara = get_node("Camera2D")
		#camara.zoom = Vector2(0.5,0.5)
		camara.zoom = Vector2(0.1,0.1)
		pass
	if Input.is_action_just_pressed("portalk"):
		#horizontal positivo
		columns+=10
		for a in range(10):
			map.append([])
			for b in range(10):
				map[a].append(0)
				
		#position.x+=50*10
		#map[playerpos.y][playerpos.x]=0
		#map[playerpos.y][playerpos.x+10]=2
		#playerpos.x+=10
		
		createBorder()
		#print("rows: ",rows,"/columns: ",columns,"/newcolumns: ",len(map),"/newrows: ",len(map[0]))
		
		#print("chunk xy: ",playerchunk.x,"/",playerchunk.y) 
		#print("rows: ",rows,"/columns: ",columns)
		#print(map)
		#map.append([0,0,0,0,0])  
		#createPortalK()
	if Input.is_action_just_pressed("portall"):
		#vertical positivo
		rows+=10
		for a in range(10):
			map.append([])
			for b in range(10):
				var m = (mundoDimensiones.x+1)/10
				#print(int(m))
				map[a+10*int(m)].append(0)
		
		
		#position.y+=50*10
		#map[playerpos.y][playerpos.x]=0
		#map[playerpos.y+10][playerpos.x]=2
		#playerpos.y+=10
		#columns+=10
		createBorder()
		#print("rows: ",rows,"/columns: ",columns)
		#createPortalL()
	
	
	pass
func teleport(intin):
	if intin == 4:
		map[playerpos.y][playerpos.x]=0
		map[lPos.x+lastDirection.y][lPos.y+lastDirection.x]=2
		#print(lPos,"/",lastDirection)
		playerpos = Vector2(lastDirection.y+lPos.y,lastDirection.x+lPos.x)
	if intin == 5:
		map[playerpos.y][playerpos.x]=0
		map[kPos.x+lastDirection.y][kPos.y+lastDirection.x]=2
		#print(lPos,"/",lastDirection)
		playerpos = Vector2(lastDirection.y+kPos.y,lastDirection.x+kPos.x)
	#generateMap()
	pass
func createPortalK():
	for i in rows:
		for j in columns:
			if map[i][j]==4:
				return
	var k = portalk.instantiate();
	var x2 = (playerpos.x+lastDirection.x)*50;
	var y2 = (playerpos.y+lastDirection.y)*50;
	if map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]==1||map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]==3:
		return
	k.position = Vector2(x2,y2)
	get_parent().add_child(k)
	map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]=4
	kPos = Vector2(playerpos.y+lastDirection.y,playerpos.x+lastDirection.x)
	pass
func createPortalL():
	for i in rows:
		for j in columns:
			if map[i][j]==5:
				return
	var l = portall.instantiate();
	var x2 = (playerpos.x+lastDirection.x)*50;
	var y2 = (playerpos.y+lastDirection.y)*50;
	if map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]==1||map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]==3:
		return
	#y2 += 50;
	#print("x: ",x2," y2: ",y2);
	l.position = Vector2(x2,y2);
	#print("posblock: ",blockI.position," posplayer: ",position," row_index: ",row_index," column_index: ",column_index);
	get_parent().add_child(l);
	map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]=5;
	lPos = Vector2(playerpos.y+lastDirection.y,playerpos.x+lastDirection.x)
	pass
func spawnEnemy():
	var enemyI = enemy.instantiate();
	var rng = RandomNumberGenerator.new()
	var i = rng.randi_range(1,rows-1)
	var j = rng.randi_range(1,columns-1)
	
	while map[i][j]==1:
		i = rng.randi_range(1,rows-1)
		j = rng.randi_range(1,columns-1)
	enemyI.position = Vector2(i,j)*50;
	enemyI.setEnemy(map, Vector2(i,j))
	enemies.append(enemyI)
	get_parent().add_child(enemyI);
	map[i][j]=3;
		
	pass
func placeBlock():
	var blockI = block.instantiate();
	var x2 = (playerpos.x+lastDirection.x)*50;
	#x2 += 50;
	var y2 = (playerpos.y+lastDirection.y)*50;
	if map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]==1||map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]==3:
		return
	#y2 += 50;
	#print("x: ",x2," y2: ",y2);
	blockI.position = Vector2(x2,y2);
	#print("posblock: ",blockI.position," posplayer: ",position," row_index: ",row_index," column_index: ",column_index);
	get_parent().add_child(blockI);
	map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]=1;
	pass
func placeBlockRAND(x, y):
	var blockI = block.instantiate();
	var x2 = x*50
	var y2 = y*50
	blockI.position = Vector2(x2,y2);
	get_parent().add_child(blockI);
	map[y][x]=1;
	pass
func placePlayer():
	for i in range(playerpos.x,rows):
		for j in range(playerpos.y,columns):
			if map[i][j]==0:
				map[i][j]=2;
				return
	pass
func generateLandPerlin():
	var noise = FastNoiseLite.new()
	noise.seed = randi()  	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.01
	for i in range(rows):
		for j in range(columns):
			var noise_value = noise.get_noise_2d(i, j)
			if noise_value > 0.0:
				map[i][j]=1
			else:
				map[i][j]=0
	pass
func createBorder():
	#print("lenmap: ",len(map),"/columns: ",columns,"/size: ",map.size(),"/[0]size:",map[0].size())
	#print(map)
	calcularDimensiones()
	var h = len(map)
	for i in range(mundoDimensiones.x):
		for j in range(mundoDimensiones.y):
			#print("i: ",i,"/j: ",j,"/ROWS: ",rows,"/COLUMNS: ",columns)
			if j == 0:
				map[i][j]=6;
			if i == 0:
				map[i][j]=6;
			if i == mundoDimensiones.x-1:
				map[i][j]=6;
			if j == mundoDimensiones.y-1:
				map[i][j]=6
	generateMap()
	pass
func destroyBlock():
	if map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]==6:
		return
	map[(playerpos.y+lastDirection.y)][(playerpos.x+lastDirection.x)]=0
	var parent_node = get_parent()
	for child in parent_node.get_children():
		if child.name=="player":
			continue
		if child.is_class("enemy"):
			continue
		parent_node.remove_child(child)
		child.queue_free()
	generateMap();
	pass
func generateMap():
	var parent_node = get_parent()
	calcularDimensiones()
	for child in parent_node.get_children():
		if child.name=="player":
			continue
		if child.is_class("enemy"):
			continue
		parent_node.remove_child(child)
		child.queue_free()
	for i in range(mundoDimensiones.x):
		for j in range(mundoDimensiones.y):
			if map[i][j]==0:
				var grassI = grass.instantiate()
				var x = j*50;
				var y = i*50;
				grassI.position = Vector2(x,y);
				get_parent().add_child(grassI);
				pass
			elif map[i][j]==1:
				var blockI = block.instantiate();
				var x = j*50;
				var y = i*50;
				blockI.position = Vector2(x,y);
				get_parent().add_child(blockI);
				pass
			elif map[i][j]==2:
				var x = j*50;
				playerpos.x=j;
				var y = i*50;
				playerpos.y=i;
				position = Vector2(x,y);
				var grassI = grass.instantiate()
				grassI.position = Vector2(x,y);
				get_parent().add_child(grassI);
				pass
			elif map[i][j]==3:
				var enemyI = enemy.instantiate();
				enemyI.setEnemy(map, Vector2(j,i))
				enemyI.position = Vector2(j,i)*50;
				enemies.append(enemyI)
				get_parent().add_child(enemyI);
			elif map[i][j]==4:
				var k = portalk.instantiate();				
				k.position = Vector2(j,i)*50;				
				get_parent().add_child(k);
			elif map[i][j]==5:
				var l = portall.instantiate();				
				l.position = Vector2(j,i)*50;				
				get_parent().add_child(l);
			elif map[i][j]==6:
				var blockI = block.instantiate();
				var x = j*50;
				var y = i*50;
				blockI.position = Vector2(x,y);
				get_parent().add_child(blockI);
				pass
	pass
func CreateMap():
	for i in range(rows):
		map.append([])
		for j in range(columns):
			map[i].append(0)
	#for i in range(rows):
		#for j in range(columns):
			#if j == 0:
				#map[i][j]=1;
			#if i == 0:
				#map[i][j]=1;
			#if i == rows-1:
				#map[i][j]=1;
			#if j == columns-1:
				#map[i][j]=1;
	
	pass
func printmap():
	var linea="";
	for row_index in range(len(map)):
		for column_index in range(len(map[row_index])):
			linea+=str(map[row_index][column_index])
			#mundoDimensiones = Vector2(row_index,column_index)
		linea+="\n"
		
	print(linea)
	
	#mundoDimensiones.x+=1
	#mundoDimensiones.y+=1
	mundoDimensiones = Vector2(rows,columns)
	print(mundoDimensiones.x,"/",mundoDimensiones.y)
func calcularDimensiones():
	#for row_index in range(len(map)):
		#for column_index in range(len(map[row_index])):
			#linea+=str(map[row_index][column_index])
			#mundoDimensiones = Vector2(row_index,column_index)
		#linea+="\n"
		
	#print(linea)
	mundoDimensiones = Vector2(rows,columns)
	#mundoDimensiones.x+=1
	#mundoDimensiones.y+=1
	pass
func generateLand():
	print("generando tierra")
	var rng = RandomNumberGenerator.new()
	for i in range(100):
		var random_i = rng.randi_range(1, 99)
		var random_j = rng.randi_range(1, 99)
		if map[random_i][random_j]==2:
			continue
		placeBlockRAND(random_i,random_j);
	map[1][1]=2
	pass
func generateWorld():
	for i in range(10):
		for j in range(10):
			if map1[i][j]==1:
				#CreateMap()
				#createBorder()
				#generateMap(i,j)
				createNewMap(i,j)
	pass
func createNewMap(xoff,yoff):
	#array
	var mapi = []
	for i in range(rows):
		mapi.append([])
		for j in range(columns):
			mapi[i].append(0)
	#borde
	for i in range(rows):
		for j in range(columns):
			#print("i: ",i,"/j: ",j,"/ROWS: ",rows,"/COLUMNS: ",columns)
			if j == 0:
				mapi[i][j]=1;
			if i == 0:
				mapi[i][j]=1;
			if i == rows-1:
				mapi[i][j]=1;
			if j == columns-1:
				mapi[i][j]=1;
	#texturas
	var parent_node = get_parent()
	for child in parent_node.get_children():
		if child.name=="player":
			continue
		if child.is_class("enemy"):
			continue
		parent_node.remove_child(child)
		child.queue_free()
	for i in range(rows):
		for j in range(columns):
			if mapi[i][j]==1:
				var blockI = block.instantiate();
				var x = j*50*xoff;
				var y = i*50*yoff;
				blockI.position = Vector2(x,y);
				get_parent().add_child(blockI);
				pass
			elif mapi[i][j]==2:
				var x = j*50*xoff;
				playerpos.x=j;
				var y = i*50*yoff;
				playerpos.y=i;
				position = Vector2(x,y);
				pass
			elif mapi[i][j]==3:
				var enemyI = enemy.instantiate();
				enemyI.setEnemy(mapi, Vector2(j,i))
				enemyI.position = Vector2(j,i)*50;
				enemies.append(enemyI)
				get_parent().add_child(enemyI);
			elif mapi[i][j]==4:
				var k = portalk.instantiate();				
				k.position = Vector2(j,i)*50;				
				get_parent().add_child(k);
			elif mapi[i][j]==5:
				var l = portall.instantiate();				
				l.position = Vector2(j,i)*50;				
				get_parent().add_child(l);
	map.append(mapi)
	pass
