class_name HexGrid
extends Node

var hexes = {} # dict hexpos (r,q) vec2 -> array
const hex_height = 64

func place_hexes():
	for coord in hexes.keys():
		place_hex(hexes.coord)

func place_hex(hex):
	
	hex.position = get_hex_pos(hex.coord)
	
#	print("hex placed: ", hex.position)

# HEX HELPERS

# convert between cube and axial coordinates
func cube_to_axial(cube : Vector3):
	
	var q = cube.x
	var r = cube.z
	return Vector2(q,r)

func axial_to_cube(coord : Vector2):
	
	var x = coord.x
	var z = coord.y
	var y = -x-z
	return Vector3(x, y, z)

# in cube coordinates, round partial coordiantes to nearest
# I don't know how this code works 
func cube_round(cube : Vector3):
	
	var rx = round(cube.x)
	var ry = round(cube.y)
	var rz = round(cube.z)
	
	var x_diff = abs(rx - cube.x)
	var y_diff = abs(ry - cube.y)
	var z_diff = abs(rz - cube.z)
	
	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry-rz
	elif y_diff > z_diff:
		ry = -rx-rz
	else:
		rz = -rx-ry
	
	return Vector3(rx, ry, rz)

# qr hex coordinate to x
func get_hex_pos(coord : Vector2) -> Vector2:
	
	var q = coord.x
	var r = coord.y
	
	var x = 0
	var y = 0
	
	# over one hex per q
	x = q * hex_height * sqrt(3) 
	# over one half, down 3/4 per r
	x += r * (hex_height / 2) * sqrt(3) # over  
	y = r * 3 * hex_height * 2 / 4 # down
	
	return Vector2(x,y)

# get qr hex coordinate from xy
func get_hex_from_pos(pos : Vector2) -> Vector2:
	
	# matrix conversion to qr coordinates
	var q = sqrt(3)/3 * pos.x  - pos.y * 1/3
	var r = pos.y * 2/3
	
	var coord = Vector2(q,r) / 64 # scale to height
	
	# convert to cube, round, convert back
	return cube_to_axial(cube_round(axial_to_cube(coord)))
