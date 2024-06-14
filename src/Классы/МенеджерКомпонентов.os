
Перем Компоненты;
Перем КомпонентКорняСтатическихФайлов;

Процедура ПриСозданииОбъекта()
	
	Компоненты = Новый Массив();

КонецПроцедуры

Процедура Инициализировать(ИмяКомпонента, ИмяКомпонентаЛатинское, КореньСтатическихФайлов = Ложь) Экспорт
	
	Отказ = Ложь;

	Лог.Отладка(СтрШаблон("Инициализация компонента %1", ИмяКомпонента));
	Компонент = Новый Компонент(ИмяКомпонента, ИмяКомпонентаЛатинское, Отказ);

	Если Отказ Тогда
		Лог.Предупреждение(СтрШаблон("Компонент не инициализирован"));
		Возврат;
	КонецЕсли;

	Если КореньСтатическихФайлов Тогда

		Если КомпонентКорняСтатическихФайлов = Неопределено Тогда
			КомпонентКорняСтатическихФайлов = Компонент;
			Лог.Информация(СтрШаблон("Компонент %1 установлен как корень статических файлов", ИмяКомпонента));
		Иначе
			Лог.Предупреждение("Компонент корня статических файлов уже указан");
		КонецЕсли;

	КонецЕсли;

	Компоненты.Добавить(Компонент);

КонецПроцедуры

Функция НайтиПоИмени(ИмяКомпонента) Экспорт

	Для каждого Компонент Из Компоненты Цикл
		Если Компонент.Имя() = ИмяКомпонента Тогда
			Возврат Компонент;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции

Функция НайтиПоКлючуОбъекта(КлючИлиТип) Экспорт

	МенеджерОбъектов = Приложение.МенеджерОбъектов();

	Если ТипЗнч(КлючИлиТип) = Тип("Строка") Тогда
		Ключ = КлючИлиТип;
	Иначе

		Ключ = МенеджерОбъектов.КлючПоТипу(ТипЗнч(КлючИлиТип));

		Если Ключ = Неопределено Тогда
			ВызватьИсключение "Не верно передан параметр для определения компонента";
		КонецЕсли;
		
	КонецЕсли;
	
	ИмяКомпонента = Лев(Ключ, СтрНайти(Ключ, ".") - 1);
	Возврат НайтиПоИмени(ИмяКомпонента);

КонецФункции

Функция Компоненты() Экспорт
	Возврат Компоненты;
КонецФункции

Функция КомпонентКорняСтатическихФайлов() Экспорт
	Возврат КомпонентКорняСтатическихФайлов;
КонецФункции
