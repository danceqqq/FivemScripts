-- Переменные для работы
local isCreatingRace = false -- Режим создания заезда
local isEditingRace = false -- Режим редактирования заезда
local startPoint, clipPoints, finishPoint = nil, {}, nil -- Точки трассы
local currentDriftPoints = {} -- Текущие дрифт-очки для каждого игрока
local raceStarted = false -- Флаг начала заезда
local leaderboardData = {} -- Данные таблицы лидеров
local blips = {} -- Хранилище blips
local raceName = "" -- Имя трассы
local timeLimit = 60 -- Временной лимит для заезда (в секундах)
local raceTimer = 0 -- Таймер заезда
local raceType = "drift" -- Тип заезда (drift или time)

-- Создание blip
local function createBlip(coords, color, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 1) -- Стандартный спрайт
    SetBlipColour(blip, color) -- Цвет blip
    SetBlipScale(blip, 0.8) -- Размер blip
    SetBlipAsShortRange(blip, true) -- Короткий диапазон видимости
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Удаление всех blips
local function removeBlips()
    for _, blip in ipairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

-- Открытие NUI интерфейса
local function openNUI(data)
    SendNUIMessage({
        action = "open",
        data = data
    })
    SetNuiFocus(true, true)
end

-- Закрытие NUI интерфейса
local function closeNUI()
    SendNUIMessage({
        action = "close"
    })
    SetNuiFocus(false, false)
end

-- Обновление данных о трассе и создание blips
RegisterNetEvent("updateClientRaceData")
AddEventHandler("updateClientRaceData", function(start, clips, finish, name)
    removeBlips() -- Удаляем старые blips

    -- Создаем blip для точки старта
    if start then
        table.insert(blips, createBlip(start, 5, "Старт (" .. name .. ")"))
    end

    -- Создаем blips для чекпоинтов
    if clips then
        for i, point in ipairs(clips) do
            table.insert(blips, createBlip(point, 4, "Чекпоинт " .. i .. " (" .. name .. ")"))
        end
    end

    -- Создаем blip для финишной точки
    if finish then
        table.insert(blips, createBlip(finish, 3, "Финиш (" .. name .. ")"))
    end
end)

-- Команда для входа в режим создания трассы
RegisterCommand("createdr", function()
    if not isCreatingRace and not isEditingRace then
        isCreatingRace = true
        removeBlips() -- Удаляем все blips перед началом создания новой трассы
        SetCamActiveWithInterp(CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(PlayerPedId()), 0.0, 0.0, 0.0, 5000, true, 2), 5000, true, true)
        openNUI({ type = "create_race" })
    else
        TriggerEvent("chat:addMessage", { args = { "^1Вы уже находитесь в режиме создания или редактирования трассы!" } })
    end
end)

-- Команда для редактирования трассы
RegisterCommand("editdr", function(_, args)
    if not isCreatingRace and not isEditingRace then
        if args[2] then
            local raceId = tostring(args[2])
            local playerPos = GetEntityCoords(PlayerPedId())
            local closestStart = nil
            for id, data in pairs(races) do
                if GetDistanceBetweenCoords(playerPos, data.startPoint, true) < 10.0 then
                    closestStart = data.startPoint
                    break
                end
            end
            if closestStart then
                isEditingRace = true
                openNUI({ type = "edit_race", raceId = raceId })
            else
                TriggerEvent("chat:addMessage", { args = { "^1Вы не находитесь рядом со стартовой точкой трассы!" } })
            end
        else
            TriggerEvent("chat:addMessage", { args = { "^1Использование: /editdr <имя_трассы>" } })
        end
    else
        TriggerEvent("chat:addMessage", { args = { "^1Вы уже находитесь в режиме создания или редактирования трассы!" } })
    end
end)

