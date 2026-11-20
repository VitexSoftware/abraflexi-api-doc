Odpočet záloh a ZDD
===================

Kapitola popisuje práci se zálohami a zálohovými daňovými doklady (ZDD)
přes REST API: odpočet na vydané faktuře, zjištění částek k odpočtu,
vytvoření ZDD z platby, vytvoření faktury z uhrazených záloh a vazby
ZDD. Zdroj: `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/4729457-odpocet-zaloh-a-zdd-api>`_
a související články (viz jednotlivé sekce).

Odpočet zálohy
--------------

Odpočet se zadává při importu vydané faktury v elementu
``odpocty-zaloh`` (položky ``odpocet``).

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - Element
     - Význam
   * - ``castkaMen``
     - Odečítaná částka v měně dokladu.
   * - ``doklad``
     - Identifikátor zálohového dokladu.
   * - ``id``
     - Externí ID vytvořené položky odpočtu.

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <faktura-vydana>
              <id>code:VF-123/2021</id>
              <typDokl>code:FAKTURA</typDokl>
              <polozkyFaktury>
                <faktura-vydana-polozka>
                  <cenik>code:CANON XS1</cenik>
                  <typPolozkyK>typPolozky.katalog</typPolozkyK>
                  <mnozMj>1.0</mnozMj>
                  <sklad>code:SKLAD</sklad>
                </faktura-vydana-polozka>
              </polozkyFaktury>
              <odpocty-zaloh>
                <odpocet>
                  <castkaMen>16300.0</castkaMen>
                  <doklad>code:ZALOHA0001/2010</doklad>
                  <id>ext:odpocet1</id>
                </odpocet>
              </odpocty-zaloh>
            </faktura-vydana>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "@version": "1.0",
                  "faktura-vydana": [{
                      "id": "code:VF-123/2021",
                      "typDokl": "code:FAKTURA",
                      "polozkyFaktury": [{
                          "cenik": "code:CANON XS1",
                          "typPolozkyK": "typPolozky.katalog",
                          "mnozMj": "1.0",
                          "sklad": "code:SKLAD"
                      }],
                      "odpocty-zaloh": [{
                          "castkaMen": 16300,
                          "doklad": "code:ZALOHA0001/2021"
                      }]
                  }]
              }
          }

Odpočet ZDD
-----------

U ZDD se částky zadávají podle sazeb DPH. Vytvořené položky dostanou k
externímu ID příponu ``-ZAKL``, ``-SNIZ``, ``-SNIZ2`` nebo ``-OSV``.

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:VF-12/2014</id>
       <typDokl>code:FAKTURA</typDokl>
       <odpocty-zaloh>
         <odpocet>
           <castkaZaklMen>400.0</castkaZaklMen>
           <castkaSnizMen>400.0</castkaSnizMen>
           <castkaSniz2Men>400.0</castkaSniz2Men>
           <castkaOsvMen>400.0</castkaOsvMen>
           <doklad>code:ZDD0001/2010</doklad>
           <id>ext:odpocet1</id>
           <castkyBezDph>true</castkyBezDph>
           <skupPlneni>code:TEPLO</skupPlneni>
           <prijmoutDoporuceni>true</prijmoutDoporuceni>
           <castkyVseDostupne>true</castkyVseDostupne>
         </odpocet>
       </odpocty-zaloh>
     </faktura-vydana>
   </winstrom>

.. list-table::
   :header-rows: 1
   :widths: 26 74

   * - Element
     - Význam
   * - ``castkaZaklMen``, ``castkaSnizMen``, ``castkaSniz2Men``, ``castkaOsvMen``
     - Částky v základní, první snížené, druhé snížené sazbě a osvobozené.
   * - ``doklad``
     - Identifikátor ZDD.
   * - ``id``
     - Prefix externího ID vytvořených položek.
   * - ``castkyBezDph``
     - Volitelné; ``true`` = částky jsou bez DPH (výchozí ``false``).
       Doporučeno posílat bez DPH, odpočet ZDD se počítá interně bez
       DPH.
   * - ``skupPlneni``
     - Volitelné; skupina plnění. Kód skupiny, ``ALL`` (nebo vynecháno
       = bez filtru) nebo ``OTHER`` (Jiná skupina). ``OTHER`` se použije,
       když se sazby faktury liší od sazeb ZDD; položky se pak vytvoří
       přímo se sazbami ZDD. Prázdná hodnota zohlední jen položky bez
       skupiny.
   * - ``prijmoutDoporuceni``
     - Volitelné; ``true`` = automaticky přijmout navržené úpravy
       faktury.
   * - ``castkyVseDostupne``
     - Volitelné; ``true`` = odečíst vše dosud neodečtené místo
       ``castka*Men``.

