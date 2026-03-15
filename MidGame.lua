function DetailedAccDraw()

    if extrasavedata and extrasavedata.extraConfigOtherMods and extrasavedata.detailedacc then
        ExtraStuffInstalled = true
    end


    if mods["DetailedAcc"].config.TapErrorMeter then

        local MeterLeft = 200
        local MeterRight = 400
        local MeterY = 330 + mods["DetailedAcc"].config.MeterYOffset or 0
        local OffsetHeight = 6

        if ExtraStuffInstalled and extrasavedata.detailedacc.moveTapErrorMeterTop then
            MeterY = 50
        end

        MeterY = MeterY or 330

        love.graphics.setLineWidth(2)
        love.graphics.line(MeterLeft, MeterY, MeterRight, MeterY)

        TapOffsets = TapOffsets or {}


        local window = 150

        if savedata.options.accessibility.taps == 'lenient' then
            window = window * 2
        elseif savedata.options.accessibility.taps == 'strict' then
            window = 75
        end

        local Min = -window / 2
        local Max = window / 2

        local i = 1
        while i <= #TapOffsets do
            if TapOffsets[i][1] <= 0 then
                table.remove(TapOffsets, i)
            else
                i = i + 1
            end
        end

        for i, v in ipairs(TapOffsets) do

            TapOffsets[i][1] = TapOffsets[i][1] - love.timer.getDelta()

            local pointOnMeter = (((-TapOffsets[i][2] - Min) / (Max - Min)) * (MeterRight - MeterLeft)) + MeterLeft

            love.graphics.line(pointOnMeter, MeterY - (OffsetHeight * (TapOffsets[i][1] / 3)), pointOnMeter, MeterY + (OffsetHeight * (TapOffsets[i][1] / 3)))

        end

    end
    if mods["DetailedAcc"].config.KeyPresses then

        DAkeys = DAkeys or {{0,false},{0,false}}

        released1 = maininput:released("tap1") or (savedata.options.game.disableClick == false and maininput:released("mouse1"))
	    released2 = maininput:released("tap2") or (savedata.options.game.disableClick == false and maininput:released("mouse2"))

        pressed1 = maininput:pressed("tap1") or (savedata.options.game.disableClick == false and maininput:pressed("mouse1"))
	    pressed2 = maininput:pressed("tap2") or (savedata.options.game.disableClick == false and maininput:pressed("mouse2"))



        if pressed1 then
            DAkeys[1][1] = DAkeys[1][1] + 1
            DAkeys[1][2] = true
        end
        if pressed2 then
            DAkeys[2][1] = DAkeys[2][1] + 1
            DAkeys[2][2] = true
        end

        -- this is so bad

        if released1 then
            DAkeys[1][2] = false
        end
        if released2 then
            DAkeys[2][2] = false
        end

        love.graphics.setFont(fonts.digitalDisco)

        love.graphics.setColor(0,0,0)

        local drawX = 572

        if not mods["DetailedAcc"].config.KeyPressesRight or (ExtraStuffInstalled and extrasavedata.detailedacc.moveTapDisplayLeft) then
            drawX = 28
        end

        drawX = drawX + mods["DetailedAcc"].config.TapXOffset

        love.graphics.rectangle("line", drawX, 180 - 16, 25, 25)
        if DAkeys[1][2] then love.graphics.rectangle("fill", drawX, 180 - 16 + mods["DetailedAcc"].config.TapYOffset, 25, 25) end
        love.graphics.printf( tostring(DAkeys[1][1]), drawX - 37.5, 180 - 10 + mods["DetailedAcc"].config.TapYOffset, 100, "center" )

        love.graphics.rectangle("line", drawX, 180 + 16, 25, 25)
        if DAkeys[2][2] then love.graphics.rectangle("fill", drawX, 180 + 16 + mods["DetailedAcc"].config.TapYOffset, 25, 25) end
        love.graphics.printf( tostring(DAkeys[2][1]), drawX - 37.5, 180 + 22 + mods["DetailedAcc"].config.TapYOffset, 100, "center" )

    end

    local Tx = 6 + mods["DetailedAcc"].config.TimerXOffset
    local Ty = 10 + mods["DetailedAcc"].config.TimerYOffset
    local Twidth = 100 + mods["DetailedAcc"].config.TwidthAdd
    local Theight = 2 + 3 --intentional extrastuff injection block
    if ExtraStuffInstalled then
        local pos = extrasavedata.detailedacc.sectionTimerPos or "topLeft"

        local screenW, screenH = 600, 360

        local marginX = 6
        local marginY = 20

        if pos == "topRight" then
            Tx = screenW - Twidth - marginX
            Ty = marginY

        elseif pos == "bottomLeft" then
            Tx = marginX
            Ty = screenH - Theight - marginY - 12 -- extra room for text

        elseif pos == "bottomRight" then
            Tx = screenW - Twidth - marginX
            Ty = screenH - Theight - marginY - 12
        end
    end


    if mods["DetailedAcc"].config.SectionTimer or mods["DetailedAcc"].config.SectionBlips then
        --draw




        local Section

        local End
        local last

        table.sort(DetailedAccBookmarks, function(k1, k2)
            return k1.time < k2.time
        end)

        LastSDA = Section2 or 1

        for i, v in ipairs(DetailedAccBookmarks) do
            if cs.cBeat < v.time then

                Section = i

                break

            end
        end

        if not Section then
            End = DAShowResults
            last = DetailedAccBookmarks[#DetailedAccBookmarks].time
        else
            last = DetailedAccBookmarks[Section - 1] and DetailedAccBookmarks[Section - 1].time or 0
            End = DetailedAccBookmarks[Section].time
        end



        Section = Section or #DetailedAccBookmarks + 1

        if not DetailedAccBuckets then

            DetailedAccBuckets = {}

            for i, v in ipairs(DetailedAccBookmarks) do

                -- time, bucket s

                table.insert(DetailedAccBuckets, {name = v.name, time = v.time, Incidents = {}, fc = true, perfect = true, misses = 0, barelies = 0})

            end


        end

        if mods["DetailedAcc"].config.SectionBlips and (tonumber(LastSDA) ~= tonumber(Section)) and (DetailedAccNotes and DetailedAccBuckets) and (LastSDA ~= 1) then
            --check for fc / perfect
            for i, v in ipairs(DetailedAccNotes) do


                table.sort(DetailedAccBuckets, function(k1, k2)
                    return k1.time < k2.time
                end)

                -- score buck et

                if v.miss or v.barely then

                    for i = 1, #DetailedAccBuckets do
                        local current = DetailedAccBuckets[i]
                        local nextBucket = DetailedAccBuckets[i + 1]
                        if not nextBucket or v.beat < nextBucket.time then
                            if v.beat >= current.time then

                                if v.miss then
                                    current.misses = current.misses + math.max(v.hits, 1)
                                elseif v.barely then
                                    current.barelies = current.barelies + v.hits
                                end

                                if v.miss then
                                    current.fc = false
                                    current.perfect = false
                                end

                                if v.barely then
                                    current.perfect = false
                                end
                            end
                            break
                        end
                    end

                end

            end

            local playBlip = true


            table.sort(DetailedAccBuckets, function(k1, k2)
                return k1.time < k2.time
            end)

            if not LvlDataDA.SectionBests[DetailedAccBuckets[tonumber(LastSDA) - 1].name] then
                playBlip = false
            end

            local t = LvlDataDA.SectionBests[DetailedAccBuckets[tonumber(LastSDA) - 1].name] or {misses = 99999999999, barelies = 99999999999}

            local isMissPB = t.misses > DetailedAccBuckets[tonumber(LastSDA) - 1].misses

            LvlDataDA.SectionBests[DetailedAccBuckets[tonumber(LastSDA) - 1].name] = {

                misses = t.misses > DetailedAccBuckets[tonumber(LastSDA) - 1].misses and DetailedAccBuckets[tonumber(LastSDA) - 1].misses or t.misses,
                barelies = t.barelies > DetailedAccBuckets[tonumber(LastSDA) - 1].barelies and DetailedAccBuckets[tonumber(LastSDA) - 1].barelies or t.barelies,

            }

            SessionBest = SessionBest or {}



            if not SessionBest[cLevel] then
                playBlip = false
            end

            local def = SessionBest[cLevel] and SessionBest[cLevel][DetailedAccBuckets[tonumber(LastSDA) - 1].name] or {misses = 99999999999, barelies = 99999999999}

            SessionBest[cLevel] = SessionBest[cLevel] or {}

            local isSessionMissPB = def.misses > DetailedAccBuckets[tonumber(LastSDA) - 1].misses

            SessionBest[cLevel][DetailedAccBuckets[tonumber(LastSDA) - 1].name] = {

                misses = def.misses > DetailedAccBuckets[tonumber(LastSDA) - 1].misses and DetailedAccBuckets[tonumber(LastSDA) - 1].misses or def.misses,
                barelies = def.barelies > DetailedAccBuckets[tonumber(LastSDA) - 1].barelies and DetailedAccBuckets[tonumber(LastSDA) - 1].barelies or def.barelies,

            }


            local PassedMaxMisses = false
            GORESETLEVELDA = false

            if LvlDataDA.MaxMissPSection[DetailedAccBuckets[tonumber(LastSDA) - 1].name] then

                PassedMaxMisses = DetailedAccBuckets[tonumber(LastSDA) - 1].misses > LvlDataDA.MaxMissPSection[DetailedAccBuckets[tonumber(LastSDA) - 1].name]

            end

            if PassedMaxMisses then

                te.playOne(sounds.MthreshFail, "static", "sfx",mods["DetailedAcc"].config.BlipVolume)

                GORESETLEVELDA = true

                if cs.restartOn == "Miss thresholds" then
                    GORESETLEVELDA = true
                end
            else

                dpf.saveJson("Mods/DetailedAcc/LvlData/" .. string.sub(cLevel,1,string.len(cLevel) - 1) .. ".json", LvlDataDA)

                if mods["DetailedAcc"].config.SectionBlips and DetailedAccBuckets[tonumber(LastSDA) - 1] then
                    local bucket = DetailedAccBuckets[tonumber(LastSDA) - 1]
                    -- priority : PB > Session PB > Perfect > FC
                    if isMissPB and playBlip then
                        te.playOne(sounds.PB, "static", "sfx",mods["DetailedAcc"].config.BlipVolume)
                    elseif isSessionMissPB and playBlip then
                        te.playOne(sounds.SessionPB, "static", "sfx",mods["DetailedAcc"].config.BlipVolume)
                    elseif bucket.perfect then
                        te.playOne(sounds.Pblip, "static", "sfx",mods["DetailedAcc"].config.BlipVolume)
                    elseif bucket.fc then
                        te.playOne(sounds.FCblip, "static", "sfx",mods["DetailedAcc"].config.BlipVolume)
                    end
                end

            end

        end



        Section2 = Section

        Twidth = Twidth or 100

        if mods["DetailedAcc"].config.SectionTimer then



            local beat = math.max(cs.cBeat, 0)

            love.graphics.setColor(0,0,0)

            love.graphics.rectangle("fill", Tx, Ty, Twidth, Theight)

            local PcentTillEnd = 1 - math.min(((DAShowResults - beat) / DAShowResults), 1)
            local PcentTillNextSection = 1 - math.min(((End - beat) / (End - last)), 1)
            local SecName = DetailedAccBookmarks[Section - 1] and DetailedAccBookmarks[Section - 1].name or "Start"

            love.graphics.setColor(1,1,1)
            if mods["DetailedAcc"].config.TimerOnlyTotal or (#DetailedAccBookmarks == 1) then
                love.graphics.rectangle("fill", Tx + 1, Ty + 1, (PcentTillEnd * (Twidth - 2)), Theight - 2)
            else
                if mods["DetailedAcc"].config.TimerOnlySection then
                    love.graphics.rectangle("fill", Tx + 1, Ty + 1, (PcentTillNextSection * (Twidth - 2)), Theight - 2)
                else
                    love.graphics.rectangle("fill", Tx + 1, Ty + 3, (PcentTillNextSection * (Twidth - 2)), Theight - 4)
                    love.graphics.rectangle("fill", Tx + 1, Ty + 1, (PcentTillEnd * (Twidth - 2)), Theight - 4)
                end
            end




            love.graphics.setColor(0,0,0)

            love.graphics.setFont(fonts.main)

            local name = "Section name:  " .. tostring(SecName)
            if not (#DetailedAccBookmarks == 1) then
                love.graphics.printf(name, Tx, Ty + Theight + 3, 300, "left")
            end
        end




    end

    if mods["DetailedAcc"].config.ShowBeat then
        love.graphics.setFont(fonts.terminal)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Beat: " .. tostring(math.floor(cs.cBeat * 100) / 100), Tx, 2 + mods["DetailedAcc"].config.TimerYOffset, 200, "left")
    end
end
