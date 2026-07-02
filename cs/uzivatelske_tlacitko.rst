Uživatelské tlačítko
==========================

Uživatelské tlačítko (evidence ``custom-button``) definuje tlačítko
zobrazené ve výpisu nebo na kartě záznamu dané evidence. Po kliknutí se
otevře URL — sestavená z šablony s dosazenými hodnotami z aktuálního
záznamu — buď v externím prohlížeči, nebo v interním panelu. Zdroj:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/4786901-uzivatelske-tlacitko>`_,
ověřeno proti referenční implementaci `Flexplorer
<https://github.com/VitexSoftware/Flexplorer>`_ (``getbuttonxml.php`` /
``Flexplorer\xml\FelexiBeeButtonXML``), která přes REST API generuje a
instaluje celou sadu takových tlačítek.

Pole
--------

- ``id`` — identifikátor tlačítka pro vytvoření/aktualizaci/smazání, stejná
  pravidla jako u kteréhokoli jiného identifikátoru evidence (``code:``,
  ``ext:`` nebo číselné ID ABRA Flexi); při vytváření je nutný identifikátor
  ``code:``.
- ``url`` — cílová URL v absolutním tvaru (schéma + doména). Doporučeno
  obalit ``<![CDATA[ ]]>``, aby nevznikaly problémy s escapováním ``&`` v
  query stringu. Schéma ``file://`` je při importu odmítnuto.
- ``title`` — text tlačítka.
- ``description`` — text nápovědy (tooltip).
- ``evidence`` — na záznamech které evidence se tlačítko zobrazuje (např.
  ``adresar``, ``faktura-vydana``; pro evidenci položek např.
  ``faktura-vydana-polozka``).
- ``location`` — ``list`` (výpis záznamů) nebo ``detail`` (karta
  konkrétního záznamu). Pro zobrazení na obou místech je nutné vytvořit dva
  samostatné záznamy ``custom-button``.
- ``browser`` *(nepovinné)* — ``desktop`` (otevřít v externím prohlížeči)
  nebo ``automatic`` (interní panel, s fallbackem na externí; výchozí
  hodnota). Webové rozhraní toto nastavení ignoruje.

Všechna pole kromě ``browser`` jsou povinná.

Vytvoření
-------------

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <custom-button>
              <id>code:JUSTICECZ</id>
              <url><![CDATA[https://or.justice.cz/ias/ui/rejstrik-$firma?ico=${object.ic}]]></url>
              <title>Obch. rejstřík</title>
              <description>Zobrazit firmu v obchodním rejstříku</description>
              <evidence>adresar</evidence>
              <location>detail</location>
              <browser>desktop</browser>
            </custom-button>
          </winstrom>
     - .. code-block:: json

          {"winstrom": {"@version": "1.0", "custom-button": [{
              "id": "code:JUSTICECZ",
              "url": "https://or.justice.cz/ias/ui/rejstrik-$firma?ico=${object.ic}",
              "title": "Obch. rejstřík",
              "description": "Zobrazit firmu v obchodním rejstříku",
              "evidence": "adresar",
              "location": "detail",
              "browser": "desktop"
          }]}}

Aktualizace: stačí uvést ``id`` a měněná pole, stejně jako u kterékoli jiné
evidence (viz :doc:`zapis_dat`). Smazání: ``action="delete"`` na elementu
``custom-button`` spolu s ``id`` (viz :doc:`akce_zamykani`):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <custom-button action="delete"><id>code:JUSTICECZ</id></custom-button>
     - .. code-block:: json

          {"winstrom": {"custom-button": [
              {"@action": "delete", "id": "code:JUSTICECZ"}
          ]}}

Proměnné v šabloně URL
---------------------------

Pole ``url`` je šablona vyhodnocovaná pro každý záznam; dostupné proměnné:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Proměnná
     - Význam
   * - ``${object}``
     - Vlastnosti aktuálního záznamu (jen když je cílem jeden záznam —
       vzájemně se vylučuje s ``${objectIds}``).
   * - ``${objectIds}``
     - Seznam ID vybraných záznamů oddělený čárkou (výpis, vícenásobný
       výběr).
   * - ``${user}``
     - Data přihlášeného uživatele.
   * - ``${url}``
     - Plná REST API URL záznamu.
   * - ``${companyUrl}``
     - Základní REST API URL aktuální firmy.
   * - ``${evidence}``
     - Název evidence, na které je tlačítko zobrazeno.
   * - ``${authSessionId}``
     - Přihlašovací token, použitelný pro volání API z otevřené stránky.
   * - ``${customerNo}``
     - Zákaznické číslo licence.
   * - ``${licenseId}``
     - Identifikátor licence.
   * - ``${flexiUrl}``
     - URL webového rozhraní.
   * - ``${language}``
     - Jazyk desktopové aplikace.

Například ``${object.ic}`` dosadí pole ``ic`` (IČ firmy) aktuálního
záznamu a ``query.php?evidence=${evidence}&id=${objectIds}`` (jak jej
používá vlastní instalátor Flexploreru) sestaví odkaz najednou na všechny
vybrané záznamy.
