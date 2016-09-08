--------------------------- ORGANIZ3D Theme sample file -----------------------------
-- Colors must be RGB or RGBA (http://www.rapidtables.com/web/color/RGB_Color.htm) --
-------------------------------------------------------------------------------------

-- INFOS --
theme_name = "Cyan Esdeath"
author = "Rinnegatamante"

-- COLORS --
menu_color = Color.new(255,255,0) -- Color of text for not selected filebrowser item
selected_color = Color.new(255,0,0) -- Color of text for selected filebrowser item
selected_item = Color.new(0,0,200,50) -- Color of background for selected filebrowser item

-- BACKGROUND IMAGE --
bg = Graphics.loadImage(System.currentDirectory().."/bg.bmp") -- Background image path