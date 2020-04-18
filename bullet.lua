local Class = require 'hump.class'

local Bullet =  Class{
  init = function(self, world, x, y, vx, vy)
    self.object = world:newCircleCollider(x, y, 2)
    self.object:setLinearVelocity(vx, vy)
    self.object:setCollisionClass('Bullet')

    local direction  = 1
    if vx < 0 then
      direction = -1
    end

    self.object:applyLinearImpulse(1000 * direction * self.object:getMass(), 0)
  end,
  dead = false
}

function Bullet:update(dt)
  if self.object:enter('Solid') then
    self.object:destroy()
    self.dead = true
  end
end

function Bullet:draw() 
  love.graphics.setColor(0, 1, 0)
  love.graphics.circle('fill', self.object:getX(), self.object:getY(), 2)
end

return Bullet
