-- Хранилище данных о трассах и лидерах
local races = {}
local leaderboards = {}

-- Сохранение новой трассы
RegisterServerEvent("saveDriftRace")
AddEventHandler("saveDriftRace", function(start, clips, finish)
    local src = source
    local raceId = tostring(start)
    races[raceId] = {
        startPoint = start,
        clipPoints = clips,
        finishPoint = finish
    }
    leaderboards[raceId] = {}
    TriggerClientEvent("updateClientRaceData", -1, start, clips, finish) -- Обновляем данные у всех игроков
    TriggerClientEvent("chat:addMessage", source, { args = { "^2Трасса успешно создана!" } })
end)

-- Получение таблицы лидеров для трассы
RegisterServerEvent("getLeaderboard")
AddEventHandler("getLeaderboard", function(start)
    local raceId = tostring(start)
    if leaderboards[raceId] then
        TriggerClientEvent("showLeaderboard", source, leaderboards[raceId])
    end
end)

-- Обновление таблицы лидеров
RegisterServerEvent("updateLeaderboard")
AddEventHandler("updateLeaderboard", function(start, points)
    local raceId = tostring(start)
    if leaderboards[raceId] then
        local src = source
        local playerName = GetPlayerName(src)
        leaderboards[raceId][playerName] = points
        TriggerClientEvent("updateLeaderboardUI", -1, raceId, leaderboards[raceId]) -- Обновление для всех игроков
    end
end)

-- Экспорт данных при остановке ресурса
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SaveResourceFile(GetCurrentResourceName(), "races.json", json.encode(races), -1)
        SaveResourceFile(GetCurrentResourceName(), "leaderboards.json", json.encode(leaderboards), -1)
    end
end)

-- Загрузка данных при запуске ресурса
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local fileRaces = LoadResourceFile(GetCurrentResourceName(), "races.json")
        local fileLeaderboards = LoadResourceFile(GetCurrentResourceName(), "leaderboards.json")
        if fileRaces then
            races = json.decode(fileRaces)
        end
        if fileLeaderboards then
            leaderboards = json.decode(fileLeaderboards)
        end

        -- Отправляем данные о трассах всем игрокам
        TriggerClientEvent("loadRaceData", -1, races)
    end
end)
