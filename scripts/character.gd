class_name Character extends Node

var damagePopup = load("res://scenes/damagePopup.tscn")
var skillUiScene = load("res://scenes/skillUI.tscn")
var effectScene = load("res://assets/effects/A_EffectScene.tscn")
var charName = "Character"
var level : int = 1
var index : int = -1

@onready var hitbox = $HitBox
@onready var character = $"."
@onready var particles = $GPUParticles2D
@onready var healthBar = $"VBoxContainer/Container--Sprite2D/ProgressBar"
@onready var skillBars = $"VBoxContainer/Container--Sprite2D/HBox_Skills"
@onready var levelLabel = $"VBoxContainer/Container--Sprite2D/Level"

@onready var sfx_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

enum SFX_TYPE { MELEE_HIT, BURN, STRENGTH, HEAL, FREEZE, PARALYZE, HASTE, EXPLOSION, DEATH }
var attack_sfx = {
	SFX_TYPE.MELEE_HIT: [
		preload("res://assets/sfx/battle/hit/FGHTImpt_HIT-Smack_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/hit/FGHTImpt_HIT-Smack_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/hit/FGHTImpt_HIT-Smack_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/hit/FGHTImpt_HIT-Smack_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/hit/FGHTImpt_HIT-Smack_HY_PC-005.wav"),
		],
	SFX_TYPE.BURN: [
		preload("res://assets/sfx/battle/fire/DSGNImpt_EXPLOSION-Fire Hit_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/fire/DSGNImpt_EXPLOSION-Fire Hit_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/fire/DSGNImpt_EXPLOSION-Fire Hit_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/fire/DSGNImpt_EXPLOSION-Fire Hit_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/fire/DSGNImpt_EXPLOSION-Fire Hit_HY_PC-005.wav"),
		preload("res://assets/sfx/battle/fire/DSGNImpt_EXPLOSION-Fire Hit_HY_PC-006.wav"),
	],
	SFX_TYPE.STRENGTH: [
		preload("res://assets/sfx/battle/strength/DSGNSynth_BUFF-Plus Damage_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/strength/DSGNSynth_BUFF-Plus Damage_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/strength/DSGNSynth_BUFF-Plus Damage_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/strength/DSGNSynth_BUFF-Plus Damage_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/strength/DSGNSynth_BUFF-Plus Damage_HY_PC-005.wav"),
		preload("res://assets/sfx/battle/strength/DSGNSynth_BUFF-Plus Damage_HY_PC-006.wav"),
	],
	SFX_TYPE.HEAL: [
		preload("res://assets/sfx/battle/heal/MAGAngl_BUFF-Healing Gusts_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/heal/MAGAngl_BUFF-Healing Gusts_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/heal/MAGAngl_BUFF-Healing Gusts_HY_PC-003.wav"),
	],
	SFX_TYPE.FREEZE: [
		preload("res://assets/sfx/battle/freeze/DSGNMisc_HIT-Zap Metal_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/freeze/DSGNMisc_HIT-Zap Metal_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/freeze/DSGNMisc_HIT-Zap Metal_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/freeze/DSGNMisc_HIT-Zap Metal_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/freeze/DSGNMisc_HIT-Zap Metal_HY_PC-005.wav"),
		preload("res://assets/sfx/battle/freeze/DSGNMisc_HIT-Zap Metal_HY_PC-006.wav"),
	],
	SFX_TYPE.PARALYZE: [
		preload("res://assets/sfx/battle/paralyze/DSGNSynth_BUFF-Enemy Debuff_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/paralyze/DSGNSynth_BUFF-Enemy Debuff_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/paralyze/DSGNSynth_BUFF-Enemy Debuff_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/paralyze/DSGNSynth_BUFF-Enemy Debuff_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/paralyze/DSGNSynth_BUFF-Enemy Debuff_HY_PC-005.wav"),
		preload("res://assets/sfx/battle/paralyze/DSGNSynth_BUFF-Enemy Debuff_HY_PC-006.wav"),
	],
	SFX_TYPE.HASTE: [
		preload("res://assets/sfx/battle/haste/MAGAngl_BUFF-Speed Debuff_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/haste/MAGAngl_BUFF-Speed Debuff_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/haste/MAGAngl_BUFF-Speed Debuff_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/haste/MAGAngl_BUFF-Speed Debuff_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/haste/MAGAngl_BUFF-Speed Debuff_HY_PC-005.wav"),
		preload("res://assets/sfx/battle/haste/MAGAngl_BUFF-Speed Debuff_HY_PC-006.wav"),
	],
	SFX_TYPE.EXPLOSION: [
		preload("res://assets/sfx/battle/explosion/DSGNImpt_EXPLOSION-Bass Hit_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/explosion/DSGNImpt_EXPLOSION-Bass Hit_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/explosion/DSGNImpt_EXPLOSION-Bass Hit_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/explosion/DSGNImpt_EXPLOSION-Bass Hit_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/explosion/DSGNImpt_EXPLOSION-Bass Hit_HY_PC-005.wav"),
		preload("res://assets/sfx/battle/explosion/DSGNImpt_EXPLOSION-Bass Hit_HY_PC-006.wav"),
	],
	SFX_TYPE.DEATH: [
		preload("res://assets/sfx/battle/death/DSGNMisc_HIT-Mecha Shimmer Damage_HY_PC-001.wav"),
		preload("res://assets/sfx/battle/death/DSGNMisc_HIT-Mecha Shimmer Damage_HY_PC-002.wav"),
		preload("res://assets/sfx/battle/death/DSGNMisc_HIT-Mecha Shimmer Damage_HY_PC-003.wav"),
		preload("res://assets/sfx/battle/death/DSGNMisc_HIT-Mecha Shimmer Damage_HY_PC-004.wav"),
		preload("res://assets/sfx/battle/death/DSGNMisc_HIT-Mecha Shimmer Damage_HY_PC-005.wav"),
		preload("res://assets/sfx/battle/death/DSGNMisc_HIT-Mecha Shimmer Damage_HY_PC-006.wav"),
	],
}

