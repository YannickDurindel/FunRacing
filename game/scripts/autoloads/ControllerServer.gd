extends Node

const PORT: int = 8080
const CERT_PATH: String = "res://web_controller/cert.pem"
const KEY_PATH: String = "res://web_controller/key.pem"

var _peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var _connected_clients: Array[int] = []

# Normalised controller state (-1..1)
var steering: float = 0.0    # from gyro gamma
var throttle: float = 0.0    # 0..1
var brake: float = 0.0       # 0..1
var drs_pressed: bool = false
var ers_pressed: bool = false

signal controller_connected()
signal controller_disconnected()
signal input_received(data: Dictionary)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_start_server()


func _start_server() -> void:
	var err: Error = _peer.create_server(PORT)
	if err != OK:
		push_error("ControllerServer: failed to create server on port %d: %s" % [PORT, error_string(err)])
		return
	multiplayer.multiplayer_peer = _peer
	multiplayer.peer_connected.connect(_on_client_connected)
	multiplayer.peer_disconnected.connect(_on_client_disconnected)
	print("ControllerServer: listening on ws://0.0.0.0:%d" % PORT)


func _process(_delta: float) -> void:
	if _peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_peer.poll()
	# Read incoming packets
	while _peer.get_available_packet_count() > 0:
		var packet: PackedByteArray = _peer.get_packet()
		var sender_id: int = _peer.get_packet_peer()
		_parse_packet(packet, sender_id)


func _parse_packet(packet: PackedByteArray, _sender_id: int) -> void:
	var text: String = packet.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if data == null or not data is Dictionary:
		return
	# Expected: {"type": "input", "steering": float, "throttle": float, "brake": float, "drs": bool, "ers": bool}
	var t: String = data.get("type", "")
	if t == "input":
		# Steering: phone gamma (-90..90 deg), normalise to -1..1 then clamp to ±17° equivalent
		var raw_gamma: float = float(data.get("steering", 0.0))
		steering = clampf(raw_gamma / 30.0, -1.0, 1.0)  # 30° feels natural for F1
		throttle = clampf(float(data.get("throttle", 0.0)), 0.0, 1.0)
		brake = clampf(float(data.get("brake", 0.0)), 0.0, 1.0)
		drs_pressed = bool(data.get("drs", false))
		ers_pressed = bool(data.get("ers", false))
		input_received.emit(data)
	elif t == "ping":
		_send_pong(_sender_id)


func _send_pong(client_id: int) -> void:
	var pong: String = JSON.stringify({"type": "pong"})
	_peer.set_target_peer(client_id)
	_peer.put_packet(pong.to_utf8_buffer())


func _on_client_connected(id: int) -> void:
	_connected_clients.append(id)
	print("ControllerServer: client connected id=%d" % id)
	controller_connected.emit()


func _on_client_disconnected(id: int) -> void:
	_connected_clients.erase(id)
	steering = 0.0
	throttle = 0.0
	brake = 0.0
	drs_pressed = false
	ers_pressed = false
	print("ControllerServer: client disconnected id=%d" % id)
	controller_disconnected.emit()


func is_phone_connected() -> bool:
	return not _connected_clients.is_empty()


func get_local_ip() -> String:
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.168.") or addr.begins_with("10.") or addr.begins_with("172."):
			return addr
	return "127.0.0.1"


func broadcast(data: Dictionary) -> void:
	if _connected_clients.is_empty():
		return
	var text: String = JSON.stringify(data)
	for client_id in _connected_clients:
		_peer.set_target_peer(client_id)
		_peer.put_packet(text.to_utf8_buffer())
