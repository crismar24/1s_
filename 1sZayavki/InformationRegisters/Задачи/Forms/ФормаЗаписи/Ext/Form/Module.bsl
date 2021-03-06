﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("ДеньРаботы") Тогда
		Запись.ДеньРаботы = Параметры.ДеньРаботы;
		Если НЕ ЗначениеЗаполнено(Запись.Исполнитель) Тогда
			Запись.Исполнитель = ПараметрыСеанса.ТекущийПользователь;
		КонецЕсли;
		Запись.Начало = ТекущаяДата();
	КонецЕсли;
	
	
КонецПроцедуры

&НаКлиенте
Процедура МинутПриИзменении(Элемент)
	
	Если Запись.Минут > 0 Тогда
		Запись.Часов = Запись.Минут / 60;
	Иначе
		Запись.Часов = 0;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Оповестить("ОбновитьЗадачи");
КонецПроцедуры

&НаКлиенте
Процедура ОкончаниеПриИзменении(Элемент)
	Запись.Минут = Цел((Запись.Окончание - Запись.Начало)/60);
КонецПроцедуры

&НаКлиенте
Процедура НачалоПриИзменении(Элемент)
	Запись.Минут = Цел((Запись.Окончание - Запись.Начало)/60);
КонецПроцедуры
