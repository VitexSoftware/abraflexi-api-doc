Kusovník
========

Kusovníkem se ve Flexi nastavuje obsah a struktura materiálu, ze kterého
se výrobek či polotovar skládá. Zdroj: `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/10838022-kusovnik-api>`_.

.. warning::

   Kusovník je dostupný od varianty licence **Premium**. V nižších
   variantách endpoint ``/kusovnik`` nevyužijete.

Založení kusovníku
------------------

``POST`` nebo ``PUT`` na ``/c/{firma}/kusovnik``. Jeden záznam je vždy buď
**hlavička** (výrobek / polotovar), nebo jeden **řádek materiálu** (uzel)
pod ní. Strukturu popisujete sami — Flexi ji nedopočítává:

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - Vlastnost
     - Význam
   * - ``mnoz``
     - Množství spotřebované do nadřazeného výrobku.
   * - ``hladina``
     - Úroveň v kusovníku — hlavička má ``1``, materiál pod ní ``2`` atd.
   * - ``poradi``
     - Pořadí řádku v rámci hladiny.
   * - ``cesta``
     - Cesta uzlu ve struktuře, např. ``1/2/``.
   * - ``otecCenik``
     - Ceníková položka výrobku, ke kterému celý kusovník patří — stejná
       na hlavičce i na všech řádcích.
   * - ``cenik``
     - Ceníková položka daného řádku. U hlavičky shodná s ``otecCenik``.
   * - ``otec``
     - Nadřazený řádek kusovníku. U hlavičky prázdný.

Ostatní vlastnosti (např. ``nazev``) jsou nepovinné. Řádky mezi sebou
provažte identifikátory ``ext:``, pokud ještě neznáte číselná ID.

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

Načtení kusovníku
-----------------

.. code-block:: text

   GET /c/{firma}/kusovnik/(otecCenik='code:PŘEDNÍ_KOLO').json?detail=full

Platí běžná filtrace, úroveň detailu a další parametry výpisu.

Přepočet cen kusovníku
----------------------

Hodnotu výrobku lze přepočítat z cen materiálu/služeb v kusovníku — viz
oficiální článek o přepočtu. Automatická aktualizace je zatím jen přes API
(pravidelný ``POST``/``PUT`` na URL přepočtu).

Mazání: ``action="delete"`` — viz :doc:`akce_zamykani`.
