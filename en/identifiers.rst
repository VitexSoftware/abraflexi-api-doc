Identifiers and data types
================================

Record identifiers
-----------------------

.. list-table::
   :header-rows: 1
   :widths: 20 15 45

   * - Name
     - Example
     - Note
   * - Internal ID
     - ``123``
     - Assigned by AbraFlexi, cannot be changed. Backed by a database
       sequence — never assigned twice (even after the record is deleted),
       but doesn't guarantee numeric continuity (a rollback discards the number).
   * - Code / abbreviation
     - ``code:CZK``
     - User-assigned label, can be changed in the app.
   * - Key (internal UUID)
     - ``key:550e8400e29b41d4a716``
     - Random identifier assigned to documents, immutable.
   * - PLU
     - ``plu:4020``
     - Identification code used at point of sale (typically a 4-5 digit number).
   * - EAN
     - ``ean:4710937332698``
     - Barcode; can also be looked up via a packaging's EAN.
   * - External identifier
     - ``ext:SHOP:123``
     - Composed of an external system identifier and that system's row
       identifier. Must be unique within the whole evidence. Cannot be
       changed from the app, only from external systems.
   * - Hybrid identifier
     - ``ws:{company UUID}:{internal ID}``
     - Behaves based on context: if the company UUID matches the target
       company, it acts as an internal ID; otherwise as an external ID.
       Activated via ``?mode=xml_import_export``.
   * - VAT ID
     - ``vatid:CZ28019920``
     - DIČ (Czechia) / IČ DPH (Slovakia).
   * - Company reg. no.
     - ``in:28019920``
     - Identifier by IČO (company registration number).
   * - IBAN
     - ``iban:CZ1201000002801992``
     - Identifier by IBAN code.

Create/update by identifier: if a non-internal identifier doesn't exist yet,
a new record is created; otherwise the existing one is updated:

.. code-block:: json

   {"winstrom": {"cenik": [{"id": "code:T100", "nazev": "Widget 100 mm"}]}}

Multiple identifiers (must all point to the same record, else it's an
error; non-existent ones are ignored — useful for incrementally attaching
identifiers from external systems):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <cenik>
            <id>123</id>
            <id>code:BOX</id>
          </cenik>
     - .. code-block:: json

          {
              "winstrom": {
                  "cenik": [
                      {
                          "id": ["123", "code:BOX"]
                      }
                  ]
              }
          }

Outside import XML (URLs, other fields), multiple identifiers are written
with a special bracket syntax: ``[123][code:CZK][ext:SHOP:abc]`` (the
characters ``[``, ``]``, ``,`` inside an identifier must be backslash-escaped
and the whole thing URL-encoded).

Incrementally attaching further external identifiers to an existing record:

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

          {
              "winstrom": {
                  "cenik": [
                      {
                          "id": ["123", "ext:SHOP:abc", "ext:SYSTEM3:xyz"]
                      }
                  ]
              }
          }

In JSON, a combined single-string form is also valid:
``"cenik": "[code:NIKON][123][ext:SHOP:abc]"``.

Removing external identifiers: the ``removeExternalIds`` attribute on the
evidence element, whose value is the prefix of identifiers to remove (empty
string = remove all; the ``ext:`` prefix itself doesn't need to be included
in the value):

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

          {
              "winstrom": {
                  "cenik": [
                      {
                          "@removeExternalIds": "SYSTEM",
                          "id": ["123", "ext:SHOP:123"]
                      }
                  ]
              }
          }

For document line items, ``removeExternalIds`` can be given once for all
items, or on a specific item (which takes precedence).

Filtering by external id:

.. code-block:: text

   /c/company/faktura-vydana/(id=='ext:EXTERNAL_ID')

Supported data types
-------------------------

Used for export/import and filtering.

.. list-table::
   :header-rows: 1
   :widths: 15 15 40 20

   * - Type
     - Name
     - Note
     - Example
   * - ``string``
     - Text
     - Unicode encoding, any character.
     - ``crazy little horse``
   * - ``integer``
     - Whole number
     - No spaces; signed 4-byte int, per-field range may be narrower.
     - ``12``
   * - ``numeric``
     - Decimal
     - No spaces, ``.`` decimal separator; 8-byte double.
     - ``12.5``
   * - ``date``
     - Date
     - ``YYYY-MM-DD``, optional (ignored) timezone. Filters must omit the timezone.
     - ``2015-01-30``
   * - ``datetime``
     - Date + time
     - ``YYYY-MM-DD'T'HH:MM:SS.SSS``, optional (ignored) timezone.
     - ``2008-09-01T17:18:14.075+02:00``
   * - ``logic``
     - Boolean
     - ``true`` / ``false``
     -
   * - ``select``
     - Enum
     - One value from a fixed set, represented as a string.
     - ``typVztahu.odberDodav``
   * - ``relation``
     - Link to another evidence
     - Value is any supported identifier.
     - ``123``, ``code:CZK``

Company identifier
-----------------------

The company identifier (``dbNazev``, used as ``{company}`` in every
``/c/{company}/...`` URL) is derived from the company name at creation time:
lowercase letters, digits and underscore only, other characters replaced
with ``_``; on a collision a numeric suffix is appended. It stays stable
across renames; a deleted company's identifier may be reused by a new
company.

List all companies on the server (no need to know a specific company
identifier upfront, just server-level auth):

.. code-block:: text

   GET /c.json?limit=0

Response fields: ``dbNazev`` (identifier), ``nazev`` (display name), ``id``,
``createDt``, ``licenseGroup``, ``show`` (visible), ``watchingChanges``
(Changes API on/off), ``stavEnum``: ``ESTABLISHING`` | ``ESTABLISHED`` |
``MAINTENANCE``.
