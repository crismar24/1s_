﻿
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Попытка
	
		ВК.ИнициализироватьСканер(Ложь, Истина);	
	
	Исключение
		
	КонецПопытки;
	
	НоменклатураПриИзменении(Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	Попытка
	
		ВК.ОтключитьСканер();
	
	Исключение
	
	КонецПопытки;
	
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если Источник = "ПодключаемоеОборудование"
		И ИмяСобытия = "Barcode"
		И ВводДоступен()	// нужен ли ВводДоступен() в окне где нет определённого поля, куда сканировать ?
		Тогда
		//проверка даты на сервере и на ТСД
		//Сообщить("ТекущаяДата() на клиенте:" + ТекущаяДата());
		//Сообщить("ТекущаяДата() на сервере:" + ПолучитьТекущаяДатанаСервере());
		//Сообщить("ТекущаяДатаСеанса() на сервере:" + ПолучитьТекущаяДатаСеансаНаСервере());
		
		Штрихкод = Параметр;
		// ищем номенклатуру
		НайтиШтрихкодНоменклатуры(Штрихкод);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТекущаяДатаСеансаНаСервере()
	Возврат ТекущаяДатаСеанса();
КонецФункции

&НаСервере
Функция ПолучитьТекущаяДатанаСервере()
	Возврат ТекущаяДата();
КонецФункции

&НаКлиенте
Процедура НайтиШтрихкодНоменклатуры(Штрихкод)

	Структура = 	НайтиНоменклатуруУпаковкуПоШтрихкоду(Штрихкод);
	Номенклатура = 	Структура.Номенклатура;
	Упаковка = 		Структура.УпаковкаПоШтрихкоду;
	
	Если НЕ ЗначениеЗаполнено(Номенклатура) Тогда
		МобильныйКлиент.ОповещениеПродолжительноеДваСигнала();
		Предупреждение("Номенклатура с таким Штрихкодом не существует !");
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Упаковка) Тогда
		МобильныйКлиент.ОповещениеПродолжительноеДваСигнала();
		Предупреждение("Упаковка с таким Штрихкодом не существует !");
		Возврат;
	КонецЕсли;

	ШК = Штрихкод;
	
	ЗаполнитьОстатки();
	
	

КонецПроцедуры // НайтиШтрихкодНоменклатуры()

&НаСервереБезКонтекста
Функция НайтиНоменклатуруУпаковкуПоШтрихкоду(Штрихкод)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ШтрихкодыНоменклатуры.Номенклатура,
		|	ШтрихкодыНоменклатуры.Упаковка КАК УпаковкаПоШтрихкоду
		|ИЗ
		|	РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|ГДЕ
		|	ШтрихкодыНоменклатуры.Штрихкод = &Штрихкод";
	
	Запрос.УстановитьПараметр("Штрихкод", Штрихкод);
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Номенклатура = Справочники.Номенклатура.ПустаяСсылка();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Возврат Новый Структура("Номенклатура, УпаковкаПоШтрихкоду", ВыборкаДетальныеЗаписи.Номенклатура, ВыборкаДетальныеЗаписи.УпаковкаПоШтрихкоду);
	КонецЦикла;
	
	Возврат Новый Структура("Номенклатура, УпаковкаПоШтрихкоду", , );
	
КонецФункции // НайтиНоменклатуруПоШтрихкоду()

&НаКлиенте
Процедура НоменклатураПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Номенклатура) Тогда
		//если не открыли форму из главного меню
	Если НЕ ЗначениеЗаполнено(Упаковка) Тогда
		//заполнить Упаковку - Шт
		ЗаполнитьУпаковкуШТ();
	КонецЕсли;
		ЗаполнитьОстатки();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьУпаковкуШТ()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УпаковкиНоменклатуры.Ссылка КАК УпаковкаШт
		|ИЗ
		|	Справочник.УпаковкиНоменклатуры КАК УпаковкиНоменклатуры
		|ГДЕ
		|	УпаковкиНоменклатуры.Владелец = &Номенклатура
		|	И УпаковкиНоменклатуры.ЕдиницаИзмерения = &ЕдиницаИзмеренияШТ
		|	И НЕ УпаковкиНоменклатуры.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("ЕдиницаИзмеренияШТ", Справочники.ЕдиницыИзмерения.НайтиПоКоду("796"));	//Шт
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Упаковка = ВыборкаДетальныеЗаписи.УпаковкаШт;
	КонецЦикла;
	
	

