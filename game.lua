local wf = require 'windfield'
local Camera = require 'hump.camera'

local conf = require 'conf'
local Level = require 'level'
local Player = require 'player'
local test = require 'maps.test'

game = {
  translate = {0, 0},
  scaling = 1,
  player = {},
}

function game:calculateScaling()
  -- Work out the scaling factor
  local minEdge = love.graphics.getHeight()
  if minEdge < love.graphics.getWidth() then
    game.scaling = minEdge / 600
     game.translate = {(love.graphics.getWidth() - (800 * game.scaling)) / 2, 0}
  else
    game.scaling = love.graphics.getWidth() / 800
  end

  camera:zoom(game.scaling)
end

function game:init()
  -- Window setup
  love.graphics.setDefaultFilter("nearest", "nearest")
  -- TODO ENABLE THIS
  love.window.setFullscreen(true)

  -- Create the world
  love.physics.setMeter(64)
  world = wf.newWorld(0, 9.81 * 64, true)
  world:addCollisionClass('Platform')
  world:addCollisionClass('Player')
  
  ground = world:newRectangleCollider(100, 500, 600, 50)
  ground:setType('static')

  platform = world:newRectangleCollider(350, 400, 100, 20)
  platform:setType('static')
  platform:setCollisionClass('Platform')

  game.player = Player(world)

  camera = Camera(game.player:getX(), game.player:getY())

  game:calculateScaling()

  level = Level(world, test)
end

function game:resize()
  love.window.setMode(800, 600)
  game:calculateScaling()
end

function game:keypressed(key)
  -- TODO we have double jump atm
  if key == 'space' then
    player:applyLinearImpulse(0, -600)
  end
end

function game:update(dt)
  game.player:update(dt)
  world:update(dt)

  local dx, dy = game.player:getX() - camera.x, game.player:getY() - camera.y
  camera:move(dx/2, dy/2)
end

function game:draw()
  love.graphics.push()
  love.graphics.translate(game.translate[1], game.translate[2])
  love.graphics.scale(game.scaling)

  -- TODO remove when done
  -- This is for debug to show any problem areas
  love.graphics.setColor(1, 0, 0)
  love.graphics.polygon("fill", 0, 0, 800, 0, 800, 600, 0, 600)

  love.graphics.pop()

  camera:attach()
  level:draw()
  game.player:draw()
  camera:detach()

  -- Draw borders
  love.graphics.setColor(conf.borderColor[1], conf.borderColor[2], conf.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), game.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - game.translate[1], 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - game.translate[2], love.graphics.getWidth(), game.translate[2])
end
