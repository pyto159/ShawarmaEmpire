extends MarginContainer

@onready var coins_label: Label = %CoinsLabel
@onready var gems_label: Label = %GemsLabel


func _ready() -> void:
	GameManager.currency_changed.connect(_on_currency_changed)
	_on_currency_changed(GameManager.coins, GameManager.gems)


func _exit_tree() -> void:
	if GameManager.currency_changed.is_connected(_on_currency_changed):
		GameManager.currency_changed.disconnect(_on_currency_changed)


func _on_currency_changed(coins: int, gems: int) -> void:
	coins_label.text = CurrencyFormatter.format_coins(coins)
	gems_label.text = CurrencyFormatter.format_gems(gems)
