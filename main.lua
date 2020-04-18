wf = require 'windfield'

player = {}

function love.load()
  world = wf.newWorld(0, 512, true)
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
end

function love.keypressed(key)
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

    player:setAngularVelocity(0)

  print(joint:getReactionForce(dt), joint:getReactionTorque(dt))
end

function love.draw()
  world:draw()
end
