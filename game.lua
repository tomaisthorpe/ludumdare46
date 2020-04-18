local conf = require 'conf'
local Level = require 'level'
local test = require 'maps.test'

game = {
  translate = {0, 0},
  scaling = 1,
  level = {},
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
end

function game:init()
  -- Window setup
  love.graphics.setDefaultFilter("nearest", "nearest")
  -- TODO ENABLE THIS
  love.window.setFullscreen(true)

  -- Create the world
  game:calculateScaling()

  self.level = Level(self, test)
end

function game:resize()
  love.window.setMode(800, 600)
  game:calculateScaling()
end

function game:keypressed(key)
  -- TODO we have double jump atm
  if key == 'space' then
    self.level.player.object:applyLinearImpulse(0, -600)
  end
end

function game:update(dt)
  self.level:update(dt)
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

  -- Drawing the level also handles camera and player
  self.level:draw()

  -- Draw borders
  love.graphics.setColor(conf.borderColor[1], conf.borderColor[2], conf.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), game.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - game.translate[1], 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - game.translate[2], love.graphics.getWidth(), game.translate[2])
end
