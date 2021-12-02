local Tunnel = module("_core", "lib/Tunnel")
local Proxy = module("_core", "lib/Proxy")

cAPI = Proxy.getInterface("API")
API = Tunnel.getInterface("API")

cam = nil
hided = false
spawnedCamera = nil
choosePed = {}
pedSelected = nil
sex = nil
zoom = 4.0
offset = 0.2
DeleteeEntity = true
local InterP = true
local adding = true

local showroomHorse_entity
local showroomHorse_model

local MyHorse_entity
local IdMyHorse
cameraUsing = {
    {
        name = "Horse",
        x = 0.2,
        y = 0.0,
        z = 1.8
    },
    {
        name = "Eyes",
        x = 0.0,
        y = -0.4,
        z = 0.65
    }
}

local saddlecloths = {}
local acshorn = {}
local bags = {}
local horsetails = {}
local manes = {}
local saddles = {}
local stirrups = {}
local acsluggage = {}

Citizen.CreateThread(
    function()
        while adding do
            Citizen.Wait(0)
            for i, v in ipairs(HorseComp) do
                if v.category == "Saddlecloths" then
                    table.insert(saddlecloths, v.Hash)
                elseif v.category == "AcsHorn" then
                    table.insert(acshorn, v.Hash)
                elseif v.category == "Bags" then
                    table.insert(bags, v.Hash)
                elseif v.category == "HorseTails" then
                    table.insert(horsetails, v.Hash)
                elseif v.category == "Manes" then
                    table.insert(manes, v.Hash)
                elseif v.category == "Saddles" then
                    table.insert(saddles, v.Hash)
                elseif v.category == "Stirrups" then
                    table.insert(stirrups, v.Hash)
                elseif v.category == "AcsLuggage" then
                    table.insert(acsluggage, v.Hash)
                end
            end
            adding = false
        end
    end
)

RegisterCommand(
    "stable",
    function()
        OpenStable()
    end
)

function OpenStable()
    inCustomization = true
    horsesp = true

    local playerHorse = MyHorse_entity

    SetEntityHeading(playerHorse, 334)
    DeleteeEntity = true
    SetNuiFocus(true, true)
    InterP = true

    local hashm = GetEntityModel(playerHorse)

    if hashm ~= nil and IsPedOnMount(PlayerPedId()) then
        createCamera(PlayerPedId())
    else
        createCamera(PlayerPedId())
    end
    --  SetEntityVisible(PlayerPedId(), false)
    if not alreadySentShopData then
        SendNUIMessage(
            {
                action = "show",
                shopData = getShopData()
            }
        )
    else
        SendNUIMessage(
            {
                action = "show"
            }
        )
    end
    TriggerServerEvent("FRP:STABLE:AskForMyHorses")
end

local promptGroup
local varStringCasa = CreateVarString(10, "LITERAL_STRING", "Stable")
local blip
local prompts = {}
local SpawnPoint = {}
local StablePoint = {}
local HeadingPoint
local CamPos = {}


Citizen.CreateThread(
    function()
        while true do
            Wait(1)
            local coords = GetEntityCoords(PlayerPedId())
            for _, prompt in pairs(prompts) do
                if PromptIsJustPressed(prompt) then
                    for k, v in pairs(Config.Stables) do
                        if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 7 then
                            HeadingPoint = v.Heading
                            StablePoint = {v.Pos.x, v.Pos.y, v.Pos.z}
                            CamPos = {v.SpawnPoint.CamPos.x, v.SpawnPoint.CamPos.y}
                            SpawnPoint = {x = v.SpawnPoint.Pos.x, y = v.SpawnPoint.Pos.y, z = v.SpawnPoint.Pos.z, h = v.SpawnPoint.Heading}
                            Wait(300)
                        end
                    end
                    OpenStable()
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        for _, v in pairs(Config.Stables) do
            -- blip = N_0x554d9d53f696d002(1664425300, v.Pos.x, v.Pos.y, v.Pos.z)
            SetBlipSprite(blip, -145868367, 1)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, "Stable")
            local prompt = PromptRegisterBegin()
            PromptSetActiveGroupThisFrame(promptGroup, varStringCasa)
            PromptSetControlAction(prompt, 0xE8342FF2)
            PromptSetText(prompt, CreateVarString(10, "LITERAL_STRING", "Access Stable"))
            PromptSetStandardMode(prompt, true)
            PromptSetEnabled(prompt, 1)
            PromptSetVisible(prompt, 1)
            PromptSetHoldMode(prompt, 1)
            PromptSetPosition(prompt, v.Pos.x, v.Pos.y, v.Pos.z)
            N_0x0c718001b77ca468(prompt, 3.0)
            PromptSetGroup(prompt, promptGroup)
            PromptRegisterEnd(prompt)
            table.insert(prompts, prompt)
        end
    end
)

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if resourceName == GetCurrentResourceName() then
            for _, prompt in pairs(prompts) do
                PromptDelete(prompt)
                RemoveBlip(blip)
            end
        end
    end
)

