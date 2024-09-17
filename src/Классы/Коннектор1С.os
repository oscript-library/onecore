
Перем Имя;
Перем АдресСервера;
Перем ИмяПубликации;
Перем ЗащищенноеСоединение;
Перем Пользователь;
Перем Пароль;

Процедура ПриСозданииОбъекта(ИмяКоннектора)

	Имя = ИмяКоннектора;
	НастройкиПодключения = Настройки.Получить("Приложение.Коннекторы1С." + Имя);

	Если НастройкиПодключения = Неопределено Тогда
		Лог.Предупреждение(СтрШаблон("У коннектора 1С: %1, отсутствуют настройки подключения", Имя));
		Возврат;
	КонецЕсли;

	АдресСервера = НастройкиПодключения.АдресСервера;
	ИмяПубликации = НастройкиПодключения.ИмяПубликации;
	ЗащищенноеСоединение = НастройкиПодключения.ЗащищенноеСоединение;
	Пользователь = НастройкиПодключения.Пользователь;
	Пароль = НастройкиПодключения.Пароль;

КонецПроцедуры

Функция СоздатьОтбор() Экспорт
	Возврат Новый ГруппаОтбораКоннектора1С();
КонецФункции

Функция Получить(ТипСущности, ИмяСущности, Отбор = Неопределено, Свойства = Неопределено) Экспорт

	СтрокаЗапроса = СтрШаблон("%1_%2", ТипСущности, ИмяСущности);
	ПараметрыЗапроса = Новый Соответствие();

	Если Отбор <> Неопределено Тогда
		ПараметрыЗапроса.Вставить("$filter", Отбор.СформироватьСтрокуЗапроса());
	КонецЕсли;

	Возврат ВыполнитьЗапрос(МетодыHttp.GET, СтрокаЗапроса, ПараметрыЗапроса);

КонецФункции

Функция ПрямойЗапрос(Метод, СтрокаЗапроса) Экспорт
	
	Возврат ВыполнитьЗапрос(Метод, СтрокаЗапроса);

КонецФункции

Функция ВыполнитьЗапрос(Метод, СтрокаЗапроса, ПараметрыЗапроса = Неопределено)

	Запрос = Новый ЗапросВнешнемуРесурсу(Метод, АдресСервера, ЗащищенноеСоединение, , 0, Пользователь, Пароль);
	ПараметрыЗапросаКоннектора = Запрос.Параметры();

	Если ТипЗнч(ПараметрыЗапроса) = Тип("Соответствие") Тогда
		Для каждого Элемент Из ПараметрыЗапроса Цикл
			ПараметрыЗапросаКоннектора.Вставить(Элемент.Ключ, Элемент.Значение);
		КонецЦикла;
	КонецЕсли;

	ПараметрыЗапросаКоннектора.Вставить("$format", "json");

	РезультатЗапроса = Запрос.Отправить(ИмяПубликации + "/odata/standard.odata/" + СтрокаЗапроса);

	Если НЕ РезультатЗапроса.ЗапросВыполнен Тогда
		ШаблонТекстаОшибки = "При выполнении запроса коннектора 1С: %1 возникла ошибка: %2";
		Лог.Ошибка(СтрШаблон(ШаблонТекстаОшибки, Имя, РезультатЗапроса.ИнформацияОбОшибке));
	КонецЕсли;

	ДесериализованныеДанные = Сериализация.ДесериализоватьJSON(РезультатЗапроса.Ответ.ПолучитьТелоКакСтроку());
	РезультатЗапроса.Вставить("ДесериализованныеДанные", ДесериализованныеДанные);

	Возврат РезультатЗапроса;

КонецФункции