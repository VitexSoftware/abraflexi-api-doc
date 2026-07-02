Listing, filtering and queries
====================================

Listing vs. detail
-----------------------

A **listing** returns multiple records — pageable, filterable, sortable,
with a selectable detail level. A **detail** always represents one specific
record.

Getting several specific records (e.g. by external id):

1. One GET per record — careful, a ``code:``/``ext:`` identifier URL
   returns a 303 redirect to the canonical numeric-id URL; the HTTP client
   must follow redirects (often needs to be enabled explicitly).
2. Filter with ``id in (...)`` — watch out for URL length limits.
3. **Bulk get-by-id** (no length limit, hundreds/thousands of ids at once):

   .. code-block:: text

      POST /c/company/faktura-vydana/get.json

   .. code-block:: json

      {"winstrom": {"id": [1, "code:2", "ext:SYS:3"]}}

   Non-existent identifiers are silently ignored; duplicate/aliased
   identifiers produce duplicate rows in the output. PUT also works.

Detail levels
-----------------

Controlled by the ``detail`` parameter (XML/JSON/XLS/CSV only, doesn't
affect other formats):

.. list-table::
   :header-rows: 1
   :widths: 20 60

   * - Value
     - Meaning
   * - ``id``
     - only the primary key + external identifiers
   * - ``summary``
     - **default for listings**: id, lastUpdate, kod, nazev etc.
   * - ``full``
     - **default for a detail**: all fields
   * - ``custom:...``
     - only the named fields (``id`` is always exported automatically)

Recommended approach: don't blanket-use ``detail=full`` (slower, more
memory); instead list just the fields you need via ``custom:``. Discover a
given evidence's available fields: ``GET /c/company/{evidence}/properties``.

``custom:`` also supports projecting into nested collections, at multiple
levels of nesting:

.. code-block:: text

   ?detail=custom:kod,sady-a-komplety(cenik,cenikSada)
   ?detail=custom:kod,sady-a-komplety(cenik(nazev),cenikSada)&includes=/cenik/sady-a-komplety/sady-a-komplety/cenik
   &includes=faktura-vydana/mistUrc/misto-urceni/kontaktOsoba&detail=custom:mistUrc(kontaktOsoba(jmeno,prijmeni,tel,mobil,email))

Unknown field names in ``custom:`` are silently ignored.

Relations and includes
---------------------------

The ``relations`` parameter (comma-separated) adds extra collections to the
output — **export only**, cannot be used for import (write directly into
the sub-table instead):

.. list-table::
   :header-rows: 1
   :widths: 20 60

   * - Code
     - Meaning
   * - ``vazby``
     - links between documents
   * - ``prilohy``
     - attachments
   * - ``sklad-karty``
     - warehouse cards (for price list items)
   * - ``polozky``
     - document line items

Example: ``/c/company/adresar?relations=vazby,prilohy``

The ``includes`` parameter expands a relation field into the full linked
object instead of just its id: ``?includes=/adresar/stat/``, multiple
separated by comma: ``includes=/adresar/stat/,/adresar/stredisko/``.

Discover a given evidence's available relations:
``GET /c/company/{evidence}/relations``.

The "missing fields" problem — why not just use detail=full
-------------------------------------------------------------------

A common mistake is to use ``detail=full`` "just in case" and then only use
a subset of fields. The fields your program actually processes are known
ahead of time — use ``detail=custom:...`` instead. Benefits: smaller
response (faster transfer), fewer SQL queries server-side (faster
response), lower client memory usage.

Pagination
--------------

.. list-table::
   :header-rows: 1
   :widths: 25 60

   * - Parameter
     - Meaning
   * - ``limit``
     - max records per page. **Default is 20!** ``limit=0`` returns ALL
       records unlimited.
   * - ``start``
     - how many records to skip; independent of ``limit``.
   * - ``add-row-count=true``
     - adds the total matching-record count to the XML/JSON output
       (respects active filters).

.. warning::

   Because the default ``limit`` is only 20, a naive listing call without
   an explicit ``limit`` can silently truncate results. Use ``limit=0`` or
   proper pagination for a complete listing.

Sorting
-----------

The ``order`` parameter (repeatable for multi-key sort):

.. code-block:: text

   ?order=nazev

.. warning::

   **Sort direction is counter-intuitive** — the letters don't match
   English intuition: ``order=nazev@A`` means **descending**,
   ``order=nazev@D`` means **ascending**. Confirmed by cross-checking the
   reference PHP library (the ``getNextRecordID``/``getPrevRecordID``
   methods only make sense with this — at first glance reversed — meaning).

