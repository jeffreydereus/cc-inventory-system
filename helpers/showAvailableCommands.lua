function showAvailableCommands(commands)
	for pos, cmd in pairs(commands) do
		write(("%s | %s | %s \n"):format(cmd.name, cmd.params, cmd.description))
	end
end

return { showAvailableCommands = showAvailableCommands }