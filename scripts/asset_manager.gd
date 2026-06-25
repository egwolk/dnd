extends Node

var using_private_assets := false

const PRIVATE_ROOT := "res://assets/private/"
const PUBLIC_ROOT  := "res://assets/public/"

func _ready():
    if FileAccess.file_exists(PRIVATE_ROOT + "marker.txt"):
        using_private_assets = true
        print("Using private assets")
    else:
        using_private_assets = false
        print("Using public assets")

func get_asset(path: String):
    var private_path = PRIVATE_ROOT + path
    
    if using_private_assets and FileAccess.file_exists(private_path):
        return load(private_path)
    
    return load(PUBLIC_ROOT + path)