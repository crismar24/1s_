﻿
Процедура УстановкаПараметровСеанса(ТребуемыеПараметры)
	
	//ИмяПользователя = ПолучитьТекущийСеансИнформационнойБазы().Пользователь.ПолноеИмя;
	ИмяПользователя = ИмяПользователя();
	Пользователь = Справочники.Пользователи.НайтиПоНаименованию(ИмяПользователя());
	Если ЗначениеЗаполнено(Пользователь) Тогда
		ПараметрыСеанса.ТекущийПользователь = Пользователь;
	Иначе
		Эл = Справочники.Пользователи.СоздатьЭлемент();
		Эл.Наименование = ИмяПользователя;
		Эл.Записать();
	КонецЕсли;
	
	А=0;
	
КонецПроцедуры