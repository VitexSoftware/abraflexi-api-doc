Price list tree
===============

The price list tree is a hierarchy of categories into which price-list
items are assigned. It can be managed via the REST API by both reading
and importing. Source: `podpora.flexibee.eu
<https://podpora.flexibee.eu/en/articles/5615241-price-list-tree-via-rest-api>`_.

.. warning::

   Import into the price list tree is **NOT_DOCUMENTED** — it is
   supported, but it is not part of the official documentation and we
   do not recommend relying on it. It is not fully implemented; for
   example, a tree node can only be identified by its numeric ID, not
   by code.

Tree evidences
--------------

The tree is described by three evidences:

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - Evidence
     - Contents
   * - ``strom``
     - Individual nodes (branches) of the tree as shown in the
       application once the tree is enabled — including level, order,
       parent node, and path.
   * - ``strom-koren``
     - The root of the tree; by default a single record ``STR_CEN`` —
       Price list tree.
   * - ``strom-cenik``
     - Assignment of price-list items to individual tree nodes.

The ``otec`` element is the previous (parent) node; ``cesta`` and
``hladina`` match the order shown in the application — the initial
Price list tree node is counted as well. Both properties are read-only;
Flexi calculates them automatically.

Creating a tree node
--------------------

A node is created with a name (``nazev``), an order (``poradi``), and
the tree it belongs to (``strom``). The order determines the position
within its category; ``strom`` is the tree root and ``otec`` is the
parent node. Path and level are calculated automatically.

.. code-block:: text

   POST /c/{company}/strom.json

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <strom>
              <kod>TELKREM</kod>
              <nazev>Tělové krémy</nazev>
              <poradi>1</poradi>
              <strom>code:STR_CEN</strom>
              <otec>code:KREMY</otec>
            </strom>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "@version": "1.0",
                  "strom": [{
                      "kod": "TELKREM",
                      "nazev": "Tělové krémy",
                      "poradi": "1",
                      "strom": "code:STR_CEN",
                      "otec": "code:KREMY"
                  }]
              }
          }

.. note::

   In the ``strom`` and ``otec`` elements, a node can be addressed by
   code (``code:…``) or by numeric ID. Nodes without a short code —
   for example the system nodes *Assigned items* and *Unassigned
   items* — can only be addressed by ID.

Assigning a price-list item to the tree
---------------------------------------

The assignment is imported into the ``strom-cenik`` evidence. You can
specify the price-list item (``idZaznamu``) by ID or code, but the node
(``uzel``) only by numeric ID, obtained by querying ``/strom``.

.. code-block:: text

   POST /c/{company}/strom-cenik.json

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <strom-cenik>
              <!-- idZaznamu = ID or code of the price-list item -->
              <idZaznamu>code:TELKREM ABC 500</idZaznamu>
              <!-- uzel = numeric node ID from /strom -->
              <uzel>4</uzel>
            </strom-cenik>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "@version": "1.0",
                  "strom-cenik": [{
                      "idZaznamu": "code:TELKREM ABC 500",
                      "uzel": "4"
                  }]
              }
          }

After the import, the assigned item ``TELKREM ABC 500`` appears in the
node with ID 4.

.. warning::

   Watch out for the asymmetry between reading and writing: when
   reading, the API returns ``uzel`` as a code (for example
   ``code:A-I``), but you cannot send that value back — the import
   rejects it with ``400`` and code ``neniKodNeboNemuzeBytID`` (Entity
   'Node' does not contain a code or it cannot be used as an ID). Use
   the value from ``uzel@ref``, which holds the numeric ID.

A non-existent price-list item is rejected with ``400`` and code
``formZaznamNenalezen``.

Filtering price-list items by tree membership uses the ``in subtree``
operator — see :doc:`listing_filtering`.

Moving a tree branch
--------------------

To move a branch, change ``otec`` of an existing node to the new parent
category and ``poradi`` to the desired position — for example ``99`` to
place it at the end.

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <strom>
              <id>code:PANSKEKREMY</id>
              <poradi>99</poradi>
              <otec>code:TELKREMY</otec>
            </strom>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "@version": "1.0",
                  "strom": [{
                      "id": "code:PANSKEKREMY",
                      "poradi": "99",
                      "otec": "code:TELKREMY"
                  }]
              }
          }

This moves the entire ``PANSKEKREMY`` category, including its
subcategories and assigned items, into ``TELKREMY`` — it does not copy
it. Level and path are recalculated automatically.
