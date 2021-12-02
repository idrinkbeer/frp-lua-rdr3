local Tunnel = module("_core", "lib/Tunnel")
local Proxy = module("_core", "lib/Proxy")

API = Proxy.getInterface("API")
API_DB = Proxy.getInterface("API_DB")
cAPI = Tunnel.getInterface("API")

RegisterCommand(
    "posse",
    function(source, args, rawCommand)
        local User = API.getUserFromSource(source)
        if User:isInAPosse() then
            local data = {}
            local Posse = API.getPosse(User:getPosseId())
            for memberCharId, rank in pairs(Posse:getMembers()) do
                local name = API.getNameById(memberCharId)
                local isOnline = false
                local UserMember = API.getUserFromCharId(memberCharId)
                -- local CharLevel = UserMember:getCharacter():getLevel()
                local CharLevel = 0

                if UserMember ~= nil and UserMember:getCharacter():getId() == tonumber(memberCharId) then
                    isOnline = true
                end

                data[memberCharId] = {
                    UserID = UserMember:getId(),
                    rank = rank,
                    name = name,
                    level = CharLevel,
                    isOnline = isOnline
                }
            end
            TriggerClientEvent("FRP:POSSE:OpenMenu", source, data, Posse:getName())
        else
            -- else
            --     User:notify('Você não tem permissao para criar um Bando')
            -- end
            -- if User:getCharacter():hasGroup('donator01') then
            TriggerClientEvent("FRP:POSSE:OpenCreationMenu", source)
        end
    end,
    false
)

RegisterCommand(
    "convidar",
    function(source, args)
        local arg = args[1]
        TriggerEvent("FRP:POSSE:Invite", source, arg)
    end
)

RegisterNetEvent("FRP:POSSE:checkBando")
AddEventHandler(
    "FRP:POSSE:checkBando",
    function()
        local _source = source
        local User = API.getUserFromSource(_source)
        local Character = User:getCharacter()
        local level = Character:getLevel()

        if not User:isInAPosse() then
            if level < 10 then
                User:notify("Must Be level 10 or up to create a Posse")
                return
            end
            TriggerEvent("FRP:POSSE:createBando", _source)
        else
            TriggerClientEvent("FRP:NOTIFY:Simple", _source, "Already in a Posse...", 5000)
        end
    end
)

RegisterNetEvent("FRP:POSSE:createBando")
AddEventHandler(
    "FRP:POSSE:createBando",
    function(source)
        local _source = source
        local PosseName = cAPI.prompt(source, "Name of Posse", "")

        local User = API.getUserFromSource(_source)

        if PosseName == "" then
            TriggerClientEvent("FRP:NOTIFY:Simple", _source, "You have not entered a valid name.", 5000)
            return
        end
        API.createPosse(User:getCharacter():getId(), PosseName)
        TriggerClientEvent("FRP:NOTIFY:Simple", _source, "Registration of the " .. PosseName .. " carried out with Success.", 5000)
    end
)

RegisterNetEvent("FRP:POSSE:Invite")
AddEventHandler(
    "FRP:POSSE:Invite",
    function(source, targetUserId)
        local _source = source
        local User = API.getUserFromSource(_source)
        local Character = User:getCharacter()

        if not User:isInAPosse() then
            User:notify("Not in a Posse")
            TriggerClientEvent("FRP:POSSE:CloseMenu", _source)
            return
        end

        local Posse = API.getPosse(User:getPosseId())

        local TargetSource = API.getUserFromUserId(parseInt(targetUserId)):getSource()
        local UserTarget = API.getUserFromSource(TargetSource)
        local userRank = Posse:getMemberRank(Character:getId())

        if userRank == 3 then
            User:notify("Only a Higher-Ranking member can invite someone to the posse...")
            return
        end

        if UserTarget == nil then
            User:notify("User id " .. targetUserId .. " not online")
            return
        end

        if UserTarget:isInAPosse() then
            User:notify("User id " .. targetUserId .. " already in a Posse!")
            return
        end

        User:notify("You invited ID " .. targetUserId .. " to join the Posse")

        UserTarget:notify("You were invited to join a Posse")

        local yes = cAPI.request(TargetSource, "Accept invitation to the Posse " .. Posse:getName() .. " ?", 30)

        if yes then
            UserTarget:notify("You join Posse " .. Posse:getName())
            Posse:addMember(UserTarget, 3)
        else
            User:notify("User " .. targetUserId .. " Decline the invite")
        end
    end
)