-- function deletePrompt()
--     if prompt ~= nil then
--         PromptSetVisible(prompt, false)
--         PromptSetEnabled(prompt, false)
--         PromptDelete(prompt)
--         prompt = nil
--         promptGroup = nil
--     end
-- end

function rotation(dir)
    local playerHorse = MyHorse_entity
    local pedRot = GetEntityHeading(playerHorse) + dir
    SetEntityHeading(playerHorse, pedRot % 360)
end

RegisterNUICallback(
    "rotate",
    function(data, cb)
        if (data["key"] == "left") then
            rotation(20)
        else
            rotation(-20)
        end
        cb("ok")
    end
)

-- AddEventHandler(
--     'onResourceStop',
--     function(resourceName)
--         if resourceName == GetCurrentResourceName() then
--             for _, prompt in pairs(prompts) do
--                 PromptDelete(prompt)
-- 			end
--         end
--     end
-- )

AddEventHandler(
    "onResourceStop",
    function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
            return
        end
        SetNuiFocus(false, false)
        SendNUIMessage(
            {
                action = "hide"
            }
        )
    end
)

function createCam(creatorType)
    for k, v in pairs(cams) do
        if cams[k].type == creatorType then
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cams[k].x, cams[k].y, cams[k].z, cams[k].rx, cams[k].ry, cams[k].rz, cams[k].fov, false, 0) -- CAMERA COORDS
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 3000, true, false)
            createPeds()
        end
    end
end

RegisterNUICallback(
    "Saddles",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            SaddlesUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xBAA7E618, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. saddles[num])
            setcloth(hash)
            SaddlesUsing = ("0x" .. saddles[num])
        end
    end
)

RegisterNUICallback(
    "Saddlecloths",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            SaddleclothsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. saddlecloths[num])
            setcloth(hash)
            SaddleclothsUsing = ("0x" .. saddlecloths[num])
        end
    end
)

RegisterNUICallback(
    "Stirrups",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            StirrupsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xDA6DADCA, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. stirrups[num])
            setcloth(hash)
            StirrupsUsing = ("0x" .. stirrups[num])
        end
    end
)

RegisterNUICallback(
    "Bags",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            BagsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x80451C25, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. bags[num])
            setcloth(hash)
            BagsUsing = ("0x" .. bags[num])
        end
    end
)

RegisterNUICallback(
    "Manes",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            ManesUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xAA0217AB, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. manes[num])
            setcloth(hash)
            ManesUsing = ("0x" .. manes[num])
        end
    end
)

RegisterNUICallback(
    "HorseTails",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            HorseTailsUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x17CEB41A, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. horsetails[num])
            setcloth(hash)
            HorseTailsUsing = ("0x" .. horsetails[num])
        end
    end
)

RegisterNUICallback(
    "AcsHorn",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            AcsHornUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0x5447332, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. acshorn[num])
            setcloth(hash)
            AcsHornUsing = ("0x" .. acshorn[num])
        end
    end
)

