extends MarginContainer

@onready var coins_label: Label = %CoinsLabel
@onready var gems_label: Label = %GemsLabel


func _ready() -> void:
	GameManager.currency_changed.connect(_on_currency_changed)
	_on_currency_changed(GameManager.coins, GameManager.gems)


func _on_currency_changed(coins: int, gems: int) -> void:
	coins_label.text = "Coins: %d" % coins
	gems_label.text = "Gems: %d" % gems
