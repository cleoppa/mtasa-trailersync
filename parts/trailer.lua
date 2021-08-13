function Physics.prototype.calculateNodes(self, vehicle, startX, startY, startZ)
    if not isElement(vehicle) then return end
    if vehicle:getData("dbid") ~= 52813 then return end
    local nodes = self.vehicleNodes[vehicle]

    local posX, posY, posZ = getElementPosition(vehicle)
    local rotationX, rotationY, rotationZ = getElementRotation(vehicle)

    if not startX then
        startX, startY, startZ = getVehicleComponentPosition(vehicle, "bump_rear_dummy", "world")
        startX = startX + ( ( math.cos ( math.rad (  rotationZ ) ) ) * 1 )
        startY = startY + ( ( math.sin ( math.rad (  rotationZ ) ) ) * 1 )

        endX, endY, endZ = getVehicleComponentPosition(vehicle, "bump_front_dummy", "world")
    else
        endX, endY, endZ = getVehicleComponentPosition(vehicle, "bump_rear_dummy", "world")
    end

    if not startX then return end

    endX = endX + ( ( math.cos ( math.rad (  rotationZ ) ) ) * 1 )
    endY = endY + ( ( math.sin ( math.rad (  rotationZ ) ) ) * 1 )

    if #self.vehicleNodes[vehicle] >= 50 then
        table.remove(self.vehicleNodes[vehicle], 1)
    end
    if not self.trailers[vehicle] then
        self.trailers[vehicle] = createVehicle(611, vehicle.position)
        
        self.updateTrailerCaches[vehicle] = 1
        self.trailers[vehicle]:setFrozen(true)
        self.trailers[vehicle]:setCollisionsEnabled(false)
        self.trailers[vehicle]:setData("trailer_first_pos", {startX, startY, startZ}, false)

        --local ped = createPed(0, vehicle.position)
        --local warp = ped:warpIntoVehicle(self.trailers[vehicle])
        --setPedControlState(ped, "accelerate", true)
    end
    table.insert(self.vehicleNodes[vehicle], {startPos = {startX, startY, startZ}, endPos = {endX, endY, endZ}, rotation = {rotationX, rotationY, rotationZ}})
end

function Physics.prototype.updateTrailers()
    local self = self or Physics

    local nearbyVehicles = self:nearbyVehicles()
    
    for index, vehicle in ipairs(nearbyVehicles) do
        if not self.vehicleNodes[vehicle] then
            self.vehicleNodes[vehicle] = {}
            self:calculateNodes(vehicle)
        end

        if not self.updateTrailerCaches[vehicle] then
            self.updateTrailerCaches[vehicle] = 0
        end

        local nodes = self.vehicleNodes[vehicle]
        local lastNode = nodes[#nodes]
        --local vehicleRotationX, vehicleRotationY, vehicleRotationZ = getElementRotation(vehicle)
        local endX, endY, endZ = getVehicleComponentPosition(vehicle, "bump_rear_dummy", "world")
        if lastNode then
            if getDistanceBetweenPoints3D(endX, endY, endZ, lastNode.endPos[1], lastNode.endPos[2], lastNode.endPos[3]) >= 0.2 then
                self:calculateNodes(vehicle, lastNode.endPos[1], lastNode.endPos[2], lastNode.endPos[3])
            end
            if self.trailers[vehicle] then

                local childNote = nodes[40]--nodes[self.updateTrailerCaches[vehicle]]
                local childRotNote = nodes[1]
                if childNote and childRotNote then
                    --[[
                    local name = "trailer-"..(vehicle:getData("dbid") or 1).."-"..self.updateTrailerCaches[vehicle]
                    local oldX, oldY, oldZ = unpack(self.trailers[vehicle]:getData("trailer_first_pos"))
                    local animateX, animateY, animateZ, status = self:smooth(name, {oldX, oldY, oldZ}, childNote.endPos, 50)
                    if status == "end" then
                        print("Update to "..self.updateTrailerCaches[vehicle])
                        
                        self.trailers[vehicle]:setData("trailer_first_pos", childNote.endPos)
                        self:removeSmooth(name)
                        self.updateTrailerCaches[vehicle] = self.updateTrailerCaches[vehicle] + 1
                    end
                    ]]--
                    local rotationX, rotationY, rotationZ = childRotNote.rotation[1], childRotNote.rotation[2], childRotNote.rotation[3]
                    local animateX, animateY, animateZ = childNote.endPos[1], childNote.endPos[2], childNote.endPos[3]
                    local distance = getDistanceBetweenPoints3D(self.trailers[vehicle].position, vehicle.position)

                    local animateX, animateY, animateZ = getVehicleComponentPosition(vehicle, "bump_rear_dummy", "world")
                    --if distance >= 3 then
                    setElementRotation(self.trailers[vehicle], rotationX, rotationY, rotationZ)
                    --end
              
                    local animateX = animateX + ( ( math.cos ( math.rad (  rotationZ ) ) ) * 5 )
                    --local animateY = animateY + ( ( math.sin ( math.rad (  rotationZ ) ) ) * 5 )
                    self.trailers[vehicle]:setPosition(animateX, animateY, animateZ + 0.30)
                end
            end
        end

        for index, value in ipairs(nodes) do
            if not value.startPos or not value.endPos then break end
            dxDrawLine3D(value.startPos[1], value.startPos[2], value.startPos[3], value.endPos[1], value.endPos[2], value.endPos[3], tocolor(255, 0, 0), 2)
        end
    end
end

function Physics.prototype.setupTrailer(self)
    self.nearbyVehicles = function()
        return getElementsWithinRange(localPlayer.position, 30, "vehicle")
    end

    addEventHandler("onClientPreRender", root, self.updateTrailers)
end