﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	//ОсновнойСклад = СкладыСервер.ПолучитьСкладПользователя(Пользователи.ТекущийПользователь());
	
	Перем МассивСвойств, тзОсновнойСклад;
	
	МассивСвойств = Новый Массив;
	МассивСвойств.Добавить(ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Основной склад"));
	тзОсновнойСклад = УправлениеСвойствами.ПолучитьЗначенияСвойств(Пользователи.ТекущийПользователь(),Ложь,Истина,МассивСвойств);
	ОсновнойСклад = Справочники.Склады.ПустаяСсылка();
	Попытка
		ОсновнойСклад = тзОсновнойСклад[0].Значение;	
	Исключение
		Сообщить("Не заполнен основной склад");
	КонецПопытки;
	
	
	ВводПоШтучно = Параметры.ВводПоШтучно;
	//Список.Параметры.УстановитьЗначениеПараметра("ОсновнойСклад",ОсновнойСклад);
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	//	Создавать Приходный ордер, Размещение ? - прямо сразу при выборе поступления ?
	// - если Приходный ордер, Размещение - в табл. части Пусто - удалять документ ?
	// общий модуль СозданиеДокументов - тут создаются приходники, размещения программно - посмотреть
	//
	//
	//	Сейчас отображается в списке поступлений ТОЛЬКО ГП (номер состоит только из цифр)
	// кладовщик должен чётко видеть понимать по каким поступлениям создавать подчиненные документы
	//если создавать документы, то так:
	// возможно в списке поступлений отображать поступления у которых Размещения со статусом "В Работе"
	//
	// - При открытии поступления из списка - находить / создавать (со статусом "В работе") Размещение -
	
	//Проверить существует ли Прих. ордер, Размещение - Создать
	
	ПриходныйОрдер 	= ПолучитьПриходныйОрдер(ВыбраннаяСтрока);
	Размещение		= ПолучитьРазмещениеТоваров(ПриходныйОрдер);
	
	Если (НЕ ЗначениеЗаполнено(Размещение) 
		ИЛИ НЕ ЗначениеЗаполнено(ПриходныйОрдер)) Тогда
		Предупреждение("Подчиненные документы не заполнены !");
		Возврат;
	КонецЕсли;

	Парам = Новый Структура("ОсновнойСклад,Поступление,ПриходныйОрдер,Размещение,ВводПоШтучно", ОсновнойСклад, ВыбраннаяСтрока, ПриходныйОрдер, Размещение, ВводПоШтучно);
	
	//Откзался от Дин. списка в пользу скорости работы
	
	//для теста
	//Ответ = Вопрос("Войти в представление Таблицы значений",РежимДиалогаВопрос.ДаНет);
	//Если Ответ = КодВозвратаДиалога.Нет Тогда
	//	ОткрытьФорму("Обработка.ТСД_РСК.Форма.Размещение",Парам);
	//Иначе
		ОписаниеОповещенияОЗакрытии = Новый ОписаниеОповещения("ОбновитьСписокЗавершение",ЭтотОбъект,);
		ОткрытьФорму("Обработка.ТСД_РСК.Форма.РазмещениеТЗ",Парам,,,,,ОписаниеОповещенияОЗакрытии);
	//КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт

	Элементы.Список.Обновить();

КонецПроцедуры


&НаСервере
Функция ПолучитьПриходныйОрдер(Поступление)
		
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриходныйОрдерНаТовары.Ссылка
		|ИЗ
		|	Документ.ПриходныйОрдерНаТовары КАК ПриходныйОрдерНаТовары
		|ГДЕ
		|	ПриходныйОрдерНаТовары.Распоряжение = &Распоряжение
		|	И ПриходныйОрдерНаТовары.Проведен
		|	И ПриходныйОрдерНаТовары.Склад = &Склад";
	
	Запрос.УстановитьПараметр("Распоряжение", Поступление);
	Запрос.УстановитьПараметр("Склад", ОсновнойСклад);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Если ВыборкаДетальныеЗаписи.Количество() = 1 Тогда
		ВыборкаДетальныеЗаписи.Следующий();
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	ИначеЕсли ВыборкаДетальныеЗаписи.Количество() > 1 Тогда
		Возврат Документы.ПриходныйОрдерНаТовары.ПустаяСсылка();
	ИначеЕсли ВыборкаДетальныеЗаписи.Количество() = 0 Тогда
	
		ПриходныйОрдер = Документы.ПриходныйОрдерНаТовары.СоздатьДокумент();
		//не проставляются упаковки, поэтому через выгрузить-загрузить
		ПриходныйОрдер.Заполнить(Поступление);
		ПриходныйОрдер.Склад = ОсновнойСклад;
		ПриходныйОрдер.СкладскаяОперация = Перечисления.СкладскиеОперации.ПриемкаОтПоставщика;
		ПриходныйОрдер.НомерПоступления = Поступление.Номер;
		ПриходныйОрдер.ЗонаПриемки = Справочники.СкладскиеЯчейки.НайтиПоНаименованию("Приемка",,,ОсновнойСклад);;
		ПриходныйОрдер.Дата = Поступление.Дата;
		ПриходныйОрдер.Статус = Перечисления.СтатусыПриходныхОрдеров.Принят;	//наверно должен быть статус ВРаботе - для последеющей работы с расходником посредством Отбора
		ПриходныйОрдер.Ответственный = Пользователи.ТекущийПользователь();
		ПриходныйОрдер.Товары.Загрузить(Поступление.Товары.Выгрузить());//каждый раз НЕ перезаписываем ТЧ Прих.ордера из ТЧ Поступления
		ПриходныйОрдер.Записать(РежимЗаписиДокумента.Проведение);
		
	КонецЕсли;
	
	Возврат ПриходныйОрдер.Ссылка;
	

КонецФункции

&НаСервере
Функция НайтиРазмещениеТоваров(знач ПриходныйОрдер)
	
	
КонецФункции // ПолучитьПриходныйОрдер()

&НаСервере
Функция НайтиПриходныйОрдер(знач Поступление)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриходныйОрдерНаТовары.Ссылка
		|ИЗ
		|	Документ.ПриходныйОрдерНаТовары КАК ПриходныйОрдерНаТовары
		|ГДЕ
		|	ПриходныйОрдерНаТовары.Распоряжение = &Распоряжение
		|	И ПриходныйОрдерНаТовары.Проведен
		|	И ПриходныйОрдерНаТовары.Склад = &Склад";
	
	Запрос.УстановитьПараметр("Распоряжение", Поступление);
	Запрос.УстановитьПараметр("Склад", ОсновнойСклад);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Если ВыборкаДетальныеЗаписи.Количество() = 1 Тогда
		ВыборкаДетальныеЗаписи.Следующий();
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	Иначе
		Возврат Документы.ПриходныйОрдерНаТовары.ПустаяСсылка();
	КонецЕсли;
	
КонецФункции // ПолучитьПриходныйОрдер()

&НаСервере
Функция ПолучитьРазмещениеТоваров(ПриходныйОрдер)
	
	//
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОтборРазмещениеТоваров.Ссылка
		|ИЗ
		|	Документ.ОтборРазмещениеТоваров КАК ОтборРазмещениеТоваров
		|ГДЕ
		|	ОтборРазмещениеТоваров.Распоряжение = &Распоряжение
		|	И ОтборРазмещениеТоваров.Склад = &Склад
		|	И ОтборРазмещениеТоваров.Проведен
		|	И ОтборРазмещениеТоваров.ВидОперации = &ВидОперации";
	
	Запрос.УстановитьПараметр("Распоряжение", ПриходныйОрдер);
	Запрос.УстановитьПараметр("Склад", ОсновнойСклад);
	Запрос.УстановитьПараметр("ВидОперации", Перечисления.ВидыОперацийОтбораРазмещенияТоваров.Размещение);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Если ВыборкаДетальныеЗаписи.Количество() = 1 Тогда
		ВыборкаДетальныеЗаписи.Следующий();
		Размещение = ВыборкаДетальныеЗаписи.Ссылка;
	
	ИначеЕсли ВыборкаДетальныеЗаписи.Количество() > 1 Тогда
		Размещение = Документы.ПриходныйОрдерНаТовары.ПустаяСсылка();
	
	ИначеЕсли ВыборкаДетальныеЗаписи.Количество() = 0 Тогда
		
		Размещение = Документы.ОтборРазмещениеТоваров.СоздатьДокумент();
		
		Размещение.ЗонаПриемки = Справочники.СкладскиеЯчейки.НайтиПоНаименованию("Приемка",,,ПриходныйОрдер.Склад);
		Размещение.Склад = ПриходныйОрдер.Склад;
		Размещение.Ответственный = Пользователи.ТекущийПользователь();
		Размещение.ВидОперации = Перечисления.ВидыОперацийОтбораРазмещенияТоваров.Размещение;
		Размещение.Дата = ПриходныйОрдер.Дата;
		Размещение.Распоряжение = ПриходныйОрдер;
		Размещение.НомерЗадания = ПриходныйОрдер.НомерПоступления;
		//Размещение.Заполнить(ПриходныйОрдер);	
		// не надо заполнять ТЧ - она будет заполняться кладовщиком каждый раз при сканировании 
		// полностью вся СТРОКА ТЧ документа Поступление, номенклатура которой сканировалась,
		// будет передаваться в ТЧ Размещения и заполняться все колонки в соответственно:
		////Стр.Номенклатура = Элем.Номенклатура;
		//
		// Выводить опционально(ВводПоШтучно) Вопрос о вводе количества по введённой номенклатуре
		////Стр.Количество = Элем.Количество;
		////Стр.КоличествоУпаковок = Элем.Количество;
		////Стр.Упаковка = Элем.Упаковка;
		//
		////Стр.Ячейка	- пока что "00000"
		// в будущем выводить Окно-Запрос о сканировании ШТРИХКОДА ЯЧЕЙКИ
		//
		//
		Размещение.Записать(РежимЗаписиДокумента.Запись);
		//Размещение.Статус = Перечисления.СтатусыОтборовРазмещенийТоваров.ВыполненоБезОшибок;	// такой статус в этом случае ?
		Размещение.Статус = Перечисления.СтатусыОтборовРазмещенийТоваров.ВРаботе;	//чтобы знать что ведётся работа по терминалу
		// При завершении Размещения - Поменять СТАТУС на Выполнено (с ошибка, без ошибок).
		// Также в этот момент можно записать время работы по документу. 
		// Только вопрос: если записывать просто период времени,
		// то что делать, если предположим решили "допринять", кладовщик еще будет работать по документу ?
		// в ТЧ ВыполнениеРабот буду записывать нового работника
		// если тот же Работник, буду добавлять к уже записанному времени работы
		// 
		// Вычислять время работы Работника буду по
		// -ДатаПервогоСканирования
		// -ДатаПоследнегоСканирования
		// При "завершении работы складовщиком над документом" - смены статутса на Выполнено -
		// - будут обнуляться резвизиты -ДатаПервогоСканирования -ДатаПоследнегоСканирования
		//
		
		Размещение.Записать(РежимЗаписиДокумента.Проведение);
		
	КонецЕсли;
	
	
	
	Возврат Размещение.Ссылка;

КонецФункции // СоздатьРазмещениеТоваров()



&НаКлиенте
Процедура УстановитьФильтрСписку()
	
	
	//Если Статус = "В работе" Тогда
	//	СписокСтатусов = Новый СписокЗначений;
	//	СписокСтатусов.Добавить(ПредопределенноеЗначение("Перечисление.СтатусыПоступленийТоваров.ЗагруженИзParadox"));
	//	СписокСтатусов.Добавить(ПредопределенноеЗначение("Перечисление.СтатусыПоступленийТоваров.ВыгруженНаТСД"));
	//	ОтборыСписковКлиентСервер.УдалитьЭлементОтбораСписка(Список,"Статус");
	//	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Список,"Статус",СписокСтатусов,ВидСравненияКомпоновкиДанных.ВСписке);
	//	
	//ИначеЕсли Статус = "В работе" Тогда
	//	ОтборыСписковКлиентСервер.УдалитьЭлементОтбораСписка(Список,"Статус");
	//	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Список,"Статус",ПредопределенноеЗначение("Перечисление.СтатусыПоступленийТоваров.ВыгруженНаТСД"),ВидСравненияКомпоновкиДанных.Равно);
	//
	//Иначе
		Если Статус = "Выгружен на ТСД" Тогда
		ОтборыСписковКлиентСервер.УдалитьЭлементОтбораСписка(Список,"Статус");
		ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Список,"Статус",ПредопределенноеЗначение("Перечисление.СтатусыПоступленийТоваров.ВыгруженНаТСД"),ВидСравненияКомпоновкиДанных.Равно);
		
		
	//ИначеЕсли Статус = "Выполнено без ошибок" Тогда
	//	ОтборыСписковКлиентСервер.УдалитьЭлементОтбораСписка(Список,"Статус");
	//	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Список,"Статус",ПредопределенноеЗначение("Перечисление.СтатусыПоступленийТоваров.ВыполненоБезОшибок"),ВидСравненияКомпоновкиДанных.Равно);
	//	
	//ИначеЕсли Статус = "Выполнено с ошибками" Тогда
	//	ОтборыСписковКлиентСервер.УдалитьЭлементОтбораСписка(Список,"Статус");
	//	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Список,"Статус",ПредопределенноеЗначение("Перечисление.СтатусыПоступленийТоваров.ВыполненоСОшибками"),ВидСравненияКомпоновкиДанных.Равно);
	//	
	//ИначеЕсли Статус = "Создан вручную" Тогда
	//	ОтборыСписковКлиентСервер.УдалитьЭлементОтбораСписка(Список,"Статус");
	//	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Список,"Статус",ПредопределенноеЗначение("Перечисление.СтатусыПоступленийТоваров.СозданВручную"),ВидСравненияКомпоновкиДанных.Равно);
	
	КонецЕсли;
	

