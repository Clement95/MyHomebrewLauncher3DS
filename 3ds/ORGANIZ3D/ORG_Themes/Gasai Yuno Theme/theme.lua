--------------------------- ORGANIZ3D Theme sample file -----------------------------
-- Colors must be RGB or RGBA (http://www.rapidtables.com/web/color/RGB_Color.htm) --
-------------------------------------------------------------------------------------

-- INFOS --
theme_name = "Gasai Yuno Theme"
author = "Rinnegatamante"

-- COLORS --
menu_color = Color.new(255,255,255) -- Color of text for not selected filebrowser item
selected_color = Color.new(0,255,0) -- Color of text for selected filebrowser item
selected_item = Color.new(0,0,200,50) -- Color of background for selected filebrowser item

-- BACKGROUND IMAGE --
bg = Graphics.loadImage(System.currentDirectory().."/bg.png") -- Background image path