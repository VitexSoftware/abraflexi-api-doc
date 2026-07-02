Changes API
===========

Company-wide changes
------------------------

When the Changes API is enabled, AbraFlexi records every create/update/delete
operation across evidences into a changelog, under a monotonically
increasing global version number — ideal for incremental synchronization of
external systems (unlike just polling ``lastUpdate``), and the basis for Web Hooks.

Version numbers may not be strictly contiguous (technical reasons can leave
gaps), but are always unique and increasing.

The license must have the REST API active at least for reading (standard on
new paid licenses).

Checking/toggling status (web UI): ``/c/{company}/changes/control``.

Programmatically:

.. code-block:: text

   PUT or POST /c/{company}/changes/enable.xml
   PUT or POST /c/{company}/changes/disable.xml
   GET  /c/{company}/changes/status.xml     — returns true/false

Without an active REST API for read/write, this returns 403 Forbidden.

.. code-block:: bash

   curl -k -L -u user:password -X PUT https://server:5434/c/company/changes/enable.xml -H Content-Length:0

Getting the current global version
----------------------------------------

Any export can include the current global version via
``?add-global-version=true``:

.. code-block:: xml

   <winstrom version="1.0" globalVersion="6">...</winstrom>

Getting change records
---------------------------

.. code-block:: text

   GET /c/{company}/changes.xml

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

Each element carries the numeric ``<id>`` and code (``<id>code:CODE</id>``);
if the object had any external ids at the time of the operation, those are
listed too (``<id>ext:...</id>``). Attributes: ``in-version`` (version the
change occurred in), ``operation`` (``create`` / ``update`` / ``delete``).
The final ``<next>`` element gives the version a subsequent listing would
continue from (``none`` if there are no further changes).

Listing parameters:

.. list-table::
   :header-rows: 1
   :widths: 25 55

   * - Parameter
     - Description
   * - ``start=123``
     - version to list from (inclusive); defaults to the start of tracked history.
   * - ``limit=500``
     - how many records to list; default 100, maximum 1000.
   * - ``evidence=faktura-vydana``
     - which evidences to list changes for; repeatable, defaults to all.

In JSON:

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

Synchronizing external systems
------------------------------------

1. **Initial load**: fetch the data you need, including the version
   (``?add-global-version=true``), store it, remember the version (from the
   ``globalVersion`` attribute).
2. **Incremental sync**: fetch changes since the last remembered version
   (``?start=``), download/apply the changed data (update or delete),
   remember the new version (from the ``next`` element, or ``globalVersion``).
3. Repeat step 2.

"could not obtain lock on relation" error
------------------------------------------------

The first time the Changes API is enabled, supporting functions get
installed into the database, which requires an exclusive lock on the whole
database. If you see ``ERROR: could not obtain lock on relation "..."``, the
fix is to log out of AbraFlexi (both web UI and the desktop client) and
retry.

Endpoints tracked by the Changes API (selection)
--------------------------------------------------------

The Changes API covers a very wide catalogue of evidences across the whole
application — address book and contacts, price list and goods, documents
(invoices, receivables, payables), bank/cash/internal documents, business
documents (offers, orders, demands), warehouse, contracts, payment orders
and payment codebooks, accounting (journal, chart of accounts, VAT, cost
centers, contracts/jobs), exchange rates, Intrastat, document series, and
settings/system evidences (users, roles, labels, user queries/relations,
filters). The most common:

``adresar``, ``kontakt``, ``cenik``, ``faktura-vydana(-polozka)``,
``faktura-prijata(-polozka)``, ``banka(-polozka)``, ``pokladni-pohyb(-polozka)``,
``interni-doklad(-polozka)``, ``objednavka-prijata/vydana(-polozka)``,
``nabidka-prijata/vydana(-polozka)``, ``poptavka-prijata/vydana(-polozka)``,
``skladovy-pohyb(-polozka)``, ``skladova-karta``, ``smlouva``,
``prikaz-k-uhrade``, ``ucetni-denik``, ``ucet``, ``stredisko``, ``zakazka``,
``mena``, ``rada``, ``nastaveni``, ``priloha``, ``uzivatel``, ``role``,
``stitek``, ``vazba``.
