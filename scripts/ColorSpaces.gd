extends Node

class UColor:
	var rgb_r = 0 setget set_rgb_r
	var rgb_g = 0 setget set_rgb_g
	var rgb_b = 0 setget set_rgb_b
	
	var hsv_h = 0 setget set_hsv_h
	var hsv_s = 0 setget set_hsv_s
	var hsv_v = 0 setget set_hsv_v
	
	var lab_l = 0 setget set_lab_l
	var lab_a = 0 setget set_lab_a
	var lab_b = 0 setget set_lab_b
	
	var hsp_h = 0 setget set_hsp_h
	var hsp_s = 0 setget set_hsp_s
	var hsp_p = 0 setget set_hsp_p
	
	var alpha = 1 setget set_alpha
	
	func set_color(color):
		rgb_r = color.r
		rgb_g = color.g
		rgb_b = color.b
		alpha = color.a
		
		rgb2others(rgb_r, rgb_g, rgb_b)
		
	func set_rgb(r, g, b):
		rgb_r = clamp(r, 0.0, 1.0)
		rgb_g = clamp(g, 0.0, 1.0)
		rgb_b = clamp(b, 0.0, 1.0)
		
		rgb2others(rgb_r, rgb_g, rgb_b)
		
	func set_hsv(h, s, v):
		hsv_h = clamp(h, 0.0, 1.0)
		hsv_s = clamp(s, 0.0, 1.0)
		hsv_v = clamp(v, 0.0, 1.0)
		
		hsv2others(hsv_h, hsv_s, hsv_v)
		
	func set_lab(l, a, b):
		lab_l = clamp(l, 0.0, 100.0)
		lab_a = clamp(a, -128.0, 128.0)
		lab_b = clamp(b, -128.0, 128.0)
		
		lab2others(lab_l, lab_a, lab_b)
		
	func set_hsp(h, s, p):
		hsp_h = clamp(h, 0.0, 1.0)
		hsp_s = clamp(s, 0.0, 1.0)
		hsp_p = clamp(p, 0.0, 1.0)
		
		hsp2others(hsp_h, hsp_s, hsp_p)
		
	func rgb2others(r, g, b):
		rgb2hsv(r, g, b)
		rgb2lab(r, g, b)
		rgb2hsp(r, g, b)
		
	func hsv2others(h, s, v):
		hsv2rgb(h, s, v)
		rgb2lab(rgb_r, rgb_g, rgb_b)
		rgb2hsp(rgb_r, rgb_g, rgb_b)
		
	func lab2others(l, a, b):
		lab2rgb(l, a, b)
		rgb2hsv(rgb_r, rgb_g, rgb_b)
		rgb2hsp(rgb_r, rgb_g, rgb_b)
		
	func hsp2others(h, s, p):
		hsp2rgb(h, s, p)
		rgb2hsv(rgb_r, rgb_g, rgb_b)
		rgb2lab(rgb_r, rgb_g, rgb_b)
		
	func rgb2hsv(r, g, b):
		var color = Color(r, g, b)
		
		hsv_h = color.h
		hsv_s = color.s
		hsv_v = color.v
		
	func rgb2lab(r, g, b):
		if r > 0.04045:
			r = pow((r + 0.055) / 1.055, 2.4)
		
		else:
			r /= 12.92
			
		if g > 0.04045:
			g = pow((g + 0.055) / 1.055, 2.4)
		
		else:
			g /= 12.92
			
		if b > 0.04045:
			b = pow((b + 0.055) / 1.055, 2.4)
		
		else:
			b /= 12.92
			
		var x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047
		var y = (r * 0.2126 + g * 0.7152 + b * 0.0722) / 1.00000
		var z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883
	
		if x > 0.008856:
			x = pow(x, 1.0 / 3.0)
		else:
			x = (7.787 * x) + 16.0 / 116.0
		
		if y > 0.008856:
			y = pow(y, 1.0 / 3.0)
		else:
			y = (7.787 * y) + 16.0 / 116.0
			
		if z > 0.008856:
			z = pow(z, 1.0 / 3.0)
		else:
			z = (7.787 * z) + 16.0 / 116.0
	
		lab_l = (116.0 * y) - 16.0
		lab_a = 500.0 * (x - y)
		lab_b = 200.0 * (y - z)
		
	func rgb2hsp(r, g, b):
		var color = Color(r, g, b)
		
		hsp_h = color.h
		hsp_s = color.s
		hsp_p = sqrt(r * r * 0.241 + g * g * 0.691 + b * b* 0.068)
	
	func hsv2rgb(h, s, v):
		var r = 0.0; var g = 0.0; var b = 0.0;
		
		var i = int(floor(h * 6.0))
		var f = h * 6.0 - i
		var p = v * (1.0 - s)
		var q = v * (1.0 - f * s)
		var t = v * (1.0 - (1.0 - f) * s)
		
		match(i % 6):
			0:
				r = v; g = t; b = p;
			1:
				r = q; g = v; b = p;
			2:
				r = p; g = v; b = t;
			3:
				r = p; g = q; b = v;
			4:
				r = t; g = p; b = v;
			5:
				r = v; g = p; b = q;
		
		rgb_r = r
		rgb_g = g
		rgb_b = b
		
	func lab2rgb(l, a, b1):
		var y = (l + 16.0) / 116.0
		var x = a / 500.0 + y
		var z = y - b1 / 200.0
	
		if (x * x * x) > 0.008856:
			x = 0.95047 * (x * x * x)
		
		else:
			x = 0.95047 * ((x - 16.0 / 116.0) / 7.787)
			
		if (y * y * y) > 0.008856:
			y = 1.00000 * (y * y * y)
		
		else:
			y = 1.00000 * ((y - 16.0 / 116.0) / 7.787)
			
		if (z * z * z) > 0.008856:
			z = 1.08883 * (z * z * z)
		
		else:
			z = 1.08883 * ((z - 16.0 / 116.0) / 7.787)
	
		var r	= x	* 3.2406	+ y * -1.5372	+ z * -0.4986
		var g	= x	* -0.9689	+ y * 1.8758	+ z *  0.0415
		var b2	= x	* 0.0557	+ y * -0.2040	+ z *  1.0570
	
		if r > 0.0031308:
			r = 1.055 * pow(r, 1.0 / 2.4) - 0.055
		else:
			r *= 12.92
			
		if g > 0.0031308:
			g = 1.055 * pow(g, 1.0 / 2.4) - 0.055
		else:
			g *= 12.92
			
		if b2 > 0.0031308:
			b2 = 1.055 * pow(b2, 1.0 / 2.4) - 0.055
		else:
			b2 *= 12.92
			
		rgb_r = r
		rgb_g = g
		rgb_b = b2
		
	func hsp2rgb(h, s, p):
		var r = 1; var g = 1; var b = 1;
	
		var part; var minOverMax = 1.0 - s
	
		if minOverMax > 0.0:
			if h < 1.0 / 6.0:	# r>g>b
				h = 6.0 * (h - 0.0 / 6.0)
				part = 1.0 + h * (1.0 / minOverMax - 1.0)
				b = p / sqrt(0.241 / minOverMax / minOverMax + 0.691 * part * part + 0.068)
				r = b / minOverMax
				g = b + h * (r-b)
				
			elif h < 2.0 / 6.0:	# g>r>b
				h = 6.0 * (-h + 2.0 / 6.0)
				part = 1.0 + h * (1.0 / minOverMax - 1.0)
				b = p / sqrt(0.691 / minOverMax / minOverMax + 0.241 * part * part + 0.068)
				g = b / minOverMax
				r = b + h * (g - b)
				
			elif h < 3.0 / 6.0:	# g>b>r
				h = 6.0 * (h - 2.0 / 6.0)
				part = 1.0 + h * (1.0 / minOverMax - 1.0)
				r = p / sqrt(0.691 / minOverMax / minOverMax + 0.068 * part * part + 0.241)
				g = r / minOverMax
				b = r + h * (g - r)
				
			elif h < 4.0 / 6.0:	# b>g>r
				h = 6.0 * (-h + 4.0 / 6.0)
				part = 1.0 + h * (1.0 / minOverMax - 1.0)
				r = p / sqrt(0.068 / minOverMax / minOverMax + 0.691 * part * part + 0.241)
				b = r / minOverMax 
				g = r + h * (b - r)
				
			elif h < 5.0 / 6.0:	# b>r>g
				h = 6.0 * (h - 4.0 / 6.0)
				part = 1.0 + h * (1.0 / minOverMax - 1.0)
				g = p / sqrt(0.068 / minOverMax / minOverMax + 0.241 * part * part + 0.691)
				b = g / minOverMax
				r = g + h * (b - g)
				
			else:	# r>b>g
				h = 6.0 * (-h + 6.0 / 6.0)
				part = 1.0 + h * (1.0 / minOverMax - 1.0)
				g = p / sqrt(0.241 / minOverMax / minOverMax + 0.068 * part * part + 0.691)
				r = g / minOverMax
				b = g + h * (r - g)
				
		else:
			if h < 1.0 / 6.0:	 # r>g>b
				h = 6.0 * (h - 0.0 / 6.0)
				r = sqrt(p * p / (0.241 + 0.691 * h * h))
				g = r * h
				b = 0.0
				
			elif h < 2.0 / 6.0:	# g>r>b
				h = 6.0 * (-h + 2.0 / 6.0)
				g = sqrt(p * p / (0.691 + 0.241 * h * h))
				r = g * h
				b = 0.0
				
			elif h < 3.0 / 6.0:	# g>b>r
				h = 6.0 * (h - 2.0 / 6.0) 
				g = sqrt(p * p / (0.691 + 0.068 * h * h))
				b = g * h
				r = 0.0
				
			elif h < 4.0 / 6.0:	# b>g>r
				h = 6.0 * (-h + 4.0 / 6.0)
				b = sqrt(p * p / (0.068 + 0.691 * h * h))
				g = b * h
				r = 0.0
				
			elif h < 5.0 / 6.0:	# b>r>g
				h = 6.0 * (h - 4.0 / 6.0)
				b = sqrt(p * p / (0.068 + 0.241 * h * h))
				r = b * h
				g = 0.0
				
			else:	# r>b>g
				h = 6.0 * (-h + 6.0 / 6.0) 
				r = sqrt(p * p / (0.241 + 0.068 * h * h)) 
				b = r * h
				g = 0.0
		
		var cr = r
		var cg = g
		var cb = b
		
		if r > 1.0:
			cg += (r - 1.0) * 0.6
			cb += (r - 1.0) * 0.6
			
		if g > 1.0:
			cr += (g - 1.0)
			cb += (g - 1.0)
			
		if b > 1.0:
			cr += (b - 1.0) * 0.25
			cg += (b - 1.0) * 0.25
		
		rgb_r = clamp(cr, 0.0, 1.0)
		rgb_g = clamp(cg, 0.0, 1.0)
		rgb_b = clamp(cb, 0.0, 1.0)
	
	func set_rgb_r(r):
		rgb_r = clamp(r, 0.0, 1.0)
		
		rgb2others(rgb_r, rgb_g, rgb_b)
		
	func set_rgb_g(g):
		rgb_g = clamp(g, 0.0, 1.0)
		
		rgb2others(rgb_r, rgb_g, rgb_b)
		
	func set_rgb_b(b):
		rgb_b = clamp(b, 0.0, 1.0)
		
		rgb2others(rgb_r, rgb_g, rgb_b)
		
	func set_hsv_h(h):
		hsv_h = clamp(h, 0.0, 1.0)
		
		hsv2others(hsv_h, hsv_s, hsv_v)
		
	func set_hsv_s(s):
		hsv_s = clamp(s, 0.0, 1.0)
		
		hsv2others(hsv_h, hsv_s, hsv_v)
		
	func set_hsv_v(v):
		hsv_v = clamp(v, 0.0, 1.0)
		
		hsv2others(hsv_h, hsv_s, hsv_v)
		
	func set_lab_l(l):
		lab_l = clamp(l, 0.0, 128.0)
		
		lab2others(lab_l, lab_a, lab_b)
		
	func set_lab_a(a):
		lab_a = clamp(a, -128.0, 128)
		
		lab2others(lab_l, lab_a, lab_b)
		
	func set_lab_b(b):
		lab_b = clamp(b, -128.0, 128)
		
		lab2others(lab_l, lab_a, lab_b)
		
	func set_hsp_h(h):
		hsp_h = clamp(h, 0.0, 1.0)
		
		hsp2others(hsp_h, hsp_s, hsp_p)

	func set_hsp_s(s):
		hsp_s = clamp(s, 0.0, 1.0)
		
		hsp2others(hsp_h, hsp_s, hsp_p)
		
	func set_hsp_p(p):
		hsp_p = clamp(p, 0.0, 1.0)
		
		hsp2others(hsp_h, hsp_s, hsp_p)
		
	func set_alpha(a):
		alpha = clamp(a, 0.0, 1.0)
		
	func to_color():
		return Color(rgb_r, rgb_g, rgb_b, alpha)
		