var sprite
@onready var baseSprite = $VBoxContainer/BaseSprite
@onready var wizardSprites = $VBoxContainer/BaseSprite/WIZARDSPECIFIC

@onready var trail = $VBoxContainer/BaseSprite/GPU_TrailParticles
var image = Image.new() 
var isFollowing : bool = false
var isHurt : float = 0.0
var timePass
var orig
var end

var isPlayer : bool = false
var expCounter : Array[int] = []

var baseStats : CharacterStats = CharacterStats.new() 
var statChanges : CharacterStats = CharacterStats.new() # final stats, including all buffs and debuffs
var statusEffects : Array[StatusEffect] = []


var skills : Array[Skill] = []
var skillToUse = -1


func _ready() -> void:
	orig = self.global_position
	
	if isPlayer:
		baseSprite.texture = load("res://assets/wizard_defaults/wizardBase.png")
		SetSpells()
		SetUpWizard()
		CreatePlayerCompositeImage()

		wizardSprites.visible = true;
		trail.texture = ImageTexture.create_from_image(image)
	else:
		baseSprite.texture = sprite
		trail.texture = baseSprite.texture
	
	for s in skills:
		s.set_visuals()
		skillBars.add_child(s.skillBar)
	
	levelLabel.text = str(level)
	levelLabel.self_modulate = Color.RED if level > PlayerProgress.level else Color.BLACK
	
	expCounter.resize(3)#skills.size())
	
	pass

func play_sfx(sfx_name: SFX_TYPE) -> void:
	sfx_player.stop()
	sfx_player.stream = attack_sfx.get(sfx_name).pick_random()
	sfx_player.play()
	
func play_status_effect_sfx(effect: StatusEffect.StatusEffectType) -> void:
	var sfx: AudioStream = null
	
	match effect:
		StatusEffect.StatusEffectType.Burn:
			sfx = attack_sfx.get(SFX_TYPE.BURN).pick_random()
		StatusEffect.StatusEffectType.Freeze:
			sfx = attack_sfx.get(SFX_TYPE.FREEZE).pick_random()
		StatusEffect.StatusEffectType.Paralyze:
			sfx = attack_sfx.get(SFX_TYPE.PARALYZE).pick_random()
		StatusEffect.StatusEffectType.Haste:
			sfx = attack_sfx.get(SFX_TYPE.HASTE).pick_random()
		StatusEffect.StatusEffectType.Strength:
			sfx = attack_sfx.get(SFX_TYPE.STRENGTH).pick_random()

	if sfx != null:
		sfx_player.stream = sfx
		sfx_player.play()

