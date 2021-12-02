-- FRP:TOAST:New -> "speech", "Simulate a character's speech"
-- FRP:TOAST:New -> "dev", "Intended message for Devs"
-- FRP:TOAST:New -> "alert", "you are fag"
-- FRP:TOAST:New -> "alert", "you are fag"
-- FRP:TOAST:New -> "success", "you are fag"
-- FRP:TOAST:New -> "error", "you are fag"
-- FRP:TOAST:New -> "gold", 10
-- FRP:TOAST:New -> "gold", -10
-- FRP:TOAST:New -> "dollar", 10
-- FRP:TOAST:New -> "dollar", -10
-- FRP:TOAST:New -> "item", "Volcanic Pistol", 10
-- FRP:TOAST:New -> "item", "Volcanic Pistol", -10
-- FRP:TOAST:New -> "longer_alert", "Toast that takes longer to disappear works for everyone",

RegisterNetEvent("FRP:TOAST:New")
AddEventHandler(
    "FRP:TOAST:New",
    function(type, text, quantity)
        if type == "item" then
            if ItemList[text] then
                if text == "money" or text == "gold" then
                    quantity = quantity / 100
                    if text == "money" then
                        type = "dollar"
                    elseif text == "gold" then
                        type = "gold"
                    end
                else
                    text = ItemList[text].name
                end
            end
        end

        -- if tonumber(text) then
        --     quantity = text
        --     text = nil
        -- end

        if type == "xp" then
            quantity = text
            text = nil
        end

        SendNUIMessage(
            {
                type = type,
                text = text,
                quantity = quantity
            }
        )
    end
)
