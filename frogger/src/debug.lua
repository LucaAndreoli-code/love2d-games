local Debug = {
    enabled = false
}

function Debug:toggle(key)
    if key ~= 'd' then
        return
    end
    self.enabled = not self.enabled
end

return Debug
