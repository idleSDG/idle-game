class_name EquipmentItem extends Resource

enum Slot { WEAPON, ROBE, HAT }

@export var item_name: String = "Unnamed Item"
@export var slot: Slot = Slot.WEAPON

@export var health_bonus_pct: float = 0.0
@export var attack_bonus_pct: float = 0.0
@export var defense_bonus_pct: float = 0.0
@export var crit_rate_bonus_pct: float = 0.0
@export var crit_dmg_bonus_pct: float = 0.0
@export var ingredient_gain_bonus_pct: float = 0.0

@export var cost: int = 0

func _init(name, nSlot: Slot, p_health: float = 0.0, p_attack: float = 0.0, 
	p_defense: float = 0.0, p_crit_r: float = 0.0, p_crit_dmg: float = 0.0, 
	p_ing: float = 0.0):
	item_name = name
	slot = nSlot
	health_bonus_pct = p_health
	attack_bonus_pct = p_attack
	defense_bonus_pct = p_defense
	crit_rate_bonus_pct = p_crit_r
	crit_dmg_bonus_pct = p_crit_dmg
	ingredient_gain_bonus_pct = p_ing

# Call this after setting all bonus values to auto-calculate cost
func calculate_cost() -> void:
	var total_bonus = health_bonus_pct + attack_bonus_pct + defense_bonus_pct \
		+ crit_rate_bonus_pct + crit_dmg_bonus_pct + ingredient_gain_bonus_pct
	cost = int(total_bonus * 10)
