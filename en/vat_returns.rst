VAT return, control statement and recapitulative statement
==========================================================

Outputs for the tax authority are generated via the REST API as XML (for
filing) or PDF (for printing). Parameters go in the query string; ``GET`` and
``POST`` are supported. Sources (in Czech) at `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/5487205-priznani-dph-rest-api>`_:
`VAT return
<https://podpora.flexibee.eu/cs/articles/5487205-priznani-dph-rest-api>`_,
`Control statement
<https://podpora.flexibee.eu/cs/articles/8730769-kontrolni-hlaseni-rest-api>`_,
`Recapitulative statement
<https://podpora.flexibee.eu/cs/articles/8650919-souhrnne-hlaseni-k-dph-rest-api>`_.

VAT return (``priznani-dph``)
-----------------------------

.. code-block:: text

   GET /c/{company}/priznani-dph.xml?rok=2024&mesic=1&koeficient=100
   GET /c/{company}/priznani-dph.pdf?rok=2024&mesic=1&koeficient=100
   GET /c/{company}/priznani-dph.xml?rok=2024&mesic=1&koeficient=0&stat=SK
   GET /c/{company}/priznani-dph/form-data.xml

.. list-table::
   :header-rows: 1
   :widths: 26 74

   * - Parameter
     - Meaning
   * - ``rok``, ``mesic``
     - Required. For quarterly payers ``mesic`` can be ``Q1`` to ``Q4``.
   * - ``koeficient``
     - Optional; default CZ ``100``, SK ``0``. Since 2025.8.1 coefficients
       are saved automatically.
   * - ``druh``
     - Default ``radne``. CZ: ``radne``, ``radneOpravne``, ``dodatecne``,
       ``dodatecneOpravne``. SK: ``radne``, ``opravne``, ``dodatecne``.
   * - ``dodatecneOproti``
     - Required for a supplementary return: ID of the previous return from
       ``/radek-priznani-dph``. Must be in the same period.
   * - ``duvodyProDodatecne``
     - Required for a Czech supplementary return.
   * - ``datumZjisteni``
     - ``yyyy-MM-dd``.
   * - ``vyporadaciKoeficient``, ``zmenaOdpoctu``, ``danKUhrade``,
       ``kodZdanObd``
     - Optional; ``zmenaOdpoctu`` is the difference for row 53,
       ``danKUhrade`` (row 38) only for ``dodatecne``.
   * - ``ulozit``
     - ``true``/``false`` (default ``false``) — save the return.
   * - ``report-name``
     - PDF only, e.g. ``priznaniDPH2026$$SUM``; an unknown name returns 400.
   * - ``stat``
     - ``CZ`` or ``SK``; defaults to the company's legislation.

``form-data`` returns the ``supportXml``/``supportPdf`` flags,
``dostupneDruhy`` and ``dostupneReporty``. Since 2024.7.0 it replaces the
earlier ``/dostupne-druhy``; since 2025.8.1 it also accepts period
parameters (year, month, ``Q1``–``Q4``) and returns coefficients for Czech
companies.

Saved returns:

.. code-block:: text

   GET  /c/{company}/ulozene-priznani-dph/(rok eq 2024 and mesic eq 1).xml
   POST /c/{company}/ulozene-priznani-dph/query    {"rok":"2024","mesic":"1"}

Errors (HTTP 400): ``unsupported_param_value_exception`` (unsupported
``druh``), ``missing_param_exception`` (missing ``dodatecneOproti``),
``parametrPovinny`` (missing ``rok``/``mesic``) and an error for a
corrected return in a different period. Since 2025.3.3 the API also returns
400 when the VAT state of the corrected and supplementary return differ.

Control statement (``kontrolni-hlaseni``)
-----------------------------------------

.. code-block:: text

   GET /c/{company}/kontrolni-hlaseni.xml?obdobi=2024Q2
   GET /c/{company}/kontrolni-hlaseni.pdf?obdobi=2024Q2
   GET /c/{company}/kontrolni-hlaseni.xml?obdobi=202410&druh=N&datumZjisteni=2024-10-10
   GET /c/{company}/kontrolni-hlaseni/form-data.xml

.. list-table::
   :header-rows: 1
   :widths: 26 74

   * - Parameter
     - Meaning
   * - ``obdobi``
     - Month ``yyyyMM`` (e.g. ``202410``) or quarter ``yyyyQn``
       (``2024Q2``); defaults to the current month. The range is not
       checked — ``2124Q5`` returns ``200`` and rolls over into the next
       year.
   * - ``druh``
     - CZ: ``B`` (regular, default), ``O``, ``N``, ``E``. SK: ``R``
       (default), ``O``, ``D``.
   * - ``datumZjisteni``
     - Required for ``N`` and ``E`` (``dd.MM.yyyy`` or ``yyyy-MM-dd``).
   * - ``dodatecneOproti``
     - Required for a Slovak supplementary statement.
   * - ``vyzvaOdpoved``
     - ``B`` (nil return) or ``P`` (confirms the last filed return).
   * - ``cisloJednaciVyzvy``
     - Required if ``vyzvaOdpoved`` is set; format
       ``99999999/99/9999-99999-999999``.
   * - ``stat``, ``ulozit``
     - As for the VAT return.

Generated data (JSON and XML):
``GET /c/{company}/kontrolni-hlaseni-dph.json?rok=2024&ctvrtleti=2``
(``rok`` and ``ctvrtleti`` or ``mesic`` required; optional
``clenKonVykNull=true``, ``kodSkTooLong=true``). Saved statements:
``/c/{company}/ulozene-priznani-kon-vyk-dph/(rok eq 2024 and ctvrtleti eq 2).xml``.

Errors (HTTP 400): missing company settings (tax office, e-mail or data box,
representative); since 2025.9.0 the same for both XML and PDF when the tax
office is not filled in; ``missing_param_exception``,
``unsupported_param_value_exception``, ``illegal_parameter_exception``.

Recapitulative statement (``souhrnne-hlaseni``)
-----------------------------------------------

.. code-block:: text

   GET /c/{company}/souhrnne-hlaseni.xml?mesic=1&rok=2024
   GET /c/{company}/souhrnne-hlaseni.pdf?mesic=1&rok=2024
   GET /c/{company}/souhrnne-hlaseni-dph.json?rok=2024&ctvrtleti=2

``rok`` and either ``mesic`` (1–12) or ``ctvrtleti`` (1–4) are required;
``stat`` (``CZ``/``SK``) is optional. The PDF call returns ``307`` to
``/c/{company}/souhrnne-hlaseni-dph.pdf`` — the client must follow the
redirect. Errors (HTTP 400): ``ctvrtleti`` outside 1–4, unsupported ``stat``,
no period given.
