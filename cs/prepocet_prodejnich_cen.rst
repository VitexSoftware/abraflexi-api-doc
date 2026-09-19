Přepočet prodejních cen
=======================

REST API umí přepočítat prodejní cenu ceníkové položky podle pravidel, která
má nastavená — výchozí ceny, způsobu výpočtu, procenta a zaokrouhlení.
Přepočet lze spustit nad jednotlivou položkou ceníku, nebo nad celou
skupinou zboží; obě varianty mají vlastní endpoint. Zdroj:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/9144426-api-prepocet-prodejnich-cen>`_.

Ceník
-----

.. code-block:: text

   PUT /c/{firma}/cenik/(filtr)/prepocti-prodejni-cenu

Místo filtru lze uvést přímo ID ceníkové položky:

.. code-block:: text

   PUT /c/{firma}/cenik/147/prepocti-prodejni-cenu

Použít lze i libovolnou filtraci a přepočítat tak více položek jedním
dotazem:

.. code-block:: text

   PUT /c/{firma}/cenik/(skupZboz='code:ZBOŽÍ')/prepocti-prodejni-cenu

Skupina zboží
-------------

.. code-block:: text

   PUT /c/{firma}/skupina-zbozi/(filtr)/prepocti-prodejni-cenu

Přepočet nad skupinou zboží projde všechny ceníkové položky, které do
skupiny patří. Filtr opět zastoupí i samotné ID skupiny:

.. code-block:: text

   PUT /c/{firma}/skupina-zbozi/7/prepocti-prodejni-cenu

Z čeho se cena počítá
---------------------

Přepočet nic nepřijímá v těle požadavku — vychází výhradně z nastavení
ceníkové položky, respektive skupiny zboží:

.. list-table::
   :header-rows: 1
   :widths: 28 72

   * - Vlastnost
     - Význam
   * - ``typCenyVychoziK``
     - Výchozí cena, ze které se počítá — například
       ``typCenyVychozi.nakCena`` (nákupní cena).
   * - ``typVypCenyK``
     - Způsob výpočtu — ``typVypCeny.prirazka``, ``typVypCeny.rabat`` a
       další.
   * - ``procZakl``
     - Marže, přirážka, rabat nebo sleva v procentech.
   * - ``zaokrJakK``, ``zaokrNaK``
     - Způsob a řád zaokrouhlení výsledné ceny.

Výsledek se zapíše do ``cenaZakl`` (a odvozených ``cenaZaklBezDph`` a
``cenaZaklVcDph``). Například u položky s nákupní cenou 75 a přirážkou
100 % vyjde prodejní cena 150.

.. note::

   Má-li položka výchozí cenu nastavenou na ``typCenyVychozi.zadna``, není
   z čeho počítat a přepočet ji nechá bez změny.

Odpověď a chybové stavy
-----------------------

Úspěšný přepočet vrací **HTTP 200 OK**:

.. code-block:: json

   {"winstrom": {"@version": "1.0", "success": "true"}}

.. warning::

   Odpověď neuvádí, kolik záznamů se přepočítalo. Filtr, který nic
   nenajde — i odkaz na neexistující ID — vrací rovněž ``200`` s
   ``success`` ``true``. Výsledek proto ověřujte přečtením ``cenaZakl``
   u dotčených položek.

.. list-table::
   :header-rows: 1
   :widths: 45 55

   * - Situace
     - Odpověď
   * - Volání metodou ``GET`` nebo ``DELETE``
     - ``405 Method Not Allowed``
   * - Chybně zapsaný název služby v URL
     - ``404``, ``adresaNeplatnaUrl`` — Adresa … není platná.
