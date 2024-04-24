
Перем СписокМаршрутов;
Перем Компонент;

Процедура ПриСозданииОбъекта(_Компонент = Неопределено)

	Компонент = _Компонент;

	СписокМаршрутов = Новый ТаблицаЗначений();
	СписокМаршрутов.Колонки.Добавить("Адрес", Новый ОписаниеТипов("Строка"));
	СписокМаршрутов.Колонки.Добавить("КлючОбъекта", Новый ОписаниеТипов("Строка"));
	СписокМаршрутов.Колонки.Добавить("Тип", Новый ОписаниеТипов("Строка"));
	СписокМаршрутов.Колонки.Добавить("Статический", Новый ОписаниеТипов("Булево"));
	СписокМаршрутов.Колонки.Добавить("КоличествоЧастейМаршрута", Новый ОписаниеТипов("Число"));
	СписокМаршрутов.Колонки.Добавить("СодержитПараметры", Новый ОписаниеТипов("Булево"));

КонецПроцедуры

Процедура Добавить(Адрес, КлючОбъекта, Статический = Ложь) Экспорт
	
	МенеджерОбъектов = Приложение.МенеджерОбъектов();

	Если Компонент <> Неопределено И НЕ Статический Тогда
		КлючОбъекта = СтрШаблон("%1.%2.%3", Компонент.Имя(), "Представления", КлючОбъекта);
	КонецЕсли;

	Тип = МенеджерОбъектов.ТипПоКлючу(КлючОбъекта);

	Если Тип = Неопределено Тогда
		Лог.Предупреждение(СтрШаблон("Не найден обработчик маршрута %1 по ключу %2, маршрут не добавлен", Адрес, КлючОбъекта));
		Возврат;
	КонецЕсли;

	Если НЕ АдресСвободен(Адрес) Тогда
		Лог.Предупреждение(СтрШаблон("Добавляемый адрес %1 занят другим обработчиком, маршрут не добавлен", Адрес));
		Возврат;
	КонецЕсли;

	НоваяСтрока = СписокМаршрутов.Добавить();
	НоваяСтрока.Адрес = Адрес;
	НоваяСтрока.КлючОбъекта = КлючОбъекта;
	НоваяСтрока.Тип = Тип;
	НоваяСтрока.Статический = Статический;
	НоваяСтрока.КоличествоЧастейМаршрута = СтрРазделить(Адрес, "/", Ложь).Количество();
	НоваяСтрока.СодержитПараметры = СтрНайти(Адрес, "<") > 0;

	Если Компонент <> Неопределено Тогда
		Лог.Отладка(СтрШаблон("Добавлен маршрут %1, ключ объекта обработчика: %2", Адрес, КлючОбъекта));
	КонецЕсли;
	
КонецПроцедуры

Функция СписокМаршрутов() Экспорт
	Возврат СписокМаршрутов;
КонецФункции

