local st = Gamestate:new('Results') --this is so the patch doesnt break my flipping copy patch





function imgui.EpicImDrawListGraph(LineInMid, Data, circle, bookmarks)

    DAsize = imgui.GetContentRegionAvail()
    DApos = imgui.GetCursorScreenPos()
    drawList = drawList or imgui.GetWindowDrawList()


    function uvToxy(uv)
        return imgui.ImVec2_Float(((uv[1] * DAsize.x)) + DApos.x, ((uv[2] * DAsize.y)) + DApos.y)
    end

    -- Ok. 0.8 of height, and full width
    local GraphSize = { 1, 1 }
    local GraphPos = { (1 - GraphSize[1]) / 2, 0 }

    -- Background
    drawList:AddQuadFilled(
        uvToxy({GraphPos[1], GraphPos[2]}),
        uvToxy({GraphPos[1] + GraphSize[1], GraphPos[2]}),
        uvToxy({GraphPos[1] + GraphSize[1], GraphPos[2] + GraphSize[2]}),
        uvToxy({GraphPos[1], GraphPos[2] + GraphSize[2]}),

        imgui.GetColorU32_Col(imgui.ImGuiCol_Separator)
    )

    -- Graphing

    local Min = mods["DetailedAcc"].config.ZoomIn and 100000 or 0
    local Max = 100

    local Start = 0
    local End = 0


    for i, v in ipairs(Data) do
        if type(v[1]) == "number" then
            if v[1] < Min then
                Min = v[1]
            end
            if v[1] > Max then
                Max = v[1]
            end
        end

        if v[2] < Start then
            Start = v[2]
        end
        if v[2] > End then
            End = v[2]
        end

    end
    End = End + 1

    if circle then

        local window = 150

        if savedata.options.accessibility.taps == 'lenient' then
            window = window * 2
        elseif savedata.options.accessibility.taps == 'strict' then
            window = 75
        end

        Min = -window / 2
        Max = window / 2


    end

    function valueToY(value)


        if type(value) ~= "number" then value = 0 end

        return (GraphSize[2] - (((value - Min) / (Max - Min)) * GraphSize[2])) + GraphPos[2]


    end

    function valueToX(value)


        if type(value) ~= "number" then value = 0 end

        local value2 = End - value

        return (GraphSize[1] - (((value2 - Start) / (End - Start)) * GraphSize[1])) + GraphPos[1]


    end

    for i,b in ipairs(bookmarks) do
		if i ~= 1 then
			drawList:AddLine(
				uvToxy({
					valueToX(b.time),
					valueToY(Min)
				}),
				uvToxy({
					valueToX(b.time),
					valueToY(Max)
				}),
				imgui.GetColorU32_Vec4(imgui.ImVec4_Float(0,0,0,1)),
				1
			)
			local xy = uvToxy({
				valueToX(b.time),
				(((#bookmarks - i) / #bookmarks) * GraphSize[2]) + GraphPos[2]
			})
			xy.x = xy.x + 2
			drawList:AddText_Vec2(
				xy ,
				imgui.GetColorU32_Vec4(imgui.ImVec4_Float(1,1,1,1)),
				b.name
			)
		end
    end

    local LastPoint = {valueToX(Data[1][2]), valueToY(Data[1][1])}
    local CurrentPoint = nil

    local radius = 2

    if LineInMid then
        drawList:AddLine(
            uvToxy({GraphPos[1], valueToY(LineInMid)}),
            uvToxy({GraphPos[1] + GraphSize[1], valueToY(LineInMid)}),

            imgui.GetColorU32_Vec4(imgui.ImVec4_Float(103/255, 103/255, 103/255, 1)), -- Color,
            2
        )
	else
		local gradeMargins = {
			{ 100, 'perfect' },
			{ 98, 's','plus' },
			{ 95, 's' },
			{ 93, 'a', 'plus' },
			{ 90, 'a' },
			{87, 'b', 'plus' },
			{ 83, 'b' },
			{ 80, 'b', 'minus' },
			{ 77, 'c', 'plus' },
			{ 73, 'c' },
			{ 70, 'c', 'minus' },
			{ 64, 'd', 'plus' },
			{ 56, 'd' },
			{ 50, 'd', 'minus' },
			{ 0, 'f' }
		}
		for i, data in ipairs(gradeMargins) do
			if 0 <= data[1] and data[1] < 100 and Min <= data[1] and data[1] < Max then
				drawList:AddLine(
					uvToxy({ valueToX(Start), valueToY(data[1]) }),
					uvToxy({ valueToX(End), valueToY(data[1]) }),
					imgui.GetColorU32_Vec4((i == #gradeMargins or data[2] ~= gradeMargins[i + 1][2]) and imgui.ImVec4_Float(0.67, 0.67, 0.67, 1) or imgui.ImVec4_Float(0.33, 0.33, 0.33, 1)),
					1
				)

				if Max - Min < 80 or not data[3] then
					local grade = data[2]:upper() .. ({ [""] = "", plus = "+", minus = "-" })[data[3] or ""]
					local xy = uvToxy({
						valueToX(Start),
						valueToY(data[1])
					})
					xy.x = xy.x + 2
					xy.y = xy.y - 11
					drawList:AddText_Vec2(
						xy,
						imgui.GetColorU32_Vec4(imgui.ImVec4_Float(1,1,1,1)),
						grade
					)
				end
			end
		end
    end

    if circle then
        if tostring(Data[1][1]) ~= "miss" then
            drawList:AddCircleFilled(
                uvToxy(LastPoint),
                radius,
                imgui.GetColorU32_Vec4((Data[1][1] < 0) and (imgui.ImVec4_Float(0,1,0,1)) or (imgui.ImVec4_Float(0,0,1,1)))
            )
        else

            drawList:AddCircleFilled(
                    uvToxy({
                        valueToX(Data[1][2]),
                        valueToY(0)
                    }),
                    radius,
                    imgui.GetColorU32_Vec4(imgui.ImVec4_Float(1,0,0,1))
                )
            drawList:AddLine(
                uvToxy({
                    valueToX(Data[1][2]),
                    valueToY(Min)
                }),
                uvToxy({
                    valueToX(Data[1][2]),
                    valueToY(Max)
                }),
                imgui.GetColorU32_Vec4(imgui.ImVec4_Float(1,0,0,1))
            )

        end

    end

    local drawPrecision = mods["DetailedAcc"].config.DrawPrecision

    local drawPrecisionCooldown = 0

    for i = 2, #Data do
        if circle or drawPrecisionCooldown <= 0 then
            drawPrecisionCooldown = drawPrecision

            if tostring(Data[i][1]) ~= "miss" then
                CurrentPoint = {
                    valueToX(Data[i][2]),
                    valueToY(Data[i][1])
                }


                lineColor = imgui.GetColorU32_Col(imgui.ImGuiCol_Text)

                if circle then
                    drawList:AddCircleFilled(
                        uvToxy(CurrentPoint),
                        radius,
                        imgui.GetColorU32_Vec4((Data[i][1] < 0) and (imgui.ImVec4_Float(0,1,0,1)) or (imgui.ImVec4_Float(0,0,1,1)))
                    )
                else
                    drawList:AddLine(
                        uvToxy(LastPoint), -- P1
                        uvToxy(CurrentPoint), -- P2
                        lineColor
                    )
                end
                LastPoint = CurrentPoint
            else
                drawList:AddCircleFilled(
                        uvToxy({
                            valueToX(Data[i][2]),
                            valueToY(0)
                        }),
                        radius,
                        imgui.GetColorU32_Vec4(imgui.ImVec4_Float(1,0,0,1))
                    )
                drawList:AddLine(
                    uvToxy({
                        valueToX(Data[i][2]),
                        valueToY(Min)
                    }),
                    uvToxy({
                        valueToX(Data[i][2]),
                        valueToY(Max)
                    }),
                    imgui.GetColorU32_Vec4(imgui.ImVec4_Float(1,0,0,1))
                )
            end
        end
        drawPrecisionCooldown = drawPrecisionCooldown - 1
    end

    if not circle and #Data > 1 then
        drawList:AddLine(
            uvToxy({
                valueToX(Data[#Data][2]),
                valueToY(Data[#Data][1])
            }), -- P1
            uvToxy({
                valueToX(End),
                valueToY(Data[#Data][1])
            }), -- P2
            lineColor
        )
    end
end


st:setFgDraw(function(self)
    --Setup stuff

    if not setupDetailedAccResults then


        -- Play sound

        local Rank = 'what'
		if self.lGrade == 'perfect' then
            Rank = 'perfect'
		else
			Rank = self.lGrade
		end

        print("Playing rank: " .. tostring(Rank) .. "Song")

        local snd = tostring(Rank) .. "Song"

        if sounds[snd] then
            te.playOne(sounds[snd], "static", "sfx")
        end

        DetailedAccBuckets = {}

        for i, v in ipairs(DetailedAccBookmarks) do

            -- time, bucket s

            table.insert(DetailedAccBuckets, {name = v.name, time = v.time, Incidents = {}, fc = true, perfect = true})

        end

        setupDetailedAccResults = true
        missCount = 0
        barelyCount = 0
        totalHits = 0

        table.sort(DetailedAccBuckets, function(k1, k2)
            return k1.time < k2.time
        end)


        for i, v in ipairs(DetailedAccNotes) do

            if v.miss then
                missCount = missCount + math.max(v.hits, 1)
            elseif v.barely then
                barelyCount = barelyCount + v.hits
            end
            totalHits = totalHits + v.hits

            -- score buck et




            if v.miss or v.barely then

                for i = 1, #DetailedAccBuckets do
                    local current = DetailedAccBuckets[i]
                    local nextBucket = DetailedAccBuckets[i + 1]
                    if not nextBucket or v.beat < nextBucket.time then
                        if v.beat >= current.time then
                            table.insert(current.Incidents, v)
                        end
                        break
                    end
                end

            end

        end

        SectionNumber = 1
        SectionNumber = (SectionNumber > #DetailedAccBuckets) and #DetailedAccBuckets or SectionNumber

    end

    DetailedAccBuckets = DetailedAccBuckets or {}

    table.sort(DetailedAccBuckets, function(k1, k2)
        return k1.time < k2.time
    end)

    -- hits, barely, miss, beat, noteType, mine



    love.mouse.setVisible(true)
    helpers.SetNextWindowPos(0, 25, "ImGuiCond_FirstUseEver")
    helpers.SetNextWindowSize(180, 200, "ImGuiCond_FirstUseEver")
    imgui.Begin("Detailed Accuracy")



    -- Tabs



    if imgui.BeginTabBar("DetailedAccTabs") then

        if TapTiming2 and (TapTiming2[1]) then
            if imgui.BeginTabItem("Tap Offset Graph") then
                imgui.EpicImDrawListGraph(0, TapTiming2, true, DetailedAccBookmarks)

                imgui.EndTabItem()
            end
        end

        if DetailedAccAccs then
            if imgui.BeginTabItem("Accuracy Graph") then
                local last = mods["DetailedAcc"].config.DrawPrecision

                last = helpers.SliderInt("Draw Precision", last, 1, #DetailedAccAccs)
                if last ~= mods["DetailedAcc"].config.DrawPrecision then
                    mods["DetailedAcc"].config.DrawPrecision = last
					if mods.DetailedAcc.path then -- dev fix
						dpf.saveJson(mods.DetailedAcc.path .. "/config.json", mods.DetailedAcc.config)
					else
						dpf.saveJson("Mods/DetailedAcc/mod.json", mods.DetailedAcc)
					end
                end

                last = helpers.InputBool("Zoom In?", mods["DetailedAcc"].config.ZoomIn)
                if last ~= mods["DetailedAcc"].config.ZoomIn then
                    mods["DetailedAcc"].config.ZoomIn = last
					if mods.DetailedAcc.path then -- dev fix
						dpf.saveJson(mods.DetailedAcc.path .. "/config.json", mods.DetailedAcc.config)
					else
						dpf.saveJson("Mods/DetailedAcc/mod.json", mods.DetailedAcc)
					end
                end

                imgui.EpicImDrawListGraph(nil, DetailedAccAccs, false, DetailedAccBookmarks)

                imgui.EndTabItem()
            end
        end

        if DetailedAccNotes and imgui.BeginTabItem("Section by section") then

            imgui.BeginChild_Str(loc.get("Section names"), imgui.ImVec2_Float(0, 0), imgui.ImGuiChildFlags_AutoResizeX + imgui.ImGuiChildFlags_Border)

            for i, v in ipairs(DetailedAccBuckets) do
				--[[ v.totalHits = v.totalHits or 0
				v.misses = v.misses or 0
				v.barelies = v.barelies or 0
				local acc = math.floor((((v.totalHits - v.misses - (v.barelies/4)) / v.totalHits) * 10000) + 0.5) / 100
				if acc ~= acc then -- check for nan
					acc = 100
				end ]]
                local Sname = v.name .. --[[ " - " .. tostring(acc) .. ]] "##" .. i
                if imgui.Selectable_Bool(Sname, SectionPicked == v.name) then
                    SectionPicked = v.name
                    SectionNumber = i
                end

            end

            imgui.EndChild()

            imgui.SameLine()




            Text = ""

            for k,v in ipairs(DetailedAccBuckets[SectionNumber].Incidents) do

                local Reason = v.miss and ((v.noteType ~= "mine" or v.noteType ~= "mineHold") and "missed " or "hit ") or (v.barely and "barely hit ")


                Text = Text .. "You " .. Reason .. "a " .. v.noteType .. " at beat " .. v.beat .. "\n"
            end

            if imgui.BeginChild_Str("Incidents", imgui.ImVec2_Float(0, 0), imgui.ImGuiChildFlags_Border + imgui.ImGuiChildFlags_AlwaysUseWindowPadding) then
                imgui.TextUnformatted(Text)
                imgui.EndChild()
            end

            imgui.EndTabItem()
        end

        imgui.EndTabBar()

    end
    imgui.End()

end)