Compatibility alternative: ``sort=`` + ``dir=`` (values ``ASC``/``DESC``).

Without ``order``, sorting defaults to ``id``. Exceptions: documents sort by
``datVyst`` descending first; currency rates sort by ``platiOdData``
descending then ``mena`` ascending. You can also sort by a first-level
relation property: ``?order=stredisko.nazev``.

Filtering
-------------

The filter is inserted into the URL as a parenthesized path segment (a
``filter`` query-string parameter is ignored by the server):

.. code-block:: text

   /c/company/adresar/(nazev='ACME')

Operators:

.. list-table::
   :header-rows: 1
   :widths: 25 35 20

   * - Operator
     - Meaning
     - Example
   * - ``=`` / ``==`` / ``eq``
     - equals
     - ``a = 1``
   * - ``<>`` / ``!=`` / ``ne``
     - not equal
     - ``a != 1``
   * - ``<`` / ``lt``
     - less than
     - ``a < 1``
   * - ``<=`` / ``lte``
     - less than or equal
     - ``a <= 1``
   * - ``>`` / ``gt``
     - greater than
     - ``a > 1``
   * - ``>=`` / ``gte``
     - greater than or equal
     - ``a >= 1``
   * - ``like``
     - contains
     - ``a like 'x'``
   * - ``like similar``
     - contains, accent-insensitive (PostgreSQL ≥ 9.0)
     - ``a like similar 'x'``
   * - ``between``
     - is in range
     - ``vek between 18 100``
   * - ``begins`` / ``begins similar``
     - starts with
     - ``a begins 'Win'``
   * - ``ends``
     - ends with
     - ``a ends 'x'``
   * - ``in``
     - set membership
     - ``a in (1, 2, 3)``
   * - ``in subtree`` / ``in subtree ... nonrecursive``
     - price-list tree membership
     - ``in subtree 3``
   * - ``is true`` / ``is false``
     - boolean comparison
     - ``a is true``
   * - ``is [not] null``
     - filled / empty check
     - ``a is null``
   * - ``is [not] empty``
     - empty (null/0/false/"")
     - ``a is not empty``

Combine with ``and``, ``or``, ``not``, parentheses (precedence: base
operators, then ``not``, then ``and``, lowest ``or``). Negative operators
(e.g. ``<>``) can't be used inside a relation sub-filter — use
``not(... eq ...)`` instead.

Filtering through relations (unlimited nesting depth, but only 1:1
relations):

.. code-block:: text

   firma = 'code:FIRMA'
   firma.skupFir = 'code:ODBERATEL-STANDARD'

Filtering by label: ``stitky = 'code:VIP'``.

Filtering by price-list subtree: ``in subtree 3`` (shorthand for
``id in subtree 3``); the ``nonrecursive`` modifier restricts to just that
node. Other evidences can be filtered by a related price-list item's
subtree too: ``/c/company/skladova-karta/(cenik in subtree 3)``.

Filtering document line-item fields is done directly on the line-item
evidence: ``/faktura-vydana-polozka/(doklFak=123 and cenik="code:AUTO")``.

Special values: ``now()`` (current date/time), ``currentYear()`` (current
year), ``me()`` (logged-in user) — e.g. ``datSplat < now()``,
``uzivatel = me()``.

Saved filters: the ``filtr`` evidence (``obsahFiltru``, ``beanKey`` fields),
usage: ``/c/company/cenik/(filter:2)`` (internal filter id).

Default validity filter: evidences with ``platiOd``/``platiDo`` fields are
filtered to the current accounting period by default; suppress with
``?filtrovat-platnost=false``.

Summation
-------------

.. code-block:: text

   /c/company/{evidence}/$sum
   /c/company/{evidence}/(<filter>)/$sum

Only works on documents (invoices, orders, demands, cash movements,
warehouse movements, ...). Advanced parameters (currently only for account
turnovers): ``period:(rokMesic,2020-01-01,2020-12-31)``,
``fields: obrDal,obrMd``, ``group-by: rokMesic, quarter(rokMesic)``.

The /query endpoint — filters and params in the request body
--------------------------------------------------------------------

Everything sendable via URL can also go in a POST body — useful for complex
filters (no URL length limit):

.. code-block:: text

   POST /c/{company}/{evidence}/query.json

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

Can be combined with URL params (e.g. ``?add-row-count=true&limit=100``).
Literal quotes inside the JSON ``filter`` string must be backslash-escaped.
