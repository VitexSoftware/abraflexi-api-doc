Správa firem
================

Založení firmy
-------------------

.. code-block:: text

   PUT /admin/zalozeni-firmy

Parametry URL:

.. list-table::
   :header-rows: 1
   :widths: 25 55

   * - Parametr
     - Popis
   * - ``name=Firma``
     - **povinný**, název nově zakládané firmy
   * - ``use-demo=true``
     - naplnit demo daty (jen kombinace CZ a PODNIKATELE+PU)
   * - ``country=CZ`` / ``SK``
     - legislativa
   * - ``org-type=``
     - typ organizace — pro CZ: ``PODNIKATELE+PU`` (podvojné účetnictví),
       ``PODNIKATELE+DE`` (daňová evidence), ``NEZISKOVE`` (neziskové),
       ``ROZPOCTOVE`` (příspěvkové); pro SK: ``PODNIKATELIA+PU``
   * - ``ic=``
     - IČO — doplní další údaje z ARES (plátce DPH, sídlo, spisová značka, ...)
   * - ``vatid=``
     - DIČ

Úspěch: 201, URL firmy v hlavičce ``Location``.

Obnovení ze zálohy
------------------------

Záloha: ``GET /c/{db_nazev}/backup`` (hlavička ``Accept:
application/x-winstrom-backup`` nebo ``application/octet-stream``).

Obnovení: ``PUT /c/{db_nazev}/restore?name=Firma`` — tělo = binární obsah
zálohy; cílová firma **nesmí existovat** (jinak "Company 'restored_company'
already exists").

Testovací obnovení (``&forTesting=1``) — přepínače (výchozí zapnuto=1,
explicitní 0 = nevypínat): ``disableEet`` (vypne odesílání do EET),
``disableAutoSendMail`` (vypne automatické odesílání dokladů mailem),
``disableWebHooks`` (odregistruje všechny Web Hooky), ``skipZurnal``
(neobnovit historii změn), ``skipChangelog`` (neobnovit historii Changes API).

.. code-block:: text

   PUT /c/db_nazev/restore?name=Firma&forTesting=1&disableAutoSendMail=0&skipZurnal

Identifikátor firmy a seznam firem
----------------------------------------

Viz :doc:`identifikatory` — sekce "Identifikátor firmy".

Nastavení firmy
--------------------

Vlastní evidence ``/nastaveni`` (v aplikaci: Firma → Nastavení).

.. code-block:: text

   GET /c/{firma}/nastaveni.xml?detail=full

Vrací **více** záznamů ``<nastaveni>`` — nastavení je verzované podle data
platnosti (jako changelog), ne jeden řádek.

Pro přidání nové verze nastavení platné od data odkažte na verzi, ze které
má nová vycházet, přes ``<puvodniNastaveni><id>1</id></puvodniNastaveni>``
a ``<platiOdData>...</platiOdData>``; neuvedené hodnoty zůstanou stejné jako
v odkazované verzi:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <nastaveni>
            <puvodniNastaveni><id>1</id></puvodniNastaveni>
            <platiOdData>2021-12-29</platiOdData>
            <uliceNazev>Přestěhovaná</uliceNazev>
          </nastaveni>
     - .. code-block:: json

          {"winstrom": {"nastaveni": [{
              "puvodniNastaveni": {"id": "1"},
              "platiOdData": "2021-12-29",
              "uliceNazev": "Přestěhovaná"
          }]}}

Vložení nové *počáteční* (nejstarší) verze nastavení před stávající první:
``prvniNastaveni=true`` + ``prvniNastaveniPlatiDoData=`` (konečné datum nové
první verze; aplikace jej automaticky nastaví jako ``platiOdData`` stávající
první verze), vnořeno v ``puvodniNastaveni``.

.. note::

   Příklady URL v oficiální dokumentaci k této kapitole používají prefix
   ``/v2/c/{firma}/...`` místo obvyklého ``/c/{firma}/...`` — patrně jde o
   novější/alternativní verzi cesty k API; jinde v dokumentaci se
   nevyskytuje.
