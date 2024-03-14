extends Control

@onready var _chart: Chart = $VBoxContainer/Chart

# This Chart will plot 3 different functions
var graph: Function
var MAX_TIME = 50
var cp: ChartProperties = ChartProperties.new()
var current_price: float = 50
var fish_id = null

var rng = RandomNumberGenerator.new()

signal change_price(price)

func _ready():
	randomize()
	rng.randomize()
	
	# Let's create our @x values
	var x: PackedFloat32Array = [0, 0]
	
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
	var y: Array = [0, 0]
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	cp.colors.frame = Color("#161a1d")
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color("#283442")
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.draw_bounding_box = false
	cp.title = "Giá của loài cá " + PlayerStats.fish_inventory[fish_id]["name"] 
	cp.x_label = "Time"
	cp.y_label = "Price"
	cp.x_scale = 5
	cp.y_scale = 10
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
	# and interecept clicks on the plot
	
	# Let's add values to our functions
	graph = Function.new(
		x, y, "Price", # This will create a function with x and y values taken by the Arrays 
						# we have created previously. This function will also be named "Pressure"
						# as it contains 'pressure' values.
						# If set, the name of a function will be used both in the Legend
						# (if enabled thourgh ChartProperties) and on the Tooltip (if enabled).
		# Let's also provide a dictionary of configuration parameters for this specific function.
		{ 
			color = Color("#36a2eb"), 		# The color associated to this function
			marker = Function.Marker.CIRCLE, 	# The marker that will be displayed for each drawn point (x,y)
											# since it is `NONE`, no marker will be shown.
			type = Function.Type.LINE, 		# This defines what kind of plotting will be used, 
											# in this case it will be a Linear Chart.
			interpolation = Function.Interpolation.LINEAR	# Interpolation mode, only used for 
															# Line Charts and Area Charts.
		}
	)
	
	# Now let's plot our data
	_chart.plot([graph], cp)


func add_point(value):
	current_price = value
	#print(value)
	#set_graph()

	if graph.__x.size():
		if graph.__x.back() == 0:
			graph.pop_back_point()
	graph.add_point(0, value)
	if graph.__x.size():
		if graph.__x.back() - graph.__x.front() > MAX_TIME:
			graph.remove_point(0)
			
	_chart.queue_redraw()
	
	if visible == true:
		change_price.emit(current_price)
	

func _on_timer_timeout():
	for id in range(graph.__x.size()):
		graph.__x[id] -= 1
	
	if Network.is_connected == false:
		make_new_price()
	_chart.queue_redraw()


func make_new_price():
	var delta_price = rng.randf_range(0,1)
	if rng.randi_range(0,50) == 0:
		delta_price = rng.randf_range(0,25)
	
	if rng.randf_range(-100, 100) < 0:
		delta_price *= -1
	
	var current_price = current_price
	current_price = max(0, current_price + delta_price)
	add_point(current_price)

func _on_update_price(price):
	add_point(price)
