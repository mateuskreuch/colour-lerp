extends CanvasLayer

const COLOR_EMPTY = Color(0, 0, 0, 0)
const WHEEL_CENTER = Vector2(703.5, 223.5)
const WHEEL_RADIUS = 188
const WHEEL_THICKNESS = 16

onready var SquarePicker		= $SquarePicker
onready var ChosenColor			= $ChosenColor
onready var SV_Gradient			= $SVGradient
onready var SV_Rect				= Rect2(SV_Gradient.rect_position, SV_Gradient.rect_size)
onready var V_PickerHandle		= $SVGradient/V_PickerHandle
onready var H_PickerHandle		= $SVGradient/H_PickerHandle
onready var Handler				= $Handler
onready var PrimaryHandler		= $Handler/PrimaryHandler
onready var SecondaryHandler	= $Handler/SecondaryHandler
onready var New					= $New
onready var Save				= $Save
onready var Load				= $Load
onready var Undo				= $Undo
onready var Redo				= $Redo
onready var Hex_Input			= $Hex/HexInput
onready var H_Input				= $Hue/HueInput
onready var S_Input				= $Saturation/SaturationInput
onready var V_Input				= $Value/ValueInput
onready var A_Input				= $Alpha/AlphaInput
onready var SpaceInput			= $SpaceInput
onready var Canvas				= $Canvas
onready var FileExplorer		= $FileExplorer

enum UI {CANVAS, PICKER, WHEEL}
var selected

var ucolor = Spaces.UColor.new()

func set_ucolor_hue(value):
	value = clamp(value, 0, 1)
	
	H_Input.text = str(round(value * 360))
	ucolor.hsv_h = value
	
	var color = Spaces.hsv2color(ucolor.hsv_h, 1, 1)

	Handler.rotation_degrees = ucolor.hsv_h * 360.0
	
	V_PickerHandle	.self_modulate = color.inverted()
	H_PickerHandle	.self_modulate = color.inverted()
	
	PrimaryHandler	.self_modulate = color.inverted()
	SecondaryHandler.self_modulate = color
	
	SquarePicker	.self_modulate = color
	
	var new_color = ucolor.to_color()
	
	ChosenColor.self_modulate = new_color
	Hex_Input.text = new_color.to_html()
	
func set_ucolor_saturation(value):
	value = clamp(value, 0, 1)
	
	S_Input.text = str(round(value * 100))
	ucolor.hsv_s = value
	
	V_PickerHandle.rect_position.x = clamp(ucolor.hsv_s * SV_Rect.size.x, 0, SV_Rect.size.x - 1)

	var new_color = ucolor.to_color()
	
	ChosenColor.self_modulate = new_color
	Hex_Input.text = new_color.to_html()
	
func set_ucolor_value(value):
	value = clamp(value, 0, 1)
	
	V_Input.text = str(round(value * 100))
	ucolor.hsv_v = value
	
	H_PickerHandle.rect_position.y = clamp((1 - ucolor.hsv_v) * SV_Rect.size.y, 0, SV_Rect.size.y - 1)
	
	var new_color = ucolor.to_color()
	
	ChosenColor.self_modulate = new_color
	Hex_Input.text = new_color.to_html()
	
func set_ucolor_alpha(value):
	value = clamp(value, 0, 1)
	
	A_Input.text = str(round(value * 100))
	ucolor.alpha = value
	
	var new_color = ucolor.to_color()
	
	ChosenColor.self_modulate = new_color
	Hex_Input.text = new_color.to_html()
	
func _ready():
	New			.connect("pressed", Canvas, "clear_canvas")
	Save		.connect("pressed", self, "save_file")
	Load		.connect("pressed", self, "load_file")
	Undo		.connect("pressed", Canvas, "undo")
	Redo		.connect("pressed", Canvas, "redo")
	Hex_Input	.connect("text_entered", self, "hex_input")
	H_Input		.connect("text_entered", self, "h_input")
	S_Input		.connect("text_entered", self, "s_input")
	V_Input		.connect("text_entered", self, "v_input")
	A_Input		.connect("text_entered", self, "a_input")
	SpaceInput	.connect("item_selected", self, "change_color_space")
	
	SpaceInput.add_item("HSV", 0)
	SpaceInput.add_item("L*a*b", 1)
	SpaceInput.add_item("HSP", 2)
	
	FileExplorer.connect("file_selected", self, "file_selected")
	
	FileExplorer.current_dir = OS.get_executable_path().get_base_dir()
	
	ucolor.set_rgb(1, 0, 0)
	
