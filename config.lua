-- Hello, Penta here, this is my code from utilitools
local imguiHelpers = {}
imguiHelpers.visibleLabel = function(label)
	return tostring(label):sub(1, (tostring(label):find("##", nil, true) or 0) - 1)
end
imguiHelpers.tooltip = function(tooltip)
	if imgui.IsItemHovered() and tooltip ~= nil and (type(tooltip) ~= "string" or tooltip:len() > 0) then
		imgui.PushTextWrapPos(imgui.GetFontSize() * 7 / 13 * 65)
		imgui.SetItemTooltip(tostring(tooltip))
		imgui.PopTextWrapPos()
	end
end
imguiHelpers.getWidth = function(label)
	if label == nil or imguiHelpers.visibleLabel(label):len() == 0 then
		return -1 ^ -9
	else
		return -imgui.GetFontSize() * 7 / 13 * imguiHelpers.visibleLabel(label):len() - imgui.GetStyle().ItemInnerSpacing.x
	end
end
imguiHelpers.setWidth = function(label)
	imgui.SetNextItemWidth(imguiHelpers.getWidth(label))
end
imguiHelpers.inputBool = function(label, current, default, tooltip)
	if current == nil then current = default end
	local v = ffi.new("bool[1]", { current })
	imgui.Checkbox(label, v)
	imguiHelpers.tooltip(tooltip)
	return v[0]
end
imguiHelpers.inputInt = function(label, current, default, tooltip, flags, step, stepFast)
	if current == nil then current = default end
	local v = ffi.new("int[1]", { current })
	imguiHelpers.setWidth(label)
	imgui.InputInt(label, v, step or 0, stepFast, flags or (2 ^ 12))
	imguiHelpers.tooltip(tooltip)
	return v[0]
end
imguiHelpers.inputFloat = function(label, current, default, tooltip, flags, step, stepFast, format)
	if current == nil then current = default end
	local v = ffi.new("float[1]", { current })
	imguiHelpers.setWidth(label)
	imgui.InputFloat(label, v, step or 0, stepFast, format, flags or (2 ^ 12))
	imguiHelpers.tooltip(tooltip)
	return v[0]
end
imguiHelpers.inputSliderInt = function(label, current, default, tooltip, flags, min, max, innerLabel)
	if current == nil then current = default end
	local v = ffi.new("int[1]", { current })
	imguiHelpers.setWidth(label)
	imgui.SliderInt(label, v, min, max, innerLabel, flags)
	imguiHelpers.tooltip(tooltip)
	return v[0]
end
imguiHelpers.treeNode = function(label, func, flags) -- edited
	-- if utilitools.config.foldAll then imgui.SetNextItemOpen(not not (flags and flags % 2 ^ (5 + 1) >= 2 ^ 5), 2 ^ 0) end
	if flags then
		if imgui.TreeNodeEx_Str(label, flags) then
			func()
			imgui.TreePop()
		end
	else
		if imgui.TreeNode_Str(label) then
			func()
			imgui.TreePop()
		end
	end
end

if imgui.BeginTabBar("detailedAccConfig") then
	if imgui.BeginTabItem("Game##detailedAccConfig") then
		mod.config.ShowBeat = imguiHelpers.inputBool("Show Beat", mod.config.ShowBeat, true, "Shows the current beat when playing a level")
		imguiHelpers.treeNode("Section Timer", function()
			mod.config.SectionTimer = imguiHelpers.inputBool("Section Timer", mod.config.SectionTimer, true, "Enables the Timer Bar")
			mod.config.TimerXOffset = imguiHelpers.inputInt("X Offset##timer", mod.config.TimerXOffset, 0, "Offsets the Timer Bar", nil, 1, 10)
			mod.config.TimerYOffset = imguiHelpers.inputInt("Y Offset##timer", mod.config.TimerYOffset, 0, "Offsets the Timer Bar", nil, 1, 10)
			mod.config.TwidthAdd = imguiHelpers.inputInt("Additional Width", mod.config.TwidthAdd, 0, "Widens the usually 100px Timer Bar further", nil, 10, 50)
		end, 2 ^ 5)
		imguiHelpers.treeNode("Key Presses", function()
			mod.config.KeyPresses = imguiHelpers.inputBool("Key Presses", mod.config.KeyPresses, true, "Enables Key Presses")
			mod.config.KeyPressesRight = imguiHelpers.inputBool("Right Side", mod.config.KeyPressesRight, true, "Moves Key Presses to the right side")
			mod.config.TapXOffset = imguiHelpers.inputInt("X Offset##tap", mod.config.TapXOffset, 0, "Offsets the Key Presses", nil, 1, 10)
			mod.config.TapYOffset = imguiHelpers.inputInt("Y Offset##tap", mod.config.TapYOffset, 0, "Offsets the Key Presses", nil, 1, 10)
		end, 2 ^ 5)
		imguiHelpers.treeNode("Tap Offset Meter", function()
			mod.config.TapErrorMeter = imguiHelpers.inputBool("Tap Offset Meter", mod.config.TapErrorMeter, true, "Enables the Tap Offset Meter")
			mod.config.MeterYOffset = imguiHelpers.inputInt("Y Offset##meter", mod.config.MeterYOffset, 0, "Offsets the Key Presses", nil, 1, 10)
		end, 2 ^ 5)
		imguiHelpers.treeNode("Section Blips", function()
			mod.config.SectionBlips = imguiHelpers.inputBool("Section Blips", mod.config.SectionBlips, true, "Enables Section Blips")
			mod.config.BlipVolume = imguiHelpers.inputFloat("Volume", mod.config.BlipVolume, 3, "Volume of the Section Blips", nil, 0.1, 1, nil)
		end, 2 ^ 5)
		imgui.EndTabItem("Game##detailedAccConfig")
	end
	if imgui.BeginTabItem("Results Screen##detailedAccConfig") then
		mod.config.DrawPrecision = imguiHelpers.inputSliderInt("Draw Precision", mod.config.DrawPrecision, 1, "Raise value to lower precision\nSkipping points result in faster rendering and less lag", nil, 1, 10, nil)
		mod.config.ZoomIn = imguiHelpers.inputBool("Zoom In", mod.config.ZoomIn, false, "Adjusts the axes of the graphs to stretch the data")
		imgui.EndTabItem("Results Screen##detailedAccConfig")
	end
	imgui.EndTabBar()
end