local Class = require "hump.class"

local Player = Class{
  init = function(self, world) 
    self.object = world:newRectangleCollider(390, 450, 20, 40)
    self.object:setCollisionClass('Player')
    self.object:setFixedRotation(true)
  end
}

function Player:getX()
  return self.object:getX()
end

function Player:getY()
  return self.object:getY()
end

function Player:update(dt)
  if love.keyboard.isDown("left") then 
    self.object:applyForce(-1000, 0)
  end
  if love.keyboard.isDown("right") then 
    self.object:applyForce(1000, 0)
  end
end

function Player:draw()
  love.graphics.setColor(0, 0, 1)
  love.graphics.rectangle("fill", self:getX() - 10, self:getY() - 20, 20, 40)
end

return Player
