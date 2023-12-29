--[[
    GD50
    -- Super Mario Bros. Remake --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Platform = Class{}

function Platform:init(x, y, width, height)
    self.x = x
    self.y = y

    self.width = width
    self.height = height
end

function Platform:render()
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end