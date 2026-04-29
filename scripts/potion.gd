class_name Potion extends Node

enum PotionTypes { Healing, Strength, Explosive }

var type : PotionTypes
var slot : int = -1
var quantity : int = 10

func _init(typ : PotionTypes, slt : int = -1):
	type = typ
	slot = slt
