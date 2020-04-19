Gamestate = require "hump.gamestate"

require "game"
require "menu"

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(menu)

  love.window.setTitle("Ludum Dare 46 - You can shoot!")
end

function setupWindow()
  love.window.setMode(800, 600)
end