RegisterNUICallback(
    "AcsLuggage",
    function(data)
        zoom = 4.0
        offset = 0.2
        if tonumber(data.id) == 0 then
            num = 0
            AcsLuggageUsing = num
            local playerHorse = MyHorse_entity
            Citizen.InvokeNative(0xD710A5007C2AC539, playerHorse, 0xEFB31921, 0) -- HAT REMOVE
            Citizen.InvokeNative(0xCC8CA3E88256E58F, playerHorse, 0, 1, 1, 1, 0) -- Actually remove the component
        else
            local num = tonumber(data.id)
            hash = ("0x" .. acsluggage[num])
            setcloth(hash)
            AcsLuggageUsing = ("0x" .. acsluggage[num])
        end
    end
)

myHorses = {}

function setcloth(hash)
    local model2 = GetHashKey(tonumber(hash))
    if not HasModelLoaded(model2) then
        Citizen.InvokeNative(0xFA28FE3A6246FC30, model2)
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(hash), true, true, true)
end

RegisterNUICallback(
    "selectHorse",
    function(data)
        print(data.horseID)
        TriggerServerEvent("FRP:STABLE:SelectHorseWithId", tonumber(data.horseID))
    end
)

RegisterNUICallback(
    "sellHorse",
    function(data)
        print(data.horseID)
        DeleteEntity(showroomHorse_entity)
        TriggerServerEvent("FRP:STABLE:SellHorseWithId", tonumber(data.horseID))
        TriggerServerEvent("FRP:STABLE:AskForMyHorses")
    end
)

RegisterNetEvent("FRP:STABLE:ReceiveHorsesData")
AddEventHandler(
    "FRP:STABLE:ReceiveHorsesData",
    function(dataHorses)
        SendNUIMessage(
            {
                myHorsesData = dataHorses
            }
        )
    end
)


SaddlesUsing = nil
SaddleclothsUsing = nil
StirrupsUsing = nil
BagsUsing = nil
ManesUsing = nil
HorseTailsUsing = nil
AcsHornUsing = nil
AcsLuggageUsing = nil

--- /// ARRASTAR CAVALO

local alreadySentShopData = false



