wf = require 'windfield'
Camera = require "hump.camera"

player = {}

function love.load()
  love.physics.setMeter(64)
  world = wf.newWorld(0, 9.81 * 64, true)
  world:addCollisionClass('Platform')
  world:addCollisionClass('Player')
  
  ground = world:newRectangleCollider(100, 500, 600, 50)
  ground:setType('static')
  platform = world:newRectangleCollider(350, 400, 100, 20)
  platform:setType('static')
  platform:setCollisionClass('Platform')
  player = world:newRectangleCollider(390, 450, 20, 40)
  player:setCollisionClass('Player')

  joint = world:addJoint('FrictionJoint', ground, player, 400, 490, true)
  joint:setMaxForce(200 * player:getMass())
  joint:setMaxTorque(20 * player:getInertia())

  camera = Camera(player:getX(), player:getY())
end

function love.keypressed(key)
  -- TODO we have double jump atm
  if key == 'space' then
    player:applyLinearImpulse(0, -600)
  end
end

function love.update(dt)
  if love.keyboard.isDown("left") then 
    player:applyForce(-1000, 0)
  end
  if love.keyboard.isDown("right") then 
    player:applyForce(1000, 0)
  end
  world:update(dt)

  -- TODO improve this, doesn't really work
  player:setAngularVelocity(0)

  local dx, dy = player:getX() - camera.x, player:getY() - camera.y
  camera:move(dx/2, dy/2)
end

function love.draw()
  camera:attach()
  world:draw()
  camera:detach()
end
