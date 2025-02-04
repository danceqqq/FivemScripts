-- Список всех add-on машин, которые нужно предварительно загрузить
local vehiclesToLoad = {
    "adder", -- Пример: Adder
    "banshee2", -- Пример: Banshee 2
    "bullet", -- Пример: Bullet
    "comet3", -- Пример: Comet 3
    "carbonizzare", -- Пример: Carbonizzare
    "cheetah", -- Пример: Cheetah
    -- Добавьте сюда все модели машин, которые вы хотите предварительно загрузить
}

-- Функция для загрузки модели
local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0) -- Ждем, пока модель загрузится
    end
end

-- Главный поток для загрузки всех моделей
Citizen.CreateThread(function()
    print("^2[Vehicle Loader] Начинается загрузка моделей машин...^7")

    -- Загружаем каждую модель из списка
    for _, vehicle in ipairs(vehiclesToLoad) do
        local modelHash = GetHashKey(vehicle)

        -- Проверяем, существует ли модель
        if IsModelInCdimage(modelHash) and IsModelAVehicle(modelHash) then
            print("^3[Vehicle Loader] Загрузка модели: ^5" .. vehicle .. "^7")
            LoadModel(modelHash)
            print("^3[Vehicle Loader] Модель ^5" .. vehicle .. "^3 загружена успешно.^7")
        else
            print("^1[Vehicle Loader] Модель ^5" .. vehicle .. "^1 не найдена или не является машиной.^7")
        end
    end

    print("^2[Vehicle Loader] Все модели машин загружены!^7")
end)

-- Опционально: Очистка памяти (необязательно)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, vehicle in ipairs(vehiclesToLoad) do
            local modelHash = GetHashKey(vehicle)
            if HasModelLoaded(modelHash) then
                SetModelAsNoLongerNeeded(modelHash)
            end
        end
    end
end)
