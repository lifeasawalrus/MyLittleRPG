
function Initialize()
    love.graphics.setDefaultFilter("nearest", "nearest")
    --love.graphics.setBackgroundColor(Color(0,180,0))
    --love.window.maximize()
    love.window.setMode(2048, 1024, {resizable=true}) --2048, 1024, {resizeable=true}
    math.randomseed(os.time())
    SCREEN_WIDTH = love.graphics.getWidth()
    SCREEN_HEIGHT = love.graphics.getHeight()
    love.window.setTitle("ponygame")

    GOTHIC = Init_font()
    Menu:init()
    Menu:char_select_init()

end

