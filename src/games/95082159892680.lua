return function(section, data)
    print("reached")
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    env.Farming = false
    env.WinStage = 1
    env.FastMode = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    setdata.winstage = setdata.winstage or 1
    setdata.fastmode = setdata.fastmode or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    print("yeah")

    elements:Label("Supports World 1 (Stages 1-14)", section)

    elements:Textbox("Win Stage", section, tostring(env.WinStage), function(v)
        local num = tonumber(v)
        if num and num <= 14 then
            env.WinStage = num
            getgenv().setconfig("winstage", num)
        end
    end)

    elements:Toggle("Fast Mode", section, env.FastMode, function(v)
        env.FastMode = v
        getgenv().setconfig("fastmode", v)
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
                local args = { "Walking" }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateSpeed"):FireServer(unpack(args))
                task.wait()
            end
        end)

        while env.Farming do
            pcall(function()
                local char = plr.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                for i = 1, env.WinStage do
                    if not env.Farming then break end

                    local targetStageName = "Stage" .. tostring(i + 1)
                    local winBlockName = "WinBlock" .. tostring(i)
                    
                    local stageFolder = workspace:FindFirstChild("Structure") and workspace.Structure:FindFirstChild(targetStageName)
                    if stageFolder then
                        local winBlock = stageFolder:FindFirstChild(winBlockName)
                        if winBlock then
                            -- Teleport character directly to the TouchInterest block
                            char:PivotTo(winBlock.CFrame + Vector3.new(0, 1.5, 0))
                            
                            -- Delay based on the Fast toggle
                            if env.FastMode then
                                task.wait(0.1)
                            else
                                task.wait(1.5)
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end
