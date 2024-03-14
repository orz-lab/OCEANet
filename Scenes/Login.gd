extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	Network._on_connected.connect(_on_connected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$VBoxContainer.position = get_viewport_rect().size / 2 - $VBoxContainer.size / 2

func _on_connect_pressed():
	Network.connect_server($VBoxContainer/ip/LineEdit.text)
	#Network.connect_server()
	$VBoxContainer/Buttons/Connect.disabled = true

func _on_offline_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
func _on_connected():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	$VBoxContainer/Buttons/Connect.disabled = false
	

