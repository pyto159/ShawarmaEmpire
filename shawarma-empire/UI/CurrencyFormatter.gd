extends RefCounted
class_name CurrencyFormatter

const COINS_LABEL_PREFIX: String = "Coins: "
const GEMS_LABEL_PREFIX: String = "Gems: "


static func format_coins(coins: int) -> String:
	return COINS_LABEL_PREFIX + str(coins)


static func format_gems(gems: int) -> String:
	return GEMS_LABEL_PREFIX + str(gems)
