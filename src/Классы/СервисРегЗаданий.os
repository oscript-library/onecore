
Перем РегистрацияЗаданий;
Перем ФоновыеЗадания;
Перем РаботаСервера;

// Конструктор
Процедура ПриСозданииОбъекта()
    РегистрацияЗаданий = Новый Соответствие;
    ФоновыеЗадания = Новый Массив;
    РаботаСервера = Ложь;
КонецПроцедуры

// Регистрация нового задания
// 
// Параметры:
//   Ключ         - Строка - Уникальный идентификатор задания
//   Расписание   - Строка - Cron выражение для расписания
//   ИмяМодуля    - Строка - Имя модуля, где находится метод
//   ИмяМетода    - Строка - Имя метода для выполнения
//
Процедура ДобавитьЗадание(Ключ, Расписание, ИмяМодуля, ИмяМетода) Экспорт
    СтруктураЗадания = Новый Структура;
    СтруктураЗадания.Вставить("Ключ", Ключ);
    СтруктураЗадания.Вставить("Расписание", Расписание);
    СтруктураЗадания.Вставить("ИмяМодуля", ИмяМодуля);
    СтруктураЗадания.Вставить("ИмяМетода", ИмяМетода);
    СтруктураЗадания.Вставить("ПоследнийЗапуск", '00010101');
    
    РегистрацияЗаданий.Вставить(Ключ, СтруктураЗадания);

	
КонецПроцедуры

// Запуск сервера регламентных заданий
//
Процедура Запустить() Экспорт
    РаботаСервера = Истина;
    
    Пока РаботаСервера Цикл
        ТекущееВремя = ТекущаяДата();
        
        Для Каждого Задание Из РегистрацияЗаданий Цикл
            Если ПроверитьВремяЗапуска(Задание.Значение, ТекущееВремя) Тогда
                ЗапуститьФоновоеЗадание(Задание.Значение);
            КонецЕсли;
        КонецЦикла;
        
        Приостановить(1000); // Пауза 1 секунда
    КонецЦикла;
КонецПроцедуры

// Остановка сервера регламентных заданий
//
Процедура Остановить() Экспорт
    РаботаСервера = Ложь;
КонецПроцедуры

// Проверка необходимости запуска задания по cron расписанию
//
Функция ПроверитьВремяЗапуска(Задание, ТекущееВремя)
    // Разбор cron выражения
    КомпонентыРасписания = РазобратьCronВыражение(Задание.Расписание);
    
    Если КомпонентыРасписания = Неопределено Тогда
        Возврат Ложь;
    КонецЕсли;
    
    // Проверка соответствия текущего времени расписанию
    Возврат ПроверитьСоответствиеРасписанию(КомпонентыРасписания, ТекущееВремя, Задание.ПоследнийЗапуск);
КонецФункции

// Запуск задания в фоновом режиме
//
Процедура ЗапуститьФоновоеЗадание(Задание)
    ПараметрыЗадания = Новый Массив;
    ИмяЗадания = СтрШаблон("РегЗадание_%1", Задание.Ключ);
    
    Попытка
        ФоновоеЗадание = ФоновыеЗадания.Выполнить(Задание.ИмяМодуля, Задание.ИмяМетода, ПараметрыЗадания, ИмяЗадания);
        Задание.ПоследнийЗапуск = ТекущаяДата();
    Исключение
        // Логирование ошибки запуска
    КонецПопытки;
КонецПроцедуры

// Разбор cron выражения на компоненты
//
Функция РазобратьCronВыражение(Выражение)
    // Формат: минуты часы дни месяцы дни_недели
    // Пример: */5 * * * * - каждые 5 минут
    
    Результат = Новый Структура;
    Результат.Вставить("Минуты", Новый Массив);
    Результат.Вставить("Часы", Новый Массив);
    Результат.Вставить("Дни", Новый Массив);
    Результат.Вставить("Месяцы", Новый Массив);
    Результат.Вставить("ДниНедели", Новый Массив);
    
    КомпонентыСтрокой = СтрРазделить(Выражение, " ", Ложь);
    Если КомпонентыСтрокой.Количество() <> 5 Тогда
        Возврат Неопределено;
    КонецЕсли;
    
    РазобратьКомпонентВремени(КомпонентыСтрокой[0], Результат.Минуты, 0, 59);
    РазобратьКомпонентВремени(КомпонентыСтрокой[1], Результат.Часы, 0, 23);
    РазобратьКомпонентВремени(КомпонентыСтрокой[2], Результат.Дни, 1, 31);
    РазобратьКомпонентВремени(КомпонентыСтрокой[3], Результат.Месяцы, 1, 12);
    РазобратьКомпонентВремени(КомпонентыСтрокой[4], Результат.ДниНедели, 0, 6);
    
    Возврат Результат;
КонецФункции

// Разбор компонента времени cron выражения
//
Процедура РазобратьКомпонентВремени(Значение, Массив, МинЗначение, МаксЗначение)
    Если Значение = "*" Тогда
        Для Индекс = МинЗначение По МаксЗначение Цикл
            Массив.Добавить(Индекс);
        КонецЦикла;
        Возврат;
    КонецЕсли;
    
    Если СтрНачинаетсяС(Значение, "*/") Тогда
        Шаг = Число(Сред(Значение, 3));
        Для Индекс = МинЗначение По МаксЗначение Цикл
            Если Индекс % Шаг = 0 Тогда
                Массив.Добавить(Индекс);
            КонецЕсли;
        КонецЦикла;
        Возврат;
    КонецЕсли;
    
    Компоненты = СтрРазделить(Значение, ",", Ложь);
    Для Каждого Компонент Из Компоненты Цикл
        Если СтрНайти(Компонент, "-") > 0 Тогда
            Диапазон = СтрРазделить(Компонент, "-", Ложь);
            Для Индекс = Число(Диапазон[0]) По Число(Диапазон[1]) Цикл
                Массив.Добавить(Индекс);
            КонецЦикла;
        Иначе
            Массив.Добавить(Число(Компонент));
        КонецЕсли;
    КонецЦикла;
КонецПроцедуры

// Проверка соответствия времени расписанию
//
Функция ПроверитьСоответствиеРасписанию(Расписание, ТекущееВремя, ПоследнийЗапуск)
    Если ТекущееВремя <= ПоследнийЗапуск Тогда
        Возврат Ложь;
    КонецЕсли;
    
    Возврат Расписание.Минуты.Найти(Минута(ТекущееВремя)) <> Неопределено
        И Расписание.Часы.Найти(Час(ТекущееВремя)) <> Неопределено
        И Расписание.Дни.Найти(День(ТекущееВремя)) <> Неопределено
        И Расписание.Месяцы.Найти(Месяц(ТекущееВремя)) <> Неопределено
        И Расписание.ДниНедели.Найти(ДеньНедели(ТекущееВремя) - 1) <> Неопределено;
КонецФункции
