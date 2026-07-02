Identifikátory a datové typy
==================================

Identifikátory záznamů
---------------------------

.. list-table::
   :header-rows: 1
   :widths: 20 15 45

   * - Název
     - Ukázka
     - Poznámka
   * - Interní ID
     - ``123``
     - Přiděluje AbraFlexi, nelze měnit. Databázová sekvence — nikdy se
       nepřidělí dvakrát (ani po smazání záznamu), ale nezaručuje číselnou
       návaznost (rollback číslo zahodí).
   * - Kód / zkratka
     - ``code:CZK``
     - Uživatelské označení, lze měnit v aplikaci.
   * - Key (interní UUID)
     - ``key:550e8400e29b41d4a716``
     - Náhodný identifikátor přidělený dokladům, neměnný.
   * - PLU
     - ``plu:4020``
     - Identifikační kód pro prodej (typicky 4–5 místné číslo).
   * - EAN
     - ``ean:4710937332698``
     - Čárový kód; lze dohledat i podle EAN balení.
   * - Externí identifikátor
     - ``ext:SHOP:123``
     - Skládá se z identifikátoru externího systému a identifikátoru řádku
       v něm. Musí být unikátní v rámci celé evidence. Nelze měnit z
       aplikace, jen z externích systémů.
   * - Hybridní identifikátor
     - ``ws:{UUID firmy}:{interní ID}``
     - Chová se podle kontextu: pokud UUID firmy odpovídá cílové firmě,
       funguje jako interní ID; jinak jako externí ID. Aktivuje se
       ``?mode=xml_import_export``.
   * - VAT ID
     - ``vatid:CZ28019920``
     - DIČ (ČR) / IČ DPH (SK).
   * - IČO
     - ``in:28019920``
     - Identifikátor dle IČO.
   * - IBAN
     - ``iban:CZ1201000002801992``
     - Identifikátor dle kódu IBAN.

Vytvoření/aktualizace podle identifikátoru: pokud identifikátor jiného typu
než interní neexistuje, vytvoří se nový záznam; jinak se aktualizuje
existující:

.. code-block:: json

   {"winstrom": {"cenik": [{"id": "code:T100", "nazev": "Téčko 100 mm"}]}}

Vícenásobné identifikátory (musí ukazovat na tentýž záznam, jinak chyba;
neexistující se ignorují — vhodné pro postupné doplňování z externích
systémů):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <cenik>
            <id>123</id>
            <id>code:KRABICE</id>
          </cenik>
     - .. code-block:: json

          {"winstrom": {"cenik": [
              {"id": ["123", "code:KRABICE"]}
          ]}}

Mimo importní XML (URL, ostatní pole) se více identifikátorů zapisuje
speciální syntaxí se závorkami: ``[123][code:CZK][ext:SHOP:abc]`` (znaky
``[``, ``]``, ``,`` uvnitř identifikátoru je nutné escapovat zpětným
lomítkem a URL-encode celku).

Postupné přidávání dalších externích identifikátorů k existujícímu záznamu
(inkrementální aktualizace):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <cenik id="123">
            <id>ext:SHOP:abc</id>
            <id>ext:SYSTEM3:xyz</id>
          </cenik>
     - .. code-block:: json

          {"winstrom": {"cenik": [
              {"id": ["123", "ext:SHOP:abc", "ext:SYSTEM3:xyz"]}
          ]}}

V JSON je validní i kombinovaný zápis: ``"cenik": "[code:NIKON][123][ext:SHOP:abc]"``.

Mazání externích identifikátorů: atribut evidence ``removeExternalIds``,
jehož hodnota je prefix mazaných identifikátorů (prázdný řetězec = smazat
všechny; prefix ``ext:`` v hodnotě není nutné uvádět):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <cenik removeExternalIds="SYSTEM">
            <id>123</id>
            <id>ext:SHOP:123</id>
          </cenik>
     - .. code-block:: json

          {"winstrom": {"cenik@removeExternalIds": "SYSTEM", "cenik": [
              {"id": ["123", "ext:SHOP:123"]}
          ]}}

U položek dokladu lze ``removeExternalIds`` uvést společně pro všechny
položky, nebo přímo na konkrétní položce (má přednost).

Filtrování dle externího ID:

.. code-block:: text

   /c/firma/faktura-vydana/(id=='ext:EXTERNI_ID')

Podporované datové typy
----------------------------

Používají se při exportu/importu i při filtraci.

.. list-table::
   :header-rows: 1
   :widths: 15 15 40 20

   * - Typ
     - Název
     - Poznámka
     - Ukázka
   * - ``string``
     - Řetězec
     - Kódování unicode, libovolný znak.
     - ``šílený koníček``
   * - ``integer``
     - Celé číslo
     - Bez mezer; 4bajtový integer se znaménkem, rozsah může být u
       konkrétního pole omezen.
     - ``12``
   * - ``numeric``
     - Desetinné číslo
     - Bez mezer, desetinná tečka; 8bajtový double.
     - ``12.5``
   * - ``date``
     - Datum
     - ``YYYY-MM-DD``, nepovinná (ignorovaná) časová zóna. Pro filtraci
       pouze zápis bez časové zóny.
     - ``2015-01-30``
   * - ``datetime``
     - Datum + čas
     - ``YYYY-MM-DD'T'HH:MM:SS.SSS``, nepovinná (ignorovaná) časová zóna.
     - ``2008-09-01T17:18:14.075+02:00``
   * - ``logic``
     - Logická hodnota
     - ``true`` / ``false``
     -
   * - ``select``
     - Výběr z hodnot
     - Reprezentován jako řetězec.
     - ``typVztahu.odberDodav``
   * - ``relation``
     - Vazba na jinou evidenci
     - Hodnotou je libovolný podporovaný identifikátor.
     - ``123``, ``code:CZK``

Identifikátor firmy
------------------------

Firemní identifikátor (``dbNazev``, používaný jako ``{firma}`` ve všech
``/c/{firma}/...`` URL) se odvozuje z názvu firmy při jejím založení: malá
písmena, číslice a podtržítko, ostatní znaky nahrazeny podtržítkem; při
kolizi se doplní pořadové číslo. Zůstává neměnný i po přejmenování firmy;
smazaná firma může uvolnit svůj identifikátor pro novou firmu.

Seznam všech firem na serveru (bez nutnosti znát konkrétní firemní
identifikátor předem, jen serverová autentizace):

.. code-block:: text

   GET /c.json?limit=0

Pole odpovědi: ``dbNazev`` (identifikátor), ``nazev`` (zobrazovaný název),
``id``, ``createDt``, ``licenseGroup``, ``show`` (viditelná), ``watchingChanges``
(zapnuté Changes API), ``stavEnum``: ``ESTABLISHING`` | ``ESTABLISHED`` |
``MAINTENANCE``.
