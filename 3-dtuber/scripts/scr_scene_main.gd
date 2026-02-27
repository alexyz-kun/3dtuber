class_name SceneMain
extends Node

const CURSOR_Z_DISTANCE: float = 1

static var main_viewport: Viewport
static var avatar_subviewport: SubViewport
static var camera: Camera3D

var avatar: Avatar
var avatar_frame: TextureRect

# Base methods

func _ready() -> void:
	main_viewport = get_viewport()
	avatar_subviewport = $Node3D/AvatarSubViewport
	camera = $Node3D/AvatarSubViewport/Camera3D
	avatar = $Node3D/AvatarSubViewport/Avatar
	avatar_frame = $Control/AvatarImage
	
	avatar.set_up()


func _process(delta: float) -> void:
	var avatar_texture: ViewportTexture = avatar_subviewport.get_texture()
	avatar_frame.texture = avatar_texture
