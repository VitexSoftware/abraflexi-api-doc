Web Hooks
=========

Web Hooks umožňují, aby AbraFlexi upozornilo vaši aplikaci na změny téměř
v reálném čase (obvykle do několika sekund), místo aby se aplikace
dotazovala přes :doc:`Changes API <changes_api>`. Pro každý registrovaný hook
server odešle HTTP ``POST`` na jeho URL; tělo obsahuje seznam změn od
předchozího volání ve stejném formátu jako Changes API.

Notifikace odeslané na hooky se nezapočítávají do denního limitu API
požadavků.

Předpoklady
-----------

* Pro firmu musí být zapnuté :doc:`Changes API <changes_api>`.
* Na serveru musí být povoleny hooky. U vlastní instalace nastavte
  ``enableHooks`` na ``true`` v ``flexibee-server.xml`` (v cloudu je to
  nastaveno).

Bez povolených hooků vrací všechny endpointy ``/hooks`` kód ``400`` se
zprávou „Hooks are not enabled in flexibee-server.xml“.

Registrace hooku
----------------

.. code-block:: text

   PUT nebo POST /c/{firma}/hooks

.. list-table::
   :header-rows: 1
   :widths: 25 15 60

   * - Parametr
     - Povinný
     - Popis
   * - ``url``
     - ano
     - URL, které server volá.
   * - ``format``
     - ano
     - ``XML`` nebo ``JSON`` — formát těla notifikace.
   * - ``lastVersion``
     - ne
     - Posílat změny od verze následující po této. Výchozí je aktuální
       ``globalVersion``; platný rozsah je ``[0, globalVersion]``.
   * - ``secKey``
     - ne
     - Tajný řetězec posílaný s každou notifikací v HTTP hlavičce
       ``X-FB-Hook-SecKey`` pro ověření původu volání.
   * - ``skipUrlTest``
     - ne
     - ``true`` přeskočí test URL při registraci.

.. code-block:: bash

   curl -k -L -u user:password -X PUT \
     "https://server:5434/c/firma/hooks.xml?url=https://example.com/hook&format=JSON&secKey=s3cret" \
     -H Content-Length:0

Při registraci server pošle na URL **prázdnou testovací notifikaci**. Pokud
odpověď není ``2xx``, hook se nezaregistruje. Úspěch vrací ``200``, neúspěch
``400`` s popisem. HTTPS virtuální hosty jsou podporovány (SNI) od verze
2017.1.1.

Hook nelze filtrovat podle záznamu ani evidence — dostává **všechny** změny
a relevantní si musí vybrat aplikace sama.

Výpis a odregistrace
--------------------

.. code-block:: text

   GET    /c/{firma}/hooks          — seznam registrovaných hooků
   DELETE /c/{firma}/hooks/{id}     — odregistrace hooku

Tělo notifikace
---------------

Tělo je stejný výpis změn, jaký vrací ``/c/{firma}/changes`` (viz
:doc:`changes_api`): ``globalVersion``, změněné záznamy s ``in-version`` /
``operation`` (``create`` / ``update`` / ``delete``) a identifikátory
a ``next``. Notifikace říká pouze *co* se změnilo — aktuální data záznamu si
načtěte běžným API.

Selhání, opakování a přesměrování
---------------------------------

* Neúspěšné volání se opakuje; při trvajících chybách se prodlužuje prodleva
  mezi pokusy („penalizace“).
* Hooky jsou uloženy v databázi a přežijí restart serveru. Žádná změna se
  neztratí — po obnovení endpointu se doručí všechny.
* Aktuální penalizace: ``GET /c/{firma}/hooks/{id}``.
* Zrušení penalizace a okamžité zavolání: ``PUT /c/{firma}/hooks/{id}/retry``.

Odpovědi vašeho endpointu se zvláštním významem:

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Kód
     - Účinek
   * - ``2xx``
     - Notifikace přijata.
   * - ``301`` / ``308``
     - URL hooku se změní na cíl přesměrování; notifikace pokračují tam po
       krátké penalizaci.
   * - ``410``
     - Hook je považován za trvale zrušený a automaticky se odregistruje.
   * - ostatní
     - Selhání — opakování s penalizací.

Doporučení pro příjemce
-----------------------

* Doručení je *best effort*: počítejte se zpožděním a **duplicitami**;
  k deduplikaci použijte ``globalVersion``.
* Odpovídejte rychle — cíl je do 15 sekund, tvrdý limit je 30 sekund.
  Překročení hook penalizuje a nakonec může vyřadit.
* Vraťte ``200`` (nebo jiné ``2xx``) s prázdným tělem.
* Přijaté změny okamžitě uložte a zpracujte asynchronně.
* Pokud jste zadali ``secKey``, ověřujte hlavičku ``X-FB-Hook-SecKey``.
* Po výpadku nebo při podezření na mezeru se znovu synchronizujte přes
  Changes API (``?start=`` poslední zpracovaná verze).

Obnova firmy
------------

Při obnově firmy volba ``disableWebHooks`` odregistruje všechny hooky (viz
:doc:`sprava_firem`).
