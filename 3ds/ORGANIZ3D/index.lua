update_bottom_screen = true
System.setCpuSpeed(804)
Graphics.init()
function LoadTheme(theme)
	old = System.currentDirectory()
	System.currentDirectory(System.currentDirectory().."ORG_Themes/"..theme)
	dofile(System.currentDirectory().."/theme.lua")
	System.currentDirectory(old)
end
dofile(System.currentDirectory().."ORG_CONFIG.txt")
Sound.init()
white = Color.new(255,255,255)
black = Color.new(0,0,0)
ctrlTimer = Timer.new()
timeSlap = 200
red = Color.new(255,0,0)
green = Color.new(0,255,0)
copy_or_move = false
is_fullscreen = false
oldpad = Controls.read()
function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end
function SortDirectory(dir)
	folders_table = {}
	files_table = {}
	for i,file in pairs(dir) do
		if file.directory then
			table.insert(folders_table,file)
		else
			table.insert(files_table,file)
		end
	end
	table.sort(files_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	table.sort(folders_table, function (a, b) return (a.name:lower() < b.name:lower() ) end)
	return_table = TableConcat(folders_table,files_table)
	return return_table
end
files_table = SortDirectory(System.listDirectory("/"))
mode = "SDMC"
System.currentDirectory("/")
p = 1
current_file = nil
current_type = nil
big_image = false
master_index = 0
sm_index = 1
build = System.checkBuild()
if build == 0 then
	build = "NH1"
elseif build == 1 then
	build = "CFW"
else
	build = "NH2"
end
if build == "NH1" then
	sm_voices = {"Video Player","Music Player","Image Viewer","Text Reader","Lua Interpreter","HEX Viewer","3DSX Launcher","CIA Installer","SMDH Decoder","ZIP Extractor","Info Viewer","Font Viewer","Cancel"}
	sm_funcs = {"JMPV","WAV","IMG","TXT","LUA","HEX","3DSX","CIA","SMDH","ZIP","INFO","TTF"}
elseif build == "NH2" then
	sm_voices = {"Video Player","Music Player","Image Viewer","Text Reader","Lua Interpreter","HEX Viewer","3DSX Launcher","SMDH Decoder","ZIP Extractor","Info Viewer","Font Viewer","Cancel"}
	sm_funcs = {"JMPV","WAV","IMG","TXT","LUA","HEX","3DSX","SMDH","ZIP","INFO","TTF"}
else
	sm_voices = {"Video Player","Music Player","Image Viewer","Text Reader","Lua Interpreter","HEX Viewer","CIA Installer","SMDH Decoder","ZIP Extractor","Info Viewer","Font Viewer","Cancel"}
	sm_funcs = {"JMPV","WAV","IMG","TXT","LUA","HEX","CIA","SMDH","ZIP","INFO","TTF"}
end
hex_values = {}
hex_text = {}
updateTXT = false
select_mode = false
update_main_extdata = true
delete_mode = false
move_base = nil
theme_name = "NONAME"
author = "NONAME"
copy_base = nil
x_print = 0
y_print = 0
copy_type = 0
move_type = 0
txt_index = 0
txt_words = 0
txt_i = 0
old_indexes = {}
MAX_RAM_ALLOCATION = 10485760
function FormatTime(seconds)
	minute = math.floor(seconds/60)
	seconds = seconds%60
	hours = math.floor(minute/60)
	minute = minute%60
	if minute < 10 then
		minute = "0"..minute
	end
	if seconds < 10 then
		seconds = "0"..seconds
	end
	if hours == 0 then
		return minute..":"..seconds
	else
		return hours..":"..minute..":"..seconds
	end
end
function DumpFile(input,archive)
	inp = io.open(extdata_directory..input,FREAD,archive)
	if System.doesFileExist("/"..input) then
		System.deleteFile("/"..input)
	end
	out = io.open("/"..string.format('%02X',archive).."_"..input,FCREATE)
	size = io.size(inp)
	index = 0
	while (index+(MAX_RAM_ALLOCATION/2) < size) do
		io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
		index = index + (MAX_RAM_ALLOCATION/2)
	end
	if index < size then
		io.write(out,index,io.read(inp,index,size-index),(size-index))
	end
	io.close(inp)
	io.close(out)
end
function RestoreFile(input,archive)
	inp = io.open("/"..string.format('%02X',archive).."_"..input,FREAD)
	out = io.open(extdata_directory..input,FWRITE,archive)
	if io.size(inp) <= io.size(out) then
		size = io.size(inp)
		index = 0
		while (index+(MAX_RAM_ALLOCATION/2) < size) do
			io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
			index = index + (MAX_RAM_ALLOCATION/2)
		end
		if index < size then
			io.write(out,index,io.read(inp,index,size-index),(size-index))
		end
	end
	io.close(inp)
	io.close(out)
end
function RestoreFolder(input,archive)
	files = System.listDirectory("/"..string.format('%02X',archive).."_"..input)
	for z, file in pairs(files) do
		if (file.directory) then
			RestoreFolder(input.."/"..file.name,archive)
		else
			RestoreFile(input.."/"..file.name,archive)
		end
	end
end
function DumpFolder(input,archive)
	files = System.listExtdataDir(extdata_directory..input,archive)
	System.createDirectory("/"..string.format('%02X',archive).."_"..input)
	for z, file in pairs(files) do
		if (file.directory) then
			DumpFolder(input.."/"..file.name,archive)
		else
			DumpFile(input.."/"..file.name,archive)
		end
	end
end
function CopyFile(input,output)
	inp = io.open(input,FREAD)
	if System.doesFileExist(output) then
		System.deleteFile(output)
	end
	out = io.open(output,FCREATE)
	size = io.size(inp)
	index = 0
	while (index+(MAX_RAM_ALLOCATION/2) < size) do
		io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
		index = index + (MAX_RAM_ALLOCATION/2)
	end
	if index < size then
		io.write(out,index,io.read(inp,index,size-index),(size-index))
	end
	io.close(inp)
	io.close(out)
end
function CopyDir(input,output)
	files = System.listDirectory(input)
	System.createDirectory(output)
	for z, file in pairs(files) do
		if (file.directory) then
			CopyDir(input.."/"..file.name,output.."/"..file.name)
		else
			CopyFile(input.."/"..file.name,output.."/"..file.name)
		end
	end
end
function OpenExtdataFile(text, archive)
	GarbageCollection()
	current_file = io.open(extdata_directory..text,FREAD,archive)
	current_type = "HEX"
	txt_index = 0
	updateTXT = true
end
function ForceOpenFile(text, size, mode)
	if mode == "SMDH" then
		GarbageCollection()
		current_type = "SMDH"
		current_file = System.extractSMDH(System.currentDirectory()..text)
		smdh_show = Console.new(TOP_SCREEN)
		Console.append(smdh_show,"Title: "..current_file.title.."\n\n")
		Console.append(smdh_show,"Description: "..current_file.desc.."\n\n")
		Console.append(smdh_show,"Author: "..current_file.author)
	elseif mode == "3DSX" and not build == "CFW" then
		GarbageCollection()
		Graphics.freeImage(bg)
		Sound.term()
		System.launch(System.currentDirectory()..text)
	elseif mode == "JPGV" then
		GarbageCollection()
		current_file = JPGV.load(System.currentDirectory()..text)
		current_type = "JPGV"
		JPGV.start(current_file,NO_LOOP)
	elseif mode == "WAV" then
		GarbageCollection()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		magic = io.read(current_file,8,4)
		io.close(current_file)
		if magic == "AIFF" then
			current_file = Sound.openAiff(System.currentDirectory()..text, true)
			current_type = "WAV"
			Sound.play(current_file,NO_LOOP)
		elseif magic == "RIFF" then
			current_file = Sound.openWav(System.currentDirectory()..text, true)
			current_type = "WAV"
			Sound.play(current_file,NO_LOOP)
		else
			current_file = Sound.openOgg(System.currentDirectory()..text, true)
			current_type = "WAV"
			Sound.play(current_file,NO_LOOP)
		end
	elseif mode == "IMG" then
		GarbageCollection()
		current_type = "IMG"
		current_file = Graphics.loadImage(System.currentDirectory()..text)
		width = Graphics.getImageWidth(current_file)
		height = Graphics.getImageHeight(current_file)
		if Graphics.getImageWidth(current_file) > 400 then
			width = 400
			big_image = true
		end
		if Graphics.getImageHeight(current_file) > 240 then
			height = 240
			big_image = true
		end
	elseif mode == "LUA" then
		GarbageCollection()
		Graphics.freeImage(bg)
		Sound.term()
		reset_dir = System.currentDirectory()
		System.currentDirectory(string.sub(System.currentDirectory(),1,-2))
		dofile(System.currentDirectory().."/"..text)
		System.currentDirectory(reset_dir)
		current_type = "LUA"
		Sound.init()
	elseif mode == "TXT" then
		GarbageCollection()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		text_console = Console.new(TOP_SCREEN)
		current_type = "TXT"
		txt_index = 0
		txt_words = 0
		updateTXT = true
	elseif mode == "HEX" then
		GarbageCollection()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		current_type = "HEX"
		txt_index = 0
		updateTXT = true
	elseif mode == "INFO" then
		GarbageCollection()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		current_type = "INFO"
		f_size = io.size(current_file)
		f = "Bytes"
		if (f_size > 1024) then
			f_size = f_size / 1024
			f = "KBs"
		end
		if (f_size > 1024) then
			f_size = f_size / 1024
			f = "MBs"
		end
		io.close(current_file)
		text_console = Console.new(TOP_SCREEN)
		Console.append(text_console,"Filename: "..text.."\n")
		i = -1
		while string.sub(text,i,i) ~= "." do
			i = i - 1
		end
		i = i + 1
		Console.append(text_console,"Format: "..string.upper(string.sub(text,i)).."\n")
		Console.append(text_console,"Size: "..f_size.." "..f.."\n")
	elseif mode == "ZIP" then
		GarbageCollection()
		pass = System.startKeyboard("")
		System.extractZIP(System.currentDirectory()..text,System.currentDirectory()..string.sub(text,1,-5),pass)
		files_table = System.listDirectory(System.currentDirectory())
		if System.currentDirectory() ~= "/" then
			local extra = {}
			extra.name = ".."
			extra.size = 0
			extra.directory = true
			table.insert(files_table,extra)
		end
		files_table = SortDirectory(files_table)
	elseif mode == "TTF" then
		GarbageCollection()
		current_file = Font.load(System.currentDirectory()..text)
		current_type = "TTF"
	elseif mode == "CIA" then
		GarbageCollection()
		sm_index = 1
		cia_data = System.extractCIA(System.currentDirectory()..text)
		oldpad = KEY_A
		while true do
			Screen.refresh()
			Screen.waitVblankStart()
			Screen.clear(TOP_SCREEN)
			Screen.debugPrint(0,0,"Title: "..cia_data.title,white,TOP_SCREEN)
			Screen.debugPrint(0,15,"Unique ID: 0x"..string.sub(string.format('%02X',cia_data.unique_id),1,-3),white,TOP_SCREEN)
			Screen.debugPrint(0,30,"Size to install: "..cia_data.install_size,white,TOP_SCREEN)
			Screen.debugPrint(0,45,"Version: "..cia_data.version,white,TOP_SCREEN)
			if not cia_data.icon == nil then
				Screen.debugPrint(0,30,"Name: "..cia_data.name,white,TOP_SCREEN)
				Screen.debugPrint(0,45,"Author: "..cia_data.author,white,TOP_SCREEN)
				Screen.debugPrint(0,60,"Desc: "..cia_data.desc,white,TOP_SCREEN)
				Screen.drawImage(5, 85, cia_data.icon, TOP_SCREEN)
			end
			pad = Controls.read()
			Screen.fillEmptyRect(60,260,50,95,black,BOTTOM_SCREEN)
			Screen.fillRect(61,259,51,96,white,BOTTOM_SCREEN)
			if (sm_index == 1) then
				Screen.fillRect(61,259,51,66,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Install to SDMC",red,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Install to NAND",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,83,"Cancel",black,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
					sm_index = 2
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					System.installCIA(System.currentDirectory()..text, SDMC)
					break
				end
			elseif (sm_index == 2) then
				Screen.fillRect(61,259,66,81,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Install to SDMC",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Install to NAND",red,BOTTOM_SCREEN)
				Screen.debugPrint(63,83,"Cancel",black,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
					sm_index = 3
				elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
					sm_index = 1
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					System.installCIA(System.currentDirectory()..text, NAND)
					break
				end
			else
				Screen.fillRect(61,259,81,96,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Install to SDMC",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Install to NAND",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,83,"Cancel",red,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
					sm_index = 2
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					break
				end
			end
			oldpad = pad
			Screen.flip()
		end
		update_bottom_screen = true
	end
end
function DeleteDir(dir)
	files = System.listDirectory(dir)
	for z, file in pairs(files) do
		if (file.directory) then
			DeleteDir(dir.."/"..file.name)
		else
			System.deleteFile(dir.."/"..file.name)
		end
	end
	System.deleteDirectory(dir)
end
function OpenFile(text, size)
	if string.upper(string.sub(text,-5)) == ".SMDH" then
		GarbageCollection()
		current_type = "SMDH"
		current_file = System.extractSMDH(System.currentDirectory()..text)
		smdh_show = Console.new(TOP_SCREEN)
		Console.append(smdh_show,"Title: "..current_file.title.."\n\n")
		Console.append(smdh_show,"Description: "..current_file.desc.."\n\n")
		Console.append(smdh_show,"Author: "..current_file.author)
	elseif string.upper(string.sub(text,-4)) == ".ZIP" then
		GarbageCollection()
		pass = System.startKeyboard("PASSWORD")
		System.extractZIP(System.currentDirectory()..text,System.currentDirectory()..string.sub(text,1,-5),pass)
		files_table = System.listDirectory(System.currentDirectory())
		if System.currentDirectory() ~= "/" then
			local extra = {}
			extra.name = ".."
			extra.size = 0
			extra.directory = true
			table.insert(files_table,extra)
		end
		files_table = SortDirectory(files_table)
	elseif (string.upper(string.sub(text,-5)) == ".3DSX") and not build == "CFW" then
		GarbageCollection()
		Graphics.freeImage(bg)
		Sound.term()
		Graphics.term()
		System.launch(System.currentDirectory()..text)
	elseif string.upper(string.sub(text,-5)) == ".JPGV" then
		GarbageCollection()
		current_file = JPGV.load(System.currentDirectory()..text)
		current_type = "JPGV"
		JPGV.start(current_file,NO_LOOP)
	elseif string.upper(string.sub(text,-4)) == ".TTF" then
		GarbageCollection()
		current_file = Font.load(System.currentDirectory()..text)
		current_type = "TTF"
	elseif string.upper(string.sub(text,-4)) == ".WAV" then
		GarbageCollection()
		current_file = Sound.openWav(System.currentDirectory()..text, true)
		current_type = "WAV"
		Sound.play(current_file,NO_LOOP)
	elseif string.upper(string.sub(text,-4)) == ".OGG" then
		GarbageCollection()
		current_file = Sound.openOgg(System.currentDirectory()..text,true)
		current_type = "WAV"
		Sound.play(current_file,NO_LOOP)
	elseif string.upper(string.sub(text,-4)) == ".AIF" or string.upper(string.sub(text,-5)) == ".AIFF" then
		GarbageCollection()
		current_file = Sound.openAiff(System.currentDirectory()..text, true)
		current_type = "WAV"
		Sound.play(current_file,NO_LOOP)
	elseif string.upper(string.sub(text,-4)) == ".PNG" or string.upper(string.sub(text,-4)) == ".BMP" or string.upper(string.sub(text,-4)) == ".JPG" then
		GarbageCollection()
		current_type = "IMG"
		current_file = Graphics.loadImage(System.currentDirectory()..text)
		width = Graphics.getImageWidth(current_file)
		height = Graphics.getImageHeight(current_file)
		if width > 400 then
			width = 400
			big_image = true
		end
		if height > 240 then
			height = 240
			big_image = true
		end
	elseif string.sub(text,-4) == ".lua" or string.sub(text,-4) == ".LUA" then
		GarbageCollection()
		Graphics.freeImage(bg)
		Sound.term()
		reset_dir = System.currentDirectory()
		System.currentDirectory(string.sub(System.currentDirectory(),1,-2))
		dofile(System.currentDirectory().."/"..text)
		System.currentDirectory(reset_dir)
		current_type = "LUA"
		Sound.init()
	elseif string.sub(text,-4) == ".txt" or string.sub(text,-4) == ".TXT" then
		GarbageCollection()
		current_file = io.open(System.currentDirectory()..text,FREAD)
		text_console = Console.new(TOP_SCREEN)
		current_type = "TXT"
		txt_index = 0
		txt_words = 0
		updateTXT = true
	elseif string.upper(string.sub(text,-4)) == ".CIA" and build ~= "NH2" then
		GarbageCollection()
		sm_index = 1
		cia_data = System.extractCIA(System.currentDirectory()..text)
		oldpad = KEY_A
		while true do
			Screen.refresh()
			Screen.waitVblankStart()
			Screen.clear(TOP_SCREEN)
			Screen.debugPrint(0,0,"Title: "..cia_data.title,white,TOP_SCREEN)
			Screen.debugPrint(0,15,"Unique ID: 0x"..string.sub(string.format('%02X',cia_data.unique_id),1,-3),white,TOP_SCREEN)
			Screen.debugPrint(0,30,"Size to install: "..cia_data.install_size,white,TOP_SCREEN)
			Screen.debugPrint(0,45,"Version: "..cia_data.version,white,TOP_SCREEN)
			if not cia_data.icon == nil then
				Screen.debugPrint(0,30,"Name: "..cia_data.name,white,TOP_SCREEN)
				Screen.debugPrint(0,45,"Author: "..cia_data.author,white,TOP_SCREEN)
				Screen.debugPrint(0,60,"Desc: "..cia_data.desc,white,TOP_SCREEN)
				Screen.drawImage(5, 85, cia_data.icon, TOP_SCREEN)
			end
			pad = Controls.read()
			Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
			Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
			if (sm_index == 1) then
				Screen.fillRect(61,259,51,66,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Install to SDMC",red,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Install to NAND",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,83,"Cancel",black,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
					sm_index = 2
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					System.installCIA(System.currentDirectory()..text, SDMC)
					break
				end
			elseif (sm_index == 2) then
				Screen.fillRect(61,259,66,81,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Install to SDMC",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Install to NAND",red,BOTTOM_SCREEN)
				Screen.debugPrint(63,83,"Cancel",black,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
					sm_index = 3
				elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
					sm_index = 1
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					System.installCIA(System.currentDirectory()..text, NAND)
					break
				end
			else
				Screen.fillRect(61,259,81,96,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,53,"Install to SDMC",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,68,"Install to NAND",black,BOTTOM_SCREEN)
				Screen.debugPrint(63,83,"Cancel",red,BOTTOM_SCREEN)
				if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
					sm_index = 2
				elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
					break
				end
			end
			oldpad = pad
			Screen.flip()
		end
		update_bottom_screen = true
	end
end
function OpenDirectory(text,archive_id)
	i=0
	if mode == "SDMC" then
		if text == ".." then
			j=-2
			while string.sub(System.currentDirectory(),j,j) ~= "/" do
				j=j-1
			end
			System.currentDirectory(string.sub(System.currentDirectory(),1,j))
		else
			System.currentDirectory(System.currentDirectory()..text.."/")
		end
	else
		if text == ".." then
			j=-2
			while string.sub(extdata_directory,j,j) ~= "/" do
				j=j-1
			end
			extdata_directory = string.sub(extdata_directory,1,j)
		else
			extdata_directory = extdata_directory..text.."/"
		end
	end
	if mode == "SDMC" then
		files_table = System.listDirectory(System.currentDirectory())
		if System.currentDirectory() ~= "/" then
			local extra = {}
			extra.name = ".."
			extra.size = 0
			extra.directory = true
			table.insert(files_table,extra)
		end
		files_table = SortDirectory(files_table)
	else
		if extdata_directory == "/" then
			files_table = extdata_backup
		else
			files_table = System.listExtdataDir(extdata_directory,archive_id)
			local extra = {}
			extra.name = ".."
			extra.size = 0
			extra.directory = true
			extra.archive = archive_id
			table.insert(files_table,extra)
		end
	end
end
function GarbageCollection()
	if current_type == "SMDH" then
		Console.destroy(smdh_show)
		Screen.freeImage(current_file.icon)
	elseif current_type == "TTF" then
		Font.unload(current_file)
	elseif current_type == "JPGV" then
		if JPGV.isPlaying(current_file) then
			JPGV.pause(current_file)
		end
		JPGV.unload(current_file)
		is_fullscreen = false
		fullscreen_check = nil
	elseif current_type == "WAV" then
		if Sound.isPlaying(current_file) then
			Sound.pause(current_file)
		end
		Sound.close(current_file)
	elseif current_type == "IMG" then
		Graphics.freeImage(current_file)
		big_image = false
		y_print = 0
		x_print = 0
	elseif current_type == "TXT" then
		io.close(current_file)
		Console.destroy(text_console)
		old_indexes = {}
		txt_i = 0
	elseif current_type == "INFO" then
		Console.destroy(text_console)
	elseif current_type == "CIA" then
		if not cia_data.icon == nil then
			Screen.freeImage(cia_data.icon)
		end
	elseif current_type == "HEX" then
		io.close(current_file)
		old_indexes = {}
		txt_i = 0
	elseif current_type == "LUA" then
		theme_name = "NONAME"
		author = "NONAME"
	end
	current_type = nil
end
function CropPrint(x, y, text, color, screen)
	if string.len(text) > 25 then
		Screen.debugPrint(x, y, string.sub(text,1,25) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end
function ThemePrint(x, y, text, color, screen)
	if string.len(text) > 40 then
		Screen.debugPrint(x, y, string.sub(text,1,40) .. "...", color, screen)
	else
		Screen.debugPrint(x, y, text, color, screen)
	end
end
function BuildLines(file, index)
	MAX_LENGTH = 1200
	SIZE = io.size(file)
	if ((index + MAX_LENGTH) < SIZE) then
		READ_LENGTH = MAX_LENGTH
	else
		READ_LENGTH = SIZE - index
	end
	if (index < SIZE) then
		Console.clear(text_console)
		Console.append(text_console,io.read(file,index,READ_LENGTH))
		txt_words = Console.show(text_console)
	else
		txt_words = 0
	end
	if (txt_words > 0) then
		table.insert(old_indexes, index)
		index = index + txt_words
		txt_i = txt_i + 1
	end
	return index
end
function BuildHex(file, index)
	MAX_LENGTH = 120
	SIZE = io.size(file)
	if ((index + MAX_LENGTH) < SIZE) then
		READ_LENGTH = MAX_LENGTH
	else
		READ_LENGTH = SIZE - index
	end
	if (index < SIZE) then
		hex_text = {}
		hex_values = {}
		text = io.read(file,index,READ_LENGTH)
		t = 1
		while (t <= 15) do
			if ((t*8) > string.len(text)) then
				temp = string.sub(text,1+(t-1)*8,-1)
			else
				temp = string.sub(text,1+(t-1)*8,t*8)
			end
			t2 = 1
			while t2 <= string.len(temp) do
				table.insert(hex_values,string.byte(temp,t2))
				t2 = t2 + 1
			end
			table.insert(hex_text,temp)
			t = t + 1
		end
		table.insert(old_indexes, index)
		index = index + READ_LENGTH
		txt_i = txt_i + 1
	end
	return index
end
while true do
	base_y = 0
	i = 1
	Screen.refresh()
	if current_type ~= "JPGV" then
		Screen.clear(TOP_SCREEN)
	end
	pad = Controls.read()
	if (current_type == "SMDH") then
		Console.show(smdh_show)
		Screen.debugPrint(0,170,"Icon:",white,TOP_SCREEN)
		Screen.drawImage(0,185,current_file.icon,TOP_SCREEN)
	elseif (current_type == "TTF") then
		Font.setPixelSizes(current_file,8)
		Font.print(current_file,0,5,"8: The quick brown fox",white,TOP_SCREEN)
		Font.print(current_file,10,13,"jumps over the lazy dog",white,TOP_SCREEN)
		Font.setPixelSizes(current_file,12)
		Font.print(current_file,0,25,"12: The quick brown fox",white,TOP_SCREEN)
		Font.print(current_file,10,37,"jumps over the lazy dog",white,TOP_SCREEN)
		Font.setPixelSizes(current_file,18)
		Font.print(current_file,0,54,"18: The quick brown fox",white,TOP_SCREEN)
		Font.print(current_file,10,72,"jumps over the lazy dog",white,TOP_SCREEN)
		Font.setPixelSizes(current_file,24)
		Font.print(current_file,0,95,"24: The quick brown fox",white,TOP_SCREEN)
		Font.print(current_file,10,119,"jumps over the lazy dog",white,TOP_SCREEN)
		Font.setPixelSizes(current_file,30)
		Font.print(current_file,0,149,"30: The quick brown fox",white,TOP_SCREEN)
		Font.print(current_file,10,179,"jumps over the lazy dog",white,TOP_SCREEN)
	elseif (current_type == "JPGV") then
		if fullscreen_check == nil then
			Screen.drawPixel(399,239,0xDEADBEFF, TOP_SCREEN)
			tmp = Screen.getPixel(399,239,TOP_SCREEN)
		end
		if is_fullscreen then
			JPGV.drawFast(current_file,TOP_SCREEN)
		else
			JPGV.draw(0,0,current_file,TOP_SCREEN)
		end
		if fullscreen_check == nil then
			if tmp == Screen.getPixel(399,239,TOP_SCREEN) then
				is_fullscreen = true
			end
			fullscreen_check = true
		end
	elseif (current_type == "WAV") then
		Sound.updateStream()
		Screen.debugPrint(0,0,"Title: ",white,TOP_SCREEN)
		ThemePrint(0,15,Sound.getTitle(current_file),white,TOP_SCREEN)
		Screen.debugPrint(0,40,"Author: ",white,TOP_SCREEN)
		ThemePrint(0,55,Sound.getAuthor(current_file),white,TOP_SCREEN)
		Screen.debugPrint(0,80,"Time: "..FormatTime(Sound.getTime(current_file)).." / "..FormatTime(Sound.getTotalTime(current_file)),white,TOP_SCREEN)
		Screen.debugPrint(0,95,"Samplerate: "..Sound.getSrate(current_file),white,TOP_SCREEN)
		if Sound.getType(current_file) == 1 then
			stype = "Mono"
		else
			stype = "Stereo"
		end
		Screen.debugPrint(0,110,"Audiotype: "..stype,white,TOP_SCREEN)
	elseif (current_type == "IMG") then
		Graphics.initBlend(TOP_SCREEN)
		if big_image then
			Graphics.drawPartialImage(0,0,x_print,y_print,width,height,current_file)
			x,y = Controls.readCirclePad()
			if (x < - 100) and (x_print > 0) then
				x_print = x_print - 5
				if x_print < 0 then
					x_print = 0
				end
			end
			if (y > 100) and (y_print > 0) then
				y_print = y_print - 5
				if y_print < 0 then
					y_print = 0
				end
			end
			if (x > 100) and (x_print + width < Graphics.getImageWidth(current_file)) then
				x_print = x_print + 5
			end
			if (y < - 100) and (y_print + height < Graphics.getImageHeight(current_file)) then
				y_print = y_print + 5
			end
			if x_print + width > Graphics.getImageWidth(current_file) then
				x_print = Graphics.getImageWidth(current_file) - width
			end
			if y_print + height > Graphics.getImageHeight(current_file) then
				y_print = Graphics.getImageHeight(current_file) - height
			end
		else
			Graphics.drawImage(0,0,current_file)
		end
		Graphics.termBlend()
	elseif (current_type == "INFO") then
		Console.show(text_console)
	elseif (current_type == "TXT") then
		if (updateTXT) then
			txt_index = BuildLines(current_file,txt_index)
			updateTXT = false
		end
		Console.show(text_console)
	elseif (current_type == "LUA") then
		Screen.debugPrint(0,0,"ORGANIZ3D theme recognized...",white,TOP_SCREEN)
		Screen.debugPrint(0,15,"---------------------------------",white,TOP_SCREEN)
		Screen.debugPrint(0,30,"Theme Name: ",white,TOP_SCREEN)
		ThemePrint(0,45,theme_name,white,TOP_SCREEN)
		ThemePrint(0,75,"Author: " .. author,white,TOP_SCREEN)
	elseif (current_type == "HEX") then
		if (updateTXT) then
			txt_index = BuildHex(current_file,txt_index)
			updateTXT = false
		end
		for l, line in pairs(hex_text) do
			Screen.debugPrint(280,(l-1)*15,string.gsub(line,"\0"," "),white,TOP_SCREEN)
			temp = 1
			while (temp <= string.len(line)) do
				if (temp % 2 == 0) then
					Screen.debugPrint(0+(temp-1)*30,(l-1)*15,string.format('%02X', hex_values[(l-1)*8+temp]),white,TOP_SCREEN)
				else
					Screen.debugPrint(0+(temp-1)*30,(l-1)*15,string.format('%02X', hex_values[(l-1)*8+temp]),red,TOP_SCREEN)
				end
				temp = temp + 1
			end
		end
		Screen.debugPrint(0,225,"Offset: 0x" .. string.format('%X', old_indexes[#old_indexes]) .. " (" .. (old_indexes[#old_indexes]) .. ")",white,TOP_SCREEN)
	else
		Screen.debugPrint(0,0,"Welcome to ORGANIZ3D!",white,TOP_SCREEN)
		Screen.debugPrint(0,15,"---------------------------------",white,TOP_SCREEN)
		Screen.debugPrint(0,30,"You're using v.1.1.",white,TOP_SCREEN)
		Screen.debugPrint(0,45,"---------------------------------",white,TOP_SCREEN)
		Screen.debugPrint(0,60,"Press START for a Controls List",white,TOP_SCREEN)
	end
	if update_bottom_screen then
		Graphics.initBlend(BOTTOM_SCREEN)
		Graphics.drawImage(0,0,bg)
		Graphics.termBlend()
		for l, file in pairs(files_table) do
			if (base_y > 226) then
				break
			end
			if (l >= master_index) then
				if (l==p) then
					base_y2 = base_y
					if (base_y) == 0 then
						base_y = 2
					end
					Screen.fillRect(0,319,base_y-2,base_y2+12,selected_item,BOTTOM_SCREEN)
					color = selected_color
					if (base_y) == 2 then
						base_y = 0
					end
				else
					color = menu_color
				end
				if mode == "SDMC" then
					CropPrint(0,base_y,file.name,color,BOTTOM_SCREEN)
				else
					if file.name == ".." then
						CropPrint(0,base_y,file.name,color,BOTTOM_SCREEN)
					else
						CropPrint(0,base_y,file.name.." ["..string.format('%02X',file.archive).."]",color,BOTTOM_SCREEN)
					end
				end
				base_y = base_y + 15
			end
		end
		if move_base ~= nil then
			Screen.debugPrint(300,0,"M",selected_color,BOTTOM_SCREEN)
		elseif copy_base ~= nil then
			Screen.debugPrint(300,0,"C",selected_color,BOTTOM_SCREEN)
		end
		update_bottom_screen = false
	end
	-- Select Mode Controls Functions
	if (select_mode) then
		Screen.fillEmptyRect(60,260,20,22 + #sm_voices * 15,black,BOTTOM_SCREEN)
		Screen.fillRect(61,259,21,21 + #sm_voices * 15,white,BOTTOM_SCREEN)
		for l, voice in pairs(sm_voices) do
			if (l == sm_index) then
				Screen.fillRect(61,259,21+(l-1)*15,21+l*15,green,BOTTOM_SCREEN)
				Screen.debugPrint(63,23+(l-1)*15,voice,red,BOTTOM_SCREEN)
			else
				Screen.debugPrint(63,23+(l-1)*15,voice,black,BOTTOM_SCREEN)
			end
		end
		if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
			sm_index = sm_index - 1
		elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
			sm_index = sm_index + 1
		elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
			if (sm_index < #sm_voices) then
				ForceOpenFile(files_table[p].name,files_table[p].size,sm_funcs[sm_index])
			end
			sm_index = 1
			select_mode = false
			update_bottom_screen = true
		end
		if (sm_index < 1) then
			sm_index = #sm_voices
		elseif (sm_index > #sm_voices) then
			sm_index = 1
		end
	-- Security Deletion Check Screen
	elseif (delete_mode) then
		Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
		Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
		if (sm_index == 1) then
			Screen.fillRect(61,259,51,66,green,BOTTOM_SCREEN)
			Screen.debugPrint(63,53,"Confirm",red,BOTTOM_SCREEN)
			Screen.debugPrint(63,68,"Cancel",black,BOTTOM_SCREEN)
			if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
				sm_index = 2
			elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
				update_bottom_screen = true
				if (files_table[p].directory) then
					if (files_table[p].name ~= "..") then
						DeleteDir(System.currentDirectory()..files_table[p].name)
					end
				else
					System.deleteFile(System.currentDirectory()..files_table[p].name)
				end
				while (#files_table > 0) do
					table.remove(files_table)
				end
				files_table = System.listDirectory(System.currentDirectory())
				if System.currentDirectory() ~= "/" then
					local extra = {}
					extra.name = ".."
					extra.size = 0
					extra.directory = true
					table.insert(files_table,extra)
				end
				files_table = SortDirectory(files_table)
				if (p > #files_table) then
					p = p - 1
				end
				delete_mode = false
			end
		else
			Screen.fillRect(61,259,66,81,green,BOTTOM_SCREEN)
			Screen.debugPrint(63,53,"Confirm",black,BOTTOM_SCREEN)
			Screen.debugPrint(63,68,"Cancel",red,BOTTOM_SCREEN)
			if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
				sm_index = 1
			elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
				update_bottom_screen = true
				sm_index = 1
				delete_mode = false
			end
		end
	-- Copy/Move selection
	elseif (copy_or_move) then
		Screen.fillEmptyRect(60,260,50,82,black,BOTTOM_SCREEN)
		Screen.fillRect(61,259,51,81,white,BOTTOM_SCREEN)
		if (sm_index == 1) then
			Screen.fillRect(61,259,51,66,green,BOTTOM_SCREEN)
			Screen.debugPrint(63,53,"Move",red,BOTTOM_SCREEN)
			Screen.debugPrint(63,68,"Copy",black,BOTTOM_SCREEN)
			if (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) then
				sm_index = 2
			elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
				if (files_table[p].name ~= "..") then
					update_bottom_screen = true
					move_base = System.currentDirectory() .. files_table[p].name
					move_name = files_table[p].name
					if (files_table[p].directory) then
						move_type = 0
					else
						move_type = 1
					end
				end
				copy_or_move = false
				sm_index = 1
			end
		else
			Screen.fillRect(61,259,66,81,green,BOTTOM_SCREEN)
			Screen.debugPrint(63,53,"Move",black,BOTTOM_SCREEN)
			Screen.debugPrint(63,68,"Copy",red,BOTTOM_SCREEN)
			if (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) then
				sm_index = 1
			elseif (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
				if (files_table[p].directory) then
					if (files_table[p].name ~= "..") then
						copy_name = files_table[p].name
						copy_base = System.currentDirectory() .. files_table[p].name
						copy_type = 0
					end
				else
					copy_type = 1
					copy_name = files_table[p].name
					copy_base = System.currentDirectory() .. files_table[p].name
				end
				copy_or_move = false
				sm_index = 1
			end
		end
	else
	-- Base Controls Functions
		if (Controls.check(pad,KEY_DUP)) then
			if not (Controls.check(oldpad,KEY_DUP)) then
				Timer.reset(ctrlTimer)
				update_bottom_screen = true
				p = p - 1
				if (p >= 16) then
					master_index = p - 15
				end
			else
				if Timer.getTime(ctrlTimer) > timeSlap then
					Timer.reset(ctrlTimer)
					update_bottom_screen = true
					p = p - 1
					if (p >= 16) then
						master_index = p - 15
					end
					timeSlap = math.max(100, timeSlap - 15)
				end
			end
		elseif (Controls.check(pad,KEY_DDOWN)) then
			if not (Controls.check(oldpad,KEY_DDOWN)) then
				Timer.reset(ctrlTimer)
				update_bottom_screen = true
				p = p + 1
				if (p >= 17) then
					master_index = p - 15
				end
			else
				if Timer.getTime(ctrlTimer) > timeSlap then
					Timer.reset(ctrlTimer)
					update_bottom_screen = true
					p = p + 1
					if (p >= 17) then
						master_index = p - 15
					end
					timeSlap = math.max(100, timeSlap - 15)
				end
			end
		else
			timeSlap = 200
		end
		if (p < 1) then
			p = #files_table
			if (p >= 17) then
				master_index = p - 15
			end
		elseif (p > #files_table) then
			master_index = 0
			p = 1
		end
		if (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
			if (files_table[p].directory) then
				if (mode == "SDMC") then
					OpenDirectory(files_table[p].name,0)
				else
					OpenDirectory(files_table[p].name,files_table[p].archive)
				end
				p=1
				master_index=0
			else
				if (mode == "SDMC") then
					OpenFile(files_table[p].name,files_table[p].size)
				else
					OpenExtdataFile(files_table[p].name,files_table[p].archive)
				end
			end
		elseif (Controls.check(pad,KEY_X)) and not (Controls.check(oldpad,KEY_X)) then
			if (mode == "SDMC") then
				if (move_base == nil) and (copy_base == nil) then
					delete_mode = true
				else
					update_bottom_screen = true
					move_base = nil
					move_name = nil
					copy_base = nil
					copy_name = nil
				end
			else
				if (files_table[p].directory) then
					RestoreFolder(files_table[p].name,files_table[p].archive)
				else
					RestoreFile(files_table[p].name,files_table[p].archive)
				end
			end				
		elseif (Controls.check(pad,KEY_Y)) and not (Controls.check(oldpad,KEY_Y)) then
			if (mode == "SDMC") then
				if (copy_base == nil) then
					if (move_base == nil) then
						if (files_table[p].name ~= "..") then
							update_bottom_screen = true
							copy_or_move = true
						end
					else
						update_bottom_screen = true
						if (move_type == 0) then
							System.renameDirectory(move_base,System.currentDirectory() .. move_name)
						else
							System.renameFile(move_base,System.currentDirectory() .. move_name)
						end
						move_base = nil
						files_table = System.listDirectory(System.currentDirectory())
						if System.currentDirectory() ~= "/" then
							local extra = {}
							extra.name = ".."
							extra.size = 0
							extra.directory = true
							table.insert(files_table,extra)
						end
						files_table = SortDirectory(files_table)
					end
				else
					copy_end = System.currentDirectory() .. copy_name
					if copy_end == copy_base then
						temp_copy = "Copy_" .. copy_name
						copy_end = System.currentDirectory() .. temp_copy
						if (copy_type == 1) then
							while System.doesFileExist(copy_end) do
								temp_copy = "Copy_" .. temp_copy
								copy_end = System.currentDirectory() .. temp_copy
							end
						end
					end
					if (copy_type == 0) then
						CopyDir(copy_base,copy_end)
					else
						CopyFile(copy_base,copy_end)
					end
					files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
					files_table = SortDirectory(files_table)
					copy_name = nil
					copy_base = nil
				end
			end
		elseif (Controls.check(pad,KEY_B)) and not (Controls.check(oldpad,KEY_B)) then
			if (mode == "SDMC") then
				update_bottom_screen = true
				if (files_table[p].name ~= "..") then
					new_name = System.startKeyboard(files_table[p].name)
					oldpad = KEY_A
					if (files_table[p].directory) then
						System.renameDirectory(System.currentDirectory() .. files_table[p].name,System.currentDirectory() .. new_name)
					else
						System.renameFile(System.currentDirectory() .. files_table[p].name,System.currentDirectory() .. new_name)
					end
					files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
					files_table = SortDirectory(files_table)
				end
			else
				if (files_table[p].directory) then
					DumpFolder(files_table[p].name,files_table[p].archive)
				else
					DumpFile(files_table[p].name,files_table[p].archive)
				end
			end
		elseif (Controls.check(pad,KEY_DLEFT)) and not (Controls.check(oldpad,KEY_DLEFT)) then
			if (current_type == "SMDH") then
				update_bottom_screen = true
				name = System.startKeyboard("icon.bmp")
				Screen.saveBitmap(current_file.icon,System.currentDirectory()..name)
				oldpad = KEY_A
				files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
				files_table = SortDirectory(files_table)
			elseif (current_type == "TXT") or (current_type == "HEX") then
				if (txt_i > 1) then			
					updateTXT = true
					table.remove(old_indexes)
					txt_index = table.remove(old_indexes)
					txt_i = txt_i - 2
				end
			elseif (current_type == "WAV") then
				if (Sound.isPlaying(current_file)) then
					Sound.pause(current_file)
				else
					Sound.resume(current_file)
				end
			elseif (current_type == "JPGV") then
				if (JPGV.isPlaying(current_file)) then
					JPGV.pause(current_file)
				else
					JPGV.resume(current_file)
				end
			end
		elseif (Controls.check(pad,KEY_DRIGHT)) and not (Controls.check(oldpad,KEY_DRIGHT)) then
			if (current_type == "SMDH") then
				update_bottom_screen = true
				name = System.startKeyboard("icon.bmp")
				Screen.saveBitmap(current_file.icon,System.currentDirectory()..name)
				oldpad = KEY_A
				files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
				files_table = SortDirectory(files_table)
			elseif (current_type == "TXT") or (current_type == "HEX") then
				updateTXT = true
			elseif (current_type == "WAV") then
				if (Sound.isPlaying(current_file)) then
					Sound.pause(current_file)
				else
					Sound.resume(current_file)
				end
			elseif (current_type == "JPGV") then
				if (JPGV.isPlaying(current_file)) then
					JPGV.pause(current_file)
				else
					JPGV.resume(current_file)
				end
			end
		elseif (Controls.check(pad,KEY_SELECT)) and not (Controls.check(oldpad,KEY_SELECT)) then
			update_bottom_screen = true
			p = 1
			if (mode == "SDMC") then
				GarbageCollection()
				mode = "EXTDATA"
				if (update_main_extdata) then
					files_table = System.scanExtdata()
					extdata_backup = files_table
					update_main_extdata = false
				else
					files_table = extdata_backup
				end
				extdata_directory = "/"
			else
				mode = "SDMC"
				System.currentDirectory("/")
				files_table = SortDirectory(System.listDirectory(System.currentDirectory()))
			end
		elseif (Controls.check(pad,KEY_L)) and not (Controls.check(oldpad,KEY_L)) then
			if (mode == "SDMC") then
				if (files_table[p].directory == false) then
					select_mode = true
				end
			end
		elseif (Controls.check(pad,KEY_R)) and not (Controls.check(oldpad,KEY_R)) then
			if (mode == "SDMC") then
				update_bottom_screen = true
				name = System.startKeyboard("New Folder")
				System.createDirectory(System.currentDirectory()..name)
				oldpad = KEY_A
				files_table = System.listDirectory(System.currentDirectory())
					if System.currentDirectory() ~= "/" then
						local extra = {}
						extra.name = ".."
						extra.size = 0
						extra.directory = true
						table.insert(files_table,extra)
					end
				files_table = SortDirectory(files_table)
			end
		elseif (Controls.check(pad,KEY_TOUCH)) then
			update_bottom_screen = true
			x,y = Controls.readTouch()
			new_index = math.ceil(y/15)
			if (new_index <= #files_table) then
				if master_index > 0 then
					p = new_index + master_index - 1
				else
					p = new_index
				end
			end
		elseif (Controls.check(pad,KEY_START)) then
			GarbageCollection()
			sm_index = 1
			oldpad = KEY_START
			while exit_flag == nil do
				Screen.refresh()
				Screen.waitVblankStart()
				pad = Controls.read()
				Screen.fillEmptyRect(10,300,20,37,black,BOTTOM_SCREEN)
				Screen.fillRect(11,299,21,36,white,BOTTOM_SCREEN)
				Screen.debugPrint(13,23,"ORGANIZ3D - Controls List",black,BOTTOM_SCREEN)
				if mode == "SDMC" then
					Screen.fillEmptyRect(10,300,50,232,black,BOTTOM_SCREEN)
					Screen.fillRect(11,299,51,231,white,BOTTOM_SCREEN)
					Screen.debugPrint(13,53,"Up/Down : Navigate through files",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,68,"Left/Rght : Reader actions",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,83,"Touch : Navigate through files",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,98,"CirclePad : Move image viewport",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,113,"A : Open file/folder",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,128,"Y : Move/Copy file/folder",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,143,"B : Rename file/folder",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,158,"X : Delete file/directory",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,173,"L : Open file as...",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,188,"R : Create new folder",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,203,"Select : Go to Extdata mode",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,218,"Start : Exit ORGANIZ3D",black,BOTTOM_SCREEN)
				else
					Screen.fillEmptyRect(10,300,50,157,black,BOTTOM_SCREEN)
					Screen.fillRect(11,299,51,156,white,BOTTOM_SCREEN)
					Screen.debugPrint(13,53,"Up/Down : Navigate through files",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,68,"Touch : Navigate through files",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,83,"A : Open file/folder",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,98,"B : Dump file/folder",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,113,"X : Restore file/directory",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,128,"Select : Go to Filebrowser mode",black,BOTTOM_SCREEN)
					Screen.debugPrint(13,143,"Start : Exit ORGANIZ3D",black,BOTTOM_SCREEN)
				end
				if (Controls.check(pad,KEY_START)) and not (Controls.check(oldpad,KEY_START)) then
					exit_flag = true
				elseif (Controls.check(pad,KEY_B)) and not (Controls.check(oldpad,KEY_B)) then
					exit_flag = false
				end
				Screen.flip()
				oldpad = pad
			end
			update_bottom_screen = true
			if exit_flag then
				Graphics.freeImage(bg)
				Sound.term()
				Graphics.term()
				Timer.destroy(ctrlTimer)
				System.exit()
			else
				exit_flag = nil
			end
		end
	end	
	if not (Controls.check(pad,KEY_TOUCH)) then
		update_bottom_screen = true
		master_index = p - 15
	end
	Screen.flip()
	Screen.waitVblankStart()
	oldpad = pad
end