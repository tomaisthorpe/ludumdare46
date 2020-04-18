local wf = require 'windfield'
local Class = require 'hump.class'
local Camera = require 'hump.camera'

local Player = require 'player'
local Enemy = require 'enemy'

local Level = Class{
  init = function(self, game, data)
    self.game = game
    self.data = data
    self.canvas = love.graphics.newCanvas(data.width * 32, data.height * 32)


    -- Create the world for physics
    love.physics.setMeter(32)
    self.world = wf.newWorld(0, 9.81 * 32, true)
    self.world:addCollisionClass('Solid')
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Enemy')
    self.world:addCollisionClass('Bullet', {ignores = {'Player'}})
    self.world:addCollisionClass('Goal', {ignores = {'Player'}})

    -- Create the player
    self.player = Player(self.world)

    -- Entities contains all objects apart from the player
    self.entities = {}

    -- Create the camera defaulting to player position
    self.camera = Camera(self.player:getX(), self.player:getY())

    -- Load the tiles
    self.tiles = {}

    for t=1, #data.tilesets, 1 do
      -- Load the image
      local image = love.graphics.newImage(data.tilesets[t].image)
      local firstID = data.tilesets[t].firstgid
      local count = data.tilesets[t].tilecount

      for s=1, count, 1 do
        table.insert(self.tiles, {
          image = image,
          quad = love.graphics.newQuad(32 * (s - 1), 0, 32, 32, image.getDimensions(image)),
        })
      end

      table.insert(self.tiles, tileset)
    end

    self:updateCanvas()

    self.colliders = {}
    self:updateColliders()
    self:spawnEntities()
  end,
  tileSize = 32
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
          local enemy = Enemy(self.world, object.x, object.y)
          table.insert(self.entities, enemy)
        end
      end
    end
  end
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
          if  object.properties.isGoal then
            collider:setCollisionClass('Goal')
          else 
            collider:setCollisionClass('Solid')
          end

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

          local col = t % width - 1
          local row = math.floor(t / 40) 

          love.graphics.draw(self.tiles[tile].image, self.tiles[tile].quad, col * 32, row * 32)
        end
      end
      love.graphics.pop()
    end
  end

  love.graphics.setCanvas()
end

function Level:update(dt)
  self.player:update(dt)
  self.world:update(dt)

  if self.player.object:enter('Goal') then
    self.game:onlevelcomplete()
  end

  local dx, dy = self.player:getX() - self.camera.x, self.player:getY() - self.camera.y
  self.camera:move(dx/2, dy/2)
  self.camera:zoomTo(self.game.scaling)

  for e=1, #self.entities, 1 do
    -- TODO need to get rid of dead entities
    if self.entities[e] ~= nil then
      self.entities[e]:update(dt)
      if self.entities[e].dead then
        self.entities[e] = nil
      end
    end
  end
end

function Level:draw() 
  love.graphics.setColorMask()
  love.graphics.setColor(255, 255, 255)

  self.camera:attach()

  love.graphics.draw(self.canvas, 0, 0)
  self.player:draw()

  for e=1, #self.entities, 1 do
    -- TODO need to get rid of dead entities
    if self.entities[e] ~= nil and self.entities[e].dead ~= true then
      self.entities[e]:draw()
    end
  end

  -- Draw physics
  -- self.world:draw()

  self.camera:detach()
end

function Level:keyreleased(key)
  if key == "z" then
    local bullet = self.player:shoot()
    table.insert(self.entities, bullet)
  end
end

return Level
