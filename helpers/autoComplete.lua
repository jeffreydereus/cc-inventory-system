local completion = require("cc.completion")

local autoCompletion = {}

function autoComplete(text, commands)
    for pos, cmd in pairs(commands) do
        table.insert(autoCompletion, cmd.name)
    end
    return completion.choice(text, autoCompletion)
end

return { autoComplete = autoComplete }