function getShopData()
    alreadySentShopData = true
 
    local ret = {
        {
            name = "Work Horses",
            ["A_C_Horse_AmericanPaint_SplashedWhite"] = {"American Paint Splashed White", 20, 50},
            ["A_C_Horse_AmericanPaint_Overo"] = {"American Paint Overo", 21, 55},
            ["A_C_Horse_AmericanPaint_Greyovero"] = {"American Paint Grey Overo", 20, 50},
            ["A_C_Horse_AmericanPaint_Tobiano"] = {"American Paint Tobiano", 21, 55},
            ["A_C_Horse_Appaloosa_BrownLeopard"] = {"Appaloosa Brown Leopard", 20, 50},
            ["A_C_Horse_Appaloosa_Blanket"] = {"Appaloosa Blanket", 21, 55},
            ["A_C_Horse_Appaloosa_LeopardBlanket"] = {"Appaloosa Leopard Blanket", 20, 50},
            ["A_C_Horse_Appaloosa_Leopard"] = {"Appaloosa Leopard", 21, 55},
            ["A_C_Horse_Appaloosa_FewSpotted_PC"] = {"Appaloosa Few Spotted", 21, 55},
            ["A_C_Horse_DutchWarmblood_SootyBuckskin"] = {"Dutch Warmblood Sooty Buckskin", 20, 50},
            ["A_C_Horse_DutchWarmblood_SealBrown"] = {"Dutch Warmblood Seal Brown", 21, 55},
            ["A_C_Horse_DutchWarmblood_ChocolateRoan"] = {"Dutch Warmblood Chocolate Roan", 21, 55},
        },
        {
            name = "Top Quality Horses",
            ["A_C_Horse_Arabian_Black"] = {"Arabian Black", 5, 17},
            ["A_C_Horse_Arabian_Grey"] = {"Arabian Grey", 20, 50},
            ["A_C_Horse_Arabian_RedChestnut"] = {"Arabian Red Chestnut", 21, 55},
            ["A_C_Horse_Arabian_RoseGreyBay"] = {"Arabian Rose Gray Bay", 20, 50},
            ["A_C_Horse_Arabian_White"] = {"Arabian White", 21, 55},
            ["A_C_Horse_Arabian_WarpedBrindle_PC"] = {"Arabian Warped Brindle", 21, 55},
        },
        {
            name = "Saddle Horses",
            ["A_C_HORSEMULE_01"] = {"Mule", 5, 17},
            ["A_C_Horse_KentuckySaddle_Black"] = {"Kentucky Saddler Black", 20, 50},
            ["A_C_Horse_KentuckySaddle_ButterMilkBuckskin_PC"] = {"Kentucky Saddler Buttmilk Buckskin", 21, 55},
            ["A_C_Horse_KentuckySaddle_ChestnutPinto"] = {"Kentucky Saddler Chestnut Pinto", 20, 50},
            ["A_C_Horse_KentuckySaddle_Grey"] = {"Kentucky Saddler Grey", 21, 55},
            ["A_C_Horse_KentuckySaddle_SilverBay"] = {"Kentucky Saddler Silver Bay", 20, 50},
            ["A_C_Horse_Morgan_Bay"] = {"Morgan Bay", 21, 55},
            ["A_C_Horse_Morgan_BayRoan"] = {"Morgan Bay Roan", 20, 50},
            ["A_C_Horse_Morgan_FlaxenChestnut"] = {"Morgan Flaxen Chestnut", 21, 55},
            ["A_C_Horse_Morgan_LiverChestnut_PC"] = {"Morgan Liver Chestnut", 20, 50},
            ["A_C_Horse_Morgan_Palomino"] = {"Morgan Palomino", 21, 55},
        },
        {
            name = "Versatile Horses",
            ["A_C_Horse_Breton_MealyDappleBay"] = {"Breton Mealy Dapple Bay", 5, 17},
            ["A_C_Horse_Breton_SteelGrey"] = {"Breton Steel Grey", 20, 50},
            ["A_C_Horse_Breton_GrulloDun"] = {"Breton Grullo Dun", 21, 55},
            ["A_C_Horse_Breton_SealBrown"] = {"Breton Seal Brown", 21, 55},
            ["A_C_Horse_Breton_Sorrel"] = {"Breton Sorrel", 21, 55},
            ["A_C_Horse_Breton_RedRoan"] = {"Breton Red Roan", 21, 55},
            ["A_C_Horse_GypsyCob_SplashedPiebald"] = {"Gypsy Cob Splashed Pie Bald", 5, 17},
            ["A_C_Horse_GypsyCob_Skewbald"] = {"Gypsy Cob Skewbald", 20, 50},
            ["A_C_Horse_GypsyCob_Piebald"] = {"Gypsy Cob Piebal", 21, 55},
            ["A_C_Horse_GypsyCob_PalominoBlagdon"] = {"Gypsy Cob Palomino Blagdon", 21, 55},
            ["A_C_Horse_GypsyCob_SplashedBay"] = {"Gypsy Cob Splashed Bay", 21, 55},
            ["A_C_Horse_GypsyCob_WhiteBlagdon"] = {"Gypsy Cob White Blagdon", 21, 55},
            ["A_C_Horse_Criollo_BayBrindle"] = {"Criollo Bay Brindle", 5, 17},
            ["A_C_Horse_Criollo_BayFrameOvero"] = {"Criollo Bay Frame OVero", 20, 50},
            ["A_C_Horse_Criollo_SorrelOvero"] = {"Criollo Sorrel Overo", 21, 55},
            ["A_C_Horse_Criollo_Dun"] = {"Criollo Dun", 21, 55},
            ["A_C_Horse_Criollo_BlueRoanOvero"] = {"Criollo Blue Roan Overo", 21, 55},
            ["A_C_Horse_Criollo_MarbleSabino"] = {"Criollo Marble Sabino", 21, 55},
            ["A_C_Horse_Kladruber_Black"] = {"Kladruber Black", 5, 17},
            ["A_C_Horse_Kladruber_DappleRoseGrey"] = {"Kladruber Dapple Rose Grey", 20, 50},
            ["A_C_Horse_Kladruber_White"] = {"Kladruber White", 21, 55},
            ["A_C_Horse_Kladruber_Grey"] = {"Kladruber Grey", 21, 55},
            ["A_C_Horse_Kladruber_Cremello"] = {"Kladruber Cremello", 21, 55},
            ["A_C_Horse_Kladruber_Silver"] = {"Kladruber Silver", 21, 55},
            ["A_C_Horse_MissouriFoxtrotter_SilverDapplePinto"] = {"Missouri Fox Trotter Silver Dapple Pinto", 5, 17},
            ["A_C_Horse_MissouriFoxTrotter_AmberChampagne"] = {"Missouri Fox Trotter Amber Champagn", 20, 50},
            ["A_C_Horse_Mustang_TigerStripedBay"] = {"Mustang Tiger Striped Bay", 21, 55},
            ["A_C_Horse_Mustang_Buckskin"] = {"Mustang Buckskin", 21, 55},
            ["A_C_Horse_Mustang_Wildbay"] = {"Mustang Wildbay", 21, 55},
            ["A_C_Horse_NorfolkRoadster_RoseGrey"] = {"Norfolk Roadster Rose Grey", 21, 55},
            ["A_C_Horse_NorfolkRoadster_SpeckledGrey"] = {"Norfolk Roadster Speckled Grey", 5, 17},
            ["A_C_Horse_NorfolkRoadster_Black"] = {"Norfolk Roadster Black", 20, 50},
            ["A_C_Horse_NorfolkRoadster_SpottedTricolor"] = {"Norfolk Roadster Spotted Tricolor", 21, 55},
            ["A_C_Horse_NorfolkRoadster_PieBaldRoan"] = {"Norfolk Roadster Pie Bald Roan", 21, 55},
            ["A_C_Horse_NorfolkRoadster_DappledBuckSkin"] = {"Norfolk Roadster Dappled Buck Skin", 21, 55},
            ["A_C_Horse_Turkoman_Gold"] = {"Turkoman Gold", 21, 55},
            ["A_C_Horse_Turkoman_DarkBai"] = {"Turkoman Dark Bay", 21, 55},
            ["A_C_Horse_Turkoman_Silver"] = {"Turkoman Silver", 21, 55},
 
        },
        {
            name = "Race horses",
            ["A_C_Horse_Nokota_BlueRoan"] = {"Nokota Blue Roan", 47, 130},
            ["A_C_Horse_Nokota_ReverseDappleRoan"] = {"Nokota Reverse Dapple Roan.", 135, 450},
            ["A_C_Horse_Nokota_WhiteRoan"] = {"Nokota White Roan", 47, 130},
            ["A_C_Horse_Thoroughbred_Brindle"] = {"Thoroughbred Brindle", 47, 130},
            ["A_C_Horse_Thoroughbred_DappleGrey"] = {"Thoroughbred Dapple Grey", 47, 130},
            ["A_C_Horse_Thoroughbred_BlackChestnut"] = {"Thoroughbred Black Chestnut", 47, 130},
            ["A_C_Horse_Thoroughbred_BloodBay"] = {"Thoroughbred Blood Bay", 135, 450},
            ["A_C_Horse_Thoroughbred_ReverseDappleBlack"] = {"Thoroughbred Reverse Dapple Black", 47, 130},
            ["A_C_Horse_AmericanStandardbred_PalominoDapple"] = {"American Standardbred Palomino Dapple", 47, 130},
            ["A_C_Horse_AmericanStandardbred_Black"] = {"American Standardbred Black", 47, 130},
            ["A_C_Horse_AmericanStandardbred_Buckskin"] = {"American Standardbred Buckskin", 47, 130},
            ["A_C_Horse_AmericanStandardbred_SilverTailBuckskin"] = {"American Standardbred Silver Tail Buckskin", 47, 130},
 
 
        },
        {
            name = "War horses",
            ["A_C_Horse_Andalusian_DarkBay"] = {"Andalusian Dark Bay", 50, 140},
            ["A_C_Horse_Andalusian_Perlino"] = {"Andalusian Perlino", 50, 140},
            ["A_C_Horse_Andalusian_RoseGray"] = {"Andalusian Rose Grey", 50, 140},
            ["A_C_Horse_Ardennes_BayRoan"] = {"Ardennes Bay Roan", 50, 140},
            ["A_C_Horse_Ardennes_IronGreyRoan"] = {"Ardennes Iron Grey Roan", 50, 140},
            ["A_C_Horse_Ardennes_StrawberryRoan"] = {"Ardennes Strawberry Roan", 50, 140},
            ["A_C_Horse_HungarianHalfbred_DarkDappleGrey"] = {"HungarianHalfbred Dark Dapple Grey", 50, 140},
            ["A_C_Horse_HungarianHalfbred_FlaxenChestnut"] = {"HungarianHalfbred Flaxen Chestnut", 50, 140},
            ["A_C_Horse_HungarianHalfbred_LiverChestnut"] = {"HungarianHalfbred Liver Chestnut", 50, 140},
            ["A_C_Horse_HungarianHalfbred_PiebaldTobiano"] = {"HungarianHalfbred Piebald Tabiano", 50, 140},
        },
        {
            name = "Draft horses",
            ["A_C_Horse_Belgian_BlondChestnut"] = {"Belgian Blonde Chestnut", 47, 130},
            ["A_C_Horse_Belgian_MealyChestnut"] = {"Belgian Mealy Chestnut", 50, 140},
            ["A_C_Horse_Shire_DarkBay"] = {"Shire Dark Bay", 73, 200}, 
            ["A_C_Horse_Shire_LightGrey"] = {"Shire Light Grey", 47, 130},
            ["A_C_Horse_Shire_RavenBlack"] = {"Shire Raven Black", 50, 140},
            ["A_C_Horse_SuffolkPunch_RedChestnut"] = {"Suffolk Punch Red Chestnut", 73, 200},     
            ["A_C_Horse_SuffolkPunch_Sorrel"] = {"Suffolk Punch Sorrel", 73, 200},       
        },
    }
 
    return ret
