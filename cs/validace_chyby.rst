Validace a obsluha chyb
=============================

Validace dat
----------------

Při ukládání proběhne validace se třemi úrovněmi závažnosti:

- **error** (chyba) — záznam kvůli ní nejde uložit, celá operace je zrušena.
- **warning** (varování) — problém nastal, ale záznam **byl uložen**.
- **info** (informace) — doplňující informace, záznam byl uložen.

Při chybě se zpracování okamžitě zastaví. U varování a informací proběhne
kompletní import a všechny výsledné stavy se vrátí najednou. Chcete-li, aby
i varování zabránilo uložení, přidejte ``?fail-on-warning=true``. Pro
ověření bez uložení použijte ``?dry-run=true`` (viz :doc:`pozadavky`).

Ukázka odpovědi s varováním a informací:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <success>true</success>
            <result>
              <id>105</id>
              <warnings>
                <warning for="radekDph">Záznam nemá vyplněn řádek DPH a proto nebude doklad zaúčtován.</warning>
              </warnings>
              <infos>
                <info>Došlo k automatickému výběru výrobního čísla.</info>
              </infos>
            </result>
            <result><id>103</id></result>
          </winstrom>
     - .. code-block:: json

          {
            "winstrom": {
              "@version": "1.0",
              "success": true,
              "result": [
                {
                  "id": "105",
                  "warnings": {
                    "warning@for": "radekDph",
                    "warning": "Záznam nemá vyplněn řádek DPH a proto nebude doklad zaúčtován."
                  },
                  "infos": {
                    "info": "Došlo k automatickému výběru výrobního čísla."
                  }
                },
                {"id": "103"}
              ]
            }
          }

Atribut ``for`` u ``<warning>`` odkazuje na pole, kterého se zpráva týká.

Obsluha chyb — HTTP stavové kódy
--------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15 60

   * - Kód
     - Význam
   * - 200 OK
     - Operace proběhla úspěšně.
   * - 201 Created
     - Záznam byl vytvořen; hlavička ``Location`` a identifikátor v těle.
   * - 304 Not Modified
     - Záznam nebyl změněn (v kombinaci s ``If-Modified-Since``).
   * - 400 Bad Request
     - Špatný požadavek, typicky PUT odkazující na neexistující objekt.
   * - 401 Unauthorized
     - Je nutné se přihlásit.
   * - 402 Payment Required
     - Cílový systém nemá aktivované REST API pro zápis (čtecí operace vrací
       místo toho 404).
   * - 403 Forbidden
     - Uživatel nemá oprávnění, nebo to neumožňuje licence.
   * - 404 Not Found
     - Záznam (evidence nebo konkrétní záznam) nenalezen.
   * - 405 Method Not Allowed
     - Použita nepovolená metoda (např. POST tam, kde je povoleno jen GET).
   * - 406 Not Acceptable
     - Cílový formát není nad daným zdrojem podporován (např. export
       adresáře jako ISDOC).
   * - 500 Internal Server Error
     - Vnitřní chyba serveru — vždy chyba v kódu AbraFlexi, hlaste podpoře.

Ukázka chybové odpovědi:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <?xml version="1.0"?>
          <winstrom version="1.0">
            <success>false</success>
            <result>
              <id>105</id>
              <error>Je očekáváno číselné ID, ale 'null' není číslo</error>
            </result>
          </winstrom>
     - .. code-block:: json

          {
            "winstrom": {
              "@version": "1.0",
              "success": false,
              "result": [
                {
                  "id": "105",
                  "error": "Je očekáváno číselné ID, ale 'null' není číslo"
                }
              ]
            }
          }

Formát chybové zprávy je shodný s formátem validačních zpráv výše.
