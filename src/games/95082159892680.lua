return function(section, data)
    print("reached")
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer
    local PathfindingService = game:GetService("PathfindingService")

    env.Farming = false
    env.WinStage = 1

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    setdata.winstage = setdata.winstage or 1
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    print("yeah")

    elements:Label("supports all stages - By Jay", section)

    elements:Textbox("Win Stage", section, tostring(env.WinStage), function(v)
        env.WinStage = tonumber(v)
        getgenv().setconfig("winstage", tonumber(v))
    end)

    local part = Instance.new("Part")
    part.Anchored = true
    part.Size = Vector3.new(10, 1, 546)
    part.Position = Vector3.new(1, 75, 1090)
    part.Parent = workspace

    elements:Toggle("Autofarm", section, env.Farming, function(v)
        env.Farming = v
        getgenv().setconfig("farming", v)

        if not v then return end

        spawn(function()
            while env.Farming do
                local args = {
                    "Walking"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateSpeed"):FireServer(unpack(args))
                task.wait()
            end
        end)

        while env.Farming do
            pcall(function()
                local currentStageNum = env.WinStage
                local targetStageName = "Stage" .. tostring(currentStageNum + 1)
                local winBlockName = "WinBlock" .. tostring(currentStageNum)
                
                local structure = workspace:FindFirstChild("Structure")
                if not structure then 
                    task.wait(1) 
                    return 
                end
                
                local stageFolder = structure:FindFirstChild(targetStageName)
                if not stageFolder then
                    warn("Target stage folder not found: " .. targetStageName)
                    task.wait(1)
                    return
                end
                
                local winBlock = stageFolder:FindFirstChild(winBlockName)
                if not winBlock then
                    for _, child in ipairs(stageFolder:GetChildren()) do
                        if child.Name:find("WinBlock") then
                            winBlock = child
                            break
                        end
                    end
                end
                
                if winBlock and winBlock:IsA("BasePart") and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = plr.Character.Humanoid
                    local hrp = plr.Character.HumanoidRootPart
                    
                    for _, descendant in ipairs(stageFolder:GetDescendants()) do
                        if descendant:IsA("TouchInterest") and descendant.Parent ~= winBlock then
                            descendant:Destroy()
                        end
                        
                        if descendant:IsA("BasePart") and descendant ~= winBlock then
                            descendant.CanCollide = false
                        end
                    end
                    
                    local path = PathfindingService:CreatePath({
                        AgentRadius = 3,
                        AgentHeight = 6,
                        AgentCanJump = true
                    })
                    
                    path:ComputeAsync(hrp.Position, winBlock.Position)
                    
                    if path.Status == Enum.PathStatus.Success then
                        local waypoints = path:GetWaypoints()
                        
                        for _, waypoint in ipairs(waypoints) do
                            if not env.Farming or env.WinStage ~= currentStageNum then break end
                            
                            if waypoint.Action == Enum.PathWaypointAction.Jump then
                                humanoid.Jump = true
                            end
                            
                            humanoid:MoveTo(waypoint.Position)
                            
                            local completed = false
                            local connection
                            connection = humanoid.MoveToFinished:Connect(function()
                                completed = true
                                connection:Disconnect()
                            end)
                            
                            local startTime = os.clock()
                            while not completed and (os.clock() - startTime) < 4 do
                                task.wait(0.05)
                                if not env.Farming then break end
                            end
                            if connection then connection:Disconnect() end
                        end
                    else
                        humanoid:MoveTo(winBlock.Position)
                        humanoid.Humanoid.MoveToFinished:Wait()
                    end
                    
                    task.wait(1)
                else
                    task.wait(1)
                end
            end)
            task.wait(0.1)
        end
    end)
end
