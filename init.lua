local mouseScrollButtonId = 2

local mouseScrollCircleDeadZone = 5

------------------------------------------------------------------------------------------

local mouseScrollCircle = nil
local mouseScrollTimer = nil
local mouseScrollStartPos = 0
local mouseScrollDragPosX = nil
local mouseScrollDragPosY = nil

overrideScrollMouseDown = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(e)
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == mouseScrollButtonId then
        if mouseScrollCircle then
            mouseScrollCircle:delete()
            mouseScrollCircle = nil
        end

        if mouseScrollTimer then
            mouseScrollTimer:stop()
            mouseScrollTimer = nil
        end

        mouseScrollStartPos = hs.mouse.getAbsolutePosition()
        mouseScrollDragPosX = mouseScrollStartPos.x
        mouseScrollDragPosY = mouseScrollStartPos.y

        mouseScrollTimer = hs.timer.doAfter(0.01, mouseScrollTimerFunction)

        return true
    end
end)

overrideScrollMouseUp = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(e)
    if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == mouseScrollButtonId then
        mouseScrollPos = hs.mouse.getAbsolutePosition()

        xDiff = math.abs(mouseScrollPos.x - mouseScrollStartPos.x)
        yDiff = math.abs(mouseScrollPos.y - mouseScrollStartPos.y)

        if (xDiff < mouseScrollCircleDeadZone and yDiff < mouseScrollCircleDeadZone) and not mouseScrollCircle then
            overrideScrollMouseDown:stop()
            overrideScrollMouseUp:stop()

            hs.eventtap.otherClick(e:location(), mouseScrollButtonId)

            overrideScrollMouseDown:start()
            overrideScrollMouseUp:start()
        end

        if mouseScrollCircle then
            mouseScrollCircle:delete()
            mouseScrollCircle = nil
        end

        if mouseScrollTimer then
            mouseScrollTimer:stop()
            mouseScrollTimer = nil
        end

        return true
    end
end)

overrideScrollMouseDrag = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDragged }, function(e)
    if mouseScrollDragPosX == nil or mouseScrollDragPosY == nil then
        return true
    end

    mouseScrollDragPosX = mouseScrollDragPosX + e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
    mouseScrollDragPosY = mouseScrollDragPosY + e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])

    return true
end)

function mouseScrollTimerFunction()
    xDiff = math.abs(mouseScrollDragPosX - mouseScrollStartPos.x)
    yDiff = math.abs(mouseScrollDragPosY - mouseScrollStartPos.y)

    r = 10

    if mouseScrollCircle == nil and (xDiff > mouseScrollCircleDeadZone or yDiff > mouseScrollCircleDeadZone) then
        mouseScrollCircle = hs.drawing.circle(hs.geometry.rect(mouseScrollStartPos.x - r, mouseScrollStartPos.y - r,
            r * 2, r * 2))
        mouseScrollCircle:setStrokeColor({ ["red"] = 0.3,["green"] = 0.3,["blue"] = 0.3,["alpha"] = 0.5 })
        mouseScrollCircle:setFillColor({ ["red"] = 0.8,["green"] = 0.8,["blue"] = 0.8,["alpha"] = 0.5 })
        mouseScrollCircle:setFill(true)
        mouseScrollCircle:setStrokeWidth(1)
        mouseScrollCircle:show()
    end

    if xDiff > r or yDiff > r then
        deltaX = mouseScrollDragPosX - mouseScrollStartPos.x
        deltaY = mouseScrollDragPosY - mouseScrollStartPos.y

        deltaX = deltaX / 12
        deltaY = deltaY / 12

        deltaXDirMod = 1
        deltaYDirMod = 1

        if deltaX < 0 then
            deltaXDirMod = -1
        end
        if deltaY < 0 then
            deltaYDirMod = -1
        end

        deltaX = deltaX * deltaX * deltaXDirMod
        deltaY = deltaY * deltaY * deltaYDirMod


        function round(x)
            return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
        end

        deltaX = round(deltaX)
        deltaY = round(deltaY)

        hs.eventtap.event.newScrollEvent({ deltaX, deltaY }, {}, 'pixel'):post()
    end

    mouseScrollTimer = hs.timer.doAfter(0.01, mouseScrollTimerFunction)
end

-- local xyzzy = hs.hotkey.bind({}, "f13",


-- local xyzzy = hs.hotkey.bind({ "shift", "cmd" }, {},
--     function()
--         local lay = hs.keycodes.currentLayout()
--         if lay == "ABC" then
--             hs.keycodes.setLayout("Hungarian")
--             hs.alert.show("Hungarian")
--         else
--             hs.keycodes.setLayout("ABC")
--             hs.alert.show("ABC")
--         end
--     end
-- )


e = hs.eventtap.new({
        hs.eventtap.event.types.flagsChanged,
        hs.eventtap.event.types.keyUp,
        hs.eventtap.event.types.keyDown }, function(ev)
        -- synthesized events set 0x20000000 and we may or may not get the nonCoalesced bit,
        -- so filter them out
        local rawFlags = ev:getRawEventData().CGEventData.flags & 0xdffffeff
        local regularFlags = ev:getFlags()

        -- uncomment this out when troubleshooting -- apparently different modifiers use
        -- different flags indicating left vs right: e.g.
        --     {
        --       cmd = true
        --     }    1048584
        --     {}   0
        --     {
        --       cmd = true
        --     }    1048592        // right
        --     {}   0
        --
        --     {
        --       shift = true
        --     }    131076         // right
        --     {}   0
        --     {
        --       shift = true
        --     }    131074
        --     {}   0

        --
        --
        --
        --
        --print(rawFlags)

        if rawFlags == 1179658 then --lcmd + lshift
            -- do what the right cmd key is supposed to do
            -- may want to check ev:getType() to see if this was just the modifier (flagsChanged)
            -- or a command key sequence (keyDown/keyUp)


            local lay = hs.keycodes.currentLayout()
            if lay == "ABC" then
                hs.keycodes.setLayout("Hungarian")
                hs.alert.show("Hungarian")
            else
                hs.keycodes.setLayout("ABC")
                hs.alert.show("ABC")
            end

            -- if you want to replace it with a different modifier, you'd do something like:
            -- local newEvent = hs.eventtap.event.newEvent(....)....
            -- return true, { newEvent }
        end
    end):start()


overrideScrollMouseDown:start()
overrideScrollMouseUp:start()
overrideScrollMouseDrag:start()
