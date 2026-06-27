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

    elements:Label("Currently supports up to 14 stages - By Jay", section)

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
                local head = char and char:FindFirstChild("Head")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not head or not hrp then return end

                local currentStageNum = env.WinStage
                local targetStageName = "Stage" .. tostring(currentStageNum + 1)
                local winBlockName = "WinBlock" .. tostring(currentStageNum)
                
                local stageFolder = workspace:FindFirstChild("Structure") and workspace.Structure:FindFirstChild(targetStageName)
                if stageFolder then
                    local winBlock = stageFolder:FindFirstChild(winBlockName)
                    if not winBlock then
                        for _, child in ipairs(stageFolder:GetChildren()) do
                            if child.Name:find("WinBlock") then
                                winBlock = child
                                break
                            end
                        end
                    end

                    if winBlock then
                        if firetouchinterest then
                            -- Best method: Tricks the game into thinking your head touched it without moving you
                            firetouchinterest(head, winBlock, 0)
                            task.wait(0.05)
                            firetouchinterest(head, winBlock, 1)
                        else
                            -- Fallback method: If firetouchinterest fails, bobs you up and down quickly
                            local originalCFrame = hrp.CFrame
                            hrp.CFrame = winBlock.CFrame * CFrame.new(0, 1, 0)
                            task.wait(0.05)
                            hrp.CFrame = winBlock.CFrame * CFrame.new(0, -1, 0)
                            task.wait(0.05)
                            hrp.CFrame = originalCFrame
                        end
                    end
                end
            end)
            
            if env.FastMode then
                task.wait(0.1)
            else
                task.wait(1.5)
            end
        end
    end)
end
