--MMMMMMMM               MMMMMMMMIIIIIIIIII   SSSSSSSSSSSSSSS TTTTTTTTTTTTTTTTTTTTTTT
--M:::::::M             M:::::::MI::::::::I SS:::::::::::::::ST:::::::::::::::::::::T
--M::::::::M           M::::::::MI::::::::IS:::::SSSSSS::::::ST:::::::::::::::::::::T
--M:::::::::M         M:::::::::MII::::::IIS:::::S     SSSSSSST:::::TT:::::::TT:::::T
--M::::::::::M       M::::::::::M  I::::I  S:::::S            TTTTTT  T:::::T  TTTTTT
--M:::::::::::M     M:::::::::::M  I::::I  S:::::S                    T:::::T        
--M:::::::M::::M   M::::M:::::::M  I::::I   S::::SSSS                 T:::::T        
--M::::::M M::::M M::::M M::::::M  I::::I    SS::::::SSSSS            T:::::T        
--M::::::M  M::::M::::M  M::::::M  I::::I      SSS::::::::SS          T:::::T        
--M::::::M   M:::::::M   M::::::M  I::::I         SSSSSS::::S         T:::::T        
--M::::::M    M:::::M    M::::::M  I::::I              S:::::S        T:::::T        
--M::::::M     MMMMM     M::::::M  I::::I              S:::::S        T:::::T        
--M::::::M               M::::::MII::::::IISSSSSSS     S:::::S      TT:::::::TT      
--M::::::M               M::::::MI::::::::IS::::::SSSSSS:::::S      T:::::::::T       
--M::::::M               M::::::MI::::::::IS:::::::::::::::SS       T:::::::::T      
--MMMMMMMM               MMMMMMMMIIIIIIIIII SSSSSSSSSSSSSSS         TTTTTTTTTTT 

local object = nil
local objectCoords = vector3(-843.693359, -811.919861, 31.0244923) -- Replace with the real coordinates for the flag position
local objectGround = vector3(-843.83746337891, -811.98425292969, 20.771106719971) -- Replace with the real coordinates for the player interaction
local spawnDistance = 50.0  -- Spawn's distance from the object in relation to the player
local isMovingDown = true
local totalDescent = 0.0
local descentStep = 0.035
local flagspeed = 100 -- the speed for flag movement animation
local flag = "prop_flag_us" -- default object model

function createObject(model)
    if object then
        deleteObject()
    end
    object = CreateObject(GetHashKey(model), objectCoords.x, objectCoords.y, objectCoords.z, true, true, true)
    -- Update object coordinates
    objectCoords = vector3(objectCoords.x, objectCoords.y, objectCoords.z)
end

function deleteObject()
    if object then
        DeleteEntity(object)
        object = nil
    end
end

function drawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.3, 0.3)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function animateCharacter()
    local playerPed = PlayerPedId()
    RequestAnimDict("amb@prop_human_movie_bulb@base")
        Citizen.Wait(flagspeed)
    FreezeEntityPosition(playerPed, true)
    TaskPlayAnim(playerPed, "amb@prop_human_movie_bulb@base", "base", 1.0, -3.0, 2000, 0, 0, false, false, false)
    FreezeEntityPosition(playerPed, false)
end


--RegisterCommand("changeflag", function(source, args)
--    local model = args[1]
--    if model then
--        createObject(model)
--    else
--        print("Usage: /changeflag [object_model]")
--    end
--end)
--
--Citizen.CreateThread(function()
--    TriggerEvent("chat:addSuggestion", "/changeflag", "Changes the flag object", {
--        {name = 'object_model', help = "The model name of the flag object"}
--    })
--end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - objectGround)

        if not object and distance < spawnDistance then
            createObject(flag) -- default object model
        elseif object and distance >= spawnDistance then
            deleteObject()
        end

        if object then
            local distanceToObject = #(playerCoords - objectGround)

            if distanceToObject < 3.0 then
                if isMovingDown then 
                    drawText3D(objectGround.x, objectGround.y, objectGround.z, "🚩 [H] ~b~Lower Flag~s~")
                else
                    drawText3D(objectGround.x, objectGround.y, objectGround.z, "🚩 [H] ~b~Raise Flag~s~")
                end
            end

            if distanceToObject < 2.0 then
                if IsControlJustReleased(0, 74) then
                    while (isMovingDown and totalDescent < 5.0) or (not isMovingDown and totalDescent > 0.0) do
                        animateCharacter()
                        SetEntityCoordsNoOffset(object, objectCoords.x, objectCoords.y, objectCoords.z - totalDescent, true, true, true)
                        totalDescent = isMovingDown and (totalDescent + descentStep) or (totalDescent - descentStep)
                    end
                    isMovingDown = not isMovingDown
                end
            end
        else
            -- If the object does not exist and the player is out of the area, wait 5 seconds
            Citizen.Wait(5000)
        end
    end
end)
