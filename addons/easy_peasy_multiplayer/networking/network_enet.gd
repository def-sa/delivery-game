class_name NetworkEnet
extends Node

## The port number to use for Enet servers
const PORT = 7000

## The [MultiplayerPeer] for the Enet server. We can define this on initialization because this script should only run if we are going to be networking using ENet
var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

#region Network-Specific Functions
## Creates a game server as the host. See [Network.become_host] for more information
func become_host(_lobby_type):
	var error = peer.create_server(PORT, Network.room_size)
	if error:
		return error
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.multiplayer_peer = peer

	Network.connected_players[1] = Network.player_info
	Network.server_started.emit()
	Network.player_connected.emit(1, Network.player_info)
	if Network._is_verbose:
		print("ENet Server hosted on port " + str(PORT))

## Joins a game using an id in [Network]. See [Network.join_as_client] for more information
func join_as_client():
	var error = peer.create_client(Network.ip_address, PORT)
	if error:
		return error
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.multiplayer_peer = peer

## This does nothing as Enet does not have a lobby implementation. It is only here to prevent errors.
func list_lobbies():
	pass
#endregion
