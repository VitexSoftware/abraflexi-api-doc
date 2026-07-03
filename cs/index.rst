.. image:: _static/abraflexi.svg
   :align: center
   :width: 140px
   :alt: logo AbraFlexi
   :target: https://github.com/VitexSoftware/abraflexi-api-doc

Dokumentace REST API AbraFlexi
=================================

Tato příručka shrnuje REST API systému AbraFlexi (FlexiBee) — nejde o
dokumentaci žádné konkrétní klientské knihovny (např. ``python-abraflexi``),
ale o samotné HTTP rozhraní AbraFlexi serveru, jak jej může využít libovolný
klient v libovolném jazyce.

Obsah je sestaven a přeložen z oficiální dokumentace na
`podpora.flexibee.eu <https://podpora.flexibee.eu/cs/collections/2592813-dokumentace-rest-api>`_
a doplněn o ověření proti referenční PHP knihovně AbraFlexi. Zaměřuje se na obecné
mechanismy REST API použitelné napříč evidencemi; nepokrývá vyloženě obchodní
témata jednotlivých agend (mzdy, DPH přiznání, sklad do detailu apod.) ani XML
schéma — příklady všude používají formát **JSON**.

.. toctree::
   :maxdepth: 2

   autentizace
   pozadavky
   vypis_filtrovani
   identifikatory
   zapis_dat
   validace_chyby
   akce_zamykani
   inicializace_obdobi
   davky_transakce
   prilohy
   changes_api
   sprava_firem
   stitky_atributy_vazby
   uzivatelske_tlacitko
   parovani_plateb
   kopie_tisky_qr
   workflow
   seznam_evidenci
   prava_agend

Rychlý přehled
------------------

Základní tvar URL:

.. code-block:: text

   https://server:port/c/<identifikátor firmy>/<evidence>/<ID záznamu>.<formát>

- **Autentizace**: HTTP Basic, nebo JSON přihlašovací token (``authSessionId``).
- **Formát**: JSON i XML jsou plnohodnotně podporovány (CSV, XLS, PDF, ISDOC,
  EDI, vCard, iCalendar pro export); tato příručka se drží JSON.
- **Čtení**: GET na výpisové (bez ID) nebo detailní (s ID) URL, s volitelnou
  filtrací, řazením, stránkováním a úrovní detailu.
- **Zápis**: PUT/POST se stejnou strukturou dat jako u čtení; AbraFlexi
  nerozlišuje vytvoření a aktualizaci — určuje to podle existence identifikátoru.
- **Mazání**: HTTP DELETE, nebo obecnější ``action="delete"`` na libovolné evidenci.

Zdroje
------

- Oficiální dokumentace: https://podpora.flexibee.eu/cs/collections/2592813-dokumentace-rest-api
- Demo instance: https://demo.flexibee.eu (uživatel/heslo ``winstrom``/``winstrom``)
