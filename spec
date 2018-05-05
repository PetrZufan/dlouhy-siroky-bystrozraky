Pocatecni pozice: 
	Na zacatku jsou agenti, depot i suroviny a bonusy umisteny nahodne. Depot a agenti maji pevne zadanou pocatecni polohu pro jednotlive mapy ve WorldModel.java. Ale obecne muze byt jakakoliv.

Chovani: 
	- Bystrozraky se snazi prozkoumat celou mapu. Potom, co ji celou prozkouma, nebo vsechnu jeji dostupnou cast. (Teoreticky muze existovat nedostupna plocha ohranicena prekazkami. Prakticky se v mapach vyskytuji pouze velke bloky prekazek, ktere jsou ovsem dostatecne male, na to aby bystrozraky bez bryli videl z dostupnych mist na vsechna policka.) Po te co prozkouma celou mapu, jde sbirat suroviny. Asi jenom drevo.

	- Siroky se vyda nahodne po mape, dokud nenarazi na surovinu. Tu pak sebere a sbira suroviny stejneho typu dokud neni naplnena jeho kapacita. Pote je odnese do depotu. Kdyz je prazdnej, jde pro nejblizsi surovinu. Pokud jde pro zlato, zavola kolegu na pomoc. Oba soucasne zvednou zlato. Kolega preda zlato sirokemu a jde si zase po svem. Siroky jde pro dalsi zlato, dokud neni naplnena jeho kapacita. (Kapacita sirokeho je sude cislo, melo by to vyjit, ze ten kolega, ktery prijde na pomoc bude odchazet prazdnej.)

	- Dlouhy se taktez vyda nahodne po mape a sbira drevo. V pripade, ze siroky zavola o pomoc se zlatem, jde mu pomoct (po te co vylozi pripadny naklad).

Bonusy: 
	- Jakmile je objeven bonus, prislusny agent jde ihned pro nej.

Komunikace:
	- Objeven objekt na pozici: Kdokoliv objevi surovinu nebo bonus, vsem zahlasi jeho pozici. Pr. send(aFast, tell, wood(10,15))
	
	- Odstranen objekt na pozici: Kdokoliv uvidi policko, na kterem mel byt nejaky objekt, ale uz tam neni (sebral ho protihrac), nebo pokud sam sebere objekt, zahlasi ostatnim, ze uz tam neni. Pr. send(aFast, untell, wood(10,15))
	
	- Jdu pro cil: Vzdy kdyz si agent urci cil (surovina, depo, ..), ulozi tuto informaci do sve BB. Pr. goal(wood, 10, 15).
		Kdyz se pak nejaky agent rozhoduje pro jakou surovinu jit, zvoli takovou, ktera neni aktualnim cilem ostatnich. Da se zjistit zpravou typu ask. napr send(aFast, askOne, wood(10,15)). 
		Do depa samozrejme muzou jit vsici zaroven. Sber zlata je vyjimka.

	- Pomoc se zlatem: kdyz se agent vyda pro zlato, zavola si nekoho na pomoc. Jdou oba na stejne policko.


Otazky a zamysleni:
	- Na mape jsou od kazdeho bonusu dva kusy. Muze napr dlouhy sebrat dvoje boty a chodit o 9 respektive 12 policek? Odpoved: NE.
	
	- Jak se bude chovat dlouhy a bystrozraky kdyz dojde drevo ale zbyde zlato? Budou nejakym zpusobem sbirat zlato vsici tri? 
