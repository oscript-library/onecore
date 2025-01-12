#Использовать entity

Перем МенеджерОбъектов;
Перем МенеджерКомпонентов;
Перем МенеджерСеансов;
Перем Коннекторы1С;
Перем МенеджерыСущностей;
Перем ИспользоватьORM;
Перем ПриложениеПроинициализировано;

Перем БазыДанныхКИнициализации;
Перем КомпонентыКИнициализации;
Перем ПерехватчикиКИнициализации;

Процедура Инициализировать(УровеньВыводаЛогов = "Отладка") Экспорт

	Лог.Инициализировать(УровеньВыводаЛогов);

	Для каждого Компонент Из КомпонентыКИнициализации Цикл
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

	Для каждого ДанныеПодключения Из БазыДанныхКИнициализации Цикл

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

		ИнициализироватьМенеджерСущностей(ДанныеПодключения.Ключ, ТипКоннектора, СтрокаСоединения);

	КонецЦикла;

	ПриложениеПроинициализировано = Истина;

КонецПроцедуры

Процедура Запустить() Экспорт
	
	Порт = Настройки.Получить("Приложение.ПортПрослушивания");

	СервисВебСервера = Новый СервисВебСервер(Порт);
	СервисВебСервера.Запустить(Истина);
	
КонецПроцедуры

Процедура ИспользоватьORM() Экспорт
	ИспользоватьORM = Истина;
КонецПроцедуры

Процедура ПодключитьБазуДанныхORM(Ключ, ТипКоннектора = Неопределено, СтрокаСоединения = Неопределено) Экспорт

	Если НЕ ИспользоватьORM Тогда
		Лог.Предупреждение("ORM не используется");
	КонецЕсли;

	Если ПриложениеПроинициализировано Тогда
		ИнициализироватьМенеджерСущностей(Ключ, ТипКоннектора = Неопределено, СтрокаСоединения = "");
	Иначе
		ДанныеПодключения = Новый Структура("ТипКоннектора, СтрокаСоединения", ТипКоннектора, СтрокаСоединения);
		БазыДанныхКИнициализации.Вставить(Ключ, ДанныеПодключения);
	КонецЕсли;

КонецПроцедуры

Процедура ИнициализироватьМенеджерСущностей(Знач Ключ, Знач ТипКоннектора = Неопределено, Знач СтрокаСоединения = "")

	Попытка

		Если ТипЗнч(ТипКоннектора) = Тип("Строка") Тогда
			ТипКоннектора = Тип(ТипКоннектора);
		КонецЕсли;

		МенеджерСущностей = Новый МенеджерСущностей(ТипКоннектора, СтрокаСоединения);

		Для каждого Компонент Из МенеджерКомпонентов.Компоненты() Цикл
			Для каждого ДанныеМодели Из Компонент.МоделиКомпонента() Цикл
				Попытка
					МенеджерСущностей.ДобавитьКлассВМодель(ДанныеМодели.Значение);
					Лог.Информация("Класс " + ДанныеМодели.Значение + " добавлен в модель");
				Исключение
					Лог.Предупреждение("Класс " + ДанныеМодели.Значение + " не добавлен в модель по причине " + ОписаниеОшибки());
				КонецПопытки;
			КонецЦикла;
		КонецЦикла;

		МенеджерСущностей.Инициализировать();
		МенеджерыСущностей.Вставить(Ключ, МенеджерСущностей);
		
		Лог.Информация("Менеджер сущностей по ключу " + Ключ + " успешно инициализирован");

	Исключение
		Лог.Ошибка(СтрШаблон("Ошибка инициализации менеджера сущностей по ключу %1 по причине %2", Ключ, ОписаниеОшибки()));
	КонецПопытки;

КонецПроцедуры

Процедура ИспользоватьКоннектор1С(Имя) Экспорт
	Коннекторы1С.Добавить(Имя);
КонецПроцедуры

Функция Коннекторы1С() Экспорт
	Возврат Коннекторы1С;
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

Функция ЗаполнитьСтруктуруНастроекПоУмолчанию()
	
	Структура = Новый Структура();
	
	Структура.Вставить("ПортПрослушивания", 5555);
	Структура.Вставить("РежимРазработки", Истина);
	Структура.Вставить("УровеньВыводаЛогов", "Информация");

	Если Коннекторы1С.Количество() Тогда

		МассивНастроекБаз1С = Новый Структура();
		СтруктураНастроекБазы1С = Новый Структура("АдресСервера, ИмяПубликации, ЗащищенноеСоединение, Пользователь, Пароль", "", "", Ложь, "", "");

		Для каждого ИмяБазы1С Из Коннекторы1С Цикл
			МассивНастроекБаз1С.Вставить(ИмяБазы1С, СтруктураНастроекБазы1С);
		КонецЦикла;

		Структура.Вставить("Коннекторы1С", МассивНастроекБаз1С);

	КонецЕсли;

	Если ИспользоватьORM Тогда

		Для каждого ДанныеПодключения Из БазыДанныхКИнициализации Цикл
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

МенеджерОбъектов = Новый МенеджерОбъектов();
МенеджерКомпонентов = Новый МенеджерКомпонентов();
МенеджерСеансов = Новый МенеджерСеансов();
Коннекторы1С = Новый Массив();
МенеджерыСущностей = Новый Соответствие();