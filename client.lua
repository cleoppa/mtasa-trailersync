Physics = new("physics")

-- Physics
-- - cars
-- - trailers
-- - utils


function Physics.prototype.____constructor(self)
    self.smoothlist = {}
    self.vehicleNodes = {}
    self.trailers = {}
    self.updateTrailerCaches = {}

    if exports.irp_integration:isPlayerDeveloper(localPlayer) then
    --self:setupSmooth()
    --self:setupDistance()
    self:setupTrailer()
    end
end


addEventHandler("onClientResourceStart", resourceRoot,
    function()
        Physics = load(Physics)
    end
)