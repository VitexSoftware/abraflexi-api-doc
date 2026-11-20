Přiznání DPH, kontrolní a souhrnné hlášení
==========================================

Výstupy pro finanční správu se generují přes REST API jako XML (podání) nebo
PDF (tisk). Parametry se předávají v query stringu, podporovány jsou ``GET``
i ``POST``. Zdroje na `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/5487205-priznani-dph-rest-api>`_:
`Přiznání DPH
<https://podpora.flexibee.eu/cs/articles/5487205-priznani-dph-rest-api>`_,
`Kontrolní hlášení
<https://podpora.flexibee.eu/cs/articles/8730769-kontrolni-hlaseni-rest-api>`_,
`Souhrnné hlášení
<https://podpora.flexibee.eu/cs/articles/8650919-souhrnne-hlaseni-k-dph-rest-api>`_.

Přiznání DPH
------------

.. code-block:: text

   GET /c/{firma}/priznani-dph.xml?rok=2024&mesic=1&koeficient=100
   GET /c/{firma}/priznani-dph.pdf?rok=2024&mesic=1&koeficient=100
   GET /c/{firma}/priznani-dph.xml?rok=2024&mesic=1&koeficient=0&stat=SK
   GET /c/{firma}/priznani-dph/form-data.xml

.. list-table::
   :header-rows: 1
   :widths: 26 74

   * - Parametr
     - Význam
   * - ``rok``, ``mesic``
     - Povinné. Za ``mesic`` lze u čtvrtletních plátců zadat ``Q1`` až
       ``Q4``.
   * - ``koeficient``
     - Volitelný; výchozí CZ ``100``, SK ``0``. Od 2025.8.1 se koeficienty
       ukládají automaticky.
   * - ``druh``
     - Výchozí ``radne``. CZ: ``radne``, ``radneOpravne``, ``dodatecne``,
       ``dodatecneOpravne``. SK: ``radne``, ``opravne``, ``dodatecne``.
   * - ``dodatecneOproti``
     - Povinné u dodatečného přiznání: ID předchozího přiznání z
       ``/radek-priznani-dph``. Musí být ve stejném období.
   * - ``duvodyProDodatecne``
     - Povinné u českého dodatečného přiznání.
   * - ``datumZjisteni``
     - ``yyyy-MM-dd``.
   * - ``vyporadaciKoeficient``, ``zmenaOdpoctu``, ``danKUhrade``,
       ``kodZdanObd``
     - Volitelné; ``zmenaOdpoctu`` je rozdíl pro řádek 53, ``danKUhrade``
       (řádek 38) jen u ``dodatecne``.
   * - ``ulozit``
     - ``true``/``false`` (výchozí ``false``) — uložit přiznání.
   * - ``report-name``
     - Jen PDF, např. ``priznaniDPH2026$$SUM``; neznámý název vrací 400.
   * - ``stat``
     - ``CZ`` nebo ``SK``; výchozí podle legislativy firmy.

``form-data`` vrací příznaky ``supportXml``/``supportPdf``, ``dostupneDruhy``
a ``dostupneReporty``. Od 2024.7.0 nahrazuje dřívější ``/dostupne-druhy``,
od 2025.8.1 přijímá i parametry období (rok, měsíc, ``Q1``–``Q4``) a pro
české firmy vrací koeficienty.

Uložená přiznání:

.. code-block:: text

   GET  /c/{firma}/ulozene-priznani-dph/(rok eq 2024 and mesic eq 1).xml
   POST /c/{firma}/ulozene-priznani-dph/query    {"rok":"2024","mesic":"1"}

Chyby (HTTP 400): ``unsupported_param_value_exception`` (nepodporovaná
hodnota ``druh``), ``missing_param_exception`` (chybí ``dodatecneOproti``),
``parametrPovinny`` (chybí ``rok``/``mesic``) a chyba u opravného přiznání v
jiném období. Od 2025.3.3 vrací API 400 také při nesouladu stavu DPH
opravovaného a dodatečného přiznání.

Kontrolní hlášení
-----------------

.. code-block:: text

   GET /c/{firma}/kontrolni-hlaseni.xml?obdobi=2024Q2
   GET /c/{firma}/kontrolni-hlaseni.pdf?obdobi=2024Q2
   GET /c/{firma}/kontrolni-hlaseni.xml?obdobi=202410&druh=N&datumZjisteni=2024-10-10
   GET /c/{firma}/kontrolni-hlaseni/form-data.xml

.. list-table::
   :header-rows: 1
   :widths: 26 74

   * - Parametr
     - Význam
   * - ``obdobi``
     - Měsíc ``yyyyMM`` (např. ``202410``) nebo čtvrtletí ``yyyyQn``
       (``2024Q2``); výchozí aktuální měsíc. Rozsah se nekontroluje —
       ``2124Q5`` vrátí ``200`` a přetéká do dalšího roku.
   * - ``druh``
     - CZ: ``B`` (řádné, výchozí), ``O``, ``N``, ``E``. SK: ``R`` (výchozí),
       ``O``, ``D``.
   * - ``datumZjisteni``
     - Povinné u ``N`` a ``E`` (``dd.MM.yyyy`` nebo ``yyyy-MM-dd``).
   * - ``dodatecneOproti``
     - Povinné u slovenského dodatečného hlášení.
   * - ``vyzvaOdpoved``
     - ``B`` (nulové) nebo ``P`` (potvrzuje poslední podané).
   * - ``cisloJednaciVyzvy``
     - Povinné, je-li zadáno ``vyzvaOdpoved``; tvar
       ``99999999/99/9999-99999-999999``.
   * - ``stat``, ``ulozit``
     - Jako u přiznání.

Vygenerovaná data (JSON i XML):
``GET /c/{firma}/kontrolni-hlaseni-dph.json?rok=2024&ctvrtleti=2`` (povinné
``rok`` a ``ctvrtleti`` nebo ``mesic``; volitelné ``clenKonVykNull=true``,
``kodSkTooLong=true``). Uložená hlášení:
``/c/{firma}/ulozene-priznani-kon-vyk-dph/(rok eq 2024 and ctvrtleti eq 2).xml``.

Chyby (HTTP 400): chybějící údaje v nastavení firmy (finanční úřad,
e-mail nebo datová schránka, zástupce); od 2025.9.0 stejně pro XML i PDF při
nevyplněném finančním úřadu; ``missing_param_exception``,
``unsupported_param_value_exception``, ``illegal_parameter_exception``.

Souhrnné hlášení
----------------

.. code-block:: text

   GET /c/{firma}/souhrnne-hlaseni.xml?mesic=1&rok=2024
   GET /c/{firma}/souhrnne-hlaseni.pdf?mesic=1&rok=2024
   GET /c/{firma}/souhrnne-hlaseni-dph.json?rok=2024&ctvrtleti=2

Povinné je ``rok`` a ``mesic`` (1–12) nebo ``ctvrtleti`` (1–4); volitelné
``stat`` (``CZ``/``SK``). PDF vrací ``307`` na
``/c/{firma}/souhrnne-hlaseni-dph.pdf`` — klient musí přesměrování
následovat. Chyby (HTTP 400): ``ctvrtleti`` mimo 1–4, nepodporovaný ``stat``,
nezadané období.