RegisterNetEvent("FRP:POSSE:Promote")
AddEventHandler(
    "FRP:POSSE:Promote",
    function(targetUserId)
        local _source = source
        local User = API.getUserFromSource(_source)

        local TargetSource = API.getUserFromUserId(parseInt(targetUserId)):getSource()
        local UserT = API.getUserFromSource(TargetSource)

        if not User:isInAPosse() then
            User:notify("You are not in a Posse")
            TriggerClientEvent("FRP:POSSE:CloseMenu", _source)
            return
        end

        local Character = User:getCharacter()
        local TCharacter = UserT:getCharacter()
        local Posse = API.getPosse(User:getPosseId())

        if not Posse:isAMember(TCharacter:getId()) then
            User:notify(TCharacter:getName() .. " Left the Posse")
            return
        end

        local targetRank = Posse:getMemberRank(TCharacter:getId())
        if targetRank <= 2 then
            User:notify(TCharacter:getName() .. " Already Highest Rank")
            return
        end

        local userRank = Posse:getMemberRank(Character:getId())

        if userRank <= 2 then
            if userRank == targetRank then
                User:notify("Only a senior member can promote this member.")
                return
            end

            Posse:promoteMember(TCharacter:getId())
            Posse:notifyMembers(TCharacter:getName() .. " Was promoted in the Posse")
        end
    end
)

RegisterNetEvent("FRP:POSSE:Demote")
AddEventHandler(
    "FRP:POSSE:Demote",
    function(targetUserId)
        local _source = source
        local User = API.getUserFromSource(_source)

        local TargetSource = API.getUserFromUserId(parseInt(targetUserId)):getSource()
        local UserT = API.getUserFromSource(TargetSource)

        if not User:isInAPosse() then
            User:notify("You are not in a Posse")
            TriggerClientEvent("FRP:POSSE:CloseMenu", _source)
            return
        end

        local Character = User:getCharacter()
        local TCharacter = UserT:getCharacter()
        local Posse = API.getPosse(User:getPosseId())

        if not Posse:isAMember(TCharacter:getId()) then
            User:notify(TCharacter:getName() .. " Left the Posse")
            return
        end

        local targetRank = Posse:getMemberRank(TCharacter:getId())
        if targetRank == 3 then
            User:notify(charName .. " Is already in the lowest rank!")
            return
        end

        local userRank = Posse:getMemberRank(Character:getId())

        if userRank <= 2 then
            if userRank == targetRank then
                User:notify("Only a senior member can demote this member.")
                return
            end

            Posse:demoteMember(TCharacter:getId())
            Posse:notifyMembers(TCharacter:getName() .. " was demoted!")
        end
    end
)

RegisterNetEvent("FRP:POSSE:Leave")
AddEventHandler(
    "FRP:POSSE:Leave",
    function()
        local _source = source
        local User = API.getUserFromSource(_source)

        if not User:isInAPosse() then
            User:notify("You are not in a Posse")
            TriggerClientEvent("FRP:POSSE:CloseMenu", _source)
            return
        end

        local Character = User:getCharacter()
        local Posse = API.getPosse(User:getPosseId())

        Posse:removeMember(Character:getId())
        Posse:notifyMembers(Character:getName() .. " Left the Posse!")

        User:notify("You left the Posse!")
    end
)

RegisterNetEvent("FRP:POSSE:Kick")
AddEventHandler(
    "FRP:POSSE:Kick",
    function(targetUserId)
        local TargetSource = API.getUserFromUserId(parseInt(targetUserId)):getSource()
        local User = API.getUserFromSource(TargetSource)

        if not User:isInAPosse() then
            User:notify("You are not in a Posse")
            TriggerClientEvent("FRP:POSSE:CloseMenu", _source)
            return
        end

        local Character = User:getCharacter()
        local Posse = API.getPosse(User:getPosseId())

        Posse:removeMember(Character:getId())
        Posse:notifyMembers(Character:getName() .. " was removed from the Posse")

        User:notify("You were removed from the Posse!")
    end
)
