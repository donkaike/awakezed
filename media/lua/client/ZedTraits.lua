require('NPCs/MainCreationMethods');
require("Items/Distributions");
require("Items/ProceduralDistributions");

--Global Variables
skipxpadd = false;
internalTick = 0;

--[[
TraitFactory.addTrait("inverseinfection", getText("UI_trait_inverseinfection"), 0, getText("UI_trait_inverseinfectiondesc"), true, false);
ProfessionFramework.addProfession('Biohazard Scientist', {
    name = "Biohazard Scientist",
    icon = "Profession_BiohazardScientist",
    cost = 16,
    xp = {
        [Perks.Doctor] = 3,             
    },
    traits = {"inverseinfection"},
    inventory = {
        ["Base.HolsterSimple"] = 1,
        ["Base.HazmatSuit"] = 1,
    },
});
]]


local function tableContains(t, e)
    for _, value in pairs(t) do
        if value == e then
            return true
        end
    end
    return false
end
local function istable(t)
    local type = type(t)
    return type == 'table'
end
local function tablelength(T)
    local count = 0
    if istable(T) == true then
        for _ in pairs(T) do
            count = count + 1
        end
    else
        count = 1
    end
    return count
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function initZedTraits()
    --POSITIVE--
    local awake = TraitFactory.addTrait("awake", getText("UI_trait_awake"), 0, getText("UI_trait_awakedesc"), false, false);
    local fearful = TraitFactory.addTrait("zedmule", getText("UI_trait_zedmule"), 0, getText("UI_trait_zedmuledesc"), false, false);
    local scratch = TraitFactory.addTrait("scratch", getText("UI_trait_scratch"), 0, getText("UI_trait_scratchdesc"), false, false);
    local runner = TraitFactory.addTrait("runner", getText("UI_trait_runner"), 0, getText("UI_trait_runnerdesc"), false, false);
    local masked = TraitFactory.addTrait("masked", getText("UI_trait_masked"), 0, getText("UI_trait_maskeddesc"), false, false);
    local minions = TraitFactory.addTrait("minions", getText("UI_trait_minions"), 0, getText("UI_trait_minionsdesc"), false, false);
    local sunregen = TraitFactory.addTrait("sunregen", getText("UI_trait_sunregen"), 0, getText("UI_trait_sunregendesc"), false, false);

    --NEGATIVE--
    local zedmouse = TraitFactory.addTrait("zedmouse", getText("UI_trait_zedmouse"), 0, getText("UI_trait_zedmousedesc"), false, false);
    local walker = TraitFactory.addTrait("walker", getText("UI_trait_walker"), 0, getText("UI_trait_walkerdesc"), false, false);
    local bloodthirst = TraitFactory.addTrait("bloodthirst", getText("UI_trait_bloodthirst"), 0, getText("UI_trait_bloodthirstdesc"), false, false);
    local sunsensitivity = TraitFactory.addTrait("sunsensitivity", getText("UI_trait_sunsensitivity"), 0, getText("UI_trait_sunsensitivitydesc"), false, false);
    local zedstomach = TraitFactory.addTrait("zedstomach", getText("UI_trait_zedstomach"), 0, getText("UI_trait_zedstomachdesc"), false, false);
    local rotting = TraitFactory.addTrait("rotting", getText("UI_trait_rotting"), 0, getText("UI_trait_rottingdesc"), false, false);
    local brainproblems = TraitFactory.addTrait("brainproblems", getText("UI_trait_brainproblems"), 0, getText("UI_trait_brainproblemsdesc"), false, false);
end 

