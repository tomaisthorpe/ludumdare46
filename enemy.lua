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
    self.direction = love.math.random(0, 1) * 2 - 1
    self.startX = x
    self.patrolling = true

    self.image = love.graphics.newImage("assets/enemy.png")
    self.timer = 0
    self.frame = 0
  end,
  speed = 200,
  health = 50,
  time = love.timer.getTime(),
  fps = 10,
}

function Enemy:getX()
  return self.object:getX()
end

function Enemy:getY()
  return self.object:getY()
end

function Enemy:update(dt)
  self.timer = self.timer + dt

  if self.timer > 1 / self.fps then
    self.frame = self.frame + 1

    if self.frame > 4 then self.frame = 0 end
    self.timer = 0
  end

  if self.dead ~= true then
    -- Check if the enemy can see the player
    local x, y, px, py = self:getX(), self:getY(), self.level.player:getX(), self.level.player:getY()
    local colliders = self.world:queryLine(x, y, px, py, {'Solid'})
    if #colliders == 0 then
      -- Check angle is okay
      local angle = math.atan2(math.abs(x-px),math.abs(y-py)) - math.pi / 2
      local distance = math.sqrt(math.pow(x - px, 2) + math.pow(y - py, 2))

      if math.abs(angle) < 0.2 and distance < 200 then
        if love.timer.getTime() - self.time > 0.75 then
          if px - x < 0 then
            self.direction = -1
          else
            self.direction = 1
          end

          self.patrolling = false
          self:shoot()
          self.time = love.timer.getTime()
        end
      end
    end

    -- If enemy is partrolling then move them
    if self.patrolling then
      local diff = self:getX() - self.startX
      if self.direction == -1 then
        if diff < -20 then
          self.direction = 1
        end
      else
        if self.direction == 1 then
          if diff > 20 then
            self.direction = -1
          end
        end
      end

      self.object:applyForce(self.direction * self.speed * self.object:getMass(), 0)
    end
  end
end

function Enemy:shoot()
  local vx, vy = self.object:getLinearVelocity()
  local bullet = Bullet(self.world, self.object:getX(), self.object:getY(), vx, vy, self.direction, {
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

  quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, self.image:getWidth(), self.image:getHeight())
  love.graphics.draw(self.image, quad, self.object:getX() + 16 * self.direction, self.object:getY() + 16, 0, self.direction, 1, 32, 32)
end

function Enemy:destroy()
  self.object:destroy()
  self.dead = true
end

return Enemy
