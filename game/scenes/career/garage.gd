extends Control

@onready var lbl_budget: Label = $Header/Budget
@onready var upgrade_container: GridContainer = $UpgradeGrid
@onready var btn_back: Button = $BtnBack


func _ready() -> void:
	btn_back.pressed.connect(func(): GameState.go_back())
	_build_upgrade_ui()


func _build_upgrade_ui() -> void:
	var career = GameState.career
	if career == null:
		return

	lbl_budget.text = "Budget: $%s" % _format_money(career.prize_money)

	# Clear existing
	for child in upgrade_container.get_children():
		child.queue_free()

	for branch in UpgradeTree.BRANCHES:
		var level: int = career.upgrades[branch]["level"]
		var cost: int = UpgradeTree.get_next_cost(career, branch)
		var can_buy: bool = UpgradeTree.can_afford(career, branch)

		# Branch label
		var lbl_branch: Label = Label.new()
		lbl_branch.text = branch.capitalize()
		lbl_branch.custom_minimum_size = Vector2(100, 0)
		upgrade_container.add_child(lbl_branch)

		# Level indicator
		var lbl_level: Label = Label.new()
		lbl_level.text = "Lv %d/%d" % [level, UpgradeTree.MAX_LEVEL]
		lbl_level.custom_minimum_size = Vector2(80, 0)
		upgrade_container.add_child(lbl_level)

		# Description
		var lbl_desc: Label = Label.new()
		lbl_desc.text = UpgradeTree.get_description(branch, level)
		lbl_desc.custom_minimum_size = Vector2(200, 0)
		upgrade_container.add_child(lbl_desc)

		# Upgrade button
		var btn: Button = Button.new()
		if level >= UpgradeTree.MAX_LEVEL:
			btn.text = "MAXED"
			btn.disabled = true
		elif not can_buy:
			btn.text = "$%s" % _format_money(cost)
			btn.disabled = true
		else:
			btn.text = "Buy $%s" % _format_money(cost)
			btn.disabled = false
			var b: String = branch  # capture
			btn.pressed.connect(func(): _purchase(b))
		upgrade_container.add_child(btn)


func _purchase(branch: String) -> void:
	var career = GameState.career
	if UpgradeTree.purchase(career, branch):
		# Refresh UI
		_build_upgrade_ui()


func _format_money(amount: int) -> String:
	if amount >= 1000000:
		return "%.1fM" % (float(amount) / 1000000.0)
	elif amount >= 1000:
		return "%.0fK" % (float(amount) / 1000.0)
	return str(amount)
