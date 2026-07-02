Actions and locking
========================

Performing actions
-----------------------

Instead of an ordinary create/update, an action can be triggered on a
record via the ``action`` attribute (body-level, not a different HTTP
method):

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

          {
              "winstrom": {
                  "faktura-vydana": [
                      {
                          "@action": "delete",
                          "id": ["123", "uuid:123456"]
                      }
                  ]
              }
          }

.. list-table::
   :header-rows: 1
   :widths: 20 60

   * - Action
     - Description
   * - ``delete``
     - The record will be deleted.
   * - ``storno``
     - The record will be cancelled (documents only).
   * - ``lock``
     - The record will be locked.
   * - ``unlock``
     - The record will be unlocked.
   * - ``lock-for-ucetni``
     - The record will be locked for the accountant.

When performing actions, records aren't otherwise modified, so there's no
point listing elements other than ``id``; records must already exist.

Actions can also be triggered **in bulk** over a group of records via the
``filter`` attribute on the evidence (see :doc:`batch_transactions`):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <faktura-vydana action="lock" filter="stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"/>
     - .. code-block:: json

          {
              "winstrom": {
                  "faktura-vydana": [
                      {
                          "@action": "lock",
                          "@filter": "stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"
                      }
                  ]
              }
          }

Actions on document line items (must nest through the parent document's
item collection):

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

          {
              "winstrom": {
                  "faktura-vydana": [
                      {
                          "id": "123",
                          "polozkyFaktury": [
                              {
                                  "id": "456",
                                  "@action": "delete"
                              }
                          ]
                      }
                  ]
              }
          }

Difference between ``action="delete"`` and the DELETE method
--------------------------------------------------------------------

Functionally almost identical; they differ in pre-checks:

- ``action="delete"`` allows deleting documents even in a non-current
  accounting period; ``DELETE`` does not ("No permission" error).
- ``action="delete"`` works almost everywhere, except on users and
  standard/built-in overview-type records.
- ``action="delete"`` is "safely usable": depending on relation type it
  will cascade-delete dependent records, unlink relations, or refuse the
  operation; in rare cases a database trigger can still abort the transaction.

Record locking
-------------------

Same mechanism as general actions (see above):

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

          {
              "winstrom": {
                  "faktura-vydana": [
                      {"@action": "lock", "id": "1"},
                      {"@action": "lock-for-ucetni", "id": "1"},
                      {"@action": "unlock", "id": "1"}
                  ]
              }
          }

In bulk via filter:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <faktura-vydana action="lock" filter="stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"/>
     - .. code-block:: json

          {
              "winstrom": {
                  "faktura-vydana": [
                      {
                          "@action": "lock",
                          "@filter": "stavUhrK = 'stavUhr.uhrazeno' and typDokl = 'code:INTERNET'"
                      }
                  ]
              }
          }

Accounting period locks
----------------------------

Distinct from locking individual records — a dedicated evidence
``/c/{company}/zamek``.

Reading: ``GET /c/{company}/zamek.xml?detail=full&limit=0``. Key fields:

- ``zamekK`` — lock type: ``zamek.otevreno`` (open) / ``zamek.polozamceno``
  (locked except accounting) / ``zamek.zamceno`` (locked).
- ``platiOdData`` / ``platiDoData`` — date range.
- ``neucetni`` — whether to also lock non-accounting documents (default ``true``).
- One boolean flag per module (see below).

Setting a lock: ``POST /c/{company}/zamek.xml`` with required ``zamekK``,
``platiOdData``, ``platiDoData``, and **at least one** module flag set
``true`` (otherwise nothing is locked):

``modulFav`` (issued inv.), ``modulFap`` (received inv.), ``modulPhl``
(other receivables), ``modulZav`` (other payables), ``modulBan`` (bank),
``modulPok`` (cash), ``modulInt`` (internal docs), ``modulSkl`` (warehouse),
``modulPpp``/``modulPpv`` (demands recv/issued), ``modulNap``/``modulNav``
(offers recv/issued), ``modulObp``/``modulObv`` (orders recv/issued),
``modulMaj`` (assets), ``modulLea`` (leasing), ``modulMzd`` (payroll).

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

          {
              "winstrom": {
                  "zamek": [
                      {
                          "zamekK": "zamek.zamceno",
                          "platiOdData": "2022-01-01",
                          "platiDoData": "2022-01-15",
                          "modulFap": "true"
                      }
                  ]
              }
          }

Deleting a lock: ``<zamek action="delete"><id>6</id></zamek>``.

.. warning::

   Deleting a period lock does **NOT unlock individual documents** that
   were locked while it was active! Those must be unlocked separately
   (``action="unlock"``).
