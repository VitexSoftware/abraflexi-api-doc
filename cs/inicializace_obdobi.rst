Inicializace účetního období (konec roku)
============================================

Odlišné od :doc:`akce_zamykani` — jde o obdobu menu "Účetnictví > Inicializace
následujícího účetního období" v desktopové aplikaci: převede konečné
zůstatky do následujícího účetního období a lze ji volat opakovaně (např.
jednou na přelomu roku bez přecenění, jen pro převod skladu, a znovu, jakmile
je znám kurz pro přecenění).

Spuštění inicializace
------------------------

.. code-block:: text

   GET /c/{firma}/ucetni-obdobi/inicializace-noveho-obdobi.json

Pokud má požadavek všechna potřebná data, spustí se vlákno na pozadí a vrátí
se stav **HTTP 202 Accepted**. Neexistuje samostatný endpoint pro stav úlohy —
kontroluje se pole ``lastUpdate`` příslušného záznamu v evidenci
``ucetni-obdobi`` (``GET /c/{firma}/ucetni-obdobi.json?detail=custom:kod,lastUpdate``),
dokud se nezmění.

Pokud neexistuje následující účetní období:

.. code-block:: json

   {
       "winstrom": {
           "@version": 1,
           "success": false,
           "message": "Neexistuje následující účetní období. Prosím založte ho."
       }
   }

Povinné parametry
--------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Parametr
     - Popis
   * - ``ucetOtv``
     - Účet otevření účetní knihy (``druhUctuK = "druhUctu.otevknih"``).
   * - ``ucetZav``
     - Účet uzavření účetní knihy (``druhUctuK = "druhUctu.uzavknih"``).
   * - ``ucetPre``
     - Účet převodu hospodářského výsledku (``druhUctuK = "druhUctu.prhosvys"``).
   * - ``ucetVys``
     - Účet výsledku hospodaření ve schvalovacím řízení (``druhUctuK = "druhUctu.pasivhvy"``).

.. note::

   U firmy typu **daňová evidence** nejsou parametry účtů podvojného
   účetnictví (výše) vyžadovány vůbec.

Chybějící parametr:

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "K provedení operace je vyžadován parametr 'ucetOtv'"}}

Nesprávný druh účtu (např. ``ucetZav`` bez ``druhUctuK = 'druhUctu.uzavknih'``):

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "Parametr 'ucetZav' má nepodporovanou hodnotu! Zvolte jednu z následujících možností: [Zvolený účet musí mít druhUctuK 'druhUctu.uzavknih']"}}

Volitelné parametry
----------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Parametr
     - Popis
   * - ``ucetniObdobi``
     - Kód uzavíraného období. Výchozí je aktuální období.
   * - ``preceneni``
     - ``true``/``false`` — přecenit neuhrazené doklady v cizí měně. Viz
       *Přecenění měn* níže.
   * - ``prevodSkladu``
     - ``true``/``false`` — provést převod skladu. Bez něj se skladové
       položky v novém období nenabídnou.
   * - ``vynechatNulove``
     - ``true``/``false`` — vynechat karty s nulovým zůstatkem.
   * - ``dnyBezPohybu``
     - Celé číslo — počet dnů bez pohybu, použije se spolu s
       ``vynechatNulove`` pro výběr vynechaných karet.
   * - ``zrusitStare``
     - ``true``/``false`` — zrušit nepoužívané staré karty v novém období.
   * - ``typDokl``
     - ID typu dokladu pro generování závazků leasingových splátek.
       **Povinné**, pokud existují nezaplacené závazky pro nové období;
       vybraný typ musí mít řadu dokladu s roční položkou číselné řady k
       následujícímu období, jinak volání selže.
   * - ``kontrolaZaokrouhleni``
     - ``true``/``false`` (výchozí ``true``) — nastavením na ``false``
       potlačíte varování o nestandardním zaokrouhlení DPH (obdoba tlačítka
       "Ano" v desktopovém průvodci) místo opravy zaokrouhlení na typech
       dokladů.

Všechny booleovské parametry mají výchozí hodnotu ``false``. Nestandardní
zaokrouhlení DPH bez ``kontrolaZaokrouhleni=false`` vede k chybě s výpisem
dotčených typů dokladů.

Přecenění měn
----------------

Při ``preceneni=true`` se neuhrazené doklady v cizí měně přeceňují závěrkovým
kurzem. Nejprve lze zjistit, jaký kurz bude použit:

.. code-block:: text

   GET /c/{firma}/ucetni-obdobi/meny-pro-preceneni.json?ucetniObdobi={kód}

.. code-block:: json

   {
       "meny-pro-preceneni": {
           "datumPreceneni": "2023-12-31T00:00:00+01:00",
           "meny": {
               "mena": [
                   {"symbol": "€", "kod": "EUR", "kurz": "24.725", "kurzMnozstvi": "1.0"},
                   {"symbol": "", "kod": "THB", "kurz": "65.107", "kurzMnozstvi": "100.0"}
               ]
           }
       }
   }

Měna s ``kurz`` (nebo ``kurzMnozstvi``) rovným ``0.0`` nemá známý kurz a je
třeba jej zadat ručně, jinak se systém pokusí kurz stáhnout z centrální banky
a pokud selže i to, vrátí se:

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "Nebyly zadány všechny potřebné kurzy platné k poslednímu dni účetního období,\nkteré jsou nutné pro přecenění neuhrazených pohledávek/závazků."}}

Kurzy se zadávají přímo na volání inicializace, dvojicí parametrů pro
každý kód měny:

.. code-block:: text

   ?preceneni=true&kurz[EUR]=24.52&kurzMnozstvi[EUR]=1.0&kurz[HUF]=6.12&kurzMnozstvi[HUF]=100.0

``kurz[KÓD]`` i ``kurzMnozstvi[KÓD]`` je nutné uvést vždy společně; uloží se
jako nový kurz do evidence
``/c/{firma}/kurz-pro-preceneni/(platiOdData, mena)``.

Bankovní účty a pokladny v jiné měně, než je jejich nastavená měna nebo
tuzemská měna, nelze přecenit:

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "Následující bankovní účty a pokladny nelze přecenit:\n• <seznam>\nPřeceňovány mohou být pouze bankovní účty a pokladny, které mají pohyb v měně, ve které jsou vedeny nebo v tuzemské měně."}}

Lze potlačit vynecháním dotčených účtů z přecenění:
``preceneniVynechatBanAPokSChybnouMenou=true``.

Kompletní příklad
--------------------

.. code-block:: text

   GET /c/demo/ucetni-obdobi/meny-pro-preceneni.json?ucetniObdobi=2022
   GET /c/demo/ucetni-obdobi/inicializace-noveho-obdobi.json
       ?ucetniObdobi=2022&ucetOtv=701000&ucetZav=702000&ucetPre=710000&ucetVys=431001
       &preceneni=true&kurz[EUR]=25&kurzMnozstvi[EUR]=1

U firmy typu **daňová evidence** se stejné volání provede bez čtyř
parametrů ``ucet*``.

Viz také :doc:`akce_zamykani` pro uzamknutí období po dokončení inicializace
a závěrkových prací.