local function ZedAwake(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local bodydamage = player:getBodyDamage();
    local chance = 100;
    if playerdata.bAwake ~= nil and player:HasTrait("awake") == false then
        if player:HasTrait("Lucky") then
            chance = chance + 1;
        end
        if player:HasTrait("Unlucky") then
            chance = chance - 1;
        end
        if playerdata.bAwake == true then
            if bodydamage:isInfected() and bodydamage:getInfectionLevel() > 2  then
                if ZombRand(0, 101) <= chance then
                    print("Player's Immune system fought-off zombification.");
                    player:getTraits():add("awake");
                else
                    print("Immune system failed.");
                    playerdata.bAwake = false;
                end
            end

        end
    else
        playerdata.bAwake = true;
    end
    if bodydamage:isInfected() == false and playerdata.bAwake == false then
        playerdata.bAwake = true;
    end
end

local function awake()
    local player = getPlayer();
    if player:HasTrait("awake") then
        local bodydamage = player:getBodyDamage();
        if (player:getHoursSurvived() - 30) > 0 then
            bodydamage:setInfectionTime(player:getHoursSurvived() - 30);
        else 
            bodydamage:setInfectionTime(0);
        end
        --[[
            if bodydamage:getInfectionLevel() < 5 then
                bodydamage:setInfectionTime(player:getHoursSurvived() + 10);
            elseif bodydamage:getInfectionLevel() >= 5 then
                bodydamage:setInfectionTime(player:getHoursSurvived() + 10);
            end 
        ]]
        
    end
end

local function gimp()
    local player = getPlayer();
    local playerdata = player:getModData();
    local modifier = 0.85;
    if player:HasTrait("gimp") and player:isLocalPlayer() then
        if playerdata.fToadTraitsPlayerX ~= nil and playerdata.fToadTraitsPlayerY ~= nil then
            local oldx = playerdata.fToadTraitsPlayerX;
            local oldy = playerdata.fToadTraitsPlayerY;
            local newx = player:getX();
            local newy = player:getY();
            local xdif = (newx - oldx);
            local ydif = (newy - oldy);
            if xdif > 5 or xdif < -5 or ydif > 5 or ydif < -5 then
                playerdata.fToadTraitsPlayerX = player:getX();
                playerdata.fToadTraitsPlayerY = player:getY();

                return
            end
            player:setX((oldx + xdif * modifier));
            player:setY((oldy + ydif * modifier));
        end
        playerdata.fToadTraitsPlayerX = player:getX();
        playerdata.fToadTraitsPlayerY = player:getY();
    end
end

local function fast()
    local player = getPlayer();
    local playerdata = player:getModData();
    local vector = player:getPlayerMoveDir();
    local length = vector:getLength();
    local modifier = 2.15;
    if player:HasTrait("fast") and player:isLocalPlayer() then
        if playerdata.fToadTraitsPlayerX ~= nil and playerdata.fToadTraitsPlayerY ~= nil then
            local oldx = playerdata.fToadTraitsPlayerX;
            local oldy = playerdata.fToadTraitsPlayerY;
            local newx = player:getX();
            local newy = player:getY();
            local xdif = (newx - oldx);
            local ydif = (newy - oldy);
            if xdif > 5 or xdif < -5 or ydif > 5 or ydif < -5 then
                playerdata.fToadTraitsPlayerX = player:getX();
                playerdata.fToadTraitsPlayerY = player:getY();

                return
            end
            if xdif ~= 0 or xdif ~= 0 or ydif ~= 0 or ydif ~= 0 then
                player:setX((oldx + xdif * modifier));
                player:setY((oldy + ydif * modifier));
                playerdata.fToadTraitsPlayerX = player:getX();
                playerdata.fToadTraitsPlayerY = player:getY();
            end
        else
            playerdata.fToadTraitsPlayerX = player:getX();
            playerdata.fToadTraitsPlayerY = player:getY();
        end
    end

end

local function checkWeight()
    local player = getPlayer();
    local strength = player:getPerkLevel(Perks.Strength);

    print(player:getMaxWeightBase());
    print(player:getMaxWeight());

    if player:HasTrait("packmule") then
        player:setMaxWeightBase(11);    
    elseif player:HasTrait("packmouse") then
        player:setMaxWeightBase(7);
    end
end

local function graveRobber(_zombie)
    local player = getPlayer();
    local zombie = _zombie;
    local chance = 5;

    if player:HasTrait("graverobber") then
        if player:HasTrait("Lucky") then
            chance = chance + 2;
        end
        if player:HasTrait("Unlucky") then
            chance = chance - 2;
        end 
        if chance <= 0 then
            chance = 1;
        end
        if ZombRand(0, 100) <= chance then
            local inv = zombie:getInventory();
            local itterations = ZombRand(1, chance + 1);
            for i = 0, itterations do
                i = i + 1;
                local roll = ZombRand(0, 100);
                print("roool " .. tostring(roll));
                if roll <= 10 then
                    local randomitem = { "Base.Apple", "Base.Avocado", "Base.Banana", "Base.BellPepper", "Base.BeerCan",
                                         "Base.BeefJerky", "Base.Bread", "Base.Broccoli", "Base.Butter", "Base.CandyPackage", "Base.TinnedBeans",
                                         "Base.CannedCarrots2", "Base.CannedChili", "Base.CannedCorn", "Base.CannedCornedBeef", "CannedMushroomSoup",
                                         "Base.CannedPeas", "Base.CannedPotato2", "Base.CannedSardines", "Base.CannedTomato2", "Base.TunaTin" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 20 then
                    local randomitem = { "Base.PillsAntiDep", "Base.AlcoholWipes", "Base.AlcoholedCottonBalls", "Base.Pills", "Base.PillsSleepingTablets",
                                         "Base.Tissue", "Base.ToiletPaper", "Base.PillsVitamins", "Base.Bandaid", "Base.Bandage", "Base.CottonBalls", "Base.Splint", "Base.AlcoholBandage",
                                         "Base.AlcoholRippedSheets", "Base.SutureNeedle", "Base.Tweezers", "Base.WildGarlicCataplasm", "Base.ComfreyCataplasm", "Base.PlantainCataplasm", "Base.Disinfectant" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 25 then
                    local randomitem = { "Base.223Box", "Base.308Box", "Base.Bullets38Box", "Base.Bullets44Box", "Base.Bullets45Box", "Base.556Box", "Base.Bullets9mmBox",
                                         "Base.ShotgunShellsBox", "Base.DoubleBarrelShotgun", "Base.Shotgun", "Base.ShotgunSawnoff", "Base.Pistol", "Base.Pistol2", "Base.Pistol3", "Base.AssaultRifle", "Base.AssaultRifle2",
                                         "Base.VarmintRifle", "Base.HuntingRifle", "Base.556Clip", "Base.M14Clip", "Base.308Clip", "Base.223Clip", "Base.44Clip", "Base.45Clip", "Base.9mmClip", "Base.Revolver_Short", "Base.Revolver_Long",
                                         "Base.Revolver" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 30 then
                    local randomitem = { "Base.Aerosolbomb", "Base.Axe", "Base.BaseballBat", "Base.SpearCrafted", "Base.Crowbar", "Base.FlameTrap", "Base.HandAxe", "Base.HuntingKnife", "Base.Katana",
                                         "Base.PipeBomb", "Base.Sledgehammer", "Base.Shovel", "Base.SmokeBomb", "Base.WoodAxe", "Base.GardenFork", "Base.WoodenLance", "Base.SpearBreadKnife",
                                         "Base.SpearButterKnife", "Base.SpearFork", "Base.SpearLetterOpener", "Base.SpearScalpel", "Base.SpearSpoon", "Base.SpearScissors", "Base.SpearHandFork",
                                         "Base.SpearScrewdriver", "Base.SpearHuntingKnife", "Base.SpearMachete", "Base.SpearIcePick", "Base.SpearKnife", "Base.Machete", "Base.GardenHoe" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 45 then
                    local randomitem = { "Base.Wine", "Base.Wine2", "Base.WhiskeyFull", "Base.BeerCan", "Base.BeerBottle" };
                    print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 50 then
                    local randomitem = { "Base.Bag_SurvivorBag", "Base.Bag_BigHikingBag", "Base.Bag_DuffelBag", "Base.Bag_FannyPackFront", "Base.Bag_NormalHikingBag", "Base.Bag_ALICEpack", "Base.Bag_ALICEpack_Army",
                                         "Base.Bag_Schoolbag", "Base.SackOnions", "Base.SackPotatoes", "Base.SackCarrots", "Base.SackCabbages" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 52 then
                    local randomitem = { "Base.Hat_SPHhelmet", "Base.Jacket_CoatArmy", "Base.Hat_BalaclavaFull", "Base.Hat_BicycleHelmet", "Base.Shoes_BlackBoots", "Base.Hat_CrashHelmet",
                                         "Base.HolsterDouble", "Base.Hat_Fireman", "Base.Jacket_Fireman", "Base.Trousers_Fireman", "Base.Hat_FootballHelmet", "Base.Hat_GasMask", "Base.Ghillie_Trousers", "Base.Ghillie_Top",
                                         "Base.Gloves_LeatherGloves", "Base.JacketLong_Random", "Base.Shoes_ArmyBoots", "Base.Vest_BulletArmy", "Base.Hat_Army", "Base.Hat_HardHat_Miner", "Base.Hat_NBCmask",
                                         "Base.Vest_BulletPolice", "Base.Hat_RiotHelmet", "Base.AmmoStrap_Shells" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 60 then
                    local randomitem = { "Base.CarBattery1", "Base.CarBattery2", "Base.CarBattery3", "Base.Extinguisher", "Base.PetrolCan", "Base.ConcretePowder", "Base.PlasterPowder", "Base.BarbedWire", "Base.Log",
                                         "Base.SheetMetal", "Base.MotionSensor", "Base.ModernTire1", "Base.ModernTire2", "Base.ModernTire3", "Base.ModernSuspension1", "Base.ModernSuspension2", "Base.ModernSuspension3",
                                         "Base.ModernCarMuffler1", "Base.ModernCarMuffler2", "Base.ModernCarMuffler3", "Base.ModernBrake1", "Base.ModernBrake2", "Base.ModernBrake3", "Base.smallSheetMetal",
                                         "Base.Speaker", "Base.EngineParts", "Base.LogStacks2", "Base.LogStacks3", "Base.LogStacks4", "Base.NailsBox" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 65 then
                    local randomitem = { "Base.ComicBook", "Base.ElectronicsMag4", "Base.HerbalistMag", "Base.MetalworkMag1", "Base.MetalworkMag2", "Base.MetalworkMag3", "Base.MetalworkMag4",
                                         "Base.HuntingMag1", "Base.HuntingMag2", "Base.HuntingMag3", "Base.FarmingMag1", "Base.MechanicMag1", "Base.MechanicMag2", "Base.MechanicMag3",
                                         "Base.CookingMag1", "Base.CookingMag2", "Base.EngineerMagazine1", "Base.EngineerMagazine2", "Base.ElectronicsMag1", "Base.ElectronicsMag2", "Base.ElectronicsMag3", "Base.ElectronicsMag5",
                                         "Base.FishingMag1", "Base.FishingMag2", "Base.Book" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 80 then
                    local randomitem = { "Base.Banana", "Base.BellPepper", "Base.BeerCan",
                    "Base.BeefJerky", "Base.Bread", "Base.Gum", "farming.Strewberrie", "farming.Tomato", "farming.Potato", "farming.Cabbage", "Base.Milk",
                    "farming.CarrotBagSeed", "farming.BroccoliBagSeed", "farming.RedRadishBagSeed", "farming.StrewberrieBagSeed", "farming.TomatoBagSeed", "farming.PotatoBagSeed", "farming.CabbageBagSeed",
                    "Base.Needle", "Base.Thread", "Base.RippedSheets", "Base.Matches"};
                                        print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 90 then
                    local randomitem = { "Base.DumbBell", "Base.EggCarton", "Base.HomeAlarm", "Base.HotDog", "Base.HottieZ", "Base.Icecream", "Base.Machete", "Base.Revolver_Long",
                                         "Base.MeatPatty", "Base.Milk", "Base.MuttonChop", "Base.Padlock", "Base.PorkChop", "Base.Ham" };
                                         print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 97 then
                    local randomitem = { "Base.PropaneTank", "Base.BlowTorch", "Base.Woodglue", "Base.DuctTape", "Base.Rope", "Base.Extinguisher" };
                    print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                elseif roll <= 100 then
                    local randomitem = { "Base.Spiffo", "Base.SpiffoSuit", "Base.Hat_Spiffo", "Base.SpiffoTail" };
                    print(randomitem);
                    inv:AddItem(randomitem[ZombRand(1, tablelength(randomitem) - 1)]);
                end
            end

        end
    end
end

local function FearfulUpdate(_player)
    local player = _player;
    if player:HasTrait("fearful") then
        local stats = player:getStats();
        local panic = stats:getPanic();
        if panic > 5 then
            local chance = 3 + panic / 10;
            if player:HasTrait("Cowardly") then
                chance = chance + 1;
            end
            if player:HasTrait("Lucky") then
                chance = chance - 1;
            end
            if player:HasTrait("Unlucky") then
                chance = chance + 1;
            end
            if ZombRand(0, 1000) <= chance then
                if panic <= 25 then
                    player:Say("*Whimper*");
                    addSound(player, player:getX(), player:getY(), player:getZ(), 5, 10);
                elseif panic <= 50 then
                    player:Say("*Muffled Shriek*");
                    addSound(player, player:getX(), player:getY(), player:getZ(), 10, 15);
                elseif panic <= 75 then
                    player:Say("*Panicked Screech*");
                    addSound(player, player:getX(), player:getY(), player:getZ(), 20, 25);
                elseif panic > 75 then
                    player:Say("*Desperate Screaming*");
                    addSound(player, player:getX(), player:getY(), player:getZ(), 25, 50);
                end
            end
        end
    end
end

local function MainPlayerUpdate(_player)
    local player = _player;
    local playerdata = player:getModData();
    if internalTick >= 30 then
        --FearfulUpdate(player);
        --Reset internalTick every 30 ticks
        internalTick = 0;
    elseif internalTick == 10 then
        ZedAwake(player, playerdata);
    end
    internalTick = internalTick + 1;
end

--Events.OnZombieDead.Add(graveRobber);
Events.OnPlayerUpdate.Add(MainPlayerUpdate);
Events.EveryTenMinutes.Add(awake);
Events.OnGameBoot.Add(initZedTraits);