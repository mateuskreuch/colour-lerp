extends Node

enum ColorSpaces {HSV = 0, LAB = 1, HSP = 2}

var color_space = ColorSpaces.HSV
	
func lerp_color(c1, c2, t):
	var c3 = Spaces.UColor.new()
	
	match color_space:
		ColorSpaces.HSV:
			var h; var s; var v;
			
			if abs(c2.hsv_h - c1.hsv_h) > (1.0 - abs(c2.hsv_h - c1.hsv_h)):
				if c1.hsv_h < c2.hsv_h:
					h = hue_clamp(lerp(1.0 + c1.hsv_h, c2.hsv_h, t))
					
				else:
					h = hue_clamp(lerp(c1.hsv_h, 1.0 + c2.hsv_h, t))
					
			else:
				h = hue_clamp(lerp(c1.hsv_h, c2.hsv_h, t))
			
			s = lerp(c1.hsv_s, c2.hsv_s, t)
			v = lerp(c1.hsv_v, c2.hsv_v, t)
			
			c3.set_hsv(h, s, v)
			
		ColorSpaces.LAB:
			var l; var a; var b;
			
			l = lerp(c1.lab_l, c2.lab_l, t)
			a = lerp(c1.lab_a, c2.lab_a, t)
			b = lerp(c1.lab_b, c2.lab_b, t)
			
			c3.set_lab(l, a, b)
		
		ColorSpaces.HSP:
			var h; var s; var p;
			
			if abs(c2.hsv_h - c1.hsv_h) > (1.0 - abs(c2.hsv_h - c1.hsv_h)):
				if c1.hsv_h < c2.hsv_h:
					h = hue_clamp(lerp(1.0 + c1.hsv_h, c2.hsv_h, t))
					
				else:
					h = hue_clamp(lerp(c1.hsv_h, 1.0 + c2.hsv_h, t))
					
			else:
				h = hue_clamp(lerp(c1.hsv_h, c2.hsv_h, t))
				
			s = lerp(c1.hsp_s, c2.hsp_s, t)
			p = lerp(c1.hsp_p, c2.hsp_p, t)
			
			c3.set_hsp(h, s, p)
			
	c3.alpha = lerp(c1.alpha, c2.alpha, t)
	
	return c3.to_color()
	
func is_vector_in_rect(vector, rect):
	if vector.x > rect.position.x and vector.y > rect.position.y and vector.x < (rect.position.x + rect.size.x) and vector.y < (rect.position.y + rect.size.y):
		return true
	
	return false
	
func hue_clamp(value):
	if value < 0.0:
		return 1.0 - abs(fmod(value, 1.0))
	elif value > 1.0:
		return abs(fmod(value, 1.0))
	
	return value
	
func degclamp(degrees):	
	if (degrees > 0):		
		degrees -= (floor((degrees / 360.0)) * 360.0)		
	else:		
		degrees += (ceil((degrees / -360.0)) * 360.0)

	return degrees