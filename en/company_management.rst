Company management
========================

Creating a company
------------------------

.. code-block:: text

   PUT /admin/zalozeni-firmy

URL parameters:

.. list-table::
   :header-rows: 1
   :widths: 25 55

   * - Parameter
     - Description
   * - ``name=Company``
     - **required**, display name of the new company
   * - ``use-demo=true``
     - seed with demo data (CZ + PODNIKATELE+PU combination only)
   * - ``country=CZ`` / ``SK``
     - legislation
   * - ``org-type=``
     - organization type — for CZ: ``PODNIKATELE+PU`` (double-entry
       bookkeeping), ``PODNIKATELE+DE`` (tax records), ``NEZISKOVE``
       (non-profit), ``ROZPOCTOVE`` (budgetary org); for SK: ``PODNIKATELIA+PU``
   * - ``ic=``
     - company registration number — auto-fills more fields (VAT payer
       status, registered seat, file reference, ...) from the ARES registry
   * - ``vatid=``
     - VAT ID

Success: 201, new company URL in the ``Location`` header.

Restoring from backup
--------------------------

Backup: ``GET /c/{db_name}/backup`` (``Accept: application/x-winstrom-backup``
or ``application/octet-stream``).

Restore: ``PUT /c/{db_name}/restore?name=Company`` — body = raw backup file
bytes; the target company must **not** already exist (else "Company
'restored_company' already exists").

Test-mode restore (``&forTesting=1``) — flags (each enabled=1 by default
unless explicitly set to 0): ``disableEet`` (turn off EET reporting),
``disableAutoSendMail`` (turn off auto document emailing), ``disableWebHooks``
(deregister all webhooks), ``skipZurnal`` (don't restore change history),
``skipChangelog`` (don't restore Changes API history).

.. code-block:: text

   PUT /c/db_name/restore?name=Company&forTesting=1&disableAutoSendMail=0&skipZurnal

Company identifier and listing companies
-----------------------------------------------

See :doc:`identifiers` — "Company identifier" section.

Company settings
---------------------

A dedicated evidence ``/nastaveni`` (Company > Settings in the app).

.. code-block:: text

   GET /c/{company}/nastaveni.xml?detail=full

Returns **multiple** ``<nastaveni>`` records — settings are versioned by
effective date (like a changelog), not a single row.

To add a new settings version effective from a date, reference the version
it's based on via ``<puvodniNastaveni><id>1</id></puvodniNastaveni>`` and
``<platiOdData>...</platiOdData>``; unlisted fields stay the same as the
referenced version:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <nastaveni>
            <puvodniNastaveni><id>1</id></puvodniNastaveni>
            <platiOdData>2021-12-29</platiOdData>
            <uliceNazev>Relocated Street</uliceNazev>
          </nastaveni>
     - .. code-block:: json

          {
              "winstrom": {
                  "nastaveni": [
                      {
                          "puvodniNastaveni": {"id": "1"},
                          "platiOdData": "2021-12-29",
                          "uliceNazev": "Relocated Street"
                      }
                  ]
              }
          }

To insert a new *earliest* settings version before the current first one,
use ``prvniNastaveni=true`` + ``prvniNastaveniPlatiDoData=`` (end date for
the new first version; the app auto-sets this as the existing first
version's new ``platiOdData``), nested inside ``puvodniNastaveni``.

.. note::

   Example URLs in the official documentation for this section use a
   ``/v2/c/{company}/...`` prefix instead of the usual ``/c/{company}/...``
   — likely a newer/alternate API version path; not otherwise documented
   elsewhere.