Zpracování probíhá ve dvou krocích: nejprve se vytvoří položky z vlastních
řádků faktury podle sazeb faktury, zbytek se založí jako položky přeplatku
podle sazeb ZDD.

.. note::

   Odeslání ``castkyBezDph`` u neúčetní zálohy skončí chybou HTTP 400
   s kódem ``zalohyXmlZalohaCastkyBezDph`` („U neúčetních záloh nelze
   použít částky bez DPH.“).

Automatický odpočet
-------------------

Odečte všechny zálohy a ZDD, které mají na typu dokladu povolen
automatický odpočet.

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <typDokl>code:FAKTURA</typDokl>
       <odpocty-zaloh>
         <automaticky-odpocet>true</automaticky-odpocet>
       </odpocty-zaloh>
     </faktura-vydana>
   </winstrom>

* Typ zálohy/ZDD musí mít zaškrtnuto „Povolit automatické odpočtení při
  vytvoření nového dokladu“.
* Při importu více faktur s automatickým odpočtem v jednom XML použijte
  na elementu ``faktura-vydana`` atribut ``atomic="false"``.
* Při problémech se zaokrouhlením nejprve naimportujte samotnou fakturu
  s ``atomic="false"`` a ``<id>ext:mojeId</id>``, poté pošlete druhý
  ``faktura-vydana`` se stejným ``ext:mojeId`` obsahujícím
  ``automaticky-odpocet``.

Částky k odpočtu
----------------

Od verze ABRA Flexi 2024.3 lze zjistit, co lze k dokladu odečíst.

.. code-block:: text

   GET /c/{firma}/faktura-vydana/{ID}/zalohy-k-odpoctu.xml
   GET /c/{firma}/faktura-vydana/{ID}/castky-k-odpoctu.xml
   GET /c/{firma}/faktura-vydana/{ID}.xml?relations=zalohy-k-odpoctu
   GET /c/{firma}/faktura-vydana/{ID}.xml?relations=castky-k-odpoctu
   GET /c/{firma}/faktura-vydana/{ID}/zalohy-k-odpoctu.xml?relations=doporuceni

Obě podevidence mají stejné vlastnosti: ``zaloha``, ``ucetni``,
``sumOsv``, ``sumZklZakl``, ``sumZklSniz``, ``sumZklSniz2``,
``sumDphZakl``, ``sumDphSniz``, ``sumDphSniz2``, ``sumCelkZakl``,
``sumCelkSniz``, ``sumCelkSniz2``. Částky jsou v měně dokladu.
``ucetni=true`` znamená odpočet jako ZDD, ``false`` neúčetní zálohu,
která nese částku jen v ``sumOsv``. Přes relaci ``doporuceni`` získáte
navržené úpravy faktury.

.. code-block:: json

   {"winstrom": {"@version": "1.0", "castky-k-odpoctu": [{
       "zaloha": "code:VF1-0005/2024",
       "ucetni": "true",
       "sumOsv": "0.0",
       "sumZklZakl": "3305.79"
   }]}}

(zkráceno). Seznam atributů získáte přes singulár
``zaloha-k-odpoctu/properties`` a ``castky-k-odpoctu/properties``;
množné ``zalohy-k-odpoctu/properties`` vrací 500, protože jde o název
relace, nikoli evidence. Prázdný výsledek je platná odpověď. Překlep v
názvu relace vrací 404 ``adresaNeplatnaUrl``.

Vytvoření ZDD z platby
----------------------

Element ``vytvorZDD`` na platebním dokladu (``banka``,
``pokladni-pohyb``, ``vzajemny-zapocet``) vytvoří ZDD. Na jiných
evidencích je element tiše ignorován (odpověď 200, ZDD nevznikne).
Platba musí být kompletně spárována se zálohovou fakturou.

