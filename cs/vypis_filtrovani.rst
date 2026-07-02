Výpis, filtrování a dotazy
===============================

Výpis vs. detail
---------------------

**Výpis** vrací více záznamů — lze stránkovat, filtrovat, řadit a určovat
úroveň detailu. **Detail** vždy reprezentuje jeden konkrétní záznam.

Získání více konkrétních záznamů (např. podle externích ID):

1. Samostatný GET na každý záznam — pozor, adresa s ``code:``/``ext:``
   identifikátorem vrací přesměrování (303) na kanonickou URL s číselným ID;
   HTTP klient musí přesměrování následovat (často nutné výslovně zapnout).
2. Filtr ``id in (...)`` — pozor na limity délky URL.
3. **Hromadné získání podle ID** (žádný limit délky, stovky až tisíce ID
   najednou):

   .. code-block:: text

      POST /c/firma/faktura-vydana/get.json

   .. code-block:: json

      {"winstrom": {"id": [1, "code:2", "ext:SYS:3"]}}

   Neexistující identifikátory se tiše ignorují; duplicitní/aliasované
   identifikátory vytvoří duplicitní řádky ve výstupu. Lze i metodou PUT.

Úrovně detailu
-------------------

Řídí se parametrem ``detail`` (jen pro XML/JSON/XLS/CSV, jiné formáty
neovlivňuje):

.. list-table::
   :header-rows: 1
   :widths: 20 60

   * - Hodnota
     - Význam
   * - ``id``
     - jen primární klíč + externí identifikátory
   * - ``summary``
     - **výchozí pro výpis**: id, lastUpdate, kod, nazev apod.
   * - ``full``
     - **výchozí pro detail**: všechna pole
   * - ``custom:...``
     - jen vyjmenovaná pole (``id`` se exportuje vždy automaticky)

Doporučený postup: nepoužívat plošně ``detail=full`` (pomalejší, více paměti),
ale vyjmenovat jen potřebná pole přes ``custom:``. Přehled dostupných polí
dané evidence: ``GET /c/firma/{evidence}/properties``.

``custom:`` podporuje i projekci do vnořených kolekcí a víceúrovňové
zanoření:

.. code-block:: text

   ?detail=custom:kod,sady-a-komplety(cenik,cenikSada)
   ?detail=custom:kod,sady-a-komplety(cenik(nazev),cenikSada)&includes=/cenik/sady-a-komplety/sady-a-komplety/cenik
   &includes=faktura-vydana/mistUrc/misto-urceni/kontaktOsoba&detail=custom:mistUrc(kontaktOsoba(jmeno,prijmeni,tel,mobil,email))

Neznámé názvy polí v ``custom:`` se tiše ignorují.

Relace a includes
----------------------

Parametr ``relations`` (čárkou oddělený seznam) přidává do výstupu další
kolekce — **pouze pro export**, nelze použít pro import (tam se zapisuje
přímo do podtabulky):

.. list-table::
   :header-rows: 1
   :widths: 20 60

   * - Kód
     - Význam
   * - ``vazby``
     - vazby mezi doklady
   * - ``prilohy``
     - přílohy
   * - ``sklad-karty``
     - skladové karty (u ceníku)
   * - ``polozky``
     - položky dokladu

Příklad: ``/c/firma/adresar?relations=vazby,prilohy``

Parametr ``includes`` rozbalí vazební pole na celý objekt místo pouhého ID:
``?includes=/adresar/stat/``, více najednou odděleno čárkou:
``includes=/adresar/stat/,/adresar/stredisko/``.

Přehled dostupných relací dané evidence: ``GET /c/firma/{evidence}/relations``.

Problém "vrácení všech polí" — proč nepoužívat detail=full
------------------------------------------------------------------

Typická chyba je použít ``detail=full`` "pro jistotu" a pak využít jen část
polí. Pole, která program skutečně zpracovává, jsou dopředu známa — použijte
proto ``detail=custom:...``. Přínos: menší odpověď (rychlejší přenos), méně
SQL dotazů na serveru (rychlejší odpověď), nižší paměťové nároky klienta.

Stránkování
---------------

.. list-table::
   :header-rows: 1
   :widths: 25 60

   * - Parametr
     - Význam
   * - ``limit``
     - max. počet záznamů na stránku. **Výchozí hodnota je 20!** ``limit=0``
       vrací všechny záznamy bez omezení.
   * - ``start``
     - kolik záznamů přeskočit; nezávislé na ``limit``.
   * - ``add-row-count=true``
     - přidá do XML/JSON celkový počet záznamů (zohledňuje aktivní filtry).

.. warning::

   Protože výchozí ``limit`` je pouze 20, naivní volání výpisu bez
   explicitního ``limit`` může nenápadně useknout výsledky. Pro úplný výpis
   použijte ``limit=0`` nebo stránkujte.

Řazení
----------

Parametr ``order`` (lze opakovat pro víceklíčové řazení):

.. code-block:: text

   ?order=nazev

.. warning::

   **Směr řazení je matoucí** — písmena neodpovídají anglické intuici:
   ``order=nazev@A`` znamená **sestupně**, ``order=nazev@D`` znamená
   **vzestupně**. Ověřeno křížovou kontrolou s referenční PHP knihovnou
   (metody ``getNextRecordID``/``getPrevRecordID`` dávají smysl jedině s
   tímto — na první pohled obráceným — významem).

Alternativa pro kompatibilitu: ``sort=`` + ``dir=`` (hodnoty ``ASC``/``DESC``).

