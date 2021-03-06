﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УпаковочныйЛист = Параметры.УпаковочныйЛист;
	Если ЗначениеЗаполнено(УпаковочныйЛист) Тогда
		Заголовок = УпаковочныйЛист.Код;
	КонецЕсли;
	
	Список.Параметры.УстановитьЗначениеПараметра("УпаковочныйЛист",УпаковочныйЛист);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Попытка
	
		ВК.ИнициализироватьСканер(Ложь, Истина);	
	
	Исключение
		
	КонецПопытки;
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
		
		Штрихкод = Параметр;
		
		ОбработатьШтрихкод(СокрЛП(Штрихкод));
		
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьШтрихкод(Штрихкод)

	Структура = 			РСК_ТСД.НайтиНоменклатуруУпаковкуПоШтрихкоду(Штрихкод);
	Номенклатура = 			Структура.Номенклатура;
	УпаковкаПоШтрихкоду = 	Структура.УпаковкаПоШтрихкоду;
	
	Если НЕ ЗначениеЗаполнено(Структура.Номенклатура) Тогда
		МобильныйКлиент.ОповещениеПродолжительноеДваСигнала();
		Предупреждение("Номенклатура с таким Штрихкодом не существует !");
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(УпаковкаПоШтрихкоду) Тогда
		МобильныйКлиент.ОповещениеПродолжительноеДваСигнала();
		Предупреждение("Упаковка с таким Штрихкодом не существует !");
		Возврат;
	КонецЕсли;
	
	МинимУпаковка = РСК_ТСД.ПолучитьУпаковкуПоЕдИзмНоменклатуры(Структура.Номенклатура);
	
	ВводПоШтучно = Ложь;	//пока пусть количество вводится только по коэффициенту сканированной упаковки
	КоличествоДобавить = ПолучитьКоэфУпаковки(УпаковкаПоШтрихкоду); 

	Если КоличествоДобавить > 0 Тогда
		
		Удачно = РСК_УпаковочныеЛисты.ДобавитьНоменклатуруКоличествоВУпаковочныйЛист(УпаковочныйЛист, Номенклатура, МинимУпаковка, КоличествоДобавить);
		Если Удачно Тогда
			
			ВыделитьСтрокуСНоменклатуройЦветом(Структура.Номенклатура);
			
			ОбновитьСписок();
			
			УстановитьТекущуюСтроку(Структура.Номенклатура);
			
			МобильныйКлиент.ОповещениеКороткоеОдинСигнал();
		Иначе
			МобильныйКлиент.ОповещениеПродолжительноеДваСигнала();
		КонецЕсли;
		
	КонецЕсли;
	ЭтаФорма.ТекущийЭлемент = Элементы.Список;

КонецПроцедуры

&НаСервере
Функция ПолучитьКоэфУпаковки(Знач Упаковка_)
	
	Возврат Упаковка_.Коэффициент;

КонецФункции

&НаКлиенте
Процедура ОбновитьСписок()

	Элементы.Список.Обновить();
	
КонецПроцедуры 

&НаКлиенте
Процедура СписокОбработкаЗапросаОбновления()
	Элементы.Список.Обновить();
КонецПроцедуры


