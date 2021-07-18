extends Control

const HISTORY_SIZE = 10

var texture

var undo_history = []
var redo_history = []

func _ready():
	texture = ImageTexture.new()
	texture.create(32, 32, Image.FORMAT_RGBA8, 0)
	
	clear_canvas()
	
	update()

func _draw():
	draw_texture_rect(texture, Rect2(0, 0, rect_size.x, rect_size.y), false)
	
func set_pixel(x, y, color):
	var data = texture.get_data()
	data.lock()
	data.set_pixel(x, y, color)
	
	texture.set_data(data)
	
	update()
	
func get_pixel(x, y):
	var data = texture.get_data()
	data.lock()
	
	return data.get_pixel(x, y)
	
func interpolate_pixel(x, y):
	var data = texture.get_data()
	data.lock()
	
	var c = Spaces.UColor.new()
	c.set_color(data.get_pixel(x, y))
	
	var add = 1
	
	for i in range (2):
		for ix in range(31):
			var nx = (x + add) + (ix * add)
		
			if (nx < 0 || nx > 31):
				break
				
			var nc = Spaces.UColor.new()
			nc.set_color(data.get_pixel(nx, y))
		
			if (nc.alpha != 0):
				var dS = convert(abs(nx - x), TYPE_REAL)

				for p in range(1, dS):
					var pdS = p / dS
					data.set_pixel(x + (p * add), y, Math.lerp_color(c, nc, pdS))
				break
				
		for iy in range(31):
			var ny = (y + add) + (iy * add)
		
			if (ny < 0 || ny > 31):
				break
				
			var nc = Spaces.UColor.new()
			nc.set_color(data.get_pixel(x, ny))
		
			if (nc.alpha != 0):
				var dS = convert(abs(ny - y), TYPE_REAL)

				for p in range(1, dS):
					var pdS = p / dS
					data.set_pixel(x, y + (p * add), Math.lerp_color(c, nc, pdS))
				break
		
		add = -1
		
		texture.set_data(data)
	
	
func get_pencil_position():
	var pos = get_local_mouse_position()
	
	# DO NOT CHANGE TO 16
	pos.x = floor(pos.x / 16)
	pos.y = floor(pos.y / 16)
	
	if pos.x < 0 or pos.x > 31 or pos.y < 0 or pos.y > 31:
		return false
	
	return pos
	
func save_canvas(dir):
	texture.get_data().save_png(dir)
	
func open_canvas(dir):
	var data = Image.new()
	data.load(dir)
	
	if data.get_size().x != 32 or data.get_size().y != 32:
		return false
	
	if data:
		texture.set_data(data)
	
func clear_canvas():
	texture.set_data(create_empty_data())
	undo_history.clear()
	
	add_to_undo_history()
		
func create_empty_data():
	var data = Image.new()
	data.create(32, 32, false, Image.FORMAT_RGBA8)
	data.lock()

	return data
		
func add_to_undo_history(data = texture.get_data()):
	undo_history.push_front(data)
	
	if undo_history.size() > HISTORY_SIZE:
		undo_history.pop_back()

func add_to_redo_history(data):
	redo_history.push_front(data)
	
	if redo_history.size() > HISTORY_SIZE:
		redo_history.pop_back()
		
func clear_redo_history():
	redo_history.clear()
	
func undo():
	if undo_history.size() < 2:
		return
		
	add_to_redo_history(undo_history[0])
	undo_history.pop_front()
	
	texture.set_data(undo_history[0])
	
func redo():
	if redo_history.size() == 0:
		return
	
	texture.set_data(redo_history[0])
	
	add_to_undo_history(redo_history[0])
	redo_history.pop_front()
	