КонецПроцедуры // УстановитьФильтрСписку()

&НаКлиенте
Процедура СтатусПриИзменении(Элемент)
	УстановитьФильтрСписку();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВК.ИнициализироватьСканер(Ложь, Истина);
	Статус = "Выгружен на ТСД";
	УстановитьФильтрСписку();
	
	ОтборыСписковКлиентСервер.УстановитьЭлементОтбораСписка(Список,"Склад",ОсновнойСклад,ВидСравненияКомпоновкиДанных.Равно);
	
КонецПроцедуры

&НаКлиенте
Процедура ВводПоШтучноИзменить(Команда)
	Если ВводПоШтучно Тогда
		Ответ = Вопрос("Выключить ВВОД ПО ШТУЧНО ?",РежимДиалогаВопрос.ДаНет,,КодВозвратаДиалога.Нет);
		Если Ответ = КодВозвратаДиалога.Да Тогда
			ВводПоШтучно = Ложь;
		КонецЕсли;
	Иначе
		
		Ответ = Вопрос("Включить ВВОД ПО ШТУЧНО ?",РежимДиалогаВопрос.ДаНет,,КодВозвратаДиалога.Нет);
		Если Ответ = КодВозвратаДиалога.Да Тогда
			ВводПоШтучно = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	//тест
	//Сообщить(Строка("ИмяСобытия: " +ИмяСобытия));
	
	
	Если Источник = "ПодключаемоеОборудование"
		И ИмяСобытия = "Barcode"
		И ВводДоступен()	// нужен ли ВводДоступен() в окне где нет определённого поля, куда сканировать ?
		Тогда
		
		Штрихкод = Параметр;
		//Сообщить(Строка("Привет из списка поступлений: "+Параметр));
		//Обработка штрихкода документа и послед. открытие формы для ТСД
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	ВК.ОтключитьСканер();
	
КонецПроцедуры

&НаКлиенте
Процедура ОтключитьСканер()
	
	#Если МобильноеПриложениеКлиент ИЛИ МобильныйКлиент Тогда
		
		Попытка
			глВКRSDriver.Отключить("Barcode");
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
		
	#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура ИнициализироватьСканер()
	
	#Если МобильноеПриложениеКлиент ИЛИ МобильныйКлиент Тогда
		Попытка
			глВКRSDriver.УстановитьПараметр("Barcode_BEEP",Истина);
			глВКRSDriver.УстановитьПараметр("Barcode_BZZ",Истина);
			глВКRSDriver.Подключить("Barcode");	
		Исключение
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
	#КонецЕсли
	
КонецПроцедуры

&НаКлиенте
Процедура СписокОбработкаЗапросаОбновления()
	Элементы.Список.Обновить();
КонецПроцедуры
