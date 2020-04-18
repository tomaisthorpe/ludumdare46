local Class = require 'hump.class'

local Bullet =  Class{
  init = function(self, world, x, y, vx, vy, direction)
    self.object = world:newCircleCollider(x, y, 2)
    self.object:setLinearVelocity(vx, vy)
    self.object:setCollisionClass('Bullet')

    self.object:applyLinearImpulse(1000 * direction * self.object:getMass(), 0)
  end,
  dead = false,
  damage = 40
}

function Bullet:update(dt)
  if self.object:enter('Solid') then
    self:destroy()
  end

  if self.object:enter('Enemy') then
    local collision = self.object:getEnterCollisionData('Enemy')
    local enemy = collision.collider:getObject()

    enemy:hit(self.damage)

    self:destroy()
  end
end

function Bullet:destroy()
  self.object:destroy()
  self.dead = true
end

function Bullet:draw() 
  love.graphics.setColor(0, 1, 0)
  love.graphics.circle('fill', self.object:getX(), self.object:getY(), 2)
end

return Bullet
