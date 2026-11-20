Sestavování požadavků
=========================

Struktura URL
-------------

.. code-block:: text

   /c/<identifikátor firmy>/<evidence>/<ID záznamu>.<výstupní formát>

- ``<identifikátor firmy>`` — jednoznačná identifikace firmy na serveru (viz
  :doc:`sprava_firem`).
- ``<evidence>`` — typ evidence (adresar, faktura-vydana, ...); kompletní
  seznam je ve webovém rozhraní pod "Evidence list", případně v Changes API
  endpoint katalogu (:doc:`changes_api`).
- ``<ID záznamu>`` — libovolný podporovaný identifikátor (viz
  :doc:`identifikatory`); pokud chybí, jde o výpis celé evidence.
- ``<výstupní formát>`` — nepovinná přípona; pokud chybí, řídí se hlavičkou
  ``Accept``, jinak se vrátí HTML. Přípona má přednost před ``Accept``.
  Vstupní formát (u zápisu) se řídí primárně hlavičkou ``Content-Type``.

Prefixy jiné než ``/c/``: ``/a/``, ``/u/`` (uživatelé serveru), ``/g/``,
``/admin/`` (administrace, mj. založení firmy), ``/status/`` (mj. odhlašování
uživatelů), ``/login-logout/`` (autentizace).

Výpis a sumace
------------------

.. code-block:: text

   /c/<firma>/<evidence>                     — výpis
   /c/<firma>/<evidence>/(<filtr>)           — výpis s filtrem
   /c/<firma>/<evidence>/$sum                — sumace
   /c/<firma>/<evidence>/(<filtr>)/$sum      — sumace s filtrem
   /c/<firma>/<evidence>/properties          — přehled podporovaných polí
   /c/<firma>/<evidence>/reports             — přehled tiskových sestav (PDF)
   /c/<firma>/<evidence>/relations           — přehled podevidencí (relací)

Podporované formáty
------------------------

.. list-table::
   :header-rows: 1
   :widths: 12 30 18 25 10

   * - Formát
     - Poznámka
     - Přípona
     - Content-Type
     - Import?
   * - HTML
     - stránka pro zobrazení v prohlížeči
     - ``.html``
     - ``text/html``
     - ne
   * - XML
     - strojově čitelná struktura
     - ``.xml``
     - ``application/xml``
     - ano
   * - JSON
     - strojově čitelná struktura
     - ``.js`` / ``.json``
     - ``text/javascript`` / ``application/json``
     - ano
   * - CSV
     - tabulkový výstup
     - ``.csv`` (``?encoding=iso-8859-2``)
     - ``text/csv``
     - ano
   * - DBF
     - databázový výstup (dBase)
     - ``.dbf``
     - ``application/dbf``
     - ano
   * - XLS
     - tabulkový výstup (Excel)
     - ``.xls``
     - ``application/ms-excel``
     - ano
   * - ISDOC
     - e-fakturace; parametry ``?typDokl=code:...&typUcOp=code:...``
     - ``.isdoc`` / ``.isdocx``
     - ``application/x-isdoc(x)``
     - ano
   * - EDI
     - formát INHOUSE
     - ``.edi``
     - ``application/x-edi-inhouse``
     - ano
   * - PDF
     - tiskový report (viz :doc:`kopie_tisky_qr`)
     - ``.pdf?report-name=...``
     - ``application/pdf``
     - ne
   * - vCard
     - elektronická vizitka (adresář)
     - ``.vcf``
     - ``text/vcard``
     - ne
   * - iCalendar
     - export událostí/splatností
     - ``.ical``
     - ``text/calendar``
     - ne

Tato příručka se dále soustředí na JSON.

HTTP operace
-------------

- **GET** — čtení (výpis nebo detail), respektuje výstupní formát.
- **DELETE** — smazání jednoho záznamu na detailní URL. Vrací 404, pokud
  záznam neexistuje, jinak 200. Hromadné mazání je nutné řešit přes
  ``action="delete"`` (viz :doc:`akce_zamykani`) — hromadné DELETE na
  výpisové URL neexistuje.
- **POST / PUT** — AbraFlexi mezi nimi nerozlišuje; obě vytvářejí i
  aktualizují podle obsahu a cílové URL:

  - Na výpisovou URL: záznamy se vytvoří nebo aktualizují podle toho, zda byl
    nalezen jejich identifikátor. Pokud má záznam interní (AbraFlexi
    přidělené) ID, musí existovat; pokud je identifikován jinak (např.
    externí ID), a neexistuje, vytvoří se.
  - Na detailní URL (s ID): identifikátor v těle není nutný, bere se z URL;
    záznam musí existovat.
  - Tělo požadavku musí být XML nebo JSON, nikoli formulářová data
    (``multipart/form-data``) — s výjimkou binárního nahrávání příloh
    (viz :doc:`prilohy`).

- Identifikátor nově vytvořeného záznamu se předává hlavičkou
  ``Location: https://server/c/demo/faktura-vydana/105`` a zároveň v těle
  odpovědi (``<result><id>105</id></result>``).

Přístupová práva viz :doc:`autentizace`.

Výkonnostní optimalizace
-----------------------------

- První požadavek po startu serveru trvá výrazně déle (JIT kompilace jádra,
  až ~20 s); další jsou už rychlé, ale i tak je vhodné server nechat
  "zahřát".
- Vždy posílejte autorizaci rovnou, nečekejte na 401.
- Používejte ``?detail=custom:...`` a vyjmenujte jen skutečně potřebná pole
  (viz :doc:`vypis_filtrovani`).
- Nepotřebujete-li externí identifikátory, vypněte je ``?no-ext-ids=true``.
- Nepoužívejte ``?relations=all`` — vyjmenujte jen relace, které opravdu
  potřebujete.
- Nevolejte stejné URL vícekrát v rámci jednoho zpracování.
- Potřebujete-li jen počet záznamů, použijte ``?add-row-count=true`` místo
  načtení všech dat.
- Podobné požadavky slučujte do jednoho volání (např. přes hromadné ID
  dotazy nebo ``/query``, viz :doc:`vypis_filtrovani`).
- Hardwarově: databáze a server na jednom stroji, dostatek paměti, ladění
  PostgreSQL, rychlejší disky, více procesorů.

Testovací uložení (dry-run)
--------------------------------

Pro ověření dat bez skutečného uložení přidejte ``?dry-run=true``. Záznam se
neuloží, ale proběhne validace a v odpovědi je i výsledná reprezentace
záznamu tak, jak by po uložení vypadal (včetně dočasně přiděleného, hned
uvolněného ID) a případná ``warnings``. Dostupné v JSON i XML. Kombinuje se
s mechanismem "předchozí hodnota" (viz :doc:`zapis_dat`) při stavbě
interaktivních editačních formulářů.

Další URL parametry
-------------------

Logické parametry lze psát i bez hodnoty (``?no-ids`` místo ``?no-ids=true``).
Zdroje: novinky desktopové aplikace ve verzích 2021.6.0, 2023.1.0, 2023.6,
2026.6.0, 2026.7.0 a 2026.7.1 na `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/collections/2551642-verze-desktopove-aplikace>`_.

.. list-table::
   :header-rows: 1
   :widths: 24 12 64

   * - Parametr
     - Od verze
     - Význam
   * - ``no-comments``
     - 2021.6.0
     - Potlačí komentáře v XML výstupu.
   * - ``mode=simple``
     - 2021.6.0
     - Minimalistický export bez atributů ``ref`` a ``showAs`` (v XML i bez
       vysvětlujících komentářů). Neplatná hodnota ``mode`` vrací od 2026.7.0
       chybu ``400`` s výčtem povolených hodnot (dříve ``500``).
   * - ``access-attribs=true``
     - 2023.6
     - U kolekcí vypíše atribut ``insertable`` — zda je možné do kolekce
       vložit novou položku.
   * - ``as-gui=true``
     - 2023.1.0
     - Uživatelsky přívětivější chybová hlášení. Od 2026.7.0 vrací odpověď na
       uložení doklad i položky tak, jak jsou uložené v databázi (včetně
       ceny po přecenění). Od 2026.7.1 vrací při odmítnutí uložení databází
       chybu ``400`` s hláškou místo ``500``.
   * - ``no-order=true``
     - 2026.6.0
     - Vypne výchozí řazení záznamů (záznamy přijdou v pořadí databáze) —
       pro rychlé čtení velkých kolekcí. Nelze kombinovat s ``order``,
       ``sort`` ani ``start``.
   * - ``only-issues=true``
     - 2026.7.0
     - Jen u ``PUT``/``POST``: ``results`` obsahuje jen záznamy s chybou,
       varováním nebo nezodpovězenou otázkou. Užitečné u velkých importů.

Filtr podle vyplněnosti štítků (od 2026.6.0):

.. code-block:: text

   stitky is empty
   stitky is not empty

Funguje i přes relaci, např. ``dodavatel.stitky is empty``.

Import s ``if-not-found=create`` (včetně importu z Excelu) od 2026.6.5 zakládá
chybějící záznam s kódem podle pravidel dané evidence; dříve se kód zkrátil
na délku kódu importovaného dokladu.

Přílohy souvisejících objektů už nejsou součástí detailu ``full`` (od
2026.6.0); použijte ``detail=custom``. Parametr ``relations=prilohy``
funguje beze změny.
