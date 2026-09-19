Recalculation of selling prices
=================================

The REST API can recalculate the sales price of a price-list item according
to the rules configured for it — default price, calculation method,
percentage, and rounding. The recalculation can be run on a single price-list
item, or on an entire product group; both variants have their own endpoint.
Source: `podpora.flexibee.eu
<https://podpora.flexibee.eu/en/articles/9144426-api-recalculation-of-selling-prices>`_.

Price list
----------

.. code-block:: text

   PUT /c/{company}/cenik/(filter)/prepocti-prodejni-cenu

Instead of a filter, you can specify the price-list item ID directly:

.. code-block:: text

   PUT /c/{company}/cenik/147/prepocti-prodejni-cenu

You can also use any filtering to recalculate multiple items with a single
request:

.. code-block:: text

   PUT /c/{company}/cenik/(skupZboz='code:ZBOŽÍ')/prepocti-prodejni-cenu

Product group
-------------

.. code-block:: text

   PUT /c/{company}/skupina-zbozi/(filter)/prepocti-prodejni-cenu

Recalculating a product group processes all price-list items belonging to
that group. Again, the filter can be replaced with the group ID itself:

.. code-block:: text

   PUT /c/{company}/skupina-zbozi/7/prepocti-prodejni-cenu

What the price is calculated from
---------------------------------

The recalculation does not accept any data in the request body — it is based
exclusively on the settings of the price-list item, or product group,
respectively:

.. list-table::
   :header-rows: 1
   :widths: 28 72

   * - Property
     - Meaning
   * - ``typCenyVychoziK``
     - The default price used as the calculation basis — for example
       ``typCenyVychozi.nakCena`` (purchase price).
   * - ``typVypCenyK``
     - Calculation method — ``typVypCeny.prirazka``, ``typVypCeny.rabat``,
       and others.
   * - ``procZakl``
     - Margin, markup, rebate, or discount, expressed as a percentage.
   * - ``zaokrJakK``, ``zaokrNaK``
     - The method and precision used for rounding the resulting price.

The result is written to ``cenaZakl`` (and the derived ``cenaZaklBezDph`` and
``cenaZaklVcDph``). For example, an item with a purchase price of 75 and a
markup of 100 % results in a sales price of 150.

.. note::

   If an item's default price is set to ``typCenyVychozi.zadna``, there is
   nothing to calculate from, and the recalculation leaves it unchanged.

Response and error states
-------------------------

A successful recalculation returns **HTTP 200 OK**:

.. code-block:: json

   {"winstrom": {"@version": "1.0", "success": "true"}}

.. warning::

   The response does not indicate how many records were recalculated. A
   filter that finds nothing — including a reference to a non-existent ID —
   also returns ``200`` with ``success`` ``true``. Therefore, verify the
   result by reading ``cenaZakl`` for the affected items.

.. list-table::
   :header-rows: 1
   :widths: 45 55

   * - Situation
     - Response
   * - Called using the ``GET`` or ``DELETE`` method
     - ``405 Method Not Allowed``
   * - Incorrectly written service name in the URL
     - ``404``, ``adresaNeplatnaUrl`` — The address … is not valid.
