local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Langsung buat Window dengan opsi tema jika didukung:
local Window = WindUI.new({
    Title = "SovereignHub | The Forge",
    Icon = "hammer",
    Folder = "SovereignHub",
    Debug = false,
})

if Window and Window.SetTheme then
    Window:SetTheme("Dark")
elseif WindUI and WindUI.SetTheme then
    WindUI:SetTheme("Dark")
end

-- Tab Main
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

-- Section Auto Mining
local MiningSection = MainTab:Section({
    Title = "Auto Mining",
    Opened = true,
})

-- Toggle Enable Auto Mining
local AutoMiningToggle = MiningSection:Toggle({
    Title = "Enable Auto Mining",
    Value = false,
    Icon = "pickaxe",
    Callback = function(state)
        AutoMining = state
        if state then
            StartAutoMining()
        else
            StopAutoMining()
        end
    end
})

-- Dropdown Pilih Location Mining
local MiningLocationDropdown = MiningSection:Dropdown({
    Title = "Location",
    Values = {"Stonewake's Cross", "Forgotten Kingdom", "Goblin Cave"},
    Value = "Stonewake's Cross",
    Callback = function(selected)
        SelectedMiningLocation = selected
        UpdateRockOptions(selected)
    end
})

-- Multi Dropdown untuk pilih jenis batu
local RockTypesDropdown = MiningSection:Dropdown({
    Title = "Rock Types",
    Values = {"Pebble", "Rock", "Boulder"},
    Value = {"Pebble", "Rock", "Boulder"},
    Multi = true,
    Callback = function(selected)
        SelectedRockTypes = selected
    end
})

-- Fungsi update rock options berdasarkan location
function UpdateRockOptions(location)
    local rockOptions = {}
    
    if location == "Stonewake's Cross" then
        rockOptions = {"Pebble", "Rock", "Boulder"}
    elseif location == "Forgotten Kingdom" then
        rockOptions = {"Basalt Rock", "Basalt Core", "Basalt Vein", "Volcanic Rock"}
    elseif location == "Goblin Cave" then
        rockOptions = {"Earth Crystal", "Cyan Crystal", "Light Crystal", "Crimson Crystal", "Violet Crystal"}
    end
    
    RockTypesDropdown:Refresh(rockOptions)
    RockTypesDropdown:Select(rockOptions) -- Select all by default
end

-- Section Auto Kill Mobs
local MobSection = MainTab:Section({
    Title = "Auto Kill Mobs",
    Opened = true,
})

-- Toggle Enable Auto Kill Mobs
local AutoMobsToggle = MobSection:Toggle({
    Title = "Enable Auto Kill Mobs",
    Value = false,
    Icon = "swords",
    Callback = function(state)
        AutoMobs = state
        if state then
            StartAutoMobs()
        else
            StopAutoMobs()
        end
    end
})

-- Dropdown Pilih Location Mobs
local MobLocationDropdown = MobSection:Dropdown({
    Title = "Location",
    Values = {"Stonewake's Cross", "Forgotten Kingdom"},
    Value = "Stonewake's Cross",
    Callback = function(selected)
        SelectedMobLocation = selected
        UpdateMobOptions(selected)
    end
})

-- Multi Dropdown untuk pilih jenis mobs
local MobTypesDropdown = MobSection:Dropdown({
    Title = "Mob Types",
    Values = {"Zombie", "Delver Zombie", "Elite Zombie", "Brute Zombie"},
    Value = {"Zombie", "Delver Zombie", "Elite Zombie", "Brute Zombie"},
    Multi = true,
    Callback = function(selected)
        SelectedMobTypes = selected
    end
})

-- Toggle Auto Dodge
local AutoDodgeToggle = MobSection:Toggle({
    Title = "Auto Dodge",
    Value = true,
    Icon = "shield",
    Callback = function(state)
        AutoDodgeEnabled = state
    end
})

-- Fungsi update mob options berdasarkan location
function UpdateMobOptions(location)
    local mobOptions = {}
    
    if location == "Stonewake's Cross" then
        mobOptions = {"Zombie", "Delver Zombie", "Elite Zombie", "Brute Zombie"}
    elseif location == "Forgotten Kingdom" then
        mobOptions = {
            "Bomber", "Skeleton Rogue", "Axe Skeleton", "Deathaxe Skeleton",
            "Elite Rogue Skeleton", "Elite Deathaxe Skeleton", "Reaper", 
            "Slime", "Burning Slime"
        }
    end
    
    MobTypesDropdown:Refresh(mobOptions)
    MobTypesDropdown:Select(mobOptions) -- Select all by default
end

