local Class = require 'hump.class'

local Shell =  Class{
  init = function(self, world, x, y, vx, vy, direction, flags)
    flags = flags or {}
    self.object = world:newCircleCollider(x, y, 2)
    self.object:setLinearVelocity(vx, vy)
    self.object:setCollisionClass('Particle')
    self.object:setRestitution(0.3)

    self.object:applyLinearImpulse(100 * direction * self.object:getMass(), 20 * self.object:getMass())
    self.lifetime = 0.75

    self.easing = love.math.newBezierCurve(0, 1, 1.293, 1, 0.935, 0.733, 1, -2.046)
  end,
  dead = false,
  damage = 20,
}

function Shell:update(dt)
  self.lifetime = self.lifetime - dt
  if self.lifetime < 0 then
    self.lifetime = 0
    self:destroy()
  end
end

function Shell:destroy()
  self.object:destroy()
  self.dead = true
end

function Shell:draw()
  local opacity = self.easing:evaluate(self.lifetime / 0.75)
  love.graphics.setColor(205 / 250, 127 / 255, 50 / 255, opacity)
  love.graphics.rectangle('fill', self.object:getX(), self.object:getY(), 2, 2)
end

return Shell
