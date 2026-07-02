Párování plateb
====================

Banku (``banka``) nebo pokladní pohyb (``pokladni-pohyb``) lze spárovat s
jednou nebo více fakturami vydanými či přijatými.

.. code-block:: xml

   <banka>
     <id>code:BANKA1</id>
     <!-- lze uvést i další vlastnosti dokladu jako při běžném importu -->
     <sparovani>
       <!-- pro úhradu více faktur se element opakuje; type - jen faktury
            stejného typu (vydané nebo přijaté); castka - (volitelné)
            omezuje uhrazovanou částku -->
       <uhrazovanaFak type="faktura-vydana" castka="1000">code:FV1</uhrazovanaFak>
       <zbytek>ignorovat</zbytek>
     </sparovani>
   </banka>

V jednom spárování lze uhradit více faktur najednou (musí být stejného
typu). Bez atributu ``castka`` se z faktury uhradí celá zbývající částka;
je-li ``castka`` menší, faktura bude uhrazena částečně; je-li rovna
zbývající částce, chová se, jako by nebyla uvedena. Při více fakturách se
uhrazující částka spotřebovává v pořadí, v jakém jsou uvedeny.

.. warning::

   **JSON kódování se liší** od obvyklé ploché konvence ``pole@atribut``
   používané jinde (např. u štítků). Potřebuje-li element zároveň atributy i
   hodnotu, hodnota jde pod vnořený klíč ``"filter"``:

   .. code-block:: json

      {"winstrom": {"banka": {"id": "code:BANKA1", "sparovani": {
        "uhrazovanaFak": {"@castka": "500.0", "@type": "faktura-vydana", "filter": "code:FV2"},
        "zbytek": "ignorovat"
      }}}}

Zbytek — jak naložit s rozdílem mezi uhrazující a uhrazovanou částkou
------------------------------------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 24 25 25 25

   * - Hodnota ``zbytek``
     - zbytek = 0 (přesná shoda)
     - zbytek > 0 (uhrazující doklad má víc)
     - zbytek < 0 (uhrazující doklad má míň)
   * - ``ne``
     - plně spárováno
     - CHYBA 400 (částky se neshodují)
     - CHYBA 400
   * - ``zauctovat``
     - plně spárováno
     - spárováno + interní doklad na zbytek
     - spárováno + interní doklad na zbytek
   * - ``ignorovat``
     - plně spárováno
     - uhrazující doklad zůstane nespárován
     - totéž
   * - ``castecnaUhrada``
     - plně spárováno
     - CHYBA 400 (nemá smysl)
     - postupná spotřeba částky dle pořadí; faktury bez zbylých prostředků nespárovány
   * - ``castecnaUhradaNeboZauctovat``
     - plně spárováno
     - spárováno + interní doklad na zbytek
     - částečná úhrada
   * - ``castecnaUhradaNeboIgnorovat``
     - plně spárováno
     - uhrazující doklad zůstane nespárován
     - částečná úhrada

Volitelné doplňkové elementy v ``<sparovani/>`` (jinak výchozí z nastavení
firmy): ``krTypDokl``/``krTypDoklZisk``/``krTypDoklZtrata``/``krRada``
(kurzový rozdíl), ``zbTypDokl``/``zbTypDoklZisk``/``zbTypDoklZtrata``/
``zbRada`` (zbytek).

Křížové párování měn: doklad v domácí měně lze spárovat i s fakturami v
cizí měně (musí sdílet stejnou cizí měnu) — kurz se dopočítá z poměru
uhrazující částky k celkové uhrazované částce.

Odpárování
--------------

.. code-block:: xml

   <banka>
     <id>code:BANKA1</id>
     <odparovani>
       <uhrazovanaFak type="faktura-vydana">code:FV1</uhrazovanaFak>  <!-- nepovinné, lze vícekrát -->
     </odparovani>
   </banka>

Bez uvedení ``<uhrazovanaFak>`` se odpáruje vše spárované s daným dokladem.
Párování je **idempotentní** (opakované volání je bezpečné).

Automatické párování
-------------------------

.. code-block:: text

   PUT /c/{firma}/banka/automaticke-parovani
   PUT /c/{firma}/banka/({filtr})/automaticke-parovani

Parametry:

- ``mod=`` — strategie: ``varCasUcet`` (VS + částka + účet), ``varCas`` (VS
  + částka, výchozí), ``jenVar`` (jen VS), ``jenCastka`` (jen částka)
- ``obdobi=`` — ``aktualni``, ``aktualni-predchozi``, ``vsechna``
  (**výchozí pro API**; pozor, aplikace má jiný výchozí — ``aktualni-predchozi``)
- ``ignorovat-rozdil-castka=`` — tolerance rozdílu částky (výchozí 0.0;
  v ``mod=jenVar`` se ignoruje); v měně bankovního dokladu.
- ``zauctovat-rozdil=`` — (výchozí ``true``) zda zaúčtovat rozdíl při
  spojování úhrad s neshodnými částkami.

.. code-block:: text

   /c/{firma}/banka/automaticke-parovani?mod=jenVar&obdobi=aktualni&ignorovat-rozdil-castka=1.5&zauctovat-rozdil=true

Starší REST-only endpoint (bez XML importu, stále podporovaný)
-----------------------------------------------------------------------

.. code-block:: text

   /c/{firma}/parovani-uhrad

.. code-block:: xml

   <sparovani>
     <uhrazovanaFak type="faktura-prijata">code:FP1</uhrazovanaFak>
     <uhrazujiciDokl type="banka">code:BANKA1</uhrazujiciDokl>
     <zbytek>ignorovat</zbytek>
   </sparovani>

.. code-block:: xml

   <odparovani>
     <uhrazujiciDokl>code:foo</uhrazujiciDokl>  <!-- povinné -->
     <uhrazovanaFak>code:bar</uhrazovanaFak>    <!-- nepovinné, lze vícekrát -->
   </odparovani>