end


RegisterNUICallback(
    "loadHorse",
    function(data)
        local horseModel = data.horseModel

        if showroomHorse_model == horseModel then
            return
        end


        if showroomHorse_entity ~= nil then
            DeleteEntity(showroomHorse_entity)
            showroomHorse_entity = nil
        end

        if MyHorse_entity ~= nil then
            DeleteEntity(MyHorse_entity)
            MyHorse_entity = nil
        end


        showroomHorse_model = horseModel

        local modelHash = GetHashKey(showroomHorse_model)

        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Citizen.Wait(10)
            end
        end

        showroomHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
        Citizen.InvokeNative(0x283978A15512B2FE, showroomHorse_entity, true)
        Citizen.InvokeNative(0x58A850EAEE20FAA3, showroomHorse_entity)
        NetworkSetEntityInvisibleToNetwork(showroomHorse_entity, true)
        SetVehicleHasBeenOwnedByPlayer(showroomHorse_entity, true)
        -- SetModelAsNoLongerNeeded(modelHash)

        interpCamera("Horse", showroomHorse_entity)
    end
)


RegisterNUICallback(
    "loadMyHorse",
    function(data)
        local horseModel = data.horseModel
        IdMyHorse = data.IdHorse
        if showroomHorse_model == horseModel then
            return
        end

        if showroomHorse_entity ~= nil then
            DeleteEntity(showroomHorse_entity)
            showroomHorse_entity = nil
        end

        if MyHorse_entity ~= nil then
            DeleteEntity(MyHorse_entity)
            MyHorse_entity = nil
        end

        showroomHorse_model = horseModel

        local modelHash = GetHashKey(showroomHorse_model)

        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Citizen.Wait(10)
            end
        end

        MyHorse_entity = CreatePed(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z - 0.98, SpawnPoint.h, false, 0)
        Citizen.InvokeNative(0x283978A15512B2FE, MyHorse_entity, true)
        Citizen.InvokeNative(0x58A850EAEE20FAA3, MyHorse_entity)
        NetworkSetEntityInvisibleToNetwork(MyHorse_entity, true)
        SetVehicleHasBeenOwnedByPlayer(MyHorse_entity, true)

        local componentsHorse = json.decode(data.HorseComp)

        if componentsHorse ~= '[]' then
            for _, Key in pairs(componentsHorse) do
                local model2 = GetHashKey(tonumber(Key))
                if not HasModelLoaded(model2) then
                    Citizen.InvokeNative(0xFA28FE3A6246FC30, model2)
                end
                Citizen.InvokeNative(0xD3A7B003ED343FD9, MyHorse_entity, tonumber(Key), true, true, true)
            end
        end

        -- SetModelAsNoLongerNeeded(modelHash)

        interpCamera("Horse", MyHorse_entity)
    end
)


