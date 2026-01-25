extends Resource
class_name Country

## Represents a country and its relationship with airlines

@export var code: String = ""  # ISO country code (e.g., "US", "GB")
@export var name: String = ""
@export var region: String = ""  # "North America", "Europe", etc.

# Relationship tracking (per airline)
# Stored as Dictionary in GameData: {airline_id: relationship_score}
# Relationship score: -100 (hostile) to +100 (allied)

# Market data
@export var gdp_per_capita: float = 0.0
@export var population: int = 0

func _init(p_code: String = "", p_name: String = "", p_region: String = "") -> void:
	code = p_code
	name = p_name
	region = p_region

func get_relationship_level(relationship_score: float) -> String:
	"""Get relationship level as string"""
	if relationship_score >= 50:
		return "Allied"
	elif relationship_score >= 20:
		return "Friendly"
	elif relationship_score >= 5:
		return "Warm"
	elif relationship_score >= -5:
		return "Neutral"
	elif relationship_score >= -20:
		return "Cold"
	elif relationship_score >= -50:
		return "Hostile"
	else:
		return "War"

func get_relationship_color(relationship_score: float) -> Color:
	"""Get color for relationship score"""
	if relationship_score > 20:
		return Color(0.2, 0.8, 0.2)  # Green
	elif relationship_score > -20:
		return Color(0.8, 0.8, 0.2)  # Yellow
	else:
		return Color(0.8, 0.2, 0.2)  # Red
