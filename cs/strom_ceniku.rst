Strom ceníku
============

Strom ceníku je hierarchie kategorií, do kterých se zařazují ceníkové
položky. Přes REST API jej lze spravovat čtením i importem. Zdroj:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/5615241-strom-ceniku-pres-rest-api>`_.

.. warning::

   Import do stromu ceníku je ve stavu **NOT_DOCUMENTED** — podporujeme
   jej, ale není součástí oficiální dokumentace a nedoporučujeme se na
   něj spoléhat. Není plně implementován; uzel stromu je například možné
   identifikovat pouze číselným ID, nikoli kódem.

Evidence stromu
---------------

Strom je popsán třemi evidencemi:

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - Evidence
     - Co obsahuje
   * - ``strom``
     - Jednotlivé uzly (větve) stromu tak, jak je vidíte v aplikaci po
       zapnutí stromu — včetně hladiny, pořadí, nadřazeného uzlu a
       cesty.
   * - ``strom-koren``
     - Kořen stromu; standardně jediný záznam ``STR_CEN`` — Strom
       ceníku.
   * - ``strom-cenik``
     - Přiřazení ceníkových položek do jednotlivých uzlů stromu.

Element ``otec`` je předchozí (nadřazený) uzel, ``cesta`` a ``hladina``
odpovídají pořadí v aplikaci — počítá se do nich i úvodní uzel Strom
ceníku. Obě tyto vlastnosti jsou pouze pro čtení, Flexi je počítá sama.

Tvorba stromu
-------------

Uzel se zakládá s názvem (``nazev``), pořadím (``poradi``) a stromem,
do kterého patří (``strom``). Pořadím určíte, na jaké pozici se uzel ve
své kategorii zobrazí; ``strom`` je kořen stromu a ``otec`` předcházející
uzel. Cesta a hladina se dopočítají.

.. code-block:: text

   POST /c/{firma}/strom.json

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

   V elementech ``strom`` a ``otec`` lze uzel adresovat kódem
   (``code:…``) i číselným ID. Uzly bez zkratky — například systémové
   *Připojené položky* a *Nepřipojené položky* — jde adresovat jen ID.

Přiřazení ceníkové položky do stromu
------------------------------------

Přiřazení se importuje do evidence ``strom-cenik``. Ceníkovou položku
(``idZaznamu``) můžete zadat ID i kódem, uzel (``uzel``) však jen
číselným ID, které zjistíte dotazem na ``/strom``.

.. code-block:: text

   POST /c/{firma}/strom-cenik.json

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <strom-cenik>
              <!-- idZaznamu = ID nebo kód ceníkové položky -->
              <idZaznamu>code:TELKREM ABC 500</idZaznamu>
              <!-- uzel = číselné ID uzlu ze /strom -->
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

Po importu se v uzlu s ID 4 zobrazí přiřazená položka
``TELKREM ABC 500``.

.. warning::

   Pozor na asymetrii čtení a zápisu: při čtení vrací API ``uzel`` jako
   kód (například ``code:A-I``), ale poslat takovou hodnotu zpět nelze —
   import ji odmítne s ``400`` a kódem ``neniKodNeboNemuzeBytID``
   (Entita 'Uzel' neobsahuje kód nebo ho nelze použít jako ID). Použijte
   hodnotu z ``uzel@ref``, kde je číselné ID.

Neexistující ceníkovou položku odmítne API s ``400`` a kódem
``formZaznamNenalezen``.

Filtrování položek podle stromu při výpisu ceníku podporuje operátor
``in subtree`` — viz :doc:`vypis_filtrovani`.

Přesun větve stromu
-------------------

Pro přesun větve stačí u existujícího uzlu změnit ``otec`` na novou
nadřazenou kategorii a ``poradi`` na požadovanou pozici — například
``99``, aby se zařadila na konec.

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

Dojde k přesunu celé kategorie ``PANSKEKREMY`` včetně podkategorií a
přiřazených položek do kategorie ``TELKREMY`` — nikoli k jejímu
zkopírování. Hladina i cesta se přepočítají samy.
