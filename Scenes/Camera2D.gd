extends Camera2D

var orginal_viewport = Vector2(1152,648)

func _process(delta):
	var kx = get_viewport().size.x / orginal_viewport.x
	var ky = get_viewport().size.y / orginal_viewport.y
	var k = min(kx, ky)
	zoom.x = k
	zoom.y = k
	return
	