.. code-block:: xml

   <winstrom version="1.0">
     <banka>
       <id>code:B-0001/2021</id>
       <vytvorZDD>
         <typDokl>code:ZDD</typDokl>
         <rada>code:FAKTURY</rada>
         <clenDph>code:40-41</clenDph>
         <prenasetCisDosle>true</prenasetCisDosle>
         <castkyDph>
           <zklZakl>100</zklZakl>
           <dphZakl>21</dphZakl>
           <celkZakl>121</celkZakl>
         </castkyDph>
       </vytvorZDD>
     </banka>
   </winstrom>

Všechny parametry jsou volitelné; prázdné ``<vytvorZDD/>`` (v JSON ``{}``)
funguje, pokud je v nastavení firmy výchozí typ dokladu.

* ``typDokl`` — typ faktury přijaté/vydané; výchozí z nastavení firmy.
* ``rada`` — číselná řada; odvodí se z typu dokladu.
* ``clenDph`` — členění DPH; odvodí se ze zálohy.
* ``castkyDph`` — ``zklZakl``, ``dphZakl``, ``celkZakl``, ``zklSniz``,
  ``dphSniz``, ``celkSniz``, ``zklSniz2``, ``dphSniz2``, ``celkSniz2``,
  ``osv``.
* ``prenasetCisDosle`` — ``true``/``false``; bez zadání se číslo
  došlé nepřenáší.

Výsledkem je nová ``faktura-prijata`` s ``typDokl`` ZDD a vazbou
platba ↔ ZDD. Není-li platba kompletně spárována, vrátí se chyba
„Doklad není kompletně spárován. Nelze vygenerovat ZDD.“

Faktura z uhrazených záloh
--------------------------

Nová faktura se vytvoří z již uhrazených záloh. Na rozdíl od aplikace se
zadává ID **platby**, nikoli zálohy.

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <typDokl>code:FAKTURA</typDokl>
       <cisDosle>123</cisDosle>
       <datSplat>2022-01-17</datSplat>
       <vytvorZUhrazenychZaloh>
         <uhrazujiciDokl>code:B+0005/2022</uhrazujiciDokl>
         <uhrazujiciEvidence>banka</uhrazujiciEvidence>
       </vytvorZUhrazenychZaloh>
     </faktura-vydana>
   </winstrom>

* ``uhrazujiciDokl`` — ID platebního dokladu.
* ``uhrazujiciEvidence`` (povinné) — ``banka``, ``pokladni-pohyb`` nebo
  ``vzajemny-zapocet`` (pokladna je ``pokladni-pohyb``, ne ``pokladna``).
* Funguje i pro ``faktura-prijata``.

Omezení (vše HTTP 400): chybná evidence (``akceEvidenceList``); odlišný
pohyb platby a nového dokladu (Výdej × Příjem); akce na existujícím
dokladu (podporovány jsou jen nové); zálohy s výrobními čísly nejsou
podporovány.

Vazby ZDD
---------

Vazba ZDD na platbu je přísně 1:1. Vytvoří se elementem
``vytvor-vazbu-zdd`` na ZDD:

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:VF1-0001/2017</id>
       <vytvor-vazbu-zdd>
         <uhrada type="banka">code:B+0001/2017</uhrada>
       </vytvor-vazbu-zdd>
     </faktura-vydana>
   </winstrom>

Pro hotovost použijte ``type="pokladni-pohyb"``; bez ``type`` se platba
bere jako bankovní. Neexistující platba vrací 400
``parovaniZddNenalezenUhrazujiciDoklad``. Vazbu zrušíte prázdným
elementem:

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:VF1-0001/2017</id>
       <zrus-vazbu-zdd/>
     </faktura-vydana>
   </winstrom>

Související články: `Částky k odpočtu
<https://podpora.flexibee.eu/cs/articles/9148386-castky-k-odpoctu-rest-api>`_,
`Tvorba ZDD
<https://podpora.flexibee.eu/cs/articles/6092533-tvorba-zdd-pres-rest-api>`_,
`Faktura z uhrazených záloh
<https://podpora.flexibee.eu/cs/articles/6091865-tvorba-faktury-z-uhrazenych-zaloh>`_,
`Vazby ZDD
<https://podpora.flexibee.eu/cs/articles/4731203-vazby-zdd>`_.
