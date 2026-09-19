Balance (saldo)
===============

Like most accounting outputs, the balance-reconciliation listing
(``saldo``) can be generated via the REST API. Source:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/en/articles/8650590-balance-rest-api>`_.

Calling
-------

.. code-block:: text

   GET /c/{company}/saldo.xml
   GET /c/{company}/saldo.json

No parameter is required. General listing parameters (pagination, detail
level, …) also apply.

Parameters
----------

.. list-table::
   :header-rows: 1
   :widths: 32 68

   * - Parameter
     - Meaning
   * - ``stavUhrady``
     - ``uhrazeno`` or ``neuhrazeno``. Omit to return all.
   * - ``filtrUcty``
     - Accounts, prefixes or ranges, comma-separated — e.g.
       ``311000,32,3-4``.
   * - ``filtrProtiucty``
     - Counter-accounts, same notation — e.g. ``211001,21,1-2``.
   * - ``datumUctovaniOd``, ``datumUctovaniDo``
     - Posting date range (``yyyy-MM-dd``).
   * - ``datumVystaveniOd``, ``datumVystaveniDo``
     - Issue date range (``yyyy-MM-dd``).
   * - ``modul``
     - Accounting module; repeatable. Values:
       ``modulUcetni.FAP``, ``FAV``, ``BAN``, ``POK``, ``SKL``, ``INT``,
       ``PHL``, ``ZAV``, ``MAJ``, ``LEA``, ``TXP``, ``TXZ``.
   * - ``castkaMDOd`` / ``Do``, ``castkaMDMenOd`` / ``Do``
     - Debit amount range (domestic / foreign currency).
   * - ``castkaDalOd`` / ``Do``, ``castkaDalMenOd`` / ``Do``
     - Credit amount range (domestic / foreign currency).
   * - ``stredisko``, ``zakazka``, ``firma``
     - Repeatable; import identifier, e.g. ``code:CENTRALA``.
   * - ``stavZauctovani``
     - ``zauctovano``, ``nezauctovano`` or ``vse``.
   * - ``popis``
     - Full-text description filter.
   * - ``cisloDokladu``, ``varSymbol``, ``parSymbol``
     - Internal number, variable or matching symbol; comma-separated.

.. warning::

   Invalid enumerated values (``stavUhrady``, ``stavZauctovani``,
   ``modul``) return ``400`` ``unsupported_param_value_exception`` with
   allowed options. An **unknown parameter name** is silently ignored —
   a typo simply disables that filter.

.. note::

   Here ``modul`` uses the ``modulUcetni.`` prefix. Payment status as of a
   date uses bare ``FAV``, ``PHL``, ``FAP``, ``ZAV``.

Sample calls
------------

.. code-block:: text

   GET /c/{company}/saldo.json?stavUhrady=neuhrazeno
   GET /c/{company}/saldo.json?stavUhrady=neuhrazeno&filtrUcty=311001,311002
   GET /c/{company}/saldo.json?modul=modulUcetni.FAV&modul=modulUcetni.FAP&stredisko=code:CENTRALA&stavZauctovani=zauctovano
   GET /c/{company}/saldo.json?castkaMDOd=1000&castkaMDDo=5000&varSymbol=2026001,2026002

Sample output (JSON excerpt):

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