-- Tab Settings
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local SettingsSection = SettingsTab:Section({
    Title = "Configuration",
    Opened = true,
})

-- Slider untuk mining range
local MiningRangeSlider = SettingsSection:Slider({
    Title = "Mining Range",
    Value = {Min = 1, Max = 100, Default = 30},
    Step = 1,
    Callback = function(value)
        MiningRange = tonumber(value)
    end
})

-- Slider untuk mob attack range
local AttackRangeSlider = SettingsSection:Slider({
    Title = "Attack Range",
    Value = {Min = 1, Max = 50, Default = 20},
    Step = 1,
    Callback = function(value)
        AttackRange = tonumber(value)
    end
})

-- Toggle untuk notifications
local NotifToggle = SettingsSection:Toggle({
    Title = "Enable Notifications",
    Value = true,
    Icon = "bell",
    Callback = function(state)
        ShowNotifications = state
    end
})

-- Variabel global
local AutoMining = false
local AutoMobs = false
local SelectedMiningLocation = "Stonewake's Cross"
local SelectedMobLocation = "Stonewake's Cross"
local SelectedRockTypes = {"Pebble", "Rock", "Boulder"}
local SelectedMobTypes = {"Zombie", "Delver Zombie", "Elite Zombie", "Brute Zombie"}
local MiningRange = 30
local AttackRange = 20
local AutoDodgeEnabled = true
local ShowNotifications = true
local MiningThread
local MobThread

-- Service references
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Fungsi untuk mendapatkan nama rock berdasarkan location
function GetRockNames(location)
    local rockNames = {}
    
    if location == "Stonewake's Cross" then
        rockNames = {"Pebble", "Rock", "Boulder"}
    elseif location == "Forgotten Kingdom" then
        rockNames = {"BasaltRock", "BasaltCore", "BasaltVein", "VolcanicRock"}
    elseif location == "Goblin Cave" then
        rockNames = {"EarthCrystal", "CyanCrystal", "LightCrystal", "CrimsonCrystal", "VioletCrystal"}
    end
    
    return rockNames
end

-- Fungsi untuk mendapatkan nama mobs berdasarkan location
function GetMobNames(location)
    local mobNames = {}
    
    if location == "Stonewake's Cross" then
        mobNames = {"Zombie", "DelverZombie", "EliteZombie", "BruteZombie"}
    elseif location == "Forgotten Kingdom" then
        mobNames = {
            "Bomber", "SkeletonRogue", "AxeSkeleton", "DeathaxeSkeleton",
            "EliteRogueSkeleton", "EliteDeathaxeSkeleton", "Reaper", 
            "Slime", "BurningSlime"
        }
    end
    
    return mobNames
end

-- Fungsi untuk mencari rock terdekat
function FindNearestRock()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local rootPart = character.HumanoidRootPart
    local closestRock = nil
    local closestDistance = MiningRange
    
    local rockNames = GetRockNames(SelectedMiningLocation)
    
    for _, rockName in pairs(rockNames) do
        -- Cek apakah rock ini dipilih
        local isSelected = false
        for _, selectedRock in pairs(SelectedRockTypes) do
            if selectedRock:lower() == rockName:lower() then
                isSelected = true
                break
            end
        end
        
        if isSelected then
            -- Cari semua rock dengan nama tersebut
            for _, rock in pairs(Workspace:GetChildren()) do
                if rock.Name:lower():find(rockName:lower()) and rock:FindFirstChild("HumanoidRootPart") then
                    local distance = (rootPart.Position - rock.HumanoidRootPart.Position).Magnitude
                    
                    -- Cek line of sight (tidak tembus tembok)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {character, rock}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    local raycastResult = Workspace:Raycast(
                        rootPart.Position,
                        (rock.HumanoidRootPart.Position - rootPart.Position).Unit * distance,
                        raycastParams
                    )
                    
                    if not raycastResult and distance < closestDistance then
                        closestRock = rock
                        closestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestRock
end

-- Fungsi untuk mencari mob terdekat
function FindNearestMob()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local rootPart = character.HumanoidRootPart
    local closestMob = nil
    local closestDistance = AttackRange
    
    local mobNames = GetMobNames(SelectedMobLocation)
    
    for _, mobName in pairs(mobNames) do
        -- Cek apakah mob ini dipilih
        local isSelected = false
        for _, selectedMob in pairs(SelectedMobTypes) do
            if selectedMob:lower() == mobName:lower() then
                isSelected = true
                break
            end
        end
        
        if isSelected then
            -- Cari semua mob dengan nama tersebut
            for _, mob in pairs(Workspace:GetChildren()) do
                if mob.Name:lower():find(mobName:lower()) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    local distance = (rootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                    
                    -- Cek line of sight (tidak tembus tembok)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {character, mob}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    local raycastResult = Workspace:Raycast(
                        rootPart.Position,
                        (mob.HumanoidRootPart.Position - rootPart.Position).Unit * distance,
                        raycastParams
                    )
                    
                    if not raycastResult and distance < closestDistance then
                        closestMob = mob
                        closestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestMob
end

-- Fungsi untuk auto dodge
function PerformDodge()
    if not AutoDodgeEnabled then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then
        return
    end
    
    local humanoid = character.Humanoid
    
    -- Simulate dodge by moving sideways
    local randomDirection = math.random(1, 2) == 1 and 1 or -1
    local dodgeVector = character.HumanoidRootPart.CFrame.RightVector * 10 * randomDirection
    
    -- Move character
    humanoid:MoveTo(character.HumanoidRootPart.Position + dodgeVector)
    
    if ShowNotifications then
        Window:Notify({
            Title = "Dodge!",
            Content = "Performed dodge maneuver",
            Icon = "shield",
            Duration = 2
        })
    end
end

-- Fungsi utama auto mining
function StartAutoMining()
    if MiningThread then return end
    
    MiningThread = task.spawn(function()
        while AutoMining do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local rock = FindNearestRock()
                
                if rock then
                    -- Walk to rock
                    character.Humanoid:MoveTo(rock.HumanoidRootPart.Position)
                    
                    -- Wait until close enough
                    local distance = (character.HumanoidRootPart.Position - rock.HumanoidRootPart.Position).Magnitude
                    while distance > 5 and AutoMining do
                        task.wait(0.1)
                        distance = (character.HumanoidRootPart.Position - rock.HumanoidRootPart.Position).Magnitude
                    end
                    
                    -- Simulate mining action
                    if ShowNotifications then
                        Window:Notify({
                            Title = "Mining",
                            Content = "Mining " .. rock.Name,
                            Icon = "pickaxe",
                            Duration = 3
                        })
                    end
                    
                    -- Wait before next action
                    task.wait(2)
                else
                    if ShowNotifications then
                        Window:Notify({
                            Title = "Auto Mining",
                            Content = "No rocks found nearby",
                            Icon = "search",
                            Duration = 2
                        })
                    end
                    task.wait(2)
                end
            else
                if ShowNotifications then
                    Window:Notify({
                        Title = "Auto Mining",
                        Content = "Character not found or dead",
                        Icon = "alert-triangle",
                        Duration = 2
                    })
                end
                task.wait(3)
            end
            
            task.wait(0.5)
        end
    end)
end

function StopAutoMining()
    if MiningThread then
        task.cancel(MiningThread)
        MiningThread = nil
    end
end

-- Fungsi utama auto kill mobs
function StartAutoMobs()
    if MobThread then return end
    
    MobThread = task.spawn(function()
        while AutoMobs do
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local mob = FindNearestMob()
                
                if mob then
                    -- Walk to mob
                    character.Humanoid:MoveTo(mob.HumanoidRootPart.Position)
                    
                    -- Wait until close enough
                    local distance = (character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                    while distance > AttackRange/2 and AutoMobs do
                        task.wait(0.1)
                        distance = (character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                    end
                    
                    -- Check if mob is attacking (simple detection)
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid:GetState() == Enum.HumanoidStateType.Attacking then
                        PerformDodge()
                    end
                    
                    -- Simulate attack action
                    if ShowNotifications then
                        Window:Notify({
                            Title = "Attacking",
                            Content = "Attacking " .. mob.Name,
                            Icon = "swords",
                            Duration = 3
                        })
                    end
                    
                    -- Wait before next action
                    task.wait(1.5)
                else
                    if ShowNotifications then
                        Window:Notify({
                            Title = "Auto Mobs",
                            Content = "No mobs found nearby",
                            Icon = "search",
                            Duration = 2
                        })
                    end
                    task.wait(2)
                end
            else
                if ShowNotifications then
                    Window:Notify({
                        Title = "Auto Mobs",
                        Content = "Character not found or dead",
                        Icon = "alert-triangle",
                        Duration = 2
                    })
                end
                task.wait(3)
            end
            
            task.wait(0.5)
        end
    end)
end

function StopAutoMobs()
    if MobThread then
        task.cancel(MobThread)
        MobThread = nil
    end
end

-- Notification saat script dimulai
Window:Notify({
    Title = "SovereignHub Loaded",
    Content = "The Forge Script v1.0",
    Icon = "check",
    Duration = 5
})

-- Update rock options awal
UpdateRockOptions(SelectedMiningLocation)
UpdateMobOptions(SelectedMobLocation)
