
Controller = {}

function Input(button)
    for i in ipairs(Controller) do
        if Controller[i]:isGamepadDown(button) then
            return true
        end
    end
    return false
end

function InputAxis(axis)
    for i in ipairs(Controller) do
        if math.abs(Controller[i]:getGamepadAxis(axis)) > MOVE_CAP then
            return Controller[i]:getGamepadAxis(axis)
        end
    end
    return 0
end

