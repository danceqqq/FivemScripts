-- Переменные для работы
local isCreatingRace = false -- Режим создания заезда
local startPoint, clipPoints, finishPoint = nil, {}, nil -- Точки трассы
local currentDriftPoints = 0 -- Текущие дрифт-очки
local raceStarted = false -- Флаг начала заезда
local leaderboardData = {} -- Данные таблицы лидеров
local blips = {} -- Хранилище blips

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

-- Обновление данных о трассе и создание blips
RegisterNetEvent("updateClientRaceData")
AddEventHandler("updateClientRaceData", function(start, clips, finish)
    removeBlips() -- Удаляем старые blips

    -- Создаем blip для точки старта
    if start then
        table.insert(blips, createBlip(start, 5, "Старт"))
    end

    -- Создаем blips для чекпоинтов
    if clips then
        for i, point in ipairs(clips) do
            table.insert(blips, createBlip(point, 4, "Чекпоинт " .. i))
        end
    end

    -- Создаем blip для финишной точки
    if finish then
        table.insert(blips, createBlip(finish, 3, "Финиш"))
    end
end)

-- Команда для входа в режим создания трассы
RegisterCommand("createdr", function()
    if not isCreatingRace then
        isCreatingRace = true
        removeBlips() -- Удаляем все blips перед началом создания новой трассы
        SetCamActiveWithInterp(CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(PlayerPedId()), 0.0, 0.0, 0.0, 5000, true, 2), 5000, true, true)
        TriggerEvent("chat:addMessage", { args = { "^3Режим создания трассы активирован!" } })
    else
        TriggerEvent("chat:addMessage", { args = { "^1Вы уже находитесь в режиме создания трассы!" } })
    end
end)

-- Обработка расстановки точек
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isCreatingRace then
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
                    isCreatingRace = false
                    DestroyCam(GetFollowPedCamViewMode(), false)
                    TriggerServerEvent("saveDriftRace", startPoint, clipPoints, finishPoint)
                    TriggerEvent("updateClientRaceData", startPoint, clipPoints, finishPoint)
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
                currentDriftPoints = 0
                TriggerEvent("chat:addMessage", { args = { "^2Заезд начался!" } })
                TriggerServerEvent("getLeaderboard", startPoint) -- Запросить таблицу лидеров
            end
        end

        if raceStarted then
            local speed = GetEntitySpeed(PlayerPedId()) * 2.236936 -- Скорость в милях/час
            local driftAngle = GetVehicleSteeringAngle(GetVehiclePedIsIn(PlayerPedId(), false))
            if math.abs(driftAngle) > 30 and speed > 30 then
                currentDriftPoints = currentDriftPoints + 1
            end

            -- Проверка чекпоинтов
            for i, point in ipairs(clipPoints) do
                if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), point, true) < 5.0 then
                    TriggerEvent("chat:addMessage", { args = { "^2Чекпоинт " .. i .. " пройден!" } })
                end
            end

            -- Проверка финиша
            if finishPoint and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), finishPoint, true) < 5.0 then
                raceStarted = false
                TriggerEvent("chat:addMessage", { args = { "^2Вы финишировали! Собрано дрифт-очков: " .. currentDriftPoints } })
                TriggerServerEvent("updateLeaderboard", startPoint, currentDriftPoints)
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

        -- Создаем blips для каждой трассы
        if start then
            table.insert(blips, createBlip(start, 5, "Старт (" .. raceId .. ")"))
        end
        if clips then
            for i, point in ipairs(clips) do
                table.insert(blips, createBlip(point, 4, "Чекпоинт " .. i .. " (" .. raceId .. ")"))
            end
        end
        if finish then
            table.insert(blips, createBlip(finish, 3, "Финиш (" .. raceId .. ")"))
        end
    end
end)
