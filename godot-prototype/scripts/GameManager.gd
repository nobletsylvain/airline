extends Node
class_name GameManager

## Game Manager - Handles scene transitions and game state
## Entry point for the game

const MAIN_MENU_SCENE = "res://scenes/MainMenu.tscn"
const GAME_SCENE = "res://scenes/Main.tscn"

var current_scene: Node = null
var main_menu: MainMenu = null
var game_settings: Dictionary = {}

func _ready() -> void:
	# Start with main menu
	call_deferred("show_main_menu")

func show_main_menu() -> void:
	"""Show the main menu"""
	# Remove current scene if any
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	# Create main menu
	main_menu = MainMenu.new()
	main_menu.name = "MainMenu"
	add_child(main_menu)
	current_scene = main_menu

	# Connect signals
	main_menu.new_game_requested.connect(_on_new_game_requested)
	main_menu.load_game_requested.connect(_on_load_game_requested)
	main_menu.quit_requested.connect(_on_quit_requested)

	print("Main menu loaded")

func _on_new_game_requested(settings: Dictionary) -> void:
	"""Start a new game with given settings"""
	game_settings = settings
	print("Starting new game: ", settings)

	# Store settings in GameData for initialization
	if GameData:
		GameData.new_game_settings = settings

	# Transition to game scene
	start_game()

func _on_load_game_requested(save_id: String) -> void:
	"""Load a saved game"""
	# TODO: Implement save/load system
	print("Load game requested: ", save_id)
	# For now, just start a new game
	start_game()

func _on_quit_requested() -> void:
	"""Quit the game"""
	get_tree().quit()

func start_game() -> void:
	"""Transition to the game scene"""
	# Fade out menu
	if main_menu:
		var tween = create_tween()
		tween.tween_property(main_menu, "modulate:a", 0.0, 0.3)
		await tween.finished

	# Remove menu
	if main_menu:
		main_menu.queue_free()
		main_menu = null
		current_scene = null

	# Load game scene
	var game_scene = load(GAME_SCENE)
	if game_scene:
		var game_instance = game_scene.instantiate()
		add_child(game_instance)
		current_scene = game_instance

		# Fade in
		game_instance.modulate.a = 0
		var fade_in = create_tween()
		fade_in.tween_property(game_instance, "modulate:a", 1.0, 0.3)

		print("Game scene loaded")
	else:
		push_error("Failed to load game scene: " + GAME_SCENE)

func return_to_menu() -> void:
	"""Return to main menu from game"""
	if current_scene:
		var tween = create_tween()
		tween.tween_property(current_scene, "modulate:a", 0.0, 0.3)
		await tween.finished

		current_scene.queue_free()
		current_scene = null

	show_main_menu()
