local Class = require 'hump.class'

local Bullet =  Class{
  init = function(self, world, x, y, vx, vy, direction, flags)
    flags = flags or {}
    self.object = world:newCircleCollider(x, y, 2)
    self.object:setLinearVelocity(vx, vy)
    self.object:setBullet(true)

    if flags.isEnemy then
      self.targetClass = 'Player'
      self.object:setCollisionClass('EnemyBullet')
    else
      self.targetClass = 'Enemy'
      self.object:setCollisionClass('Bullet')
    end

    self.object:applyLinearImpulse(1000 * direction * self.object:getMass(), 0)
  end,
  dead = false,
  damage = 20
}

function Bullet:update(dt)
  if self.object:enter('Solid') then
    self:destroy()
  end

  if self.object:enter(self.targetClass) then
    local collision = self.object:getEnterCollisionData(self.targetClass)
    local object = collision.collider:getObject()

    object:hit(self.damage)

    self:destroy()
  end
end

function Bullet:destroy()
  self.object:destroy()
  self.dead = true
end

function Bullet:draw()
  love.graphics.setColor(1, 142 / 255, 0)
  love.graphics.rectangle('fill', self.object:getX(), self.object:getY(), 4, 3)

  love.graphics.setColor(1, 100 / 255, 0)
  love.graphics.rectangle('fill', self.object:getX(), self.object:getY()+2, 4, 1)
end

return Bullet
