Class = require "hump.class"

local Level = Class{
  init = function(self, world, data)
    self.world = world
    self.data = data
    self.canvas = love.graphics.newCanvas(data.width * 32, data.height * 32)

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
  end,
  tileSize = 32
}

function Level:updateCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.setColorMask()
  love.graphics.setColor(255, 255, 255)

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
          local row = math.floor(t / 40) - 1

          love.graphics.draw(self.tiles[tile].image, self.tiles[tile].quad, col * 32, row * 32)
        end
      end
      love.graphics.pop()
    end
  end

  love.graphics.setCanvas()
end

function Level:draw() 
  love.graphics.setColorMask()
  love.graphics.setColor(255, 255, 255)

  love.graphics.draw(self.canvas, 0, 0)
end


return Level
