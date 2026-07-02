Akce a zamykání
====================

Provádění akcí
-------------------

Místo běžného vytvoření/změny lze na záznamu vyvolat akci pomocí atributu
``action`` (tělo požadavku, ne jiná HTTP metoda):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <faktura-vydana action="delete">
            <id>123</id>
            <id>uuid:123456</id>
          </faktura-vydana>
     - .. code-block:: json

          {"winstrom": {"faktura-vydana": [
              {"@action": "delete", "id": ["123", "uuid:123456"]}
          ]}}

.. list-table::
   :header-rows: 1
   :widths: 20 60

   * - Akce
     - Popis
   * - ``delete``
     - Záznam bude smazán.
   * - ``storno``
     - Záznam bude stornován (jen doklady).
   * - ``lock``
     - Záznam bude zamknut.
   * - ``unlock``
     - Záznam bude odemknut.
   * - ``lock-for-ucetni``
     - Záznam bude zamknut pro účetní.

Při provádění akcí nejsou záznamy jinak modifikovány, nemá tedy smysl
uvádět jiné elementy než ``id``; záznamy musí již existovat.

Akce lze vyvolat i **hromadně** nad skupinou záznamů pomocí atributu
``filter`` na evidenci (viz :doc:`davky_transakce`):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <faktura-vydana action="lock" filter="stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"/>
     - .. code-block:: json

          {"winstrom": {"faktura-vydana": {
              "@action": "lock",
              "@filter": "stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"
          }}}

Akce na položkách dokladu (nutné zanořit přes kolekci položek nadřazeného
dokladu):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <faktura-vydana>
            <id>123</id>
            <polozkyFaktury>
              <faktura-vydana-polozka id="456" action="delete"/>
            </polozkyFaktury>
          </faktura-vydana>
     - .. code-block:: json

          {"winstrom": {"faktura-vydana": [{
              "id": "123",
              "polozkyFaktury": [
                  {"id": "456", "@action": "delete"}
              ]
          }]}}

Rozdíl mezi ``action="delete"`` a metodou DELETE
------------------------------------------------------

V jádru shodné, liší se kontroly před provedením:

- ``action="delete"`` dovoluje smazání dokladů i v jiném než aktuálním
  účetním období; ``DELETE`` to nedovolí (chyba "No permission").
- ``action="delete"`` je použitelná téměř všude, kromě uživatelů a
  standardních/vestavěných záznamů typu přehledů.
- ``action="delete"`` je bezpečně použitelná: podle typu vazby buď smaže
  navázané záznamy, zruší vazby, nebo akci nepovolí; ve výjimečných
  případech může transakci zastavit až databázový trigger.

Zamykání a odemykání záznamů
----------------------------------

Stejný mechanismus jako obecné akce (viz výše):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <faktura-vydana action="lock"><id>1</id></faktura-vydana>
          <faktura-vydana action="lock-for-ucetni"><id>1</id></faktura-vydana>
          <faktura-vydana action="unlock"><id>1</id></faktura-vydana>
     - .. code-block:: json

          {"winstrom": {"faktura-vydana": [{"@action": "lock", "id": "1"}]}}
          {"winstrom": {"faktura-vydana": [{"@action": "lock-for-ucetni", "id": "1"}]}}
          {"winstrom": {"faktura-vydana": [{"@action": "unlock", "id": "1"}]}}

Hromadně přes filtr:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <faktura-vydana action="lock" filter="stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"/>
     - .. code-block:: json

          {"winstrom": {"faktura-vydana": {
              "@action": "lock",
              "@filter": "stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"
          }}}

Zamykání účetních období
------------------------------

Odlišné od zamykání jednotlivých záznamů — dedikovaná evidence
``/c/{firma}/zamek``.

Čtení: ``GET /c/{firma}/zamek.xml?detail=full&limit=0``. Klíčová pole:

- ``zamekK`` — typ zámku: ``zamek.otevreno`` (otevřeno) / ``zamek.polozamceno``
  (zamčeno mimo účetní) / ``zamek.zamceno`` (zamčeno).
- ``platiOdData`` / ``platiDoData`` — rozsah dat.
- ``neucetni`` — zda zamknout i neúčetní doklady (výchozí ``true``).
- Jeden boolean flag za modul (viz níže).

Nastavení zámku: ``POST /c/{firma}/zamek.xml`` s povinným ``zamekK``,
``platiOdData``, ``platiDoData`` a **alespoň jedním** modulem nastaveným na
``true`` (jinak se nic nezamkne):

``modulFav`` (fakt. vydané), ``modulFap`` (fakt. přijaté), ``modulPhl``
(ostatní pohledávky), ``modulZav`` (ostatní závazky), ``modulBan`` (banka),
``modulPok`` (pokladna), ``modulInt`` (interní doklady), ``modulSkl``
(skladové pohyby), ``modulPpp``/``modulPpv`` (poptávky přij./vyd.),
``modulNap``/``modulNav`` (nabídky přij./vyd.), ``modulObp``/``modulObv``
(objednávky přij./vyd.), ``modulMaj`` (majetek), ``modulLea`` (leasing),
``modulMzd`` (mzdy).

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <zamek>
            <zamekK>zamek.zamceno</zamekK>
            <platiOdData>2022-01-01</platiOdData>
            <platiDoData>2022-01-15</platiDoData>
            <modulFap>true</modulFap>
          </zamek>
     - .. code-block:: json

          {"winstrom": {"zamek": [{
              "zamekK": "zamek.zamceno",
              "platiOdData": "2022-01-01",
              "platiDoData": "2022-01-15",
              "modulFap": "true"
          }]}}

Smazání zámku: ``<zamek action="delete"><id>6</id></zamek>``.

.. warning::

   Smazání zámku období **neodemyká jednotlivé doklady** zamčené v jeho
   rámci! Ty je nutné odemknout samostatně (``action="unlock"``).
