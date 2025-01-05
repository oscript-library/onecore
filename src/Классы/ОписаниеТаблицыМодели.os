// BSLLS:SelfAssign-off

Перем _ИмяМодели;
Перем _ИмяТаблицы;
Перем КомпонентВладелец;
Перем Поля;

Процедура ПриСозданииОбъекта(ИмяМодели, ИмяТаблицы, Компонент)
	
	Если Служебное.СоответствуетCamelCase(ИмяТаблицы, Ложь) Тогда
		ВызватьИсключение "Имя таблицы должно быть латинское и соответствовать CamelCase нотации";
	КонецЕсли;

	_ИмяМодели = ИмяМодели;
	_ИмяТаблицы = ИмяТаблицы;
	КомпонентВладелец = Компонент;

	Поля = Новый ТаблицаЗначений();
	Поля.Колонки.Добавить("ИмяПоля", Новый ОписаниеТипов("Строка"));
	Поля.Колонки.Добавить("ИмяКолонки", Новый ОписаниеТипов("Строка"));
	Поля.Колонки.Добавить("Тип", Новый ОписаниеТипов("Тип"));
	Поля.Колонки.Добавить("ПараметрыТипа", Новый ОписаниеТипов("Структура"));

КонецПроцедуры

Процедура ДобавитьПоле(Знач ИмяПоля, Знач ИмяКолонки, Знач Тип, Знач ПараметрыТипа) Экспорт
	
	НовоеПоле = Поля.Добавить();
	НовоеПоле.ИмяПоля = ИмяПоля;
	НовоеПоле.ИмяКолонки = ИмяКолонки;
	НовоеПоле.Тип = Тип;
	НовоеПоле.ПараметрыТипа = ПараметрыТипа;

КонецПроцедуры


Функция ИмяМодели() Экспорт

	Возврат _ИмяМодели;
КонецФункции

Функция ИмяТаблицы() Экспорт

	Возврат _ИмяТаблицы;

КонецФункции

Функция Компонент() Экспорт
	
	Возврат КомпонентВладелец;

КонецФункции

Функция ПоляМодели() Экспорт

	Возврат Поля;
	
КонецФункции