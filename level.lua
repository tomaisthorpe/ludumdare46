local wf = require 'windfield'
local Class = require 'hump.class'
 Camera = require 'hump.camera'

local Player = require 'player'
local Enemy = require 'enemy'
local Goal = require 'goal'
local Cart = require 'cart'

local Level = Class{
  init = function(self, game, data)
    self.game = game
    self.data = data
    self.canvas = love.graphics.newCanvas(data.width * 16, data.height * 16)

    -- Create the world for physics
    love.physics.setMeter(32)
    self.world = wf.newWorld(0, 9.81 * 32, true)
    self.world:addCollisionClass('Solid')
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Sensor')
    self.world:addCollisionClass('Enemy')
    self.world:addCollisionClass('Bullet', {ignores = {'Player'}})
    self.world:addCollisionClass('EnemyBullet', {ignores = {'Enemy'}})
    self.world:addCollisionClass('Goal', {ignores = {'Player'}})
    self.world:addCollisionClass('Particle', {ignores={'Bullet', 'EnemyBullet', 'Goal', 'Player', 'Enemy'}})

    -- Entities contains all objects apart from the player
    self.entities = {}

    -- Load the tiles
    self.tiles = {}

    for t=1, #data.tilesets, 1 do
      -- Load the image
      local image = love.graphics.newImage(data.tilesets[t].image)
      local firstID = data.tilesets[t].firstgid
      local count = data.tilesets[t].tilecount
      local columns = data.tilesets[t].columns

      for s=1, count, 1 do
        local col = (s - 1) % columns
        local row = math.floor((s - 1) / columns)

        table.insert(self.tiles, {
          image = image,
          quad = love.graphics.newQuad(16 * col, 16 * row, 16, 16, image.getDimensions(image)),
        })
      end

      table.insert(self.tiles, tileset)
    end

    self.colliders = {}
    self:updateColliders()
    self:spawnEntities()
    self.timeLeft = 30

    -- Create the player
    self.player = Player(self, self.world, self.playerStartingPosition.x, self.playerStartingPosition.y + 1)

    -- Create the camera defaulting to player position
    self.camera = Camera(self.player:getX(), self.player:getY())
    self.camera.smoother = Camera.smooth.damped(3)
  end,
  tileSize = 16,
  paused = false,
  hasCanvas = false,
}

function Level:spawnEntities()
  self.entities = {}

  for l=1, #self.data.layers, 1 do
    local layer = self.data.layers[l]
    if layer.properties.isEntities then
      -- Each option refers to a collider
      for o=1, #layer.objects, 1 do
        local object = layer.objects[o]
        if object.type == "enemy" then
          local enemy = Enemy(self, self.world, object.x, object.y)
          self:addEntity(enemy)
        end

        if object.type == "goal" then
          local goal = Goal(self.world, object.x, object.y)
          self:addEntity(goal)
        end

        if object.type == "playerStart" then
          self.playerStartingPosition = {
            x = object.x,
            y = object.y,
          }

          local cart = Cart(object.x - 64, object.y - 32)
          self:addEntity(cart)
        end
      end
    end
  end
end

function Level:addEntity(entity)
  table.insert(self.entities, entity)
end

function Level:updateColliders()
  -- Destory existing coliders
  for c=1, #self.colliders, 1 do
    self.colliders[c]:destroy()
  end

  self.colliders = {}
  for l=1, #self.data.layers, 1 do
    local layer = self.data.layers[l]
    if layer.properties.isCollision then
      -- Each option refers to a collider
      for o=1, #layer.objects, 1 do
        local object = layer.objects[o]
        if object.shape == "rectangle" then
          local collider = self.world:newRectangleCollider(object.x, object.y, object.width, object.height)
          collider:setCollisionClass('Solid')

          collider:setType('static')
          table.insert(self.colliders, collider)
        end
      end
    end
  end
end

function Level:updateCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.setColorMask()
  love.graphics.setColor(1, 1, 1)

  for l=1, #self.data.layers, 1 do
    local layer = self.data.layers[l]

    if layer.type == "tilelayer" then
      local x, y, width = layer.x, layer.y, layer.width

      love.graphics.push()
      love.graphics.translate(x, y)

      for t=1, #layer.data, 1 do
        local tile = layer.data[t]
        if tile > 0 then

          local col = (t - 1) % width 
          local row = math.floor((t - 1) / layer.width)

          love.graphics.draw(self.tiles[tile].image, self.tiles[tile].quad, col * 16, row * 16)
        end
      end
      love.graphics.pop()
    end
  end

  height = self.data.height * 16

  love.graphics.setCanvas()

  self.hasCanvas = true
end

function Level:update(dt)
  if self.paused then
    return
  end
  
  self.timeLeft = self.timeLeft - dt
  if self.timeLeft < 0 then
    self.timeLeft = 0
  end

  -- Check if time is over
  if self.timeLeft == 0 then
    self.paused = true
    self.game:ontimeout()
    return
  end

  self.player:update(dt)
  self.world:update(dt)

  if self.player.object:enter('Goal') then
    self.paused = true
    self.game:onlevelcomplete()
  end

  local dx, dy = self.player:getX() - self.camera.x, self.player:getY() - self.camera.y
  self.camera:zoomTo(self.game.scaling)

  local minX = self.game.translate[1] + 150 * self.game.scaling
  local maxX = self.game.translate[1] + 250 * self.game.scaling
  local minY = self.game.translate[2] + 300 * self.game.scaling
  local maxY = self.game.translate[2] + 400 * self.game.scaling

  if self.player.direction == -1 then
    minX = self.game.translate[1] + 550 * self.game.scaling
    maxX = self.game.translate[1] + 650 * self.game.scaling
  end

  self.camera:lockWindow(self.player:getX(), self.player:getY() - 100, minX, maxX, minY, maxY)

  for e=1, #self.entities, 1 do
    -- TODO need to get rid of dead entities
    if self.entities[e] ~= nil then
      self.entities[e]:update(dt)
      if self.entities[e].dead then
        table.remove(self.entities, e)
      end
    end
  end
end

function Level:draw()
  if self.hasCanvas == false then
    self:updateCanvas()
  end

  love.graphics.setColorMask()
  love.graphics.setColor(255, 255, 255)

  self.camera:attach()

  love.graphics.draw(self.canvas, 0, 0)

  for e=1, #self.entities, 1 do
    -- TODO need to get rid of dead entities
    if self.entities[e] ~= nil and self.entities[e].dead ~= true then
      self.entities[e]:draw()
    end
  end

  self.player:draw()

  -- Draw physics
  -- self.world:draw()

  self.camera:detach()
end

function Level:onplayerdeath()
  self.paused = true

  self.game:onplayerdeath()
end

function Level:getUIData()
  return {
    playerHealth = self.player.health,
    timeLeft = self.timeLeft,
    timeLeftPercentage = self.timeLeft / 30,
  }
end

return Level
