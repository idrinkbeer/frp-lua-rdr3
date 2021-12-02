Quests = {
    ['carteiro'] = {
        name = "Deliver Letters",
        helptext = "Mission:Deliver letters to the appropriate places marked on the map.",
        need = {
            cartas = 15,
            needReturn = true
        },
        rewards = {
            money = math.random(10.1, 35.9),
            exp = 100
        }
    },
    ['entregador'] = {
        name = "Deliver Cargo",
        helptext = "Mission:Deliver cargo to the appropriate places marked on the map.",
        need = {
            cargas = 1,
            needReturn = true
        },
        rewards = {
            money = math.random(10.1, 35.9),
            exp = 100
        }
    },
    ['pescador'] = {
        name = "Fishing",
        helptext = "Go to one of the lakes that has been marked on your map to be able to fish.",
        need = {
            peixes = 25,
            needReturn = true
        },
        rewards = {
            money = math.random(10.1, 45.9),
            exp = 75
        }
    },
    ['cacadorderecompensas'] = {
        name = "Bounty Hunt",
        helptext = "Speak with a boss in this county so you can find the location of one of the dangerous criminals in this town.",
        need = {
            criminoso = 1,
            needReturn = true
        },
        rewards = {
            money = math.random(50.1, 95.9),
            exp = 250
        }
    },
    ['mineradordecobre'] = {
        name = "Mine Copper",
        helptext = "Find a mine near the location marked on the map, this point is not an exact place, go in search around the point!",
        need = {
            cobre = 1000,
            needReturn = true
        },
        rewards = {
            money = math.random(10.1, 25.9),
            exp = 250
        }
    },
    ['mineradordeprata'] = {
        name = "Mine Silver",
        helptext = "Find a mine near the location marked on the map, this point is not an exact place, go in search around the point!",
        need = {
            prata = 1000,
            needReturn = true
        },
        rewards = {
            money = math.random(25.1, 35.9),
            exp = 250
        }
    },
    ['mineradordeouro'] = {
        name = "Mine Gold",
        helptext = "Find a mine near the location marked on the map, this point is not an exact place, go in search around the point!",
        need = {
            ouro = 1000,
            needReturn = true
        },
        rewards = {
            money = math.random(35.1, 55.9),
            exp = 250
        }
    },
}
