Přepočet skladu
===============

Přepočet skladu zajišťuje kontrolu a přepočtení skladových stavů a cen za
zvolené účetní období. Přes REST API jej lze vyvolat stejně jako v
aplikaci. Zdroj: `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/5098676-prepocet-skladu-rest-api>`_.

Způsob volání
-------------

Služba je dostupná metodami ``PUT`` a ``POST`` na adrese:

.. code-block:: text

   /c/{firma}/sklad/prepocet

Podporovanými výstupními formáty jsou XML a JSON.

Parametry
---------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Parametr
     - Popis
   * - ``ucetniObdobi``
     - **Povinný.** Identifikuje období, za které chcete sklad přepočítat.
       Uvádí se jako identifikátor ve tvaru ``code:2024``.
   * - ``dry-run``
     - Volitelný. Zjistí, zda byl přepočet dokončen. Pokud ano, vrátí
       HTTP status ``200``. Pokud ne, vrátí HTTP status ``409`` s
       informací o tom, kdy a kým byl přepočet spuštěn.

Výsledek
--------

Pro rozpoznání úspěchu lze kontrolovat HTTP status odpovědi nebo vlastnost
``success`` v získaném dokumentu.

Při úspěšném vykonání je vracen HTTP status ``200`` a dokument ve
standardním formátu:

.. code-block:: json

   {"winstrom": {"@version": "1.0", "success": "true"}}

Při neúspěchu je vracen status ``4xx`` nebo ``5xx`` a zpráva o důvodu
neúspěchu.

Ukázky volání
-------------

.. code-block:: text

   PUT /c/{firma}/sklad/prepocet.xml?ucetniObdobi=code:2024
   PUT /c/{firma}/sklad/prepocet.json?ucetniObdobi=code:2024
   PUT /c/{firma}/sklad/prepocet?ucetniObdobi=code:2024

U posledního volání bez přípony se formát určí hlavičkou
``Accept: application/xml``, případně ``Accept: application/json``.
