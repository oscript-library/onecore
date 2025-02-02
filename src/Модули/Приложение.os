#Использовать entity

Перем МенеджерОбъектов;
Перем МенеджерКомпонентов;
Перем МенеджерСеансов;
Перем Маршрутизатор;
Перем ИспользоватьORM;
Перем МенеджерORM;
Перем ПриложениеПроинициализировано;
Перем СвойстваМаршрутовПоУмолчанию;

Перем БазыДанныхКИнициализации;
Перем КомпонентыКИнициализации;
Перем ПерехватчикиКИнициализации;

Процедура Инициализировать(УровеньВыводаЛогов = "Отладка") Экспорт
	
	Лог.Инициализировать(УровеньВыводаЛогов);
	
	Для Каждого Компонент Из КомпонентыКИнициализации Цикл
		МенеджерКомпонентов.Инициализировать(Компонент.ИмяКомпонента,
			Компонент.ИмяКомпонентаЛатинское,
			Компонент.КореньСтатическихФайлов);
	КонецЦикла;
	
	МенеджерОбъектов.ИнициализироватьПерехватчики(ПерехватчикиКИнициализации);
	
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
	Лог.Отладка("Настройки проинициализированы");
	
	// Инициализация ORM
	Для Каждого ДанныеПодключения Из БазыДанныхКИнициализации Цикл
		
		СохраненныеНастройки = Настройки.Получить("Приложение.БазыДанныхORM." + ДанныеПодключения.Ключ);
		ТипКоннектора = ДанныеПодключения.Значение.ТипКоннектора;
		СтрокаСоединения = ДанныеПодключения.Значение.СтрокаСоединения;
		
		Если НЕ ЗначениеЗаполнено(ТипКоннектора) Тогда
			СохраненныеНастройки.Свойство("ТипКоннектора", ТипКоннектора);
			СохраненныеНастройки.Свойство("СтрокаСоединения", СтрокаСоединения);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ТипКоннектора) Тогда
			Продолжить;
		КонецЕсли;
		
		МенеджерORM.ИнициализироватьМенеджерСущностей(ДанныеПодключения.Ключ, ТипКоннектора, СтрокаСоединения);
		
	КонецЦикла;

	ПриложениеПроинициализировано = Истина;
	
КонецПроцедуры

Процедура Запустить() Экспорт
	
	Маршрутизатор = Новый Маршрутизатор(СвойстваМаршрутовПоУмолчанию);

	Отказ = Ложь;

	МенеджерКомпонентов.ВыполнитьОбработчикиПриЗапуске(Отказ);

	Если Отказ Тогда
		Возврат;
	КонецЕсли;

	Порт = Настройки.Получить("Приложение.ПортПрослушивания");
	
	СервисВебСервера = Новый СервисВебСервер(Порт, СвойстваМаршрутовПоУмолчанию);
	СервисВебСервера.Запустить(Маршрутизатор);
	
КонецПроцедуры

Процедура ИспользоватьORM() Экспорт
	ИспользоватьORM = Истина;
КонецПроцедуры

Процедура УстановитьСвойстваМаршрутовПоУмолчанию(Свойства) Экспорт
	СвойстваМаршрутовПоУмолчанию = Коллекции.СкопироватьСтруктуру(Свойства);
КонецПроцедуры

Процедура ПодключитьБазуДанныхORM(Ключ, ТипКоннектора = Неопределено, СтрокаСоединения = Неопределено) Экспорт
	
	Если НЕ ИспользоватьORM Тогда
		Лог.Предупреждение("ORM не используется");
	КонецЕсли;
	
	Если ПриложениеПроинициализировано Тогда
		МенеджерORM.ИнициализироватьМенеджерСущностей(Ключ, ТипКоннектора = Неопределено, СтрокаСоединения = "");
	Иначе
		ДанныеПодключения = Новый Структура("ТипКоннектора, СтрокаСоединения", ТипКоннектора, СтрокаСоединения);
		БазыДанныхКИнициализации.Вставить(Ключ, ДанныеПодключения);
	КонецЕсли;
	
КонецПроцедуры

Функция МенеджерСущностей(Ключ) Экспорт
	Возврат МенеджерORM.МенеджерСущностей(Ключ);
КонецФункции

Функция МенеджерыСущностей() Экспорт
	Возврат МенеджерORM.МенеджерыСущностей();
КонецФункции

Функция МенеджерORM() Экспорт
	Возврат МенеджерORM;
КонецФункции

Функция МенеджерОбъектов() Экспорт
	Возврат МенеджерОбъектов;
КонецФункции

Функция МенеджерКомпонентов() Экспорт
	Возврат МенеджерКомпонентов;
КонецФункции

Функция МенеджерСеансов() Экспорт
	Возврат МенеджерСеансов;
КонецФункции

Функция Маршрутизатор() Экспорт
	Возврат Маршрутизатор;
КонецФункции

Функция ЗаполнитьСтруктуруНастроекПоУмолчанию()
	
	Структура = Новый Структура();
	
	Структура.Вставить("ПортПрослушивания", 5555);
	Структура.Вставить("РежимРазработки", Истина);
	Структура.Вставить("УровеньВыводаЛогов", "Информация");
	
	// Если Коннекторы1С.Количество() Тогда
		
	// 	МассивНастроекБаз1С = Новый Структура();
	// 	СтруктураНастроекБазы1С = Новый Структура("АдресСервера, ИмяПубликации, ЗащищенноеСоединение, Пользователь, Пароль", "", "", Ложь, "", "");
		
	// 	Для Каждого ИмяБазы1С Из Коннекторы1С Цикл
	// 		МассивНастроекБаз1С.Вставить(ИмяБазы1С, СтруктураНастроекБазы1С);
	// 	КонецЦикла;
		
	// 	Структура.Вставить("Коннекторы1С", МассивНастроекБаз1С);
		
	// КонецЕсли;
	
	Если ИспользоватьORM Тогда
		
		Для Каждого ДанныеПодключения Из БазыДанныхКИнициализации Цикл
			НастройкиБазыДанныхORM = Новый Структура(ДанныеПодключения.Ключ, Новый Структура("ТипКоннектора, СтрокаСоединения"));
		КонецЦикла;
		
		Структура.Вставить("БазыДанныхORM", НастройкиБазыДанныхORM);
		
	КонецЕсли;
	
	Возврат Структура;
	
КонецФункции

Процедура ПодключитьКомпонент(ИмяКомпонента, ИмяКомпонентаЛатинское, КореньСтатическихФайлов = Ложь) Экспорт
	
	Структура = Новый Структура("ИмяКомпонента, 
			|ИмяКомпонентаЛатинское, 
			|КореньСтатическихФайлов",
			ИмяКомпонента,
			ИмяКомпонентаЛатинское,
			КореньСтатическихФайлов);
	
	КомпонентыКИнициализации.Добавить(Структура);
	
КонецПроцедуры

Процедура ПодключитьПерехватчик(Ключ) Экспорт
	
	ПерехватчикиКИнициализации.Добавить(Ключ);
	
КонецПроцедуры

ПриложениеПроинициализировано = Ложь;
ИспользоватьORM = Ложь;
БазыДанныхКИнициализации = Новый Соответствие();
КомпонентыКИнициализации = Новый Массив();
ПерехватчикиКИнициализации = Новый Массив();
СвойстваМаршрутовПоУмолчанию = Новый Структура();

МенеджерОбъектов = Новый МенеджерОбъектов();
МенеджерКомпонентов = Новый МенеджерКомпонентов();
МенеджерСеансов = Новый МенеджерСеансов();
МенеджерORM = Новый МенеджерORM;