Saldo
=====

Stejně jako většinu účetních výstupů lze přes REST API generovat i saldo.
Zdroj: `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/8650590-saldo-rest-api>`_.

Způsob volání
-------------

.. code-block:: text

   GET /c/{firma}/saldo.xml
   GET /c/{firma}/saldo.json

Žádný parametr není povinný. Lze použít i obecné parametry výpisu
(stránkování, úroveň detailu, …).

Parametry
---------

.. list-table::
   :header-rows: 1
   :widths: 32 68

   * - Parametr
     - Význam
   * - ``stavUhrady``
     - ``uhrazeno`` nebo ``neuhrazeno``. Bez parametru vrací vše.
   * - ``filtrUcty``
     - Účty, prefixy nebo rozsahy oddělené čárkou — např.
       ``311000,32,3-4``.
   * - ``filtrProtiucty``
     - Protiúčty, stejný zápis — např. ``211001,21,1-2``.
   * - ``datumUctovaniOd``, ``datumUctovaniDo``
     - Rozsah data účtování (``yyyy-MM-dd``).
   * - ``datumVystaveniOd``, ``datumVystaveniDo``
     - Rozsah data vystavení (``yyyy-MM-dd``).
   * - ``modul``
     - Účetní modul; lze opakovat. Hodnoty:
       ``modulUcetni.FAP``, ``FAV``, ``BAN``, ``POK``, ``SKL``, ``INT``,
       ``PHL``, ``ZAV``, ``MAJ``, ``LEA``, ``TXP``, ``TXZ``.
   * - ``castkaMDOd`` / ``Do``, ``castkaMDMenOd`` / ``Do``
     - Rozsah částky MD (tuzemská / cizí měna).
   * - ``castkaDalOd`` / ``Do``, ``castkaDalMenOd`` / ``Do``
     - Rozsah částky Dal (tuzemská / cizí měna).
   * - ``stredisko``, ``zakazka``, ``firma``
     - Opakovatelné; importní identifikátor, např. ``code:CENTRALA``.
   * - ``stavZauctovani``
     - ``zauctovano``, ``nezauctovano`` nebo ``vse``.
   * - ``popis``
     - Fulltextová filtrace podle popisu.
   * - ``cisloDokladu``, ``varSymbol``, ``parSymbol``
     - Interní číslo, VS nebo párovací symbol; více hodnot čárkou.

.. warning::

   Neplatná hodnota výčtových parametrů (``stavUhrady``,
   ``stavZauctovani``, ``modul``) vrací ``400``
   ``unsupported_param_value_exception`` s výčtem možností. **Neznámý
   název parametru** se tiše ignoruje — překlep jen vypne filtr.

.. note::

   Zde se ``modul`` zapisuje s prefixem ``modulUcetni.``. U stavu úhrad
   k datu se uvádí jen ``FAV``, ``PHL``, ``FAP``, ``ZAV``.

Ukázky volání
-------------

.. code-block:: text

   GET /c/{firma}/saldo.json?stavUhrady=neuhrazeno
   GET /c/{firma}/saldo.json?stavUhrady=neuhrazeno&filtrUcty=311001,311002
   GET /c/{firma}/saldo.json?modul=modulUcetni.FAV&modul=modulUcetni.FAP&stredisko=code:CENTRALA&stavZauctovani=zauctovano
   GET /c/{firma}/saldo.json?castkaMDOd=1000&castkaMDDo=5000&varSymbol=2026001,2026002

Ukázka výstupu (JSON výřez):

.. code-block:: json

   {
       "winstrom": {
           "@version": "1.0",
           "saldo": [
               {
                   "stavUhrK": "",
                   "datVyst": "2018-01-08",
                   "datSplat": "2018-01-22",
                   "mena": "code:CZK",
                   "firma": "code:4219"
               }
           ]
       }
   }