func change_color_space(value):
	Math.color_space = value
		
func hex_input(value):
	if not value.is_valid_html_color():
		return

	color2ucolor(Color(value))
	
func h_input(value):
	set_ucolor_hue(Math.degclamp(int(value)) / 360.0)
	
func s_input(value):
	set_ucolor_saturation(int(value) / 100.0)
	
func v_input(value):
	set_ucolor_value(int(value) / 100.0)
	
func a_input(value):
	set_ucolor_alpha(int(value) / 100.0)
	
enum In {JUST_PRESSED, PRESSED, JUST_RELEASED, RELEASED}
	
var right_mouse = In.RELEASED
var left_mouse = In.RELEASED

func check_input_state(button_index, state):
	if Input.is_mouse_button_pressed(button_index):
		if (state == In.RELEASED or state == In.JUST_RELEASED):
			return In.JUST_PRESSED
			
		else:
			return In.PRESSED
			
	else:
		if (state == In.PRESSED or state == In.JUST_PRESSED):
			return In.JUST_RELEASED
			
		else:
			return In.RELEASED
	
func _input(ev):
	if FileExplorer.visible:
		return
	
	left_mouse = check_input_state(BUTTON_LEFT, left_mouse)
	right_mouse = check_input_state(BUTTON_RIGHT, right_mouse)

	match(left_mouse):
		In.JUST_PRESSED:
			check_selected()
		
			if selected == UI.CANVAS:	
				var pencil_pos = Canvas.get_pencil_position()
				
				Canvas.set_pixel(pencil_pos.x, pencil_pos.y, ucolor.to_color())
				Canvas.interpolate_pixel(pencil_pos.x, pencil_pos.y)
				Canvas.add_to_undo_history()
				Canvas.clear_redo_history()
			else:
				continue
				
		In.PRESSED, In.JUST_PRESSED:
			match(selected):
				UI.PICKER:
					var pos = SV_Gradient.get_local_mouse_position()
	
					set_ucolor_saturation(clamp(pos.x / SV_Rect.size.x, 0, 1))
					set_ucolor_value(1.0 - clamp(pos.y / SV_Rect.size.y, 0, 1))
					
					ChosenColor.self_modulate = ucolor.to_color()
					
				UI.WHEEL:
					var rot = Math.degclamp(
						rad2deg(
							ev.position.angle_to_point(WHEEL_CENTER)
						) - 90
					)
								
					set_ucolor_hue(rot / 360.0)
					
	var pencil_pos = Canvas.get_pencil_position()
	
	if pencil_pos:			
		match(right_mouse):
			In.PRESSED, In.JUST_PRESSED:
				Canvas.set_pixel(pencil_pos.x, pencil_pos.y, COLOR_EMPTY)
		
			In.JUST_RELEASED:
				Canvas.add_to_undo_history()
				Canvas.clear_redo_history()

		if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			color2ucolor(Canvas.get_pixel(pencil_pos.x, pencil_pos.y))
						
func check_selected():
	if Canvas.get_pencil_position():
		selected = UI.CANVAS
		return
		
	var mpos = Canvas.get_global_mouse_position()
	
	if Math.is_vector_in_rect(mpos, SV_Rect):
		selected = UI.PICKER
		return
		
	var distance = mpos.distance_to(WHEEL_CENTER)
	
	if distance > (WHEEL_RADIUS - WHEEL_THICKNESS) and distance < WHEEL_RADIUS:
		selected = UI.WHEEL
		return
		
	selected = null
			
func color2ucolor(color):
	set_ucolor_hue(color.h)
	set_ucolor_saturation(color.s)
	set_ucolor_value(color.v)
	set_ucolor_alpha(color.a)
	
func load_file():
	FileExplorer.mode = FileDialog.MODE_OPEN_FILE
	FileExplorer.popup()
	
func save_file():
	FileExplorer.mode = FileDialog.MODE_SAVE_FILE
	FileExplorer.popup()
	
func file_selected(dir):
	if FileExplorer.mode == FileDialog.MODE_SAVE_FILE:
		Canvas.save_canvas(dir)
	else:
		Canvas.open_canvas(dir)