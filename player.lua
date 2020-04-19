local Class = require 'hump.class'

local Bullet = require 'bullet'
local Shell = require 'shell'

local Player = Class{
  init = function(self, level, world, x, y)
    self.world = world
    self.level = level
    self.object = world:newRectangleCollider(x - 16, y - 32, 32, 32)
    self.object:setCollisionClass('Player')
    self.object:setFixedRotation(true)
    self.object:setObject(self)

    self.object:setLinearDamping(1)
    self.image = love.graphics.newImage("assets/player.png")

    self.sensor = world:newRectangleCollider(x - 15, y, 30, 4)
    self.sensor:setFixedRotation(true)
    local joint =  world:addJoint('RevoluteJoint', self.object, self.sensor, x, y - 2, false)

    self.sensor:setPreSolve(function(c1, c2, contact)
      contact:setEnabled(false)
    end)


  end,
  speed = 300,
  jumpForce = -270,
  fireRate = 0.2,
  direction = 1,
  health = 100,

  lastShoot = 0,
  canJump = true
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

  if self.sensor:enter('Solid') then
    self.canJump = true
  end

  if self.sensor:exit('Solid') then
    self.canJump = false
  end

  if love.keyboard.isDown('space') or love.keyboard.isDown('up') then
    if self.canJump then
      self.object:applyLinearImpulse(0, self.jumpForce * (self.object:getMass() + self.sensor:getMass()))
      self.canJump = false
    end
  end

  -- If key is down, check if we can shoot
  if love.keyboard.isDown('z') then
    if self.lastShoot < love.timer.getTime() - self.fireRate then
      self.lastShoot = love.timer.getTime()
      self:shoot()
    end
  end
end

function Player:shoot()
  local vx, vy = self.object:getLinearVelocity()

  local bullet = Bullet(self.world, self:getX() + 14 * self.direction, self:getY(), vx, vy, self.direction)
  self.level:addEntity(bullet)

  local shell = Shell(self.world, self:getX() + 0 * self.direction, self:getY(), vx, vy, self.direction)
  self.level:addEntity(shell)
end

function Player:hit(damage)
  self.health = self.health - damage

  if self.health <= 0 then
    self.health = 0
    self.level:onplayerdeath()
  end
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.image, self:getX() - 16 * self.direction, self:getY() - 16, 0, self.direction, 1)
end

return Player
