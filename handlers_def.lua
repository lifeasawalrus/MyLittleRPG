-- Standard callback handlers.
love.handlers = setmetatable({
    keypressed = function (b,s,r)
        if love.keypressed then return love.keypressed(b,s,r) end
    end,
    keyreleased = function (b,s)
        if love.keyreleased then return love.keyreleased(b,s) end
    end,
    textinput = function (t)
        if love.textinput then return love.textinput(t) end
    end,
    textedited = function (t,s,l)
        if love.textedited then return love.textedited(t,s,l) end
    end,
    mousemoved = function (x,y,dx,dy,t)
        if love.mousemoved then return love.mousemoved(x,y,dx,dy,t) end
    end,
    mousepressed = function (x,y,b,t,c)
        if love.mousepressed then return love.mousepressed(x,y,b,t,c) end
    end,
    mousereleased = function (x,y,b,t,c)
        if love.mousereleased then return love.mousereleased(x,y,b,t,c) end
    end,
    wheelmoved = function (x,y)
        if love.wheelmoved then return love.wheelmoved(x,y) end
    end,
    touchpressed = function (id,x,y,dx,dy,p)
        if love.touchpressed then return love.touchpressed(id,x,y,dx,dy,p) end
    end,
    touchreleased = function (id,x,y,dx,dy,p)
        if love.touchreleased then return love.touchreleased(id,x,y,dx,dy,p) end
    end,
    touchmoved = function (id,x,y,dx,dy,p)
        if love.touchmoved then return love.touchmoved(id,x,y,dx,dy,p) end
    end,
    joystickpressed = function (j,b)
        if love.joystickpressed then return love.joystickpressed(j,b) end
    end,
    joystickreleased = function (j,b)
        if love.joystickreleased then return love.joystickreleased(j,b) end
    end,
    joystickaxis = function (j,a,v)
        if love.joystickaxis then return love.joystickaxis(j,a,v) end
    end,
    joystickhat = function (j,h,v)
        if love.joystickhat then return love.joystickhat(j,h,v) end
    end,
    gamepadpressed = function (j,b)
        if love.gamepadpressed then return love.gamepadpressed(j,b) end
    end,
    gamepadreleased = function (j,b)
        if love.gamepadreleased then return love.gamepadreleased(j,b) end
    end,
    gamepadaxis = function (j,a,v)
        if love.gamepadaxis then return love.gamepadaxis(j,a,v) end
    end,
    joystickadded = function (j)
        if love.joystickadded then return love.joystickadded(j) end
    end,
    joystickremoved = function (j)
        if love.joystickremoved then return love.joystickremoved(j) end
    end,
    focus = function (f)
        if love.focus then return love.focus(f) end
    end,
    mousefocus = function (f)
        if love.mousefocus then return love.mousefocus(f) end
    end,
    visible = function (v)
        if love.visible then return love.visible(v) end
    end,
    quit = function ()
        return
    end,
    threaderror = function (t, err)
        if love.threaderror then return love.threaderror(t, err) end
    end,
    resize = function (w, h)
        if love.resize then return love.resize(w, h) end
    end,
    filedropped = function (f)
        if love.filedropped then return love.filedropped(f) end
    end,
    directorydropped = function (dir)
        if love.directorydropped then return love.directorydropped(dir) end
    end,
    lowmemory = function ()
        if love.lowmemory then love.lowmemory() end
        collectgarbage()
        collectgarbage()
    end,
    displayrotated = function (display, orient)
        if love.displayrotated then return love.displayrotated(display, orient) end
    end,
}, {
    __index = function(self, name)
        error("Unknown event: " .. name)
    end,
})
