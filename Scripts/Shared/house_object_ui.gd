extends Control

# Close the panel
func _on_close_button_pressed():
	hide()

func close_all_other_panels(panelName: String):
	if not panelName == "Calendar":
		$CalendarPanel.hide()
	if not panelName == "Computer":
		$ComputerPanel.hide()
	if not panelName == "Fridge":
		$FridgePanel.hide()
	if not panelName == "HouseDoor":
		$HouseDoorPanel.hide()

func open_panel(panelName: String):
	if panelName == "Calendar":
		$CalendarPanel.show()
	if panelName == "Computer":
		$ComputerPanel.show()
	if panelName == "Fridge":
		$FridgePanel.show()
	if panelName == "HouseDoor":
		$HouseDoorPanel.show()
	close_all_other_panels(panelName)