func SetStats(stats : CharacterStats) :
	baseStats = stats
	pass


# Charge every skill
func PassTime(delta: float) -> void:
	CalculateStatChanges()
	
	for skill in skills:
		skill.Charge(delta * (statChanges.chargeRate))
	for effect in statusEffects:
		if effect.pass_status_time(delta):
			effect.Apply(self)
	
	var toKeep : Array[StatusEffect] = []
	for effect in statusEffects:
		if effect.Count <= 0:
			RemoveStatus(effect)
		else:
			toKeep.append(effect)
	statusEffects = toKeep
	
	pass

# Update health bar (should be replaced by tying it to a variable)
func UpdateVisuals(delta : float):
	healthBar.value = baseStats.health * 1.0 / baseStats.maxHealth
	
	if isFollowing:
		timePass += delta
		if timePass >= 0.5:
			self.global_position = orig
			isFollowing = false
			trail.emitting = false
		elif timePass >= 0.25:
			self.global_position = lerp(end, orig, (timePass - 0.25) / 0.25)
		else: 
			self.global_position = lerp(orig, end, timePass / 0.25)
	
	if isHurt > 0.0:
		isHurt -= delta
		baseSprite.modulate = Color.RED if fmod(floor((fmod(isHurt, 1) * 10)), 2) == 0 else Color.WHITE
	else:
		baseSprite.modulate = Color.WHITE
	
	pass


# finds the highest overcharge of a skill and returns it (overcharge = charge amount above maxCharge)
func CheckSkillCharge() -> float:
	var val = -2
	var i = 0
	
	for skill in skills:
		var skillOvercharge = skill.GetOvercharge()
		if skillOvercharge > val:
			val = skillOvercharge
			skillToUse = i
		i += 1
	
	return val


# Use skill against target
func UseSkill(target : Array[Character]) -> void:
	if self.IsParalyzed():
		skills[skillToUse].isParalyzed = true
	
	skills[skillToUse].isCurrentAttack = true
	
	if skills[skillToUse].isAoE:
		skills[skillToUse].Use(self, target[1])
		skills[skillToUse].Use(self, target[2])
		skills[skillToUse].Use(self, target[3])
	else: skills[skillToUse].Use(self, target[0])
	
	expCounter[skills[skillToUse].equipState - 1] += 67
	
	#particles.emitting = true
	trail.emitting = true
	Follow(target[0])
	
	
	skills[skillToUse].isParalyzed = false
	
	skillToUse = -1
	
	CalculateStatChanges()
	pass

func ApplyStatus(status : StatusEffect):
	statusEffects.append(status)
	var clr : Color = status.GetColor()
	
	var popup = damagePopup.instantiate()
	character.get_parent().get_parent().add_child(popup)
	popup.SetUpText(character.get_parent().position, 0,
	 "+" + StatusEffect.StatusEffectType.keys()[status.StatusType], clr)
	
	CalculateStatChanges()
	pass

func RemoveStatus(status : StatusEffect):
	var clr : Color = status.GetColor()
	
	var popup = damagePopup.instantiate()
	character.get_parent().get_parent().add_child(popup)
	popup.SetUpText(character.get_parent().position, 0,
	 "-" + StatusEffect.StatusEffectType.keys()[status.StatusType], clr)
	
	CalculateStatChanges()
	pass


# Take damage and create a text popup
func TakeDamage(dmg : int, itCrit : bool):
	baseStats.TakeDamage(dmg)
	
	var popup = damagePopup.instantiate()
	character.get_parent().get_parent().add_child(popup)
	popup.SetUp(character.get_parent().position, dmg, itCrit)
	isHurt = 0.5
	
	CalculateStatChanges()
	pass

func TakeTrueDamage(dmg : int, source : int): # source will be used to denote what dealt the damage
	baseStats.TakeDamage(dmg)
	
	var popup = damagePopup.instantiate()
	character.get_parent().get_parent().add_child(popup)
	
	if dmg < 0:
		source = 2
	
	match source:
		2: 
			popup.SetUpText(character.get_parent().position, abs(dmg), " heal", Color.SPRING_GREEN)
			var effect = effectScene.instantiate()
			get_parent().get_parent().add_child(effect)
			effect.SetUp(get_parent().position, 1)
		1: 
			popup.SetUpText(character.get_parent().position, dmg, " explosion", Color.ORANGE)
			isHurt = 0.5
		_: 
			popup.SetUpText(character.get_parent().position, dmg, " burn", Color.ORANGE)
			isHurt = 0.1
			
	
	CalculateStatChanges()
	pass



