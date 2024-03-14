extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/password/LineEdit.secret = true
	Network._on_connected.connect(_on_connected)
	
	Network._on_login_accepted.connect(_on_login_accepted)
	Network._on_login_denied.connect(_on_login_denied)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$VBoxContainer.position = get_viewport_rect().size / 2 - $VBoxContainer.size / 2

func _on_connect_pressed():
	Network.connect_server($VBoxContainer/ip/LineEdit.text)
	#Network.connect_server()
	$VBoxContainer/ip/Connect.disabled = true

func _on_offline_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
func _on_connected():
	$VBoxContainer/Buttons/Login.disabled = false
	$VBoxContainer/ip/Connect.text = "Connected"

func _on_login_pressed():
	Network.login_server($VBoxContainer/username/LineEdit.text, $VBoxContainer/password/LineEdit.text)

func _on_login_accepted():
	PlayerStats.username = $VBoxContainer/username/LineEdit.text
	PlayerStats.password =  $VBoxContainer/password/LineEdit.text
	Network.get_inventory()
	
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
func _on_login_denied(log):
	OS.alert(log)
