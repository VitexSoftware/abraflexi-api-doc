Document copy, printed reports and QR codes
==================================================

Copying a document
------------------------

The server can copy a document directly (more efficient and reliable than
loading the full record client-side and re-inserting it) — via the
``sourceId`` attribute on the new element:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <skladovy-pohyb sourceId="1179">
              <datVyst>2022-09-11</datVyst>
            </skladovy-pohyb>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "skladovy-pohyb": [
                      {
                          "@sourceId": "1179",
                          "datVyst": "2022-09-11"
                      }
                  ]
              }
          }

``sourceId`` is the id of the record to copy; any other fields given (here
``datVyst``) override the copy's values.

Printed report export (PDF / XLSX)
----------------------------------------

.. code-block:: text

   /c/<company>/<evidence>.pdf                     — report over the whole listing
   /c/<company>/<evidence>/<ID>.pdf                 — report for one record
   /c/<company>/<evidence>.xls
   /c/<company>/<evidence>/<ID>.xls

Specific report: ``?report-name=...``. Report language: ``?report-lang=``
(``cs``, ``sk``, ``en``, ``de``). Electronic signature (requires exactly one
certificate stored in AbraFlexi): ``?report-sign=true``.

.. code-block:: text

   /c/company/faktura-vydana/1.pdf?report-name=dodaciList
   /c/company/faktura-vydana/1.pdf?report-name=dodaciList&report-lang=en
   /c/company/faktura-vydana/1.pdf?report-name=dodaciList&report-sign=true

Discover a given evidence's supported reports:
``GET /c/{company}/{evidence}/reports`` — output includes ``reportId``
(value to use for ``report-name``), ``reportName`` (localized name),
``isDefault``, ``predvybranyPocet`` (1 or N — single-record vs. overview
report), ``rozsiritelna`` (does an extended version exist?), ``sumovana``
(supports summation?).

ISDOC.PDF format: PDF outputs of invoices (non-listing type) implicitly
embed the ISDOC document, which can be used to re-import invoices from ISDOC.

QR code
-----------

A standard approved by the Czech Banking Association, readable by most
Czech banks' mobile apps directly from a screen. Supported for both issued
documents (payment TO the company) and received documents (payment BY the
company); **CZ payments only** (any currency).

.. code-block:: text

   GET /c/<company>/<evidence>/<ID>/qrcode.png?size=200

``size`` is 1–1500 px; the server adds a quiet-zone margin for clean
black/white contrast.
