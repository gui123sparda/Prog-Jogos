extends Camera2D
@onready var damage_overlay = $DamageOverlay

func _ready():
	if damage_overlay:
		damage_overlay.color = Color(1, 0, 0, 0)  # Vermelho transparente

func flash_damage():
	if not damage_overlay:
		return
	
	var tween = create_tween()
	
	# Aparece rápido
	tween.tween_property(damage_overlay, "color", 
		Color(1, 0, 0, 0.3), 0.08)  # Vermelho 30% opaco
	
	# Some devagar
	tween.tween_property(damage_overlay, "color", 
		Color(1, 0, 0, 0), 0.4)
