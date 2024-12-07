// Номер порта, который будет прослушивать TCPСервер
Перем ПортПрослушивания;

// Объект управляющий маршрутизацией запросов
Перем Маршрутизатор;

// Создаёт экземпляр web сервера
//
// Параметры:
//   Порт - Число - Порт запуска веб сервера
//
Процедура ПриСозданииОбъекта(Порт = 5555)
	
	ПортПрослушивания = Порт;
	
КонецПроцедуры

// Выпоняет запуск web сервера и ожидает соединения, блокирует поток выполнения
//
// Параметры:
//   ФоноваяОбработка - Булево - Если Истина тогда обработка соединений будет происходить в фоновом задании
//
Процедура Запустить(ФоноваяОбработка = Истина) Экспорт
	
	Маршрутизатор = Новый Маршрутизатор();
	ВебСервер = Новый ВебСервер(ПортПрослушивания);

	ВебСервер.ДобавитьОбработчикЗапросов(ЭтотОбъект, "ОбработатьЗапрос");

	Лог.Информация("Сервер будет запущен по адресу: http://127.0.0.1:" + Строка(ПортПрослушивания)); // BSLLS:UsingHardcodeNetworkAddress-off
	
	ВебСервер.Запустить();
	
КонецПроцедуры

Процедура ОбработатьЗапрос(Контекст, СледующийОбработчик) Экспорт
	
	Попытка
		
		МенеджерОбъектов = Приложение.МенеджерОбъектов();
		Перехватчики = МенеджерОбъектов.КлючиПерехватчиков();
		ОбъектыПерехватчиков = Новый Массив();

		Для Каждого КлючПерехватчика Из Перехватчики Цикл
			ОбъектыПерехватчиков.Добавить(МенеджерОбъектов.СоздатьОбъект(КлючПерехватчика));
		КонецЦикла;

		КонтекстЗапросаСтруктура = Новый Структура();
		КонтекстЗапросаСтруктура.Вставить("Запрос", Контекст.Запрос);
		КонтекстЗапросаСтруктура.Вставить("Ответ", Контекст.Ответ);
		
		СтрокаАгентаПользователя = ВебСерверСлужебное.ЗначениеЗаголовкаПоКлючу(Контекст.Запрос.Заголовки, "User-Agent");

		КонтекстЗапросаСтруктура.Вставить("ЗапросОтБраузера", ЭтоЗапросОтБраузера(СтрокаАгентаПользователя));
		КонтекстЗапросаСтруктура.Вставить("Сеанс", Неопределено);
		КонтекстЗапросаСтруктура.Вставить("Данные", Новый Структура());
		КонтекстЗапросаСтруктура.Вставить("АдресПеренаправления", "");

		Если КонтекстЗапросаСтруктура.ЗапросОтБраузера Тогда
			МенеджерСеансов = Приложение.МенеджерСеансов();
			КонтекстЗапросаСтруктура.Сеанс = МенеджерСеансов.ОпределитьСеанс(КонтекстЗапросаСтруктура);	
		КонецЕсли;
	
		ПрерватьОбработку = Ложь;
		// КонтекстЗапроса = Новый ФиксированнаяСтруктура(КонтекстЗапросаСтруктура);
		КонтекстЗапроса = КонтекстЗапросаСтруктура;

		ВызватьМетодПерехватчиков(ОбъектыПерехватчиков, "ПередВыполнениемПредставления", КонтекстЗапроса, ПрерватьОбработку);

		Если НЕ ПрерватьОбработку Тогда
			Маршрутизатор.ПеренаправитьВыполнение(КонтекстЗапроса);	
		КонецЕсли;
		
		ВызватьМетодПерехватчиков(ОбъектыПерехватчиков, "ПослеВыполненияПредставления", КонтекстЗапроса, ПрерватьОбработку);
		
	Исключение
		
		ПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		СтруктураОтвета = Новый Структура("massage", КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		Лог.Ошибка("Ошибка при выполнении обработчика соединения: " + ПредставлениеОшибки);
		
		Если Настройки.Получить("Приложение.РежимРазработки") Тогда
			СтруктураОтвета.Вставить("full_error", ПредставлениеОшибки);
		КонецЕсли;
		
		ТестОшибки = Сериализация.СериализоватьJSON(СтруктураОтвета);
		Контекст.Ответ.ТипКонтента = "json";
		Контекст.Ответ.КодСостояния = 500;
		Контекст.Ответ.ЗаписатьКакJSON(ТестОшибки);
		
	КонецПопытки;
	
КонецПроцедуры

Процедура ВызватьМетодПерехватчиков(ОбъектыПерехватчиков, ИмяМетода, Контекст, ПрерватьОбработку)
	
	МассивПараметровВызова = Новый Массив();
	МассивПараметровВызова.Добавить(Контекст);
	МассивПараметровВызова.Добавить(Истина);
	
	Для Каждого ОбъектПерехватчика Из ОбъектыПерехватчиков Цикл
		
		Если МассивПараметровВызова[1] Тогда
			Если Рефлексия.МетодСуществует(ОбъектПерехватчика, ИмяМетода) Тогда
				Попытка
					Рефлексия.ВызватьМетод(ОбъектПерехватчика, ИмяМетода, МассивПараметровВызова);
					ПрерватьОбработку = НЕ МассивПараметровВызова[1];
				Исключение
					Лог.Предупреждение(СтрШаблон("Метод ""%1"" объекта перехватчика ""%2"" не выполнен, по причине: %3",
					ИмяМетода, Строка(ОбъектПерехватчика), ОписаниеОшибки()));
				КонецПопытки;
			КонецЕсли;
		Иначе
			ПрерватьОбработку = Истина;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ЭтоЗапросОтБраузера(СтрокаАгентаПользователя)

	Возврат СтрНайти(СтрокаАгентаПользователя, "Firefox") 
		ИЛИ СтрНайти(СтрокаАгентаПользователя, "Seamonkey")
		ИЛИ СтрНайти(СтрокаАгентаПользователя, "Chrome")
		ИЛИ СтрНайти(СтрокаАгентаПользователя, "Chromium")
		ИЛИ СтрНайти(СтрокаАгентаПользователя, "Safari")
		ИЛИ СтрНайти(СтрокаАгентаПользователя, "OPR")
		ИЛИ СтрНайти(СтрокаАгентаПользователя, "Opera");

КонецФункции