func Follow(target : Character):
	end = target.global_position
	end.x = (end.x - orig.x) * 0.3 + orig.x
	end.y = (end.y - orig.y) * 0.3 + orig.y
	
	timePass = 0.0
	isFollowing = true
	trail.modulate = Color.from_hsv(BattleVariables.battleRNG.randf(), 0.8, 1)
	
	pass

func CalculateStatChanges():
	statChanges.ResetStats()
	statChanges.chargeRate = 1.0
	statChanges.attack = baseStats.attack
	statChanges.defense = baseStats.defense
	
	for effect in statusEffects:
		effect.AlterStats(statChanges)
	
	statChanges.CalculateFinalStats(baseStats)
	
	pass

func IsParalyzed() -> bool:
	for effect in statusEffects:
		if effect.StatusType == StatusEffect.StatusEffectType.Paralyze && effect.Count > 0:
			effect.Apply(self)
			return true
	
	return false



func SetSpells():
	for i in 3:
		print(i)
		for spell in SkillManager.skills:
			if spell.equipState == i + 1:
				var instance = Skill.DuplicateSkill(spell)
				skills.append(instance)
	pass

func ApplyExp():
	for skill in SkillManager.skills:
		if skill.equipState != -1:
			skill.LevelUp(expCounter[skill.equipState - 1])


func SetUpWizard():
	wizardSprites.get_child(0).modulate = PlayerAppearance.appearance.get_skin_color()

	var hat = EquipmentManager.get_equipped(EquipmentItem.Slot.HAT)
	wizardSprites.get_child(2).texture = hat.sprite if hat else null
	wizardSprites.get_child(2).modulate = Color.WHITE

	var robe = EquipmentManager.get_equipped(EquipmentItem.Slot.ROBE)
	wizardSprites.get_child(3).texture = robe.sprite if robe else null
	wizardSprites.get_child(3).modulate = Color.WHITE

	var weapon = EquipmentManager.get_equipped(EquipmentItem.Slot.WEAPON)
	wizardSprites.get_child(4).texture = weapon.sprite if weapon else null
	wizardSprites.get_child(4).modulate = Color.WHITE
	
	pass

func CreatePlayerCompositeImage():
	image = baseSprite.texture.get_image()
	
	var skin = $VBoxContainer/BaseSprite/WIZARDSPECIFIC/Skin
	var source = skin.texture.get_image()
	source.convert(Image.FORMAT_RGBA8)
	image.blend_rect(source, Rect2(Vector2.ZERO, source.get_size()), Vector2.ZERO)
	
	skin = $VBoxContainer/BaseSprite/WIZARDSPECIFIC/Face
	if skin.texture != null:
		source = skin.texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		image.blend_rect(source, Rect2(Vector2.ZERO, source.get_size()), Vector2.ZERO)
	
	skin = $VBoxContainer/BaseSprite/WIZARDSPECIFIC/Hat
	if skin.texture != null:
		source = skin.texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		image.blend_rect(source, Rect2(Vector2.ZERO, source.get_size()), Vector2.ZERO)
	
	skin = $VBoxContainer/BaseSprite/WIZARDSPECIFIC/Robe
	if skin.texture != null:
		source = skin.texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		image.blend_rect(source, Rect2(Vector2.ZERO, source.get_size()), Vector2.ZERO)
	
	skin = $VBoxContainer/BaseSprite/WIZARDSPECIFIC/Weapon
	if skin.texture != null:
		source = skin.texture.get_image()
		source.convert(Image.FORMAT_RGBA8)
		image.blend_rect(source, Rect2(Vector2.ZERO, source.get_size()), Vector2.ZERO)
	
	pass

func select(on : bool):
	$"VBoxContainer/Container--Sprite2D/Selection".visible = on
	$VBoxContainer/BaseSprite/TextureRect.visible = on
