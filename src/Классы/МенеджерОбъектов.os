#Использовать strings

Перем ТаблицаОбъектов;
Перем КлючиПерехватчиков;

Процедура ПриСозданииОбъекта()
	
	ТаблицаОбъектов = Новый ТаблицаЗначений();
	ТаблицаОбъектов.Колонки.Добавить("Тип");
	ТаблицаОбъектов.Колонки.Добавить("ТипСтрокой");
	ТаблицаОбъектов.Колонки.Добавить("Ключ");

	КлючиПерехватчиков = Новый Массив();

КонецПроцедуры

Функция КлючиПерехватчиков() Экспорт
	Возврат КлючиПерехватчиков;
КонецФункции

Процедура ЗарегистрироватьОбъект(Путь, Ключ, ЭтоМодель = Ложь, Отказ = Ложь) Экспорт
	
	ИмяТипа = ИмяТипаПоКлючу(Ключ, ЭтоМодель);

	Попытка
		ПодключитьСценарий(Путь, ИмяТипа);
	Исключение
		Отказ = Истина;
		Лог.Ошибка(СтрШаблон("Ошибка при регистрации объекта %1: %2", Ключ, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
		Возврат;
	КонецПопытки;

	НоваяСтрока = ТаблицаОбъектов.Добавить();
	НоваяСтрока.Тип = Тип(ИмяТипа);
	НоваяСтрока.ТипСтрокой = ИмяТипа;
	НоваяСтрока.Ключ = Ключ;

КонецПроцедуры

Функция СоздатьОбъект(Ключ, Параметры = Неопределено, ЗаполненияСвойств = Неопределено) Экспорт
	
	Тип = ТипПоКлючу(Ключ);

	Попытка
		Объект = Новый(Тип, Параметры);
	Исключение
		Лог.КритичнаяОшибка(СтрШаблон("Создание объекта по ключу %1 невозможно, по причине: %2", Ключ, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
		Возврат Неопределено;
	КонецПопытки;
	
	ИмяКомпонента = Лев(Ключ, СтрНайти(Ключ, ".") - 1);

	Если ЗаполненияСвойств <> Неопределено Тогда		
		Для каждого КлючЗначение Из ЗаполненияСвойств Цикл
			Если Рефлексия.СвойствоСуществует(Объект, КлючЗначение.Ключ) Тогда
				Рефлексия.УстановитьСвойство(Объект, КлючЗначение.Ключ, КлючЗначение.Значение);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	ПодключитьСервисыКОбъекту(Объект, ИмяКомпонента);

	Коннекторы1С = Рефлексия.ПолучитьТаблицуСвойств(Объект, "Коннектор1С");

	Для каждого СвойствоКоннектора Из Коннекторы1С Цикл
		АннотацииСвойства = Рефлексия.ТаблицаАннотацийВСтруктуру(СвойствоКоннектора.Аннотации);
		ИмяКоннектора = АннотацииСвойства.Коннектор1С;
		ЭкземплярКоннектора = Новый Коннектор1С(ИмяКоннектора);
		Рефлексия.УстановитьСвойство(Объект, СвойствоКоннектора.Имя, ЭкземплярКоннектора);
	КонецЦикла;

	МенеджерыСущностей = Рефлексия.ПолучитьТаблицуСвойств(Объект, "МенеджерСущностей");

	Для каждого СвойствоМенеджера Из МенеджерыСущностей Цикл
		АннотацииСвойства = Рефлексия.ТаблицаАннотацийВСтруктуру(СвойствоМенеджера.Аннотации);
		КлючМенеджера = АннотацииСвойства.МенеджерСущностей;
		ЭкземплярМенеджера = Приложение.МенеджерСущностей(КлючМенеджера);
		Рефлексия.УстановитьСвойство(Объект, СвойствоМенеджера.Имя, ЭкземплярМенеджера);
	КонецЦикла;	

	ПодключитьОбщиеОбъектыКОбъекту(Объект);

	Возврат Объект;

КонецФункции

Процедура ПодключитьСервисыКОбъекту(Объект, ИмяКомпонента) Экспорт

	Сервисы = Рефлексия.ПолучитьТаблицуСвойств(Объект, "Сервис");

	Для каждого СвойствоСервиса Из Сервисы Цикл

		КлючСервиса = КлючСервисаИзАннотации(СвойствоСервиса.Аннотации, ИмяКомпонента);

		Если КлючСервиса = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		ОбъектСервиса = СоздатьОбъект(КлючСервиса);

		Если ОбъектСервиса <> Неопределено Тогда
			Рефлексия.УстановитьСвойство(Объект, СвойствоСервиса.Имя, ОбъектСервиса);
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ПодключитьОбщиеОбъектыКОбъекту(Объект) Экспорт

	ОбщиеОбъекты = Новый Структура();
	ОбщиеОбъекты.Вставить("МенеджерОбъектов", ЭтотОбъект);
	ОбщиеОбъекты.Вставить("Маршрутизатор", Приложение.Маршрутизатор());
	ОбщиеОбъекты.Вставить("МенеджерСеансов", Приложение.МенеджерСеансов());
	ОбщиеОбъекты.Вставить("МенеджерORM", Приложение.МенеджерORM());

	Для каждого ОбщийОбъект Из ОбщиеОбъекты Цикл
		Если Рефлексия.СвойствоСуществует(Объект, ОбщийОбъект.Ключ) Тогда
			Рефлексия.УстановитьСвойство(Объект, ОбщийОбъект.Ключ, ОбщийОбъект.Значение);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

Функция ИмяТипаПоКлючу(Ключ, ЭтоМодель = Ложь) Экспорт

	Имя = "";
	МассивПодстрок = СтрРазделить(Ключ, ".");

	Для Счетчик = 0 По МассивПодстрок.ВГраница() Цикл

		ЧастьКлюча = МассивПодстрок[Счетчик];

		Если ЭтоМодель И Счетчик = 1 Тогда
			Продолжить;
		КонецЕсли;

		Имя = Имя + ТРег(ЧастьКлюча);

	КонецЦикла;

	Возврат Имя;
	
КонецФункции

Функция КлючПоТипу(Тип) Экспорт
	
	НайденныеСтроки = ТаблицаОбъектов.НайтиСтроки(Новый Структура("Тип", Тип));

	Если НайденныеСтроки.Количество() Тогда
		Возврат НайденныеСтроки[0].Ключ;
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции

Функция ОбъектЗарегистрирован(Ключ) Экспорт
	
	Возврат ЗаписьПоКлючу(Ключ) <> Неопределено;

КонецФункции

Функция ТипПоКлючу(Ключ) Экспорт
	
	Запись = ЗаписьПоКлючу(Ключ);

	Если Запись = Неопределено Тогда
		Возврат Запись;
	КонецЕсли;

	Возврат Запись.Тип;

КонецФункции

Процедура ИнициализироватьПерехватчики(КлючиСервисов) Экспорт
	
	Лог.Отладка("Инициализация перехватчиков");

	Если ТипЗнч(КлючиСервисов) = Тип("Строка") Тогда
		МассивКлючейСервисов = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(КлючиСервисов, ",", Истина, Истина);
	ИначеЕсли ТипЗнч(КлючиСервисов) = Тип("Массив") Тогда
		МассивКлючейСервисов = КлючиСервисов;
	Иначе
		Лог.КритичнаяОшибка("Ошибка при инициализации перехватчиков, передано не верное значение путей сервисов");
	КонецЕсли;

	Для каждого КлючСервиса Из МассивКлючейСервисов Цикл

		Если НЕ СтрНайти(КлючСервиса, ".Сервисы.") Тогда
			ИмяКомпонента = Лев(КлючСервиса, СтрНайти(КлючСервиса, ".") - 1);
			Ключ = СтрЗаменить(КлючСервиса, ИмяКомпонента, ИмяКомпонента + ".Сервисы");
		Иначе
			Ключ = КлючСервиса;
		КонецЕсли;

		Если НЕ ОбъектЗарегистрирован(Ключ) Тогда
			Лог.Предупреждение(СтрШаблон("Сервис перехватчика по ключу ""%1"" не зарегистрирован", Ключ));
			Продолжить;
		КонецЕсли;

		КлючиПерехватчиков.Добавить(Ключ);
		Лог.Отладка(СтрШаблон("Перехватчик по ключу ""%1"" проинициализирован", Ключ));

	КонецЦикла;

КонецПроцедуры

Функция СвойстваОбъектаВСтруктуру(Объект) Экспорт
	
	Структура = Новый Структура();
	ИменаСвойств = Рефлексия.ПолучитьТаблицуСвойств(Объект).ВыгрузитьКолонку("Имя");
	
	Для каждого Имя Из ИменаСвойств Цикл
		Структура.Вставить(Имя, Рефлексия.ПолучитьСвойство(Объект, Имя));
	КонецЦикла;

	Возврат Структура;

КонецФункции

Функция ЗаписьПоКлючу(Ключ)
	
	НайденныеСтроки = ТаблицаОбъектов.НайтиСтроки(Новый Структура("Ключ", Ключ));

	Если Не НайденныеСтроки.Количество() Тогда
		Возврат Неопределено;
	КонецЕсли;

	Возврат НайденныеСтроки[0];

КонецФункции

Функция КлючСервисаИзАннотации(Аннотации, ИмяКомпонента)

	КлючСервиса = Неопределено;
	МенеджерКомпонентов = Приложение.МенеджерКомпонентов();

	Для каждого Аннотация Из Аннотации Цикл
		Если Аннотация.Имя = "Сервис" Тогда
			Если Аннотация.Параметры.Количество() Тогда

				ПутьКСервису = Аннотация.Параметры[0].Значение;
				ИмяПредполагаемогоКомпонента = Лев(ПутьКСервису, СтрНайти(ПутьКСервису, ".") - 1);

				Если МенеджерКомпонентов.НайтиПоИмени(ИмяПредполагаемогоКомпонента) <> Неопределено Тогда
					КлючСервиса = ПутьКСервису;
				Иначе
					КлючСервиса = ?(СтрНачинаетсяС(ПутьКСервису, ИмяКомпонента), ПутьКСервису, СтрШаблон("%1.Сервисы.%2", ИмяКомпонента, ПутьКСервису));
				КонецЕсли;

				Прервать;

			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат КлючСервиса;

КонецФункции