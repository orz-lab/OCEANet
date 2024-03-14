extends Node

const Packet = preload("res://WebSockets/packet.gd")

signal connected
signal data
signal disconnected
signal error

var is_connected = false
var _client = WebSocketPeer.new()

func _ready():
	#_client.verify_ssl = false
	return

func _process(delta):
	_client.poll()
	var state = _client.get_ready_state()
	
	if state == WebSocketPeer.STATE_OPEN:
		if not is_connected:
			connected.emit()
			is_connected = true
		while _client.get_available_packet_count():
			_on_data()
	elif state == WebSocketPeer.STATE_CLOSING:
		_closed()
	elif state == WebSocketPeer.STATE_CLOSED:
		_closed()
		
		

func connect_to_server(hostname: String, port: int) -> void:
	var websocket_url = "wss://%s:%d" % [hostname, port]
	var err = _client.connect_to_url(websocket_url, TLSOptions.client_unsafe())
	#print(websocket_url, " Error ", err)
	if err:
		print("Unable to connect")
		set_process(false)
		emit_signal("error")


func send_packet(packet: Packet):
	_send_string(packet.tostring())

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)
	emit_signal("disconnected", was_clean)


func _connected(proto = ""):
	print("Connected with protocol: ", proto)
	

func _on_data():
	var data: String = _client.get_packet().get_string_from_utf8()
	#print("Got data from server: ", data)
	emit_signal("data", data)

func _send_string(str: String):
	_client.put_packet(str.to_utf8_buffer())
