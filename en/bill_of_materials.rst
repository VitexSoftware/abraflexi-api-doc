Bill of materials (BOM)
=======================

The bill of materials (``kusovnik``) sets the content and structure of
materials that make up a product or semi-finished product. Source:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/en/articles/10838022-bill-of-materials-api>`_.

.. warning::

   Available from the **Premium** licence plan. On lower plans the
   ``/kusovnik`` endpoint is not usable.

Creating a bill of materials
----------------------------

``POST`` or ``PUT`` on ``/c/{company}/kusovnik``. One record is always either
the BOM **header** (product / semi-finished product) or a single **material
row** (node) under that header. You describe the structure yourself —
Flexi does not compute it:

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - Property
     - Meaning
   * - ``mnoz``
     - Quantity consumed into the parent product.
   * - ``hladina``
     - Level in the BOM — header is ``1``, materials under it ``2``, etc.
   * - ``poradi``
     - Row order within its level.
   * - ``cesta``
     - Node path in the structure, e.g. ``1/2/``.
   * - ``otecCenik``
     - Price-list item of the product the whole BOM belongs to — same on
       the header and all rows.
   * - ``cenik``
     - Price-list item of this row. On the header it matches ``otecCenik``.
   * - ``otec``
     - Parent BOM row. Empty on the header.

Other evidence fields (e.g. ``nazev``) are optional. Link rows with
``ext:`` identifiers when numeric IDs are not yet known.

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <kusovnik>
              <id>ext:KUS:1</id>
              <mnoz>1.0</mnoz>
              <hladina>1</hladina>
              <poradi>1</poradi>
              <cesta>1/</cesta>
              <otecCenik>code:PŘEDNÍ_KOLO</otecCenik>
              <cenik>code:PŘEDNÍ_KOLO</cenik>
              <otec></otec>
            </kusovnik>
            <kusovnik>
              <id>ext:KUS:2</id>
              <mnoz>1.0</mnoz>
              <hladina>2</hladina>
              <poradi>1</poradi>
              <cesta>1/1/</cesta>
              <otecCenik>code:PŘEDNÍ_KOLO</otecCenik>
              <cenik>code:RÁFEK</cenik>
              <otec>ext:KUS:1</otec>
            </kusovnik>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "@version": "1.0",
                  "kusovnik": [
                      {
                          "id": "ext:KUS:1",
                          "mnoz": "1.0",
                          "hladina": "1",
                          "poradi": "1",
                          "cesta": "1/",
                          "otecCenik": "code:PŘEDNÍ_KOLO",
                          "cenik": "code:PŘEDNÍ_KOLO",
                          "otec": ""
                      },
                      {
                          "id": "ext:KUS:2",
                          "mnoz": "1.0",
                          "hladina": "2",
                          "poradi": "1",
                          "cesta": "1/1/",
                          "otecCenik": "code:PŘEDNÍ_KOLO",
                          "cenik": "code:RÁFEK",
                          "otec": "ext:KUS:1"
                      }
                  ]
              }
          }

Retrieving a bill of materials
------------------------------

.. code-block:: text

   GET /c/{company}/kusovnik/(otecCenik='code:PŘEDNÍ_KOLO').json?detail=full

Filtering, detail level and other standard listing parameters apply.

Recalculating BOM prices
------------------------

Product value can be recalculated from material/service prices configured
in the BOM — see the official recalculation article. Automatic updates are
currently API-only (periodic ``POST``/``PUT`` to that recalculation URL).

Deleting uses ``action="delete"`` — see :doc:`actions_locking`.
