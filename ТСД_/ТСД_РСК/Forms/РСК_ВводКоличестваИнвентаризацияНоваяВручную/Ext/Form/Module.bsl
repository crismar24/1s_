﻿
&НаКлиенте
Процедура НоменклатураПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Номенклатура) Тогда
		
		//если не открыли форму из главного меню
		Если НЕ ЗначениеЗаполнено(МинимУпаковка) Тогда
			//заполнить Упаковку - Шт
			МинимУпаковка = РСК_ТСД.ПолучитьУпаковкуПоЕдИзмНоменклатуры(Номенклатура);
		КонецЕсли;
		
		Элементы.Количество.РедактированиеТекста = Истина;
		
		Количество = 0;
		Элементы.Количество.ОбновитьТекстРедактирования();
		Элементы.Количество.Видимость = Ложь;
		Элементы.Количество.Видимость = Истина;
		ЭтаФорма.ТекущийЭлемент = Элементы.Количество;
		#Если МобильныйКлиент Тогда    
			НачатьРедактированиеЭлемента();
		#КонецЕсли
		
	КонецЕсли;
	

КонецПроцедуры

&НаСервере
Функция ПолучитьУпаковкуПоЕдИзмНоменклатуры(Ном)

	// Подставляется ед изм. ШТ так как сами ввели в ручную номенклатуру 
	//в этом случае нет информации о упаковке(ед. изм.)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	УпаковкиНоменклатуры.Ссылка КАК УпаковкаШт
		|ИЗ
		|	Справочник.УпаковкиНоменклатуры КАК УпаковкиНоменклатуры
		|ГДЕ
		|	УпаковкиНоменклатуры.Владелец = &Номенклатура
		|	И УпаковкиНоменклатуры.ЕдиницаИзмерения = &ЕдиницаИзмерения
		|	И НЕ УпаковкиНоменклатуры.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("ЕдиницаИзмерения", Ном.ЕдиницаИзмерения);	//Шт
	Запрос.УстановитьПараметр("Номенклатура", Ном);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Возврат ВыборкаДетальныеЗаписи.УпаковкаШт;
	КонецЦикла;
	
	

КонецФункции // ЗаполнитьУпаковкуШТ()

&НаКлиенте
Процедура КоличествоПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Номенклатура) Тогда
		
		Попытка
			коэф = ПолучитьКоэффициентУпаковкиНаСервере(МинимУпаковка);
			Если коэф = 0 Тогда
				Предупреждение("Коэффициент упаковки 0 ");
				Возврат;
			КонецЕсли;
			
			ЧислоКоличество = число(СокрЛП(Количество));
			Если ЗначениеЗаполнено(СокрЛП(Количество)) И ТипЗнч(ЧислоКоличество) = тип("Число") тогда
				//ЭтаФорма.Закрыть( Число(СокрЛП(Количество)) );	
				//или ???
				КоличествоДобавить = Число(СокрЛП(Количество)) * ПолучитьКоэффициентУпаковкиНаСервере(МинимУпаковка);// да , наверно так, так правильнее
				//всё равно при штучке дожна попадать миним упаковка - либо 1шт либо самая маленькая упаковка ,например как в мелочёвке - пакетик маленький - 10 шт.
				СтруктураОтвет = Новый Структура("Номенклатура, МинимУпаковка, КоличествоДобавить", Номенклатура, МинимУпаковка,КоличествоДобавить ); 
				ЭтаФорма.Закрыть( СтруктураОтвет );	
			Иначе
				Предупреждение("Введите количество");
			КонецЕсли;
			
		Исключение
			Предупреждение(ОписаниеОшибки());
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьКоэффициентУпаковкиНаСервере(Упаковка)
	
	Возврат Упаковка.Коэффициент;

КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.Номенклатура.РедактированиеТекста = Истина;
	
	Номенклатура = ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка");
	Элементы.Номенклатура.ОбновитьТекстРедактирования();
	Элементы.Номенклатура.Видимость = Ложь;
	Элементы.Номенклатура.Видимость = Истина;
	ЭтаФорма.ТекущийЭлемент = Элементы.Номенклатура;
	#Если МобильныйКлиент Тогда    
		НачатьРедактированиеЭлемента();
	#КонецЕсли
		
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Инвентаризация = Параметры.Инвентаризация;	
	НомерПросчета = Параметры.НомерПросчета;
	Ячейка = Параметры.Ячейка;
	
	
КонецПроцедуры
