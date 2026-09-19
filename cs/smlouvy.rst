Smlouvy
=======

Odběratelské a dodavatelské smlouvy slouží k automatické fakturaci. Ze
smluv lze přes REST API generovat faktury a smlouvy valorizovat. Zdroj:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/7924365-smlouvy-v-api>`_.

Způsob volání
-------------

``PUT`` nebo ``POST``; XML i JSON. Odběratelské smlouvy jsou v evidenci
``smlouva``, dodavatelské v ``dodavatelska-smlouva``:

.. code-block:: text

   POST /c/{firma}/smlouva.xml
   POST /c/{firma}/dodavatelska-smlouva.json

Doprovodné evidence
-------------------

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Evidence
     - Účel
   * - ``typ-smlouvy``, ``dodavatelsky-typ-smlouvy``
     - Typy smluv (předpisy, obdobně jako typ dokladu).
   * - ``stav-smlouvy``
     - Vlastní stavy smluv.
   * - ``smlouva-polozka``
     - Položky smluv — pro generování faktury je nutná alespoň jedna
       (co fakturovat, frekvence, datum generování).
   * - ``smlouva-zurnal``
     - Historie generování faktur ze smluv.

.. warning::

   Do ``smlouva-polozka`` nelze importovat samostatně — bez hlavičky
   smlouvy vrací požadavek ``400`` s ``importNotAllowed``. Položky
   posílejte vnořené do smlouvy při vytvoření nebo aktualizaci.

Povinná pole
------------

Hlavička: ``kod`` (max. 20), ``nazev`` (max. 255), ``smlouvaOd``,
``typSml``, ``firma``. Položka: ``kod`` a ``nazev`` — nebo odkaz
``cenik`` a hodnoty se přeberou z ceníku.

Ostatní vlastnosti (frekvence, den/měsíc cyklu, způsob fakturace, …)
nejsou pro import povinné, ale pro správné generování faktur je nutné je
nastavit.

.. warning::

   Flexi **nevaliduje** volitelné hodnoty jako ``frekFakt``, ``den`` či
   ``mesic``. Nesmyslné hodnoty (např. ``frekFakt: 121``, ``mesic: 13``)
   projdou a pak zabrání generování faktur.

Ukázky volání
-------------

Odběratelská smlouva (XML):

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

Dodavatelská smlouva s položkami (JSON):

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

``zpusFaktK``: ``zpusobFakt.dopredu`` (dopředu) nebo ``zpusobFakt.zpetne``
(zpětně). Úspěch vrací **201 Created**.

Hledání faktur ze smlouvy
-------------------------

Filtrovat vydané faktury podle ``smlouva`` (nebo textu ``cisSml``):

.. code-block:: text

   GET /c/{firma}/faktura-vydana/(smlouva='code:45644').json

Historie generování je v ``smlouva-zurnal``.
