local conf = require 'conf'
local Level = require 'level'
local level1 = require 'maps.level1'

game = {
  translate = {0, 0},
  scaling = 1,
  levelData = {
    level1,
  },
  level = {},
  levelIndex = 0,
  font = {},
  titleFont = {},
  lives = 1,
  isGameOver = false,
  isGameCompleted = false,
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

  game.font = love.graphics.newFont( "assets/veramono.ttf", 10)
  game.font:setFilter( "nearest", "nearest" )

  game.titleFont = love.graphics.newFont( "assets/veramono.ttf", 30)
  game.titleFont:setFilter( "nearest", "nearest" )

  game.images = {
    heart = love.graphics.newImage("assets/heart.png"),
  }

  -- Create the world
  game:calculateScaling()
end

function game:enter()
  self:loadLevel(1)
end

function game:loadLevel(index)
  self.levelIndex = index
  self.level = Level(self, self.levelData[index])
end

function game:resize()
  love.window.setMode(800, 600)
  game:calculateScaling()
end

function game:keypressed(key)
  if key == "escape" then
    love.event.quit()
  end

  if key == "space" and (self.isGameOver or self.isGameCompleted) then
    love.event.quit()
  end
end

function game:onlevelcomplete()
  if self.levelIndex == #self.levelData then
    self.isGameCompleted = true
  else
    self:loadLevel(self.levelIndex + 1)
  end
end

function game:onplayerdeath()
  self.lives = self.lives - 1
  if self.lives == 0 then
    self:gameOver()
  else
    self:loadLevel(self.levelIndex)
  end
end

function game:ontimeout()
  self.lives = self.lives - 1
  if self.lives == 0 then
    self:gameOver()
  else
    self:loadLevel(self.levelIndex)
  end
end

function game:gameOver()
  self.isGameOver = true
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
  love.graphics.setColor(199 / 255, 125 / 255, 139 / 255)
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

  self:drawUI()
end

function game:drawUI()
  local data = self.level:getUIData()

  love.graphics.push()
  love.graphics.translate(game.translate[1], game.translate[2])
  love.graphics.scale(game.scaling)

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(game.font)

  for l=1, self.lives, 1 do 
    love.graphics.draw(self.images.heart, 800 - 40 * l, 16 + conf.healthHeight)
  end

  -- Draw health bar
  love.graphics.push()
  love.graphics.translate(800 - conf.healthWidth - 8, 8)
  love.graphics.setColor(conf.healthBorderColor)
  love.graphics.setLineWidth(conf.healthBorderWidth)
  love.graphics.rectangle("line", 0, 0, conf.healthWidth, conf.healthHeight)

  love.graphics.setColor(conf.healthColor)
  love.graphics.rectangle("fill", conf.healthBorderWidth * 2, conf.healthBorderWidth * 2, (conf.healthWidth - conf.healthBorderWidth * 4) * (data.playerHealth / 100), conf.healthHeight - conf.healthBorderWidth * 4)
  love.graphics.pop()

  -- Draw power bar
  love.graphics.push()
  love.graphics.translate(8, 8)
  love.graphics.setColor(conf.powerBorderColor)
  love.graphics.setLineWidth(conf.powerBorderWidth)
  love.graphics.rectangle("line", 0, 0, conf.powerWidth, conf.powerHeight)

  love.graphics.setColor(conf.powerColor)
  love.graphics.rectangle("fill", conf.powerBorderWidth * 2, conf.powerBorderWidth * 2, (conf.powerWidth - conf.powerBorderWidth * 4) * data.timeLeftPercentage, conf.powerHeight - conf.powerBorderWidth * 4)

  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.print("POWER", 0, 1 + conf.powerHeight)
  love.graphics.pop()


  -- Positition transform for gameover and game completed
  love.graphics.push()
  love.graphics.translate(0, 250)
  -- If we're in the game over state, then display the game over message
  if self.isGameOver then
    love.graphics.setFont(game.titleFont)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("GAME OVER!", 0, 2, 800, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME OVER!", 0, 0, 800, "center")
  end

  if self.isGameCompleted then
    love.graphics.setFont(game.titleFont)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("GAME COMPLETED!", 0, 2, 800, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("GAME COMPLETED!", 0, 0, 800, "center")
  end

  if self.isGameOver or self.isGameCompleted then
    love.graphics.setFont(game.font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Thanks for playing!", 0, 35, 800, "center")

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Press space to quit.", 0, 45, 800, "center")

  end
    love.graphics.pop()
  love.graphics.pop()
end