Bez ``order`` se řadí dle ID; výjimky: doklady se řadí nejprve dle
``datVyst`` sestupně, měnové kurzy dle ``platiOdData`` sestupně a ``mena``
vzestupně. Lze řadit i dle vlastnosti relace první úrovně:
``?order=stredisko.nazev``.

Filtrování
--------------

Filtr se do URL vkládá jako závorkovaný segment cesty (parametr ``filter``
v query stringu server ignoruje):

.. code-block:: text

   /c/firma/adresar/(nazev='ACME')

Operátory:

.. list-table::
   :header-rows: 1
   :widths: 25 35 20

   * - Operátor
     - Význam
     - Příklad
   * - ``=`` / ``==`` / ``eq``
     - rovnost
     - ``a = 1``
   * - ``<>`` / ``!=`` / ``ne``
     - nerovnost
     - ``a != 1``
   * - ``<`` / ``lt``
     - menší než
     - ``a < 1``
   * - ``<=`` / ``lte``
     - menší nebo rovno
     - ``a <= 1``
   * - ``>`` / ``gt``
     - větší než
     - ``a > 1``
   * - ``>=`` / ``gte``
     - větší nebo rovno
     - ``a >= 1``
   * - ``like``
     - obsahuje
     - ``a like 'x'``
   * - ``like similar``
     - obsahuje bez háčků/čárek (PostgreSQL ≥ 9.0)
     - ``a like similar 'x'``
   * - ``between``
     - je v rozsahu
     - ``vek between 18 100``
   * - ``begins`` / ``begins similar``
     - začíná na
     - ``a begins 'Win'``
   * - ``ends``
     - končí na
     - ``a ends 'x'``
   * - ``in``
     - je prvkem výčtu
     - ``a in (1, 2, 3)``
   * - ``in subtree`` / ``in subtree ... nonrecursive``
     - patří do podstromu ceníku
     - ``in subtree 3``
   * - ``is true`` / ``is false``
     - logická hodnota
     - ``a is true``
   * - ``is [not] null``
     - je (není) vyplněno
     - ``a is null``
   * - ``is [not] empty``
     - je (není) prázdné (null/0/false/"")
     - ``a is not empty``

Kombinace: ``and``, ``or``, ``not``, závorky (priorita: základní operátory,
pak ``not``, pak ``and``, nakonec ``or``). Negativní operátory (např. ``<>``)
nelze použít uvnitř podfiltru přes relaci — místo toho ``not(... eq ...)``.

Filtrování přes relace (libovolná hloubka zanoření, ale jen 1:1 relace):

.. code-block:: text

   firma = 'code:FIRMA'
   firma.skupFir = 'code:ODBERATEL-STANDARD'

Filtrování dle štítku: ``stitky = 'code:VIP'``.

Filtrování dle podstromu ceníku: ``in subtree 3`` (zkratka za
``id in subtree 3``); modifikátor ``nonrecursive`` omezí jen na daný uzel.
Lze filtrovat i jiné evidence dle zařazení souvisejícího ceníku:
``/c/firma/skladova-karta/(cenik in subtree 3)``.

Filtrování polí položek dokladu se dělá přímo v evidenci položek:
``/faktura-vydana-polozka/(doklFak=123 and cenik="code:AUTO")``.

Speciální hodnoty: ``now()`` (aktuální datum a čas), ``currentYear()``
(aktuální rok), ``me()`` (přihlášený uživatel) — např. ``datSplat < now()``,
``uzivatel = me()``.

Uložené filtry: evidence ``filtr`` (pole ``obsahFiltru``, ``beanKey``),
použití: ``/c/firma/cenik/(filter:2)`` (interní ID filtru).

Výchozí filtr platnosti: evidence s poli ``platiOd``/``platiDo`` se ve
výchozím stavu filtrují podle aktuálního účetního období; potlačení:
``?filtrovat-platnost=false``.

Sumace
----------

.. code-block:: text

   /c/firma/{evidence}/$sum
   /c/firma/{evidence}/(<filtr>)/$sum

Funguje jen nad doklady (faktury, objednávky, poptávky, pokladní pohyby,
skladové pohyby, ...). Pokročilé parametry (aktuálně jen pro obraty na
účtech): ``period:(rokMesic,2020-01-01,2020-12-31)``, ``fields: obrDal,obrMd``,
``group-by: rokMesic, quarter(rokMesic)``.

Endpoint /query — filtry a parametry v těle požadavku
-----------------------------------------------------------

Vše, co lze poslat v URL, lze poslat i v těle POST požadavku — vhodné pro
komplexní filtry (žádný limit délky URL):

.. code-block:: text

   POST /c/{firma}/{evidence}/query.json

.. code-block:: json

   {
     "winstrom": {
       "detail": "custom:kod,nazFirmy,datVyst,datSplat,zbyvaUhradit,sumCelkem,stavUhrK,sumCelkemMen,mena(kod),stredisko(nazev,kod,id)",
       "includes": "/faktura-vydana/mena,/faktura-vydana/stredisko",
       "filter": "(datSplat lt now() and storno eq false)",
       "order": ["sumCelkem", "kod"],
       "no-ext-ids": "true",
       "limit": "100",
       "start": "0",
       "@version": "1.0"
     }
   }

Lze kombinovat s parametry v URL (např. ``?add-row-count=true&limit=100``).
Uvnitř JSON řetězce ``filter`` je nutné uvozovky escapovat zpětným lomítkem.
