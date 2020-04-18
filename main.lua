Gamestate = require "hump.gamestate"

require "game"

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(game)

  love.window.setTitle("Ludum Dare 46 - tomaisthorpe")
end

function setupWindow()
  love.window.setMode(800, 600)
end
