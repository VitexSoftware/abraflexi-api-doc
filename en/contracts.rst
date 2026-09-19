Contracts
=========

Customer and supplier contracts drive automatic invoicing at regular (or
irregular) intervals. Via the REST API you can create contracts, generate
invoices from them, and valorize them. Source: `podpora.flexibee.eu
<https://podpora.flexibee.eu/en/articles/7924365-api-agreements>`_.

Calling
-------

``PUT`` or ``POST``; XML and JSON. Customer contracts live in ``smlouva``,
supplier contracts in ``dodavatelska-smlouva``:

.. code-block:: text

   POST /c/{company}/smlouva.xml
   POST /c/{company}/dodavatelska-smlouva.json

Related evidences
-----------------

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Evidence
     - Purpose
   * - ``typ-smlouvy``, ``dodavatelsky-typ-smlouvy``
     - Contract type templates (like document types).
   * - ``stav-smlouvy``
     - Custom contract statuses.
   * - ``smlouva-polozka``
     - Contract line items — at least one is required for invoice
       generation (what to invoice, frequency, generation date).
   * - ``smlouva-zurnal``
     - History of invoice generation from contracts.

.. warning::

   ``smlouva-polozka`` cannot be imported standalone — without a contract
   header the request returns ``400`` with ``importNotAllowed``. Nest items
   inside the contract on create or update.

Required fields
---------------

Contract header: ``kod`` (max 20), ``nazev`` (max 255), ``smlouvaOd``,
``typSml``, ``firma``. Item: ``kod`` and ``nazev`` — or link ``cenik`` and
they are taken from the price list.

Other fields (frequency, cycle day/month, invoicing method, …) are optional
for import but must be set correctly for invoicing to work.

.. warning::

   Flexi does **not** validate optional values such as ``frekFakt``, ``den``
   or ``mesic``. Nonsense values (e.g. ``frekFakt: 121``, ``mesic: 13``) are
   accepted and then prevent invoice generation.

Sample calls
------------

Customer contract (XML):

.. code-block:: xml

   <winstrom>
     <smlouva>
       <kod>INTERNETROK23</kod>
       <nazev>Internet na rok výhodně</nazev>
       <smlouvaOd>2023-03-01</smlouvaOd>
       <typSml>code:SMLOUVA</typSml>
       <firma>code:ABRA</firma>
     </smlouva>
   </winstrom>

Supplier contract with items (JSON):

.. code-block:: json

   {
       "winstrom": {
           "dodavatelska-smlouva": {
               "kod": "INTERNETROK23",
               "nazev": "Internet na rok výhodně",
               "smlouvaOd": "2023-03-01",
               "typSml": "code:SMLOUVA",
               "firma": "code:ABRA",
               "frekFakt": 12,
               "den": 31,
               "mesic": 1,
               "zpusFaktK": "zpusobFakt.dopredu",
               "typDoklFak": "code:FAKTURA",
               "polozkySmlouvy": {
                   "smlouva-polozka": [
                       {"kod": "INTERNET2023", "nazev": "Internet výhodně 2023"},
                       {"cenik": "code:KONZULTACE"}
                   ]
               }
           }
       }
   }

``zpusFaktK``: ``zpusobFakt.dopredu`` (in advance) or ``zpusobFakt.zpetne``
(in arrears). Success returns **201 Created**.

Finding invoices generated from a contract
------------------------------------------

Filter issued invoices by ``smlouva`` (or by ``cisSml`` text):

.. code-block:: text

   GET /c/{company}/faktura-vydana/(smlouva='code:45644').json

Generation history is in ``smlouva-zurnal``.