RegisterNUICallback(
    "BuyHorse",
    function(data)
        local HorseName = cAPI.prompt("Name Your Horse:", "McHorse")
        
        if HorseName == "" then
            return
        end
        SetNuiFocus(true, true)

        TriggerServerEvent('FRP:STABLE:BuyHorse', data, HorseName)
    end
)



RegisterNUICallback(
    "CloseStable",
    function()
        SetNuiFocus(false, false)

        SendNUIMessage(
            {
                action = "hide"
            }
        )
        SetEntityVisible(PlayerPedId(), true)

        showroomHorse_model = nil

        if showroomHorse_entity ~= nil then
            DeleteEntity(showroomHorse_entity)
        end

        if MyHorse_entity ~= nil then
            DeleteEntity(MyHorse_entity)
        end

        DestroyAllCams(true)
        showroomHorse_entity = nil
        CloseStable()
    end
)


function CloseStable()
        local dados = {
            -- ['saddles'] = SaddlesUsing,
            -- ['saddlescloths'] = SaddleclothsUsing,
            -- ['stirrups'] = StirrupsUsing,
            -- ['bags'] = BagsUsing,
            -- ['manes'] = ManesUsing,
            -- ['horsetails'] = HorseTailsUsing,
            -- ['acshorn'] = AcsHornUsing,
            -- ['ascluggage'] = AcsLuggageUsing
            SaddlesUsing,
            SaddleclothsUsing,
            StirrupsUsing,
            BagsUsing,
            ManesUsing,
            HorseTailsUsing,
            AcsHornUsing,
            AcsLuggageUsing
        }
        local DadosEncoded = json.encode(dados)

        if DadosEncoded ~= "[]" then            
            TriggerServerEvent("FRP:STABLE:UpdateHorseComponents", dados, IdMyHorse ) 
        end

       
