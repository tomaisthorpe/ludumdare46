local Class = require 'hump.class'

local Bullet = require 'bullet'

local Player = Class{
  init = function(self, level, world)
    self.world = world
    self.level = level
    self.object = world:newRectangleCollider(390, 450, 26, 54)
    self.object:setCollisionClass('Player')
    self.object:setFixedRotation(true)
    self.object:setObject(self)
  end,
  speed = 400,
  jumpForce = -270,
  direction = 1,
  health = 100,
}

function Player:getX()
  return self.object:getX()
end

function Player:getY()
  return self.object:getY()
end

function Player:update(dt)
  if love.keyboard.isDown('left') then
    self.object:applyForce(-self.speed * self.object:getMass(), 0)
    self.direction = -1
  end
  if love.keyboard.isDown('right') then
    self.object:applyForce(self.speed * self.object:getMass(), 0)
    self.direction = 1
  end

  if love.keyboard.isDown('space') or love.keyboard.isDown('up') then
    _, y = self.object:getLinearVelocity()
    if y == 0 then
      self.object:applyLinearImpulse(0, self.jumpForce * self.object:getMass())
    end
  end
end

function Player:shoot()
  local vx, vy = self.object:getLinearVelocity()
  local bullet = Bullet(self.world, self:getX(), self:getY(), vx, vy, self.direction)

  self.level:addEntity(bullet)
end

function Player:hit(damage)
  self.health = self.health - damage

  if self.health <= 0 then
    self.health = 0
    self.level:onplayerdeath()
  end
end

function Player:draw()
  love.graphics.setColor(0, 0, 1)
  love.graphics.rectangle('fill', self:getX() - 13, self:getY() - 27, 26, 54)
end

return Player
