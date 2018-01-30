-- This file is part of SUIT, copyright (c) 2016 Matthias Richter

local BASE = (...):match('(.-)[^%.]+$')
local utf8 = require 'utf8'

local function split(str, pos)
	local offset = utf8.offset(str, pos) or 0
	return str:sub(1, offset-1), str:sub(offset)
end

return function(core, password, ...)
	local opt, x,y,w,h = core.getOptionsAndSize(...)
	opt.id = opt.id or password
	opt.font = opt.font or love.graphics.getFont()

	local text_width = opt.font:getWidth(password.text)
	w = w or text_width + 6
	h = h or opt.font:getHeight() + 4

	password.text = password.text or ""
	password.cursor = math.max(1, math.min(utf8.len(password.text)+1, password.cursor or utf8.len(password.text)+1))
	-- cursor is position *before* the character (including EOS) i.e. in "hello":
	--   position 1: |hello
	--   position 2: h|ello
	--   ...
	--   position 6: hello|

	-- get size of text and cursor position
	opt.cursor_pos = 0
	if password.cursor > 1 then
		local s = password.text:sub(1, utf8.offset(password.text, password.cursor)-1)
		opt.cursor_pos = opt.font:getWidth(s)
	end

	-- compute drawing offset
	local wm = w - 6 -- consider margin
	password.text_draw_offset = password.text_draw_offset or 0
	if opt.cursor_pos - password.text_draw_offset < 0 then
		-- cursor left of password box
		password.text_draw_offset = opt.cursor_pos
	end
	if opt.cursor_pos - password.text_draw_offset > wm then
		-- cursor right of password box
		password.text_draw_offset = opt.cursor_pos - wm
	end
	if text_width - password.text_draw_offset < wm and text_width > wm then
		-- text bigger than password box, but does not fill it
		password.text_draw_offset = text_width - wm
	end

	-- user interaction
	if password.forcefocus ~= nil and password.forcefocus then
		core.active = opt.id
		password.forcefocus = false
	end

	opt.state = core:registerHitbox(opt.id, x,y,w,h)
	opt.hasKeyboardFocus = core:grabKeyboardFocus(opt.id)

	if (core.candidate_text.text == "") and opt.hasKeyboardFocus then
		local keycode,char = core:getPressedKey()
		-- text password
		if char and char ~= "" then
			local a,b = split(password.text, password.cursor)
			password.text = table.concat{a, char, b}
			password.cursor = password.cursor + utf8.len(char)
		end

		-- text editing
		if keycode == 'backspace' then
			local a,b = split(password.text, password.cursor)
			password.text = table.concat{split(a,utf8.len(a)), b}
			password.cursor = math.max(1, password.cursor-1)
		elseif keycode == 'delete' then
			local a,b = split(password.text, password.cursor)
			local _,b = split(b, 2)
			password.text = table.concat{a, b}
		end

		-- cursor movement
		if keycode =='left' then
			password.cursor = math.max(0, password.cursor-1)
		elseif keycode =='right' then -- cursor movement
			password.cursor = math.min(utf8.len(password.text)+1, password.cursor+1)
		elseif keycode =='home' then -- cursor movement
			password.cursor = 1
		elseif keycode =='end' then -- cursor movement
			password.cursor = utf8.len(password.text)+1
		end

		-- move cursor position with mouse when clicked on
		if core:mouseReleasedOn(opt.id) then
			local mx = core:getMousePosition() - x + password.text_draw_offset
			password.cursor = utf8.len(password.text) + 1
			for c = 1,password.cursor do
				local s = password.text:sub(0, utf8.offset(password.text, c)-1)
				if opt.font:getWidth(s) >= mx then
					password.cursor = c-1
					break
				end
			end
		end
	end

	password.candidate_text = {text=core.candidate_text.text, start=core.candidate_text.start, length=core.candidate_text.length}
	core:registerDraw(opt.draw or core.theme.Password, password, opt, x,y,w,h)

	return {
		id = opt.id,
		hit = core:mouseReleasedOn(opt.id),
		submitted = core:keyPressedOn(opt.id, "return"),
		hovered = core:isHovered(opt.id),
		entered = core:isHovered(opt.id) and not core:wasHovered(opt.id),
		left = not core:isHovered(opt.id) and core:wasHovered(opt.id)
	}
end