end


Citizen.CreateThread(
    function()
       while true do
        Citizen.Wait(100)
            if MyHorse_entity ~= nil then
                SendNUIMessage(
                    {
                        EnableCustom = "true"
                    }
                )
            else
                SendNUIMessage(
                    {
                        EnableCustom = "false"
                    }
                )
            end
       end
    end
)

function interpCamera(cameraName, entity)
    for k, v in pairs(cameraUsing) do
        if cameraUsing[k].name == cameraName then
            tempCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
            AttachCamToEntity(tempCam, entity, cameraUsing[k].x + CamPos[1], cameraUsing[k].y + CamPos[2], cameraUsing[k].z)
            SetCamActive(tempCam, true)
            SetCamRot(tempCam, -30.0, 0, HeadingPoint + 50.0)
            if InterP then
                SetCamActiveWithInterp(tempCam, fixedCam, 1200, true, true)
                InterP = false
            end
        end
    end
end

function createCamera(entity)
    groundCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(groundCam, StablePoint[1] + 0.5, StablePoint[2] - 3.6, StablePoint[3] )
    SetCamRot(groundCam, -20.0, 0.0, HeadingPoint + 20)
    SetCamActive(groundCam, true)
    RenderScriptCams(true, false, 1, true, true)
    --Wait(3000)
    -- last camera, create interpolate
    fixedCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(fixedCam, StablePoint[1] + 0.5, StablePoint[2] - 3.6, StablePoint[3] +1.8)
    SetCamRot(fixedCam, -20.0, 0, HeadingPoint + 50.0)
    SetCamActive(fixedCam, true)
    SetCamActiveWithInterp(fixedCam, groundCam, 3900, true, true)
    Wait(3900)
    DestroyCam(groundCam)
end
