V1.003
<details>
1. Добавлен интерфейс для создания и редактирования трасс.

1. Реализовано отображение информации о заезде (время, дрифт-очки).
   
1. Выбор типа заезда (дрифт или гонка на время).
   
1. Звуковые эффекты при прохождении чекпоинтов.
   
1. Полная синхронизация данных между игроками.
   
1. Удобное управление трассами через форму.
   
</details>
  
V1.002
<details>
1. Редактирование трасс :
Игроки могут редактировать существующие трассы через команду /editdr <имя_трассы>.
Необходимо находиться рядом со стартовой точкой трассы для редактирования.

1. Мультиплеерные заезды :
Поддержка одновременного участия нескольких игроков в одном заезде.
Полная синхронизация данных (дрифт-очков, чекпоинтов, таблицы лидеров).

1. Временной лимит :
Каждый заезд имеет временной лимит (60 секунд по умолчанию).
По истечении времени заезд автоматически завершается.

1. Отображение прогресса других игроков :
Игроки могут видеть, какие чекпоинты прошли другие участники.

1. Улучшенное управление трассами :
Возможность давать трассам уникальные имена для удобства управления.
</details>


V1.001
<details> <summaryV1.01 </summary>

1. Создание трассы :
Игрок может использовать команду /createdr для входа в режим создания трассы.
В этом режиме можно установить стартовую точку, до 5 чекпоинтов и финишную точку.
Все созданные трассы сохраняются на сервере.

1. Графическое отображение трассы :
Точки трассы (старт, чекпоинты, финиш) отображаются на карте в виде blips.
Каждый тип точки имеет свой цвет: старт — синий, чекпоинты — зеленый, финиш — красный.
1. Начало заезда :
Когда игрок подъезжает к стартовой точке, начинается заезд.
При старте показывается таблица лидеров для данной трассы.
1. Дрифт-очки :
Игрок получает очки за дрифт (угол поворота больше 30° и скорость выше 30 миль/ч).
Очки начисляются только во время заезда.
1. Завершение заезда :
При достижении финишной точки заезд завершается, результаты отправляются на сервер.
Таблица лидеров обновляется для всех игроков.
1. Таблица лидеров :
После каждого заезда таблица лидеров обновляется и отображается в игре.
1. Сохранение данных :
Данные о трассах и таблицах лидеров сохраняются в файлах races.json и leaderboards.json
</details>


# Установка :
` ensure drift_race_creator `


# Команды:
`/createdr` : Вход в режим создания трассы.
`/editdr <имя_трассы> `