КонецПроцедуры // ЗаполнитьУпаковкуШТ()

&НаСервере
Процедура ЗаполнитьОстатки()

	ПолучитьОстаткиНаСервере();
	
	//ПолучитьДокументыВОтборахПоОстаткам(); - по кнопке подробнее по резерву
	

КонецПроцедуры // ЗаполнитьОстатки()

&НаСервере
Процедура ПолучитьОстаткиНаСервере()
//марченко 31.07.2019	
Запрос = Новый Запрос;
Запрос.Текст = "ВЫБРАТЬ
               |	ТоварыВЯчейкахОстатки.ВНаличииОстаток КАК Остаток,
               |	ТоварыВЯчейкахОстатки.Номенклатура КАК Номенклатура,
               |	ТоварыВЯчейкахОстатки.ВНаличииОстаток - ТоварыВЯчейкахОстатки.КОтборуОстаток КАК СвободныйОстаток,
               |	ТоварыВЯчейкахОстатки.Ячейка КАК Ячейка,
               |	ТоварыВЯчейкахОстатки.Ячейка.Владелец КАК ЯчейкаВладелец
               |ПОМЕСТИТЬ ОстатокНоменклатуры
               |ИЗ
               |	РегистрНакопления.ТоварыВЯчейках.Остатки КАК ТоварыВЯчейкахОстатки
               |ГДЕ
               |	ТоварыВЯчейкахОстатки.Номенклатура = &Номенклатура
               |	И ТоварыВЯчейкахОстатки.Ячейка В(&МассивНулевыхЯчеек)
               |
               |ИНДЕКСИРОВАТЬ ПО
               |	ЯчейкаВладелец,
               |	Номенклатура
               |;
               |
               |////////////////////////////////////////////////////////////////////////////////
               |ВЫБРАТЬ
               |	СвободныеОстаткиОстатки.Номенклатура КАК Номенклатура,
               |	СвободныеОстаткиОстатки.Склад КАК Склад,
               |	СвободныеОстаткиОстатки.ВНаличииОстаток
               |ПОМЕСТИТЬ СвобОстатки
               |ИЗ
               |	РегистрНакопления.СвободныеОстатки.Остатки(
               |			,
               |			Склад В (&МассивСкладов)
               |				И Номенклатура = &Номенклатура) КАК СвободныеОстаткиОстатки
               |
               |ИНДЕКСИРОВАТЬ ПО
               |	Номенклатура,
               |	Склад
               |;
               |
               |////////////////////////////////////////////////////////////////////////////////
               |ВЫБРАТЬ
               |	ОстатокНоменклатуры.ЯчейкаВладелец КАК Склад,
               |	ОстатокНоменклатуры.Остаток КАК Остаток,
               |	ОстатокНоменклатуры.СвободныйОстаток КАК СвободныйОстаток,
               |	ЕСТЬNULL(СвобОстатки.ВНаличииОстаток, 0) КАК ВНаличииОстаток,
               |	СУММА(ЕСТЬNULL(ТоварыКОтборуОстатки.КОтборуОстаток, 0)) КАК КОтборуПоЗаданию,
               |	СУММА(ЕСТЬNULL(ТоварыКОтборуОстатки.ОтбираетсяОстаток, 0)) КАК ОтбираетсяНаТСД,
               |	СУММА(ЕСТЬNULL(ТоварыКОтборуОстатки.ОтобраноОстаток, 0)) КАК ОтобраноНаТСД
               |ИЗ
               |	ОстатокНоменклатуры КАК ОстатокНоменклатуры
               |		ЛЕВОЕ СОЕДИНЕНИЕ СвобОстатки КАК СвобОстатки
               |		ПО ОстатокНоменклатуры.Номенклатура = СвобОстатки.Номенклатура
               |			И ОстатокНоменклатуры.ЯчейкаВладелец = СвобОстатки.Склад
               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыКОтбору.Остатки(, Номенклатура = &Номенклатура) КАК ТоварыКОтборуОстатки
               |		ПО ОстатокНоменклатуры.Номенклатура = ТоварыКОтборуОстатки.Номенклатура
               |			И ОстатокНоменклатуры.ЯчейкаВладелец = ТоварыКОтборуОстатки.Распоряжение.Склад
               |
               |СГРУППИРОВАТЬ ПО
               |	ОстатокНоменклатуры.ЯчейкаВладелец,
               |	ОстатокНоменклатуры.Остаток,
               |	ОстатокНоменклатуры.СвободныйОстаток,
               |	ЕСТЬNULL(СвобОстатки.ВНаличииОстаток, 0)
               |
               |УПОРЯДОЧИТЬ ПО
               |	Склад";
	НачалоПериода 		= Дата (2018, 1, 1);
	МассивСкладов		= Новый Массив;
	МассивНулевыхЯчеек 	= Новый Массив;
	
	МассивСкладов.Добавить(ОсновнойСклад);	
	МассивНулевыхЯчеек.Добавить(Справочники.СкладскиеЯчейки.НайтиПоНаименованию("00000",,,ОсновнойСклад));
	
	//СкладХранСк = Справочники.Склады.НайтиПоНаименованию("Склад хран. СК");	
	//Калуга-участок сборки
	//СВХ сырья СК
	//Склад брака СК
	//Склад врем.хран. СК
	//Склад СЦ КВТ
	//Склад хран. СК
	//Склад хран.сырья СК	
	
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("МассивНулевыхЯчеек", МассивНулевыхЯчеек);
	Запрос.УстановитьПараметр("МассивСкладов", МассивСкладов);
	Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);
	Остатки.Очистить();
	
	ЗначениеВРеквизитФормы(Запрос.Выполнить().Выгрузить(),"Остатки");
	
		
		
