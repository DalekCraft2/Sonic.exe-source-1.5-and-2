function start(song)
    print("Song: " .. song .. " @ " .. bpm .. " downscroll: " .. downscroll)
end

function update(elapsed)
    local currentBeat = (songPos / 1000) * (bpm / 84)
    if curStep >= 789 and curStep < 923 then
        for i = 0, 8 do
            local receptor = _G['receptor_'..i]
            receptor.y = receptor.defaultY + 5 * math.sin((currentBeat + i * 0.25) * math.pi)
        end
    end

    if curStep >= 924 and curStep < 1048 then
        for i = 0, 8 do
            local receptor = _G['receptor_'..i]
            receptor.y = receptor.defaultY - 5 * math.sin((currentBeat + i * 0.25) * math.pi)
        end
    end

    if curStep >= 1049 and curStep < 1176 then
        for i = 0, 8 do
            local receptor = _G['receptor_'..i]
            receptor.x = receptor.defaultX + 2 * math.sin((currentBeat + i * 0.25) * math.pi)
        end
    end

    if curStep >= 1177 and curStep < 1959 then
        for i = 0, 8 do
            local receptor = _G['receptor_'..i]
            receptor.x = receptor.defaultX - 6 * math.sin((currentBeat + i * 0.25) * math.pi)
        end
    end

    if curStep >= 760 and curStep < 786 then
        camGame.tweenZoom(camGame, 1.2, 0.5)
    end

    if curStep >= 1392 and curStep < 1428 then
        camGame.tweenZoom(camGame, 1.2, 0.5)
    end
end

function beatHit(beat)
    -- do nothing
end

function stepHit(step)
    -- do nothing
end

function keyPressed(key)
    -- do nothing
end

print("Mod Chart script loaded :)")