Функция НайтиМаршрут(Адрес) Экспорт
	
	// TODO: Всё вот это чудо нужно рефакторить

	ЧастиМаршрута = СтрРазделить(Адрес, "/", Ложь);
	КоличествоЧастейМаршрута = ЧастиМаршрута.Количество();

	НайденныеСтроки = СписокМаршрутов.НайтиСтроки(Новый Структура("КоличествоЧастейМаршрута", КоличествоЧастейМаршрута));
	
	Если НЕ НайденныеСтроки.Количество() Тогда
		Возврат Неопределено;
	КонецЕсли;

	ТаблицаСравнения = Новый ТаблицаЗначений();
	ТаблицаСравнения.Колонки.Добавить("ОсновнойМаршрут", Новый ОписаниеТипов("Строка"));

	ТаблицаРезультата = Новый ТаблицаЗначений();
	ТаблицаРезультата.Колонки.Добавить("ИндексМаршрута", Новый ОписаниеТипов("Число"));
	ТаблицаРезультата.Колонки.Добавить("КоличествоСхождений", Новый ОписаниеТипов("Число"));	

	Для Индекс = 1 По НайденныеСтроки.Количество() Цикл
		ТаблицаСравнения.Колонки.Добавить("Маршрут" + Строка(Индекс), Новый ОписаниеТипов("Строка"));
		НоваяСтрока = ТаблицаРезультата.Добавить();
		НоваяСтрока.ИндексМаршрута = Индекс;
	КонецЦикла;

	Для каждого ЧастьМаршрута Из ЧастиМаршрута Цикл
		НоваяСтрока = ТаблицаСравнения.Добавить();
		НоваяСтрока.ОсновнойМаршрут = ЧастьМаршрута;
	КонецЦикла;	

	ИндексМаршрута = 1;

	Для каждого НайденныйМаршрут Из НайденныеСтроки Цикл
			
		ЧастиНайденногоМаршрута = СтрРазделить(НайденныйМаршрут.Адрес, "/", Ложь);
		
		ИндексЧастиМаршрута = 0;

		Для каждого ЧастьНайденногоМаршрута Из ЧастиНайденногоМаршрута Цикл
			НоваяСтрока = ТаблицаСравнения[ИндексЧастиМаршрута];
			НоваяСтрока["Маршрут" + Строка(ИндексМаршрута)] = ЧастьНайденногоМаршрута;
			ИндексЧастиМаршрута = ИндексЧастиМаршрута + 1;
		КонецЦикла;
		
		ИндексМаршрута = ИндексМаршрута + 1;

	КонецЦикла;

	Для каждого СтрокаТаблицы Из ТаблицаСравнения Цикл

		Для каждого Колонка Из ТаблицаСравнения.Колонки Цикл

			Если Колонка.Имя = "ОсновнойМаршрут" Тогда
				Продолжить;
			КонецЕсли;

			Параметризируемый = СтрНачинаетсяС(СтрокаТаблицы[Колонка.Имя], "<");
			ИндексМаршрута = Число(СтрЗаменить(Колонка.Имя, "Маршрут", ""));

			НайденнаяСтрокаРезультата = ТаблицаРезультата.НайтиСтроки(Новый Структура("ИндексМаршрута", ИндексМаршрута));
			НайденнаяСтрокаРезультата = НайденнаяСтрокаРезультата[0];
			
			Если Параметризируемый Тогда
				
				ЧастьМаршрута = СтрокаТаблицы[Колонка.Имя];

				Если Не СтрНайти(ЧастьМаршрута, ":") Тогда
					Продолжить;
				КонецЕсли;

				Если СтрокаТаблицы.ОсновнойМаршрут = ЧастьМаршрута Тогда
					НайденнаяСтрокаРезультата.КоличествоСхождений = НайденнаяСтрокаРезультата.КоличествоСхождений + 1;
					Продолжить;
				КонецЕсли;
				
				ОписаниеТипа = Новый ОписаниеТипов("Число");
				Значение = ОписаниеТипа.ПривестиЗначение(СтрокаТаблицы.ОсновнойМаршрут);

				Если Значение <> 0 Тогда
					ТипОсновнойЧастиМаршрута = Тип("Число");
				Иначе
					ТипОсновнойЧастиМаршрута = Тип("Строка");
				КонецЕсли;
				
				ДанныеЧастиМаршрута = ДанныеЧастиМаршрутаПараметром(ЧастьМаршрута);

				Если ТипОсновнойЧастиМаршрута = ДанныеЧастиМаршрута.Тип Тогда
					НайденнаяСтрокаРезультата.КоличествоСхождений = НайденнаяСтрокаРезультата.КоличествоСхождений + 1;
				КонецЕсли;

			Иначе
				Если СтрокаТаблицы.ОсновнойМаршрут = СтрокаТаблицы[Колонка.Имя] Тогда
					НайденнаяСтрокаРезультата.КоличествоСхождений = НайденнаяСтрокаРезультата.КоличествоСхождений + 1;
				КонецЕсли;
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;

	НайденныеСтрокиРезультата = ТаблицаРезультата.НайтиСтроки(Новый Структура("КоличествоСхождений", КоличествоЧастейМаршрута));

	Если НайденныеСтрокиРезультата.Количество() Тогда
		ИндексМаршрута = НайденныеСтрокиРезультата[0].ИндексМаршрута;
		Возврат НайденныеСтроки[ИндексМаршрута - 1];
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции

Функция ДанныеЧастиМаршрутаПараметром(Знач ЧастьМаршрута) Экспорт
	
	Если НЕ СтрНайти(ЧастьМаршрута, ":") Тогда
		Возврат Неопределено;
	КонецЕсли;

	ЧастьМаршрута = СтрЗаменить(СтрЗаменить(ЧастьМаршрута, "<", ""), ">", "");
	МассивРазделения = СтрРазделить(ЧастьМаршрута, ":", Ложь);
	
	Попытка
		Возврат Новый Структура("Тип, ИмяПараметра", Тип(МассивРазделения[0]), МассивРазделения[1]);
	Исключение
		Лог.Ошибка(СтрШаблон("В части %1 маршрута ошибка: %2", ЧастьМаршрута, ОписаниеОшибки()));
		Возврат Неопределено;
	КонецПопытки;

КонецФункции

Функция АдресСвободен(Адрес)
	
	НайденныеСтроки = СписокМаршрутов.НайтиСтроки(Новый Структура("Адрес", Адрес));
	Возврат НЕ НайденныеСтроки.Количество();

КонецФункции