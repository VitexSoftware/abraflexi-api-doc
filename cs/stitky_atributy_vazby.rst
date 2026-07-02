Štítky, atributy a uživatelské vazby
==========================================

Štítky
----------

Štítky lze přilepit téměř k libovolnému objektu (doklady, adresář, zakázka,
...), případně i k různým stavům (např. způsob úhrady) — vhodné pro
signalizaci propojenému systému.

Podmínkou přiřazení štítku je jeho předchozí založení v číselníku štítků.

Práce se štítky je technicky relace emulovaná jako položka — stejný
mechanismus ``removeAll="true"`` jako u položek dokladu (viz
:doc:`zapis_dat`):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <adresar><id>14</id><stitky removeAll="true"/></adresar>  <!-- smaže všechny -->
          <stitky removeAll="true">STITEK1,NOVY_STITEK</stitky>       <!-- nahradí celou množinu -->
     - .. code-block:: json

          {"winstrom": {"adresar": [{"id": "14", "stitky@removeAll": "true"}]}}
          {"stitky@removeAll": "true", "stitky": "STITEK1,NOVY_STITEK"}

Bez ``removeAll`` se štítky jen přidávají (existující zůstávají). JSON:
``"stitky@removeAll": "true", "stitky": "STITEK1,NOVY_STITEK"``.

**Skupiny štítků**: štítek může patřit do skupiny; je-li skupina nastavena
jako "jen jeden štítek", přiřazením nového štítku ze skupiny se ostatní
štítky téže skupiny automaticky odeberou — jednoduchá emulace stavového
automatu. Export dle skupiny: ``?skupina-stitku=SKUPINA1,SKUPINA2``, výstup
pak obsahuje atributy skupin přímo na elementu ``<stitky>``:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <stitky SKUPINA1="STITEK1" SKUPINA2="STITEK2">STITEK1,STITEK2,STITEK3</stitky>
     - .. code-block:: json

          {"stitky@SKUPINA1": "STITEK1", "stitky@SKUPINA2": "STITEK2",
           "stitky": "STITEK1,STITEK2,STITEK3"}

Atributy (custom pole ceníku a adresáře)
----------------------------------------------

Volná vlastní pole pro ``cenik`` (ceník) a ``adresar`` (adresář), přes
dedikovanou evidenci ``atribut``. U adresáře jsou dostupné jen přes REST API
(zobrazení už i v desktopové aplikaci); u ceníku plné CRUD i v aplikaci.

Export atributů jednoho záznamu (jen dle ID, bez filtrace):

.. code-block:: text

   GET /c/{firma}/cenik/{id}/atributy.xml
   GET /c/{firma}/adresar/{id}/atributy.xml

Export přes obecnou evidenci ``atribut`` (podporuje běžnou filtraci dle
kódu i ID):

.. code-block:: text

   GET /c/{firma}/atribut/(cenik='code:CENIK').xml
   GET /c/{firma}/atribut/(adresar='code:FIRMA').xml

Založení:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <atribut>
            <hodnota>KUZE</hodnota>
            <cenik>code:KUFR</cenik>  <!-- nebo <adresar>code:FIRMA</adresar> -->
            <typAtributu>code:MATERIAL</typAtributu>
          </atribut>
     - .. code-block:: json

          {"winstrom": {"atribut": [{
              "hodnota": "KUZE",
              "cenik": "code:KUFR",
              "typAtributu": "code:MATERIAL"
          }]}}

Editace: stejná struktura + ``<id>``. Smazání: stejná struktura + ``<id>`` +
``action="delete"`` na elementu ``<atribut>`` (viz :doc:`akce_zamykani`).

Uživatelské vazby
----------------------

Propojení libovolného objektu s jiným, s uvedením typu vazby. Dva druhy:
ruční (vytvořené v aplikaci nebo importem) a automatické (dosazované podle
konfigurace typu vazby filtrem).

Čtení: ``GET /c/{firma}/{evidence}/{id}/uzivatelske-vazby``. Navázaný objekt
lze zahrnout přímo do exportu (``?detail=full&includes=/winstrom/uzivatelska-vazba/object``),
nebo přes standardní relace na nadřazeném záznamu (``?relations=uzivatelske-vazby``).

Vytvoření (vnořeno pod vlastnící záznam):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <adresar>
            <id>109</id>
            <uzivatelske-vazby>
              <uzivatelska-vazba>
                <id>ext:VAZBA:TESTEXTID-CEN</id>
                <evidenceType>cenik</evidenceType>
                <object>code:SKL-0001/2022</object>
                <popis>popisek</popis>
                <poznam>poznámka</poznam>
                <vazbaTyp>code:ADRCEN</vazbaTyp>
              </uzivatelska-vazba>
            </uzivatelske-vazby>
          </adresar>
     - .. code-block:: json

          {"winstrom": {"adresar": [{
              "id": "109",
              "uzivatelske-vazby": [{
                  "id": "ext:VAZBA:TESTEXTID-CEN",
                  "evidenceType": "cenik",
                  "object": "code:SKL-0001/2022",
                  "popis": "popisek",
                  "poznam": "poznámka",
                  "vazbaTyp": "code:ADRCEN"
              }]
          }]}}

.. code-block:: json

   {"winstrom": {"interni-doklad": [{"id": "1054", "uzivatelske-vazby": [
     {"vazbaTyp": "code:INT-FAV", "evidenceType": "faktura-vydana", "object": "code:VF1-0073/2022"}
   ]}]}}

Smazání (samostatně na evidenci vazby, ne vnořeně):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <uzivatelska-vazba action="delete"><id>ext:VAZBA:TESTEXTID-CEN</id></uzivatelska-vazba>
     - .. code-block:: json

          {"winstrom": {"uzivatelska-vazba": [
              {"@action": "delete", "id": "ext:VAZBA:TESTEXTID-CEN"}
          ]}}