func lab2color(l, a, b1, alpha = 1):
	var y = (l + 16.0) / 116.0
	var x = a / 500.0 + y
	var z = y - b1 / 200.0

	if (x * x * x) > 0.008856:
		x = 0.95047 * (x * x * x)
	
	else:
		x = 0.95047 * ((x - 16.0 / 116.0) / 7.787)
		
	if (y * y * y) > 0.008856:
		y = 1.00000 * (y * y * y)
	
	else:
		y = 1.00000 * ((y - 16.0 / 116.0) / 7.787)
		
	if (z * z * z) > 0.008856:
		z = 1.08883 * (z * z * z)
	
	else:
		z = 1.08883 * ((z - 16.0 / 116.0) / 7.787)

	var r	= x	* 3.2406	+ y * -1.5372	+ z * -0.4986
	var g	= x	* -0.9689	+ y * 1.8758	+ z *  0.0415
	var b2	= x	* 0.0557	+ y * -0.2040	+ z *  1.0570

	if r > 0.0031308:
		r = 1.055 * pow(r, 1.0 / 2.4) - 0.055
	else:
		r *= 12.92
		
	if g > 0.0031308:
		g = 1.055 * pow(g, 1.0 / 2.4) - 0.055
	else:
		g *= 12.92
		
	if b2 > 0.0031308:
		b2 = 1.055 * pow(b2, 1.0 / 2.4) - 0.055
	else:
		b2 *= 12.92
		
	return Color(r, g, b2, alpha)
	
func hsv2color(h, s, v, alpha = 1):
	var r = 0.0; var g = 0.0; var b = 0.0;
		
	var i = int(floor(h * 6.0))
	var f = h * 6.0 - i
	var p = v * (1.0 - s)
	var q = v * (1.0 - f * s)
	var t = v * (1.0 - (1.0 - f) * s)
	
	match(i % 6):
		0:
			r = v; g = t; b = p;
		1:
			r = q; g = v; b = p;
		2:
			r = p; g = v; b = t;
		3:
			r = p; g = q; b = v;
		4:
			r = t; g = p; b = v;
		5:
			r = v; g = p; b = q;
	
	return Color(r, g, b, alpha)