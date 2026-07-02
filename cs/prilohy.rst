Přílohy
===========

Export
----------

Seznam příloh záznamu:

.. code-block:: text

   /c/firma/adresar/12/prilohy

Metadata jedné konkrétní přílohy:

.. code-block:: text

   /c/firma/adresar/12/prilohy/75

Binární data přílohy (odpověď obsahuje i správnou hlavičku ``Content-Type``):

.. code-block:: text

   /c/firma/adresar/12/prilohy/75/content

Náhled (jen pro obrázkové přílohy; neexistuje-li, 404):

.. code-block:: text

   /c/firma/adresar/12/prilohy/75/thumbnail

Import binárního souboru
------------------------------

.. code-block:: text

   PUT /c/firma/adresar/12/prilohy/new/<název souboru>
   Content-Type: image/jpeg

Binární data musí být přímo v těle požadavku. Existující přílohu nelze
měnit — je nutné ji smazat a znovu založit.

Import přes XML/JSON
-------------------------

Podporován i import přílohy vloženě do XML/JSON dat rodičovského záznamu
(base64), s omezeními: nová příloha musí být součástí jiného objektu (nemůže
být kořenový tag), lze měnit jen metadata, ne samotná data přílohy. Pro
tento způsob je nutné použít endpoint rodičovské evidence (např.
``/c/firma/faktura-vydana.xml``), nikoli binární endpoint výše.

.. code-block:: xml

   <winstrom>
     <faktura-vydana>
       <id>11925</id>
       <prilohy>
         <priloha update="ignore">
           <id>ext:DPH-KONTROLA:faktura-vydana:11925</id>
           <contentType>text/html</contentType>
           <nazSoub>vies-CZ18239617-2023-01-19.html</nazSoub>
           <typK>typPrilohy.ostatni</typK>
           <content encoding="base64">PGh0bWw+PG...</content>
         </priloha>
       </prilohy>
     </faktura-vydana>
   </winstrom>

.. code-block:: json

   {
     "winstrom": {
       "faktura-vydana": {
         "id": "11925",
         "prilohy": {
           "priloha": {
             "id": "ext:DPH-KONTROLA:faktura-vydana:11925",
             "contentType": "text/html",
             "nazSoub": "vies-CZ18239617-2023-01-19.html",
             "typK": "typPrilohy.ostatni",
             "content@encoding": "base64",
             "content": "PGh0bWw+PG..."
           }
         }
       }
     }
   }

.. note::

   Pokud importujete XML přílohu, API se automaticky přepne na komunikaci
   ve formátu XML (JSON hlavička je pak ignorována).

Export přílohy jako součásti nadřazeného objektu (base64):

.. code-block:: text

   /c/firma/faktura-vydana/1.xml?relations=prilohy

Podpora obrázků
--------------------

Nahraná příloha ve formátu ``image/jpeg``, ``image/gif`` nebo ``image/png``
automaticky získá vygenerovaný náhled. Primární obrázek objektu (neexistuje-
li, 404):

.. code-block:: text

   /c/firma/cenik/12/thumbnail.png?w=<šířka>&h=<výška>

Přílohy nastavení firmy (logo, podpis a razítko)
-------------------------------------------------------

Speciální, oddělený mechanismus (ne obecná evidence příloh):

.. code-block:: text

   GET    /c/firma/nastaveni/1/logo             — zjištění/přesměrování na existující logo (303) nebo 404
   PUT/POST /c/firma/nastaveni/1/logo           — nahrání loga (jen pokud ještě žádné není, jinak 400)
   DELETE /c/firma/nastaveni/1/logo             — smazání loga

Úspěšné nahrání: 201 + hlavička ``Location`` s URL nově vzniklé přílohy.
Stejně funguje ``podpis-razitko`` místo ``logo`` (podpis a razítko).
