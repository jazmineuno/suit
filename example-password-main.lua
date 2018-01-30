-- suit up
local suit = require 'suit'

-- storage for text input
local username = {text = ""}
local password = {text = ""}

-- make love use font which support CJK text
function love.load()
    local font = love.graphics.newFont("NotoSansHans-Regular.otf", 20)
    love.graphics.setFont(font)
    love.keyboard.setKeyRepeat(true)
end

-- all the UI is defined in love.update or functions that are called from here
function love.update(dt)
	-- put the layout origin at position (100,100)
	-- the layout will grow down and to the right from this point
	suit.layout:reset(100,100)

	-- put an input widget at the layout origin, with a cell size of 200 by 30 pixels
	suit.Label("Email Address", {align = "left"}, suit.layout:row(300,30))
	suit.Input(username, suit.layout:row(300,30))
	suit.Label("Password", {align = "left"}, suit.layout:row())
	suit.Password(password, suit.layout:row(300,30))
	suit.layout:row()

	-- put a label that displays the text below the first cell
	-- the cell size is the same as the last one (200x30 px)
	-- the label text will be aligned to the left

	-- put an empty cell that has the same size as the last cell (200x30 px)

	-- put a button of size 200x30 px in the cell below
	-- if the button is pressed, quit the game
	if suit.Button("Submit", suit.layout:row()).hit then
		love.window.showMessageBox("Your Entered","email: " .. username.text .. " password: " .. password.text)
		love.event.quit()
	end
end

function love.draw()
	-- draw the gui
	suit.draw()
end

function love.textedited(text, start, length)
    -- for IME input
    suit.textedited(text, start, length)
end

function love.textinput(t)
	-- forward text input to SUIT
	suit.textinput(t)
end

function love.keypressed(key)
	-- forward keypresses to SUIT
	suit.keypressed(key)
end
