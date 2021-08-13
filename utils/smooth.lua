
function Physics.prototype.renderSmooth(delta)
    local self = self or Physics
    local nowTick = getTickCount()

    for key, data in pairs(self.smoothlist) do
        local startCount = data[3]
        local state = data[4]
        local duration = 500--data[6] or 2000
        local x, y, z = data[1][1], data[1][2], data[1][3]
        local x2, y2, z2 = data[2][1], data[2][2], data[2][3]

        if state == "start" then
            local elapsedTime = nowTick - startCount
            local duration = (startCount + duration) - startCount
            local progress = elapsedTime / duration

            local newX, newY, newZ = interpolateBetween(
                x, y, z,
                x2, y2, z2,
                progress,
                "Linear"
            )
            
            self.smoothlist[key][5] = {newX, newY, newZ}

            if newX >= x2 and newY >= y2 and newZ >= z2 then
                self.smoothlist[key][4] = "end"
            end
        elseif state == "end" then
            
        end
    end

    dxDrawText("smooth debug: "..toJSON(self.smoothlist), 30, 400, 200, 25, tocolor(255, 255, 255, 255 / 2), 1, "default")
end

function Physics.prototype.removeSmooth(self, key)
    self.smoothlist[key] = nil
    collectgarbage("collect")
    return
end

function Physics.prototype.smooth(self, key, from, to, duration)
    assert(from, "Please use {x, y, z} for first arg.")
    assert(to, "Please use {x, y, z} for second arg.")

    if not self.smoothlist[key] then
        self.smoothlist[key] = {from, to, getTickCount(), "start", from, duration}
    end

    return self.smoothlist[key][5][1], self.smoothlist[key][5][2], self.smoothlist[key][5][3], self.smoothlist[key][4]
end

function Physics.prototype.setupSmooth(self)
    addEventHandler("onClientPreRender", root, self.renderSmooth)
end