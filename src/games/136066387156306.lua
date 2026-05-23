-- Be Flash for Brainrots

return function(section)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local repstorage = game:GetService("ReplicatedStorage")
    local eventsFold = repstorage.Events
    local dashev = repstorage.DashEvent
    local traintreadev = eventsFold.TrainTreadmillEvent

    local speedWalls = workspace.Gameplay.SpeedWalls
    workspace.Map.EntranceBlocker:Destroy()
    
    local plr = game:GetService("Players").LocalPlayer
    local stamamt = plr.StaminaLevel

    getgenv().FarmBrainrots = false

    local startPos = Vector3.new(-0, 3, 13)

    elements:Toggle("Farm Brainrots", section, function(bool)
        if bool then
            getgenv().FarmBrainrots = true

            while getgenv().FarmBrainrots do
                dashev:FireServer("StartCharge")
                task.wait()
                dashev:FireServer(3)
                task.wait()

                local char = plr.Character
                local humanoid = char.Humanoid
                local hrp = char.HumanoidRootPart

                local bestArea = speedWalls.SpeedWall_1
                for _, v in pairs(speedWalls:GetChildren()) do
                    if v == bestArea then continue end
                    if v:GetAttribute("ReqSpeed") > bestArea:GetAttribute("ReqSpeed") 
                        and stamamt.Value >= v:GetAttribute("ReqSpeed") then
                        bestArea = v
                    end
                end

                local stamina = stamamt.Value
                local chargeRatio = 1

                local distance
                local requirements = require(game:GetService("ReplicatedStorage").Modules.ZoneConfig)["REQUIREMENTS"]
                local baseDistance = 600
                local prevReq = 0
                local prevDist = 600

                for i = 1, #requirements do
                    local req = requirements[i]
                    local dist = i * 1000 + 32 + 20
                    if stamina < req then
                        local t
                        if prevReq > 0 and prevReq <= stamina then
                            t = (math.log10(stamina) - math.log10(prevReq)) / (math.log10(req) - math.log10(prevReq))
                        else
                            t = stamina / req
                        end
                        distance = prevDist + math.pow(math.clamp(t, 0, 1), 0.6) * (dist - prevDist)
                        break
                    end
                    prevDist = dist
                    prevReq = req
                end

                if not distance then
                    local logS = math.log10(stamina)
                    local logP = math.log10(prevReq)
                    local cap = prevReq * 15
                    local logC = math.log10(cap)
                    local t = math.clamp((logS - logP) / (logC - logP), 0, 1)
                    distance = prevDist + math.pow(t, 0.6) * 1000
                    distance = math.min(distance, (#requirements + 1) * 1000 - 64)
                end

                distance = math.max(300, distance * chargeRatio - 20)

                local launchSpeed = math.sqrt(distance * 150 + 3600)
                local decel = (launchSpeed ^ 2 - 3600) / (distance * 2)

                local runDirection = (bestArea.Position - hrp.Position).Unit
                runDirection = Vector3.new(runDirection.X, 0, runDirection.Z).Unit

                humanoid.WalkSpeed = launchSpeed

                local remainingDist = distance
                local lastPos = hrp.Position

                while remainingDist > 1 and humanoid.Health > 0 do
                    task.wait()
                    
                    local moved = (hrp.Position - lastPos):Dot(runDirection)
                    if moved > 0 then
                        remainingDist = remainingDist - moved
                    end
                    lastPos = hrp.Position
                    
                    local speedSq = math.max(3600, decel * 2 * math.max(0, remainingDist) + 3600)
                    humanoid.WalkSpeed = math.sqrt(speedSq)
                    
                    humanoid:Move(runDirection, false)
                end

                humanoid.WalkSpeed = 32
                humanoid:Move(Vector3.new(0, 0, 0))

                task.wait(0.5)
                dashev:FireServer("EndWarp")
                task.wait(5)
            end
        else
            getgenv().FarmBrainrots = false
        end
    end)
end