КонецПроцедуры

&НаСервере
Процедура ПолучитьДокументыВОтборахПоОстаткам()
	
	//оставить МассивНулевыхЯчеек только нулевые ячейки для СкладПользователя
	НачалоПериода 		= Дата (2018, 1, 1);
	МассивНулевыхЯчеек = Новый Массив;
	МассивНулевыхЯчеек.Добавить(Справочники.СкладскиеЯчейки.НайтиПоНаименованию("00000",,,ОсновнойСклад)); 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТоварыВЯчейкахОстатки.ВНаличииОстаток КАК Остаток,
		|	ТоварыВЯчейкахОстатки.Номенклатура КАК Номенклатура,
		|	ТоварыВЯчейкахОстатки.ВНаличииОстаток - ТоварыВЯчейкахОстатки.КОтборуОстаток КАК СвободныйОстаток,
		|	ТоварыВЯчейкахОстатки.Ячейка КАК Ячейка,
		|	ТоварыВЯчейкахОстатки.Ячейка.Владелец КАК ЯчейкаВладелец
		|ПОМЕСТИТЬ ОстатокНоменклатуры
		|ИЗ
		|	РегистрНакопления.ТоварыВЯчейках.Остатки КАК ТоварыВЯчейкахОстатки
		|ГДЕ
		|	ТоварыВЯчейкахОстатки.Номенклатура = &Номенклатура
		|	И ТоварыВЯчейкахОстатки.Ячейка В(&МассивНулевыхЯчеек)
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	ЯчейкаВладелец,
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СвободныеОстаткиОстатки.Номенклатура КАК Номенклатура,
		|	СвободныеОстаткиОстатки.Склад КАК Склад,
		|	СвободныеОстаткиОстатки.ВНаличииОстаток
		|ПОМЕСТИТЬ СвобОстатки
		|ИЗ
		|	РегистрНакопления.СвободныеОстатки.Остатки(
		|			,
		|			Склад = &СкладПользователя
		|				И Номенклатура = &Номенклатура) КАК СвободныеОстаткиОстатки
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура,
		|	Склад
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТоварыКОтборуОстатки.Распоряжение.Распоряжение КАК СкладскоеЗадание,
		|	ТоварыКОтборуОстатки.Распоряжение.Распоряжение.Подготовлено КАК Подготовлено,
		|	ТоварыКОтборуОстатки.Распоряжение.Распоряжение.Партнер КАК Клиент,
		|	ОстатокНоменклатуры.ЯчейкаВладелец КАК Склад,
		|	ОстатокНоменклатуры.Остаток КАК Остаток,
		|	ОстатокНоменклатуры.СвободныйОстаток КАК СвободныйОстаток,
		|	ЕСТЬNULL(СвобОстатки.ВНаличииОстаток, 0) КАК ВНаличииОстаток,
		|	ТоварыКОтборуОстатки.КОтборуОстаток КАК КОтборуПоЗаданию,
		|	ТоварыКОтборуОстатки.ОтбираетсяОстаток КАК ОтбираетсяНаТСД,
		|	ТоварыКОтборуОстатки.ОтобраноОстаток КАК ОтобраноНаТСД
		|ИЗ
		|	ОстатокНоменклатуры КАК ОстатокНоменклатуры
		|		ЛЕВОЕ СОЕДИНЕНИЕ СвобОстатки КАК СвобОстатки
		|		ПО ОстатокНоменклатуры.Номенклатура = СвобОстатки.Номенклатура
		|			И ОстатокНоменклатуры.ЯчейкаВладелец = СвобОстатки.Склад
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыКОтбору.Остатки(, Номенклатура = &Номенклатура) КАК ТоварыКОтборуОстатки
		|		ПО ОстатокНоменклатуры.Номенклатура = ТоварыКОтборуОстатки.Номенклатура
		|			И ОстатокНоменклатуры.ЯчейкаВладелец = ТоварыКОтборуОстатки.Распоряжение.Склад
		|
		|УПОРЯДОЧИТЬ ПО
		|	Склад";
	
	Запрос.УстановитьПараметр("МассивНулевыхЯчеек", МассивНулевыхЯчеек);
	Запрос.УстановитьПараметр("СкладПользователя", ОсновнойСклад);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Отборы.Очистить();
	
	ЗначениеВРеквизитФормы(Запрос.Выполнить().Выгрузить(),"Отборы");
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОсновнойСклад = СкладыСервер.ПолучитьСкладПользователя(Пользователи.ТекущийПользователь());
	
	//Если Параметры.Свойство("Номенклатура") Тогда
		Попытка
		Номенклатура 	= Параметры.Номенклатура;
		Упаковка		= Параметры.Упаковка;
		ШК				= Параметры.ШК;
		Исключение
		КонецПопытки;
	//КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КОтборуПоЗаданиюОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Сообщить("Открыли Отборы по заданиям");
	
КонецПроцедуры

&НаКлиенте
Процедура КОтборуПоЗаданиюНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	
КонецПроцедуры

&НаКлиенте
Процедура КОтборуПоЗаданиямПодробнее(Команда)
	//ПолучитьДокументыВОтборахПоОстаткам(); //- по кнопке подробнее по резерву
	СтандартнаяОбработка = Ложь;
	
	Парам = Новый Структура("Номенклатура, ОсновнойСклад", Номенклатура, ОсновнойСклад);
	ОткрытьФорму("Обработка.ТСД_РСК.Форма.КОтборуПоЗаданиямПодробнее",Парам);
КонецПроцедуры

&НаКлиенте
Процедура ЭмитацияСканера(Команда)
	// Вставить содержимое обработчика.
КонецПроцедуры



