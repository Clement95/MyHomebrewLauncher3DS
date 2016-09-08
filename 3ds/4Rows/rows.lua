board = {}

empty = Screen.loadImage(System.currentDirectory().."/empty.png")
red = Screen.loadImage(System.currentDirectory().."/red.png")
blue = Screen.loadImage(System.currentDirectory().."/blue.png")
title = Screen.loadImage(System.currentDirectory().."/title.png")

boardWidth = 7
boardHeight = 6

for y=1,boardHeight do
	board[y] = {}
	for x=1,boardWidth do
		board[y][x] = empty
	end
end

cellWidth = 20
cellHeight = 20

function checkWin(color, x, y)
	return nil
end

function drop(color, column)
	for y=1, boardHeight do
		if board[y][column] == empty then
			if y == boardHeight then
				board[y][column] = color
				return column, y
			else
				if board[y + 1][column] ~= empty then
					board[y][column] = color
					return column, y
				end	
			end
		end
	end
end

function countPieces(x, y, dx, dy)
	local count = 0
	while true do
		x = x + dx
		y = y + dy
		if x < 1 or x > boardWidth then break end
		if y < 1 or y > boardHeight then break end
		if board[y][x] == player then
			count = count + 1
		else
			break
		end
	end
	return count
end

function hasCurrentPlayerWon(x0, y0)
	local directions = { { 1, -1 }, { 1, 0 }, { 1, 1 }, { 0, 1 } }
	for _, direction in pairs(directions) do
		dx = direction[1]
		dy = direction[2]
		count = countPieces(x0, y0, dx, dy) + countPieces(x0, y0, -dx, -dy) + 1
		if count >= 4 then return true end
	end
	return false
end

function checkDraw()
	for x=1, boardWidth do
		if board[1][x] == empty then
			return false
		end
	end
	return true
end

column = 1
player = red

while true do
	Controls.init()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
	Screen.drawImage(100, 200, title,TOP_SCREEN)
	Screen.drawImage(column * cellWidth, 0, player, TOP_SCREEN)
	for y=1,boardHeight do
		for x=1,boardWidth do
			piece = board[y][x]
			x0 = x * cellWidth
			y0 = y * cellHeight
			if piece ~= empty then Screen.drawImage(x0, y0, empty, TOP_SCREEN) end
			Screen.drawImage(x0, y0, board[y][x],TOP_SCREEN)
		end
	end
	if checkDraw() then
		won = "no"
	end
	if won then
		Screen.debugPrint(20, 150, won .. " player has won", Color.new(255, 255, 255), BOTTOM_SCREEN)
		Screen.debugPrint(20, 165, "Press A to restart", Color.new(255, 255, 255), BOTTOM_SCREEN)
		Screen.debugPrint(20, 180, "Press B to exit", Color.new(255, 255, 255), BOTTOM_SCREEN)
		pad = Controls.read()
		if pad ~= oldPad then
			oldPad = pad
			if Controls.check(pad,KEY_A) then
				column = 1
				player = red
				won = false
				board = {}
				boardWidth = 7
				boardHeight = 6

				for y=1,boardHeight do
					board[y] = {}
					for x=1,boardWidth do
						board[y][x] = empty
					end
				end
				
			elseif Controls.check(pad,KEY_B) then
				Screen.freeImage(blue)
				Screen.freeImage(empty)
				Screen.freeImage(red)
				Screen.freeImage(title)
				System.exit()
			end
		end
	else
		pad = Controls.read()
		if pad ~= oldPad then
			oldPad = pad
			if Controls.check(pad,KEY_A) then
				x, y = drop(player, column)
				if x then
					if hasCurrentPlayerWon(x, y) then
						if player == red then
							won = "red"
						else
							won = "blue"
						end
					else
						if player == red then
							player = blue
						else
							player = red
						end
					end
				end 
			elseif Controls.check(pad,KEY_DLEFT) then
				column = column - 1
				if column < 1 then
					column = boardWidth
				end
			elseif Controls.check(pad,KEY_DRIGHT) then
				column = column + 1
				if column > boardWidth then
					column = 1
				end
			end
		end
	end
	Screen.waitVblankStart()
	Screen.flip()
end
