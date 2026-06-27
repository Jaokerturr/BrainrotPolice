return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer
    local PathfindingService = game:GetService("PathfindingService")

    env.Farming = false
    env.WinStage = 1
    env.FastMode = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    setdata.winstage = setdata.winstage or 1
    setdata.fastmode = setdata.fastmode or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Label("Currently supports up to 14 stages - By thejaokertur", section)

    elements:Textbox("Win Stage", section, tostring(env.WinStage), function(v)
        local num = tonumber(v)
        if num then
            env.WinStage = num
            getgenv().setconfig("winstage", num)
        end
    end)

    elements:Toggle("Fast Mode", section, env.FastMode, function(v)
        env.FastMode = v
        getgenv().setconfig("fastmode", v)
    end)

    elements:Toggle("Autofarm", section, env.Farming, function(v)
        env.Farming = v
        getgenv().setconfig("farming", v)

        if not v then return end

        spawn(function()
            while env.Farming do
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateSpeed"):FireServer("Walking")
                task.wait()
            end
        end)

        while env.Farming do
            pcall(function()
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local humanoid = char and char:FindFirstChild("Humanoid")
                
                if not hrp or not humanoid then return end

                local targetStageName = "Stage" .. tostring(env.WinStage + 1)
                local winBlockName = "WinBlock" .. tostring(env.WinStage)
                local stageFolder = workspace:FindFirstChild("Structure") and workspace.Structure:FindFirstChild(targetStageName)
                
                if stageFolder then
                    local winBlock = stageFolder:FindFirstChild(winBlockName)
                    
                    -- Conditional Logic: Walking for 1-5, TouchInterest for 6+
                    if env.WinStage <= 5 then
                        local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 6, AgentCanJump = true})
                        path:ComputeAsync(hrp.Position, winBlock.Position)
                        if path.Status == Enum.PathStatus.Success then
                            for _, waypoint in ipairs(path:GetWaypoints()) do
                                if not env.Farming then break end
                                if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
                                humanoid:MoveTo(waypoint.Position)
                                humanoid.MoveToFinished:Wait()
                            end
                        end
                    else
                        -- TouchInterest Method for 6+
                        if firetouchinterest and head and winBlock then
                            firetouchinterest(head, winBlock, 0)
                            task.wait(0.05)
                            firetouchinterest(head, winBlock, 1)
                        elseif hrp and winBlock then
                            local oldPos = hrp.CFrame
                            hrp.CFrame = winBlock.CFrame
                            task.wait(0.05)
                            hrp.CFrame = oldPos
                        end
                    end
                end
            end)
            
            task.wait(env.FastMode and 0.1 or 1.5)
        end
    end)
end
