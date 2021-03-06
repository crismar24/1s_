﻿
&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ВыбранныйДокументИнвентаризации = ВыбраннаяСтрока;
	
	ВсеПросчеты = РСК_ТСД.ПолучитьВсеНомераПросчетовПоИнвентаризации(ВыбранныйДокументИнвентаризации);
	// 3 варианта выбора
	ВыбранныйПунктМеню = ВыбратьИзМеню(ВсеПросчеты);	//красивее в ТСД смотрится и быстрее кажется
	//ВыбранныйПунктМеню = ВыбратьИзСписка(СписокСкладов);
	//ВыбранныйПунктМеню = СписокСкладов.ВыбратьЭлемент("Выберите склад для инвентаризации");
	Если ВыбранныйПунктМеню <> Неопределено Тогда
		
		
		НомерПросчета = ВыбранныйПунктМеню.Значение;
		Если ЗначениеЗаполнено(НомерПросчета) Тогда
			ПервичныйВводДанныхЗавершен = ПолучитьПризнакПервичныйВводДанныхЗавершен(ВыбранныйДокументИнвентаризации);
			
			Если НомерПросчета = 1 Тогда
				Если ПервичныйВводДанныхЗавершен Тогда 
					Предупреждение("Первичный ввод данных завершён!");
					Возврат;
				КонецЕсли;
				
				//ввод первичных данных
				Парам = Новый Структура("Инвентаризация, НомерПросчета", ВыбранныйДокументИнвентаризации, НомерПросчета);
				ОписаниеОповещенияОЗакрытии = Новый ОписаниеОповещения("ОбновитьСписокЗавершение",ЭтотОбъект,);
				ОткрытьФорму("Обработка.ТСД_РСК.Форма.РСК_СписокЯчеек",Парам,,,,,ОписаниеОповещенияОЗакрытии);
				
			Иначе
				Если НЕ ПервичныйВводДанныхЗавершен Тогда
					Предупреждение("Первичный ввод данных ещё НЕ завершён!");
					Возврат;
				КонецЕсли;
				
				//ввод данных по заданию
				Парам = Новый Структура("Инвентаризация, НомерПросчета, Исполнитель", ВыбранныйДокументИнвентаризации, НомерПросчета, РСК_ТСД.ПолучитьТекущегоПользователяНаСервере());
				ОписаниеОповещенияОЗакрытии = Новый ОписаниеОповещения("ОбновитьСписокЗавершение",ЭтотОбъект,);
				ОткрытьФорму("Обработка.ТСД_РСК.Форма.РСК_СписокЯчеекПоЗаданиюИсполнителя",Парам,,,,,ОписаниеОповещенияОЗакрытии);
				
				
			КонецЕсли; 
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьТекущегоПользователяНаСервере()
	
	Перем а;
	
	а = Пользователи.ТекущийПользователь();
	
	Возврат а;

КонецФункции

&НаСервере 
Функция ПолучитьПризнакПервичныйВводДанныхЗавершен(Знач ВыбранныйДокументИнвентаризации)
	
	Возврат ВыбранныйДокументИнвентаризации.ПервичныйВводДанныхЗавершен;

КонецФункции


&НаСервере
Функция ПолучитьСписокСкладов()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Склады.Ссылка КАК Склад
		|ИЗ
		|	Справочник.Склады КАК Склады
		|ГДЕ
		|	НЕ Склады.ЭтоГруппа
		|	И Склады.Родитель = &ОсновнойСклад
		|
		|УПОРЯДОЧИТЬ ПО
		|	Склады.Наименование";
	
	Запрос.УстановитьПараметр("ОсновнойСклад", ОсновнойСклад.Родитель);
	
	ТЗскладов = Запрос.Выполнить().Выгрузить();
	ТЗскладов.ВыгрузитьКолонку("Склад");
	
	СписокСкладов = Новый СписокЗначений;
	СписокСкладов.ЗагрузитьЗначения(ТЗскладов.ВыгрузитьКолонку("Склад"));
	Если СписокСкладов.Количество() <> 0 Тогда
		Возврат СписокСкладов;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	//

КонецФункции // ПолучитьСписокСкладов()


&НаКлиенте
Процедура ОбновитьСписокЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Элементы.Список.Обновить();
	

КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОсновнойСклад = Параметры.ОсновнойСклад;
	
	Если НЕ ЗначениеЗаполнено(ОсновнойСклад) Тогда
		ОсновнойСклад = СкладыСервер.ПолучитьСкладТекущегоПользователя();
		
	КонецЕсли;
	ГруппаСкладов = Склад_РСК.ПолучитьГруппуСкладаТекущегоПользователя();
	Список.Параметры.УстановитьЗначениеПараметра("ГруппаСкладов",ГруппаСкладов);
КонецПроцедуры


&НаКлиенте
Процедура СписокОбработкаЗапросаОбновления()
	Элементы.Список.Обновить();
КонецПроцедуры

