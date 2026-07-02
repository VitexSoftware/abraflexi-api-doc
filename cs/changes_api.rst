Changes API
===========

Firemní přehled změn
------------------------

Je-li Changes API zapnuté, AbraFlexi zaznamenává všechny operace
vytvoření/aktualizace/smazání napříč evidencemi do changelogu, pod stále
rostoucím číslem globální verze — ideální pro inkrementální synchronizaci
externích systémů (na rozdíl od pouhého pole ``lastUpdate``) a základ pro
Web Hooks.

Čísla verzí nemusí následovat těsně po sobě (z technických důvodů mohou
vznikat mezery), ale vždy jsou unikátní a rostoucí.

Licence musí mít aktivní REST API alespoň pro čtení (u nových placených
licencí standardně splněno).

Zjištění stavu a zapnutí/vypnutí (webové rozhraní): ``/c/{firma}/changes/control``.

Programově:

.. code-block:: text

   PUT nebo POST /c/{firma}/changes/enable.xml
   PUT nebo POST /c/{firma}/changes/disable.xml
   GET  /c/{firma}/changes/status.xml     — vrací true/false

Bez aktivního REST API pro čtení/zápis vrací 403 Forbidden.

.. code-block:: bash

   curl -k -L -u jmeno:heslo -X PUT https://server:5434/c/firma/changes/enable.xml -H Content-Length:0

Získání aktuální globální verze
------------------------------------

Do libovolného exportu lze doplnit aktuální globální verzi parametrem
``?add-global-version=true``:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0" globalVersion="6">...</winstrom>
     - .. code-block:: json

          {"winstrom": {"@version": "1.0", "@globalVersion": "6", "...": "..."}}

Získání záznamů o změnách
------------------------------

.. code-block:: text

   GET /c/{firma}/changes.xml

.. code-block:: xml

   <winstrom version="1.0" globalVersion="6">
     <faktura-vydana in-version="3" operation="create" timestamp="2019-01-01 00:00:00.0">
       <id>1</id>
     </faktura-vydana>
     <faktura-vydana-polozka in-version="4" operation="create" timestamp="2019-06-07 12:34:56.7">
       <id>1</id>
     </faktura-vydana-polozka>
     <faktura-vydana in-version="5" operation="update" timestamp="2019-06-07 12:34:56.7">
       <id>1</id>
       <id>code:VF1-0001/2012</id>
     </faktura-vydana>
     <next>6</next>
   </winstrom>

U každého elementu je uveden číselný ``<id>`` a kód (``<id>code:KÓD</id>``);
měl-li objekt v době operace i nějaká externí ID, jsou uvedena také
(``<id>ext:...</id>``). Atributy: ``in-version`` (verze, ve které ke změně
došlo), ``operation`` (``create`` / ``update`` / ``delete``). Poslední
element ``<next>`` udává, od jaké verze by výpis pokračoval (``none``,
pokud žádné další změny nejsou).

Parametry výpisu:

.. list-table::
   :header-rows: 1
   :widths: 25 55

   * - Parametr
     - Popis
   * - ``start=123``
     - od které verze vypisovat (včetně); výchozí od počátku sledování.
   * - ``limit=500``
     - kolik záznamů vypsat; výchozí 100, maximálně 1000.
   * - ``evidence=faktura-vydana``
     - pro které evidence vypisovat změny; lze uvést vícekrát, jinak všechny.

V JSON:

.. code-block:: json

   {
     "winstrom": {
       "@globalVersion": "8",
       "changes": [
         {"@evidence": "faktura-vydana", "@in-version": "3", "@operation": "create",
          "@timestamp": "2019-01-01 00:00:00.0", "id": "1", "external-ids": []},
         {"@evidence": "faktura-vydana", "@in-version": "5", "@operation": "update",
          "@timestamp": "2019-06-07 12:34:56.7", "id": "1",
          "external-ids": ["code:VF1-0001/2012"]}
       ],
       "next": "6"
     }
   }

Synchronizace externích systémů
-------------------------------------

1. **Počáteční nahrání dat**: získat aktuální data včetně verze
   (``?add-global-version=true``), uložit je, zapamatovat si verzi
   (z atributu ``globalVersion``).
2. **Rozdílová synchronizace**: stáhnout změny od poslední zapamatované verze
   (``?start=``), stáhnout/aplikovat změněná data (aktualizovat nebo smazat),
   zapamatovat si novou verzi (z elementu ``next``, případně ``globalVersion``).
3. Krok 2 opakovat.

Chyba "could not obtain lock on relation"
-----------------------------------------------

Při prvním zapnutí Changes API se do databáze zavádí podpůrné funkce, což
vyžaduje exkluzivní zámek celé databáze. Pokud se objeví chyba
``ERROR: could not obtain lock on relation "..."``, řešením je odhlásit se
z AbraFlexi (webové rozhraní i klientská aplikace) a akci zopakovat.

Endpointy sledované Changes API (výběr)
---------------------------------------------

Changes API pokrývá velmi široký katalog evidencí napříč celou aplikací —
adresář a kontakty, ceník a zboží, doklady (faktury, pohledávky, závazky),
banka/pokladna/interní doklady, obchodní doklady (nabídky, objednávky,
poptávky), sklad, smlouvy, příkazy k úhradě a číselníky plateb, účetnictví
(deník, osnova, DPH, střediska, zakázky), kurzy, Intrastat, řady dokladů, i
nastavení a systémové evidence (uživatelé, role, štítky, uživatelské
dotazy/vazby, filtry). Kompletní a aktuální seznam najdete v anglické verzi
této kapitoly nebo přímo v oficiální dokumentaci "Changes API"; zde uvádíme
jen nejběžnější:

``adresar``, ``kontakt``, ``cenik``, ``faktura-vydana(-polozka)``,
``faktura-prijata(-polozka)``, ``banka(-polozka)``, ``pokladni-pohyb(-polozka)``,
``interni-doklad(-polozka)``, ``objednavka-prijata/vydana(-polozka)``,
``nabidka-prijata/vydana(-polozka)``, ``poptavka-prijata/vydana(-polozka)``,
``skladovy-pohyb(-polozka)``, ``skladova-karta``, ``smlouva``,
``prikaz-k-uhrade``, ``ucetni-denik``, ``ucet``, ``stredisko``, ``zakazka``,
``mena``, ``rada``, ``nastaveni``, ``priloha``, ``uzivatel``, ``role``,
``stitek``, ``vazba``.
