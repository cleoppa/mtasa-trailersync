Physics.distancelist = {}

function Physics.prototype.setupDistance(self)

end

function Physics.prototype.calculateDistance(self, element1, element2)
    return getDistanceBetweenPoints3D(element1.position, element2.position)
end

function Physics.prototype.isElementInInside(self, point, box)
    return (point.position.x >= box.minX and point.position.x <= box.maxX) and
           (point.position.y >= box.minY and point.position.y <= box.maxY) and
           (point.position.z >= box.minZ and point.position.z <= box.maxZ)
end