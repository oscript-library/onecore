// #Использовать entity

Перем МенеджерОбъектов;
Перем МенеджерКомпонентов;
Перем МенеджерСеансов;
// Перем МенеджерБазыДанных;

Процедура Запустить() Экспорт
	
	// Инициализация настроек приложения
	НастройкиПоУмолчанию = ЗаполнитьСтруктуруНастроекПоУмолчанию();
	Настройки.Инициализировать(НастройкиПоУмолчанию);
	
	// Инициализация логирования
	РежимРазработки = Настройки.Получить("Приложение.РежимРазработки");
	УровеньВыводаЛогов = Настройки.Получить("Приложение.УровеньВыводаЛогов");
	
	Если РежимРазработки Тогда
		УровеньВыводаЛогов = "Отладка";
	КонецЕсли;
	
	Лог.Инициализировать(УровеньВыводаЛогов);

	// МенеджерБазыДанных.Инициализировать();
	
	Порт = Настройки.Получить("Приложение.ПортПрослушивания");
	
	СервисВебСервера = Новый СервисВебСервер(Порт);
	СервисВебСервера.Запустить(Истина);
	
КонецПроцедуры

// Процедура ИспользоватьБазуДанных() Экспорт
// 	МенеджерБазыДанных = Новый МенеджерБазыДанных();
// КонецПроцедуры

Функция МенеджерОбъектов() Экспорт
	Возврат МенеджерОбъектов;
КонецФункции

Функция МенеджерКомпонентов() Экспорт
	Возврат МенеджерКомпонентов;
КонецФункции

Функция МенеджерСеансов() Экспорт
	Возврат МенеджерСеансов;
КонецФункции

Функция ЗаполнитьСтруктуруНастроекПоУмолчанию()
	
	Структура = Новый Структура();
	
	Структура.Вставить("ПортПрослушивания", 5555);
	Структура.Вставить("РежимРазработки", Истина);
	Структура.Вставить("УровеньВыводаЛогов", "Информация");

	// Если МенеджерБазыДанных <> Неопределено Тогда
	// 	Структура.Вставить("БазаДанных", Новый Структура("Адрес, ИмяБазы, Пользователь, Пароль, Порт"));
	// КонецЕсли;
	
	Возврат Структура;
	
КонецФункции

МенеджерОбъектов = Новый МенеджерОбъектов();
МенеджерКомпонентов = Новый МенеджерКомпонентов();
МенеджерСеансов = Новый МенеджерСеансов();

Лог.Инициализировать();
Лог.Отладка("Настройки проинициализированы");