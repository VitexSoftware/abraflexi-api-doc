Building requests
=====================

URL structure
-----------------

.. code-block:: text

   /c/<company identifier>/<evidence>/<record ID>.<output format>

- ``<company identifier>`` — unique identification of the company on the
  server (see :doc:`company_management`).
- ``<evidence>`` — evidence type (adresar, faktura-vydana, ...); the full
  list is in the web UI under "Evidence list", or the Changes API endpoint
  catalogue (:doc:`changes_api`).
- ``<record ID>`` — any supported identifier (see :doc:`identifiers`); if
  omitted, this is a listing of the whole evidence.
- ``<output format>`` — optional extension; if omitted, the ``Accept``
  header decides, otherwise HTML is returned. The extension takes
  precedence over ``Accept``. The input format (on writes) is primarily
  determined by ``Content-Type``.

Prefixes other than ``/c/``: ``/a/``, ``/u/`` (server users), ``/g/``,
``/admin/`` (administration, incl. company creation), ``/status/``
(incl. logging out users), ``/login-logout/`` (authentication).

Listing and summation
--------------------------

.. code-block:: text

   /c/<company>/<evidence>                     — listing
   /c/<company>/<evidence>/(<filter>)          — filtered listing
   /c/<company>/<evidence>/$sum                — summation
   /c/<company>/<evidence>/(<filter>)/$sum     — filtered summation
   /c/<company>/<evidence>/properties          — supported field overview
   /c/<company>/<evidence>/reports             — printable reports overview (PDF)
   /c/<company>/<evidence>/relations           — sub-evidence (relation) overview

Supported formats
----------------------

.. list-table::
   :header-rows: 1
   :widths: 12 30 18 25 10

   * - Format
     - Note
     - Extension
     - Content-Type
     - Import?
   * - HTML
     - browser display page
     - ``.html``
     - ``text/html``
     - no
   * - XML
     - machine-readable structure
     - ``.xml``
     - ``application/xml``
     - yes
   * - JSON
     - machine-readable structure
     - ``.js`` / ``.json``
     - ``text/javascript`` / ``application/json``
     - yes
   * - CSV
     - tabular output
     - ``.csv`` (``?encoding=iso-8859-2``)
     - ``text/csv``
     - yes
   * - DBF
     - database output (dBase)
     - ``.dbf``
     - ``application/dbf``
     - yes
   * - XLS
     - tabular output (Excel)
     - ``.xls``
     - ``application/ms-excel``
     - yes
   * - ISDOC
     - e-invoicing; params ``?typDokl=code:...&typUcOp=code:...``
     - ``.isdoc`` / ``.isdocx``
     - ``application/x-isdoc(x)``
     - yes
   * - EDI
     - INHOUSE format
     - ``.edi``
     - ``application/x-edi-inhouse``
     - yes
   * - PDF
     - print report (see :doc:`copy_reports_qr`)
     - ``.pdf?report-name=...``
     - ``application/pdf``
     - no
   * - vCard
     - electronic business card (address book)
     - ``.vcf``
     - ``text/vcard``
     - no
   * - iCalendar
     - export of events/due dates
     - ``.ical``
     - ``text/calendar``
     - no

This guide focuses on JSON from here on.

HTTP operations
--------------------

- **GET** — reading (listing or detail), respects the output format.
- **DELETE** — deletes a single record at its detail URL. Returns 404 if the
  record doesn't exist, otherwise 200. Bulk deletion must go through
  ``action="delete"`` (see :doc:`actions_locking`) — there is no bulk DELETE
  on a listing URL.
- **POST / PUT** — AbraFlexi doesn't distinguish between them; both create
  and update depending on content and target URL:

  - On a listing URL: records are created or updated depending on whether
    their identifier was found. A record with an AbraFlexi-assigned
    internal ID must already exist; a record identified another way (e.g.
    external id) that doesn't exist yet gets created.
  - On a detail URL (with ID): the body doesn't need an identifier, it's
    taken from the URL; the record must already exist.
  - The request body must be XML or JSON, not form data
    (``multipart/form-data``) — except for binary attachment uploads
    (see :doc:`attachments`).

- The identifier of a newly created record is returned both via the
  ``Location`` header (``https://server/c/demo/faktura-vydana/105``) and in
  the response body (``<result><id>105</id></result>``).

See :doc:`authentication` for access rights.

Performance optimization
-----------------------------

- The first request after server startup takes noticeably longer (JIT
  warmup of the accounting core, up to ~20s); subsequent ones are fast, but
  it's still worth letting the server "warm up".
- Always send credentials upfront, don't wait for a 401 round-trip.
- Use ``?detail=custom:...`` and only list the fields you actually need
  (see :doc:`listing_filtering`).
- If you don't need external identifiers, turn them off with
  ``?no-ext-ids=true``.
- Don't use ``?relations=all`` — only list the relations you really need.
- Don't call the same URL repeatedly within one processing run.
- If you only need a count, use ``?add-row-count=true`` instead of loading
  everything.
- Batch similar requests into one call (e.g. via bulk-id lookups or
  ``/query``, see :doc:`listing_filtering`).
- Hardware: DB and server on the same machine, sufficient RAM, tuned
  PostgreSQL, faster disks, more CPUs.

Test save (dry-run)
------------------------

To validate data without actually saving it, add ``?dry-run=true``. The
record is not saved, but validation runs and the response includes the
resulting representation the record would have if saved (including a
temporarily-assigned, immediately-released ID) plus any ``warnings``.
Available in both JSON and XML. Combines with the "previous value"
mechanism (see :doc:`writing_data`) when building interactive edit forms.

Additional URL parameters
-------------------------

Boolean parameters can also be written without a value (``?no-ids`` instead
of ``?no-ids=true``). Sources: ABRA Flexi desktop release notes for versions
2021.6.0, 2023.1.0, 2023.6, 2026.6.0, 2026.7.0 and 2026.7.1 at
`podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/collections/2551642-verze-desktopove-aplikace>`_
(in Czech).

.. list-table::
   :header-rows: 1
   :widths: 24 12 64

   * - Parameter
     - Since
     - Meaning
   * - ``no-comments``
     - 2021.6.0
     - Suppresses comments in the XML output.
   * - ``mode=simple``
     - 2021.6.0
     - Minimal export without the ``ref`` and ``showAs`` attributes (and,
       in XML, without explanatory comments). Since 2026.7.0 an invalid
       ``mode`` value returns ``400`` listing the allowed values (previously
       ``500``).
   * - ``access-attribs=true``
     - 2023.6
     - For collections, outputs the ``insertable`` attribute — whether a new
       item can be added to the collection.
   * - ``as-gui=true``
     - 2023.1.0
     - More user-friendly error messages. Since 2026.7.0 the response to a
       save returns the document and items as stored in the database
       (including the price after revaluation). Since 2026.7.1, when the
       database rejects the save, it returns ``400`` with a message instead
       of ``500``.
   * - ``no-order=true``
     - 2026.6.0
     - Disables the default record ordering (records come back in database
       order) — for fast reads of large collections. Cannot be combined with
       ``order``, ``sort`` or ``start``.
   * - ``only-issues=true``
     - 2026.7.0
     - ``PUT``/``POST`` only: ``results`` contains only records with an
       error, a warning or an unanswered question. Useful for large imports.

Filter by label presence (since 2026.6.0):

.. code-block:: text

   stitky is empty
   stitky is not empty

It also works through a relation, e.g. ``dodavatel.stitky is empty``.

Since 2026.6.5, import with ``if-not-found=create`` (including Excel import)
creates the missing record with a code following the rules of the target
evidence; previously the code was truncated to the length of the imported
document's code.

Attachments of related objects are no longer part of the ``full`` detail
(since 2026.6.0); use ``detail=custom``. The ``relations=prilohy`` parameter
works unchanged.
