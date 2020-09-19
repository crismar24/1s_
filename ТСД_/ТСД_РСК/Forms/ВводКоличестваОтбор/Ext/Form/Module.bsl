﻿
&НаКлиенте
Процедура КоличествоПриИзменении(Элемент)
	
	Попытка
		
		ЧислоКоличество = число(СокрЛП(Количество));
		Если ЗначениеЗаполнено(СокрЛП(Количество)) И ТипЗнч(ЧислоКоличество) = тип("Число") тогда
			
			ЭтаФорма.Закрыть( Число(СокрЛП(Количество)) * ПолучитьКоэффициентУпаковки() );
			
		Иначе
			Предупреждение("Введите количество");
		КонецЕсли;
	
	Исключение
		ВызватьИсключение;
	КонецПопытки;
	
	
	
КонецПроцедуры

&НаСервере
Функция ПолучитьКоэффициентУпаковки()
	
	Возврат Упаковка.коэффициент;

КонецФункции
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Элементы.Количество.РедактированиеТекста = Истина;
	
	Количество = 0;
	Элементы.Количество.ОбновитьТекстРедактирования();
	Элементы.Количество.Видимость = Ложь;
	Элементы.Количество.Видимость = Истина;
	ЭтаФорма.ТекущийЭлемент = Элементы.Количество;
	#Если МобильныйКлиент Тогда    
		НачатьРедактированиеЭлемента();
	#КонецЕсли
		
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьЗначенияСвойств(ТЗ.Добавить(),Параметры.СтрокаТЧ);
	Упаковка = Параметры.Упаковка;
	
	//ТЗ[0].Номенклатура
	//ТЗ[0].Упаковка
	ТЗ[0].ФактПоКоробу				= Окр(ТЗ[0].ФактПоКоробу 			/ Упаковка.Коэффициент,3);
	ТЗ[0].ВесьФактПоНомВКоробах		= Окр(ТЗ[0].ВесьФактПоНомВКоробах 	/ Упаковка.Коэффициент,3);
	ТЗ[0].Всего						= Окр(ТЗ[0].Всего					/ Упаковка.Коэффициент,3);
	ТЗ[0].Осталось					= Окр(ТЗ[0].Осталось				/ Упаковка.Коэффициент,3);
	
	
КонецПроцедуры
