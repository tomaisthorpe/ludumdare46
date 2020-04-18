local Class = require 'hump.class'

local Bullet = require 'bullet'

local Enemy = Class{
  init = function(self, world, x, y)
    self.world = world
    self.object = world:newRectangleCollider(x-13, y-40, 26, 40)
    self.object:setCollisionClass('Enemy')
    self.object:setFixedRotation(true)

    self.object:setObject(self)
  end,
  speed = 400,
  health = 100
}

function Enemy:getX()
  return self.object:getX()
end

function Enemy:getY()
  return self.object:getY()
end

function Enemy:update(dt)
end

function Enemy:hit(damage)
  self.health = self.health - damage

  if self.health < 0 then
    self:destroy()
  end
end

function Enemy:draw()
  love.graphics.setColor(0, 1, 1)
  love.graphics.rectangle('fill', self:getX() - 13, self:getY() - 20, 26, 40)
end

function Enemy:destroy()
  self.object:destroy()
  self.dead = true
end

return Enemy
