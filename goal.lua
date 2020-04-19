Class = require "hump.class"

local Goal = Class{
  init = function(self, world, x, y)
    self.object = world:newRectangleCollider(x - 16, y - 16, 16, 16)
    self.object:setCollisionClass('Goal')
    self.object:setFixedRotation(true)
    self.object:setObject(self)

    self.timer = 0
    self.frame = 0

    self.image = love.graphics.newImage('assets/battery.png')
  end,
  fps = 10,
}

function Goal:update(dt)
    self.timer = self.timer + dt

    if self.timer > 1 / self.fps then
        self.frame = self.frame + 1

        if self.frame > 4 then self.frame = 0 end
        self.timer = 0 
    end
end

function Goal:draw()
    love.graphics.setColorMask()
    love.graphics.setColor(255, 255, 255)
    quad = love.graphics.newQuad(self.frame * 16, 0, 16, 16, self.image:getWidth(), self.image:getHeight())
    love.graphics.draw(self.image, quad, self.object:getX() + 8, self.object:getY() + 8, 0, 1, 1, 16, 16)
end

return Goal
