Dávkové operace a transakce
=================================

Dávkové operace (filtr místo výčtu ID)
--------------------------------------------

Jedním elementem lze aktualizovat, nebo na něm vyvolat akci, u více
záznamů najednou pomocí atributu ``filter`` na úrovni evidence — filtrovací
jazyk je stejný jako u URL filtrů (viz :doc:`vypis_filtrovani`):

.. code-block:: xml

   <winstrom version="1.0">
     <cenik filter="dodavatel = 'code:FIRMA'">
       <stitky>VIP</stitky>
     </cenik>
   </winstrom>

Přidá štítek VIP všem položkám ceníku od dodavatele FIRMA. Chová se, jako
by místo jednoho elementu s ``filter`` bylo uvedeno tolik elementů, kolik
záznamů podmínce vyhovuje — s tím rozdílem, že elementy ``id`` jsou u
dávkových operací zcela ignorovány.

V JSON:

.. code-block:: json

   {
     "winstrom": {
       "faktura-vydana": {
         "@filter": "stitky='code:OVERENO'",
         "@action": "lock"
       }
     }
   }

Tento příklad vyvolá akci ``lock`` nad všemi fakturami vydanými se
štítkem OVERENO (viz :doc:`akce_zamykani`).

Transakční zpracování
--------------------------

Ve výchozím stavu je celý import jednou databázovou transakcí — buď se
uloží vše, nebo nic.

.. code-block:: xml

   <winstrom version="1.0" atomic="false">
     <faktura-vydana><id>code:123</id>...</faktura-vydana>
     <faktura-vydana><id>code:456</id>...</faktura-vydana>
   </winstrom>

Atributem ``atomic="false"`` se každý *hlavní* záznam importuje ve vlastní
transakci (v příkladu výše proběhnou dvě transakce, jedna pro fakturu 123
a druhá pro 456; položky faktury jsou součástí stejné transakce jako
faktura samotná).

Přínos: u velkých importů s mnoha záznamy transakce dlouho trvá a hodně
dat se drží v paměti — obojí zhoršuje výkon. Pokud nevadí, že se uložení
některého záznamu nezdaří (např. import se pravidelně opakuje, nebo lze
problém ručně vyřešit), lze v režimu ``atomic="false"`` výrazně snížit
paměťové (a u opravdu velkých importů i časové, kvůli garbage collectoru)
nároky importu.
