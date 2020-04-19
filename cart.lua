Class = require "hump.class"

local Cart = Class{
  init = function(self, x, y)
    self.x = x
    self.y = y
    self.timer = 0
    self.frame = 0

    self.image = love.graphics.newImage('assets/cart.png')
  end,
  fps = 10,
}

function Cart:update(dt)
    self.timer = self.timer + dt

    if self.timer > 1 / self.fps then
        self.frame = self.frame + 1

        if self.frame > 4 then self.frame = 0 end
        self.timer = 0 
    end
end

function Cart:draw()
    love.graphics.setColorMask()
    love.graphics.setColor(255, 255, 255)
    quad = love.graphics.newQuad(self.frame * 96, 0, 96, 64, self.image:getWidth(), self.image:getHeight())
    love.graphics.draw(self.image, quad, self.x + (96 / 2), self.y + 32, 0, 1, 1, 96, 64)
end

return Cart
