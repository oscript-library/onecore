
// Сериализовать JSON.
//
// Параметры:
//  Данные - Произвольный - Данные для сериализации
//
// Возвращаемое значение:
//  Строка - Сериализовать JSON
Функция СериализоватьJSON(Данные) Экспорт

	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, Данные);

	Возврат ЗаписьJSON.Закрыть();

КонецФункции

// Десериализовать JSON.
//
// Параметры:
//  СтрокаJSON - Строка - Строка JSON
//  ИмяПолейДат - Массив - Массив строк содержащий имена полей с датами
//
// Возвращаемое значение:
//  Произвольный - Десериализованный JSON в данные поддерживаемые 1с
Функция ДесериализоватьJSON(СтрокаJSON, ИмяПолейДат = Неопределено) Экспорт

	МассивПолейДат = Новый Массив();

	Если ИмяПолейДат <> Неопределено Тогда
		Для Каждого Элемент Из ИмяПолейДат Цикл
			МассивПолейДат.Добавить(Элемент);
		КонецЦикла;
	КонецЕсли;

	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(СтрокаJSON);
	РезультатЧтения = ПрочитатьJSON(ЧтениеJSON, Ложь, МассивПолейДат);
	ЧтениеJSON.Закрыть();

	Возврат РезультатЧтения;

КонецФункции