-- Обработка расстановки точек
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isCreatingRace or isEditingRace then
            if IsControlJustPressed(0, 38) then -- Нажатие клавиши E
                local playerPos = GetEntityCoords(PlayerPedId())
                if not startPoint then
                    startPoint = playerPos
                    TriggerEvent("chat:addMessage", { args = { "^2Точка старта установлена!" } })
                elseif #clipPoints < 5 then -- Максимум 5 чекпоинтов
                    table.insert(clipPoints, playerPos)
                    TriggerEvent("chat:addMessage", { args = { "^2Чекпоинт установлен!" } })
                else
                    finishPoint = playerPos
                    TriggerEvent("chat:addMessage", { args = { "^2Финишная точка установлена!" } })
                    if isCreatingRace then
                        isCreatingRace = false
                        DestroyCam(GetFollowPedCamViewMode(), false)
                        TriggerServerEvent("saveDriftRace", startPoint, clipPoints, finishPoint, raceName, raceType)
                        TriggerEvent("updateClientRaceData", startPoint, clipPoints, finishPoint, raceName)
                    elseif isEditingRace then
                        isEditingRace = false
                        TriggerServerEvent("updateDriftRace", startPoint, clipPoints, finishPoint, raceName, raceType)
                        TriggerEvent("updateClientRaceData", startPoint, clipPoints, finishPoint, raceName)
                    end
                end
            end
        end
    end
end)

-- Отслеживание прохождения трассы
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if startPoint and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), startPoint, true) < 5.0 then
            if not raceStarted then
                raceStarted = true
                currentDriftPoints[source] = 0
                raceTimer = timeLimit
                openNUI({ type = "race_info", timeLimit = timeLimit, raceType = raceType })
                TriggerEvent("chat:addMessage", { args = { "^2Заезд начался! Время: " .. timeLimit .. " сек." } })
                TriggerServerEvent("getLeaderboard", startPoint) -- Запросить таблицу лидеров
            end
        end

        if raceStarted then
            -- Обновление таймера
            if raceTimer > 0 then
                raceTimer = raceTimer - 1
                if raceTimer == 0 then
                    raceStarted = false
                    closeNUI()
                    TriggerEvent("chat:addMessage", { args = { "^1Время вышло!" } })
                end
            end

            local speed = GetEntitySpeed(PlayerPedId()) * 2.236936 -- Скорость в милях/час
            local driftAngle = GetVehicleSteeringAngle(GetVehiclePedIsIn(PlayerPedId(), false))
            if math.abs(driftAngle) > 30 and speed > 30 then
                currentDriftPoints[source] = currentDriftPoints[source] + 1
            end

            -- Проверка чекпоинтов
            for i, point in ipairs(clipPoints) do
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), point, true) < 5.0 then
                    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
                    TriggerEvent("chat:addMessage", { args = { "^2Чекпоинт " .. i .. " пройден!" } })
                    TriggerServerEvent("syncCheckpoint", startPoint, i)
                end
            end

            -- Проверка финиша
            if finishPoint and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), finishPoint, true) < 5.0 then
                raceStarted = false
                closeNUI()
                TriggerEvent("chat:addMessage", { args = { "^2Вы финишировали! Собрано дрифт-очков: " .. currentDriftPoints[source] } })
                TriggerServerEvent("updateLeaderboard", startPoint, currentDriftPoints[source])
            end
        end
    end
end)

-- Получение данных о трассах с сервера
RegisterNetEvent("loadRaceData")
AddEventHandler("loadRaceData", function(racesData)
    removeBlips() -- Удаляем старые blips
    for raceId, data in pairs(racesData) do
        local start = data.startPoint
        local clips = data.clipPoints
        local finish = data.finishPoint
        local name = data.name

        -- Создаем blips для каждой трассы
        if start then
            table.insert(blips, createBlip(start, 5, "Старт (" .. name .. ")"))
        end
        if clips then
            for i, point in ipairs(clips) do
                table.insert(blips, createBlip(point, 4, "Чекпоинт " .. i .. " (" .. name .. ")"))
            end
        end
        if finish then
            table.insert(blips, createBlip(finish, 3, "Финиш (" .. name .. ")"))
        end
    end
end)

-- Обработка событий из NUI
RegisterNUICallback("submit", function(data, cb)
    if data.type == "create_race" then
        raceName = data.name
        raceType = data.type
        cb("ok")
    elseif data.type == "edit_race" then
        raceName = data.name
        raceType = data.type
        cb("ok")
    end
end)
