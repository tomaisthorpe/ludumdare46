local Class = require 'hump.class'

local Bullet = require 'bullet'

local Enemy = Class{
  init = function(self, level, world, x, y)
    self.world = world
    self.level = level
    self.object = world:newRectangleCollider(x-16, y-16, 32, 32)
    self.object:setCollisionClass('Enemy')
    self.object:setFixedRotation(true)
    self.object:setObject(self)
    self.direction = -1

    self.image = love.graphics.newImage("assets/enemy.png")
  end,
  speed = 400,
  health = 100,
  time = love.timer.getTime(),
}

function Enemy:getX()
  return self.object:getX()
end

function Enemy:getY()
  return self.object:getY()
end

function Enemy:update(dt)
  if love.timer.getTime() - self.time > 2 then
    self:shoot()
    self.time = love.timer.getTime()
  end
end

function Enemy:shoot()
  local vx, vy = self.object:getLinearVelocity()
  local bullet = Bullet(self.world, self.object:getX(), self.object:getY(), vx, vy, -1, {
    isEnemy = true,
  })

  self.level:addEntity(bullet)
end

function Enemy:hit(damage)
  self.health = self.health - damage

  if self.health < 0 then
    self:destroy()
  end
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.image, self:getX() - 16 * self.direction, self:getY() - 16, 0, self.direction, 1)
end

function Enemy:destroy()
  self.object:destroy()
  self.dead = true
end

return Enemy
