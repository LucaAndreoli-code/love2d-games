local Debug = {}

Debug.active = false
if arg and arg[2] == "--debug" then
    Debug.active = true
end

function Debug.draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("Debug Mode", 10, 10)
    love.graphics.setColor(1, 1, 1)
end

return Debug
