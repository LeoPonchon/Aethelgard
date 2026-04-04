--!nonstrict
-- Remote Helper for Client
-- Utility to wait for and retrieve remotes

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteHelper = {}

function RemoteHelper.waitForRemote(remoteName, timeout)
	timeout = timeout or 10
	local remote = ReplicatedStorage:FindFirstChild(remoteName)
	if remote then return remote end

	local startTime = tick()
	while tick() - startTime < timeout do
		remote = ReplicatedStorage:FindFirstChild(remoteName)
		if remote then return remote end
		task.wait(0.1)
	end

	warn("[RemoteHelper] Timeout waiting for remote:", remoteName)
	return nil
end

function RemoteHelper.waitForRemotes(remoteNames, timeout)
	timeout = timeout or 10
	local remotes = {}

	for _, name in ipairs(remoteNames) do
		remotes[name] = RemoteHelper.waitForRemote(name, timeout)
	end

	return remotes
end

return RemoteHelper
