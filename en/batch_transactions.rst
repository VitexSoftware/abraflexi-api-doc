Batch operations and transactions
========================================

Batch operations (filter instead of an id list)
------------------------------------------------------

A single element can update, or trigger an action on, many records at once
via the ``filter`` attribute at the evidence level — the filter language is
the same as URL filters (see :doc:`listing_filtering`):

.. code-block:: xml

   <winstrom version="1.0">
     <cenik filter="dodavatel = 'code:FIRMA'">
       <stitky>VIP</stitky>
     </cenik>
   </winstrom>

Adds the VIP label to every price-list item supplied by FIRMA. Behaves as
if, instead of the one element with ``filter``, one element were given per
matching record — with the difference that ``id`` elements are completely
ignored in batch operations.

In JSON:

.. code-block:: json

   {
     "winstrom": {
       "faktura-vydana": {
         "@filter": "stitky='code:OVERENO'",
         "@action": "lock"
       }
     }
   }

This example triggers the ``lock`` action on every issued invoice tagged
with the OVERENO label (see :doc:`actions_locking`).

Transactional processing
-----------------------------

By default, a whole import is a single database transaction — either
everything is saved, or nothing is.

.. code-block:: xml

   <winstrom version="1.0" atomic="false">
     <faktura-vydana><id>code:123</id>...</faktura-vydana>
     <faktura-vydana><id>code:456</id>...</faktura-vydana>
   </winstrom>

With ``atomic="false"``, each *top-level* record is imported in its own
transaction (in the example above, two transactions occur, one for invoice
123 and one for 456; line items are part of the same transaction as their
parent document).

Benefit: for large imports with many records, a single transaction takes a
long time and holds a lot of data in memory — both hurt performance. If
it's acceptable for an individual record's save to fail (e.g. the import
runs periodically, or issues can be fixed manually), ``atomic="false"`` can
significantly reduce the import's memory footprint (and, for very large
imports, time — due to garbage collection pressure).
