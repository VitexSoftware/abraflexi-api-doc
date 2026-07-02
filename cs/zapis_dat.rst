Zápis dat
=============

Povinné položky importu
----------------------------

- Obvykle stačí vyplnit jen to, co byste museli zadat i při ručním založení
  záznamu v aplikaci.
- Některé položky je nutné uvést, i když má aplikace výchozí hodnotu —
  import ji sám nedoplní.
- Téměř vždy je povinný typ dokladu (``<typDokl/>``) — určuje mnoho dalších
  výchozích hodnot.
- Uvádí se pouze hodnota tagu; atributy ``ref`` a ``showAs`` jsou při
  importu ignorovány (slouží jen k vizualizaci exportu).
- Vazby na jiné systémy se dělají přes identifikátory (``code:``, ``ext:``,
  ``ean:``, ...).
- Nutnost vyplnit konkrétní pole se může lišit podle typu dokladu.

Vnitřní vazby mezi poli
----------------------------

Při ukládání se doplní výchozí hodnoty pro nevyplněná pole. Některá pole
závisí na jiných (typ dokladu ovlivňuje sazby DPH apod.) — server sestaví
strom závislostí a aplikuje hodnoty v pořadí závislosti, aby "řídicí" pole
bylo nastaveno dřív než na něm závislé. Díky tomu **nezáleží na pořadí
atributů uvnitř jednoho záznamu v XML/JSON** (ale záleží na pořadí
jednotlivých *záznamů* v dávce — např. firma musí být založena dřív než
objednávka, která na ni odkazuje).

Vedlejší efekt: uložení může změnit i pole, které nebylo v požadavku
explicitně měněno (kaskáda závislostí) — to platí i pro inkrementální
(částečné) aktualizace.

Inkrementální (částečná) aktualizace
------------------------------------------

Při aktualizaci stačí uvést jen atributy, které se mají změnit. Explicitně
prázdný element hodnotu smaže:

.. code-block:: xml

   <cenik id="123">
     <nazevA>Nový název</nazevA>
     <ean/>  <!-- smazaná hodnota -->
   </cenik>

Položky dokladu (např. faktury): pokud položka nemá uveden identifikátor,
řídí se **pořadím** — rizikové pro update (vložení na začátek posune
všechno ostatní a odpojí navázaná data od špatného řádku). Doporučeno vždy
uvádět externí identifikátor položky.

Aktualizace bez identifikátoru vždy **přidává** nové položky. Pro úplné
nahrazení kolekce (smazání všeho neuvedeného) použijte ``removeAll="true"``:

.. code-block:: xml

   <faktura-vydana id="123">
     <polozkyFaktury removeAll="true">
       <faktura-vydana-polozka><id>14</id>...</faktura-vydana-polozka>
     </polozkyFaktury>
   </faktura-vydana>

.. code-block:: json

   {"winstrom": {"faktura-vydana": [{
     "id": "123",
     "polozkyFaktury@removeAll": "true",
     "polozkyFaktury": [{"id": "14", "...": "..."}]
   }]}}

Vše, co v seznamu chybí, se smaže; uvedené položky se aktualizují/vytvoří.
Přímé smazání konkrétních položek: ``action="delete"`` (viz
:doc:`akce_zamykani`). Stejný mechanismus platí i pro aktualizaci štítků
(viz :doc:`stitky_atributy_vazby`).

Režim pro založení / změnu
-------------------------------

Element ``update="..."`` řídí chování podle existence záznamu:

.. list-table::
   :header-rows: 1
   :widths: 20 20 40

   * - Operace
     - Režim
     - Popis
   * - Založení
     - ``ignore``
     - Pokud záznam neexistuje, ignoruj požadavek na založení.
   * - Založení
     - ``fail``
     - Pokud záznam neexistuje, operace selže.
   * - Založení
     - ``ok`` (výchozí)
     - Pokud záznam neexistuje, normálně jej založ.
   * - Změna
     - ``ignore``
     - Pokud záznam už existuje, ignoruj požadavek na změnu.
   * - Změna
     - ``fail``
     - Pokud záznam už existuje, operace selže.
   * - Změna
     - ``ok`` (výchozí)
     - Pokud záznam existuje, normálně jej změň.

.. code-block:: xml

   <faktura-vydana update="ignore"><id>123</id>...</faktura-vydana>

Obdobný mechanismus pro **relace** — atribut ``if-not-found`` na vazebním
elementu:

.. list-table::
   :header-rows: 1
   :widths: 25 55

   * - Hodnota
     - Popis
   * - ``null``
     - Pokud odkazovaný záznam neexistuje, vazbu nenastavuj (zůstane prázdná).
   * - ``nearest-invalid``
     - Pokud odkaz kódem existoval v minulosti, ale už neplatí, naváže se
       na nejmladší již neplatný záznam (podle data dokladu/události) — pro
       import historických dokladů s vazbou na již neplatná čísla účtů.
   * - ``create``
     - Pokud odkazovaný záznam neexistuje, automaticky se založí (vyplní se
       jen kód/název z hodnoty odkazu) — nelze pro evidence s dalšími
       povinnými poli.

.. code-block:: xml

   <firma if-not-found="null">code:FIRMA</firma>

Předchozí hodnota — reakce na skutečnou změnu
----------------------------------------------------

Používá se s ``?dry-run=true`` při stavbě interaktivních editačních
formulářů: server spustí kaskádu závislých hodnot pole (viz výše) jen
pokud se hodnota **skutečně** změnila oproti tomu, co klient naposledy
viděl.

.. code-block:: xml

   <faktura-vydana id="123">
     <firma previousValue="code:JINA FIRMA">code:FIRMA</firma>
     <nazFirmy>Jiná firma</nazFirmy>  <!-- stará hodnota z formuláře -->
   </faktura-vydana>

Odpověď doplní ``nazFirmy`` na aktuální název firmy (``Firma``), protože
server detekoval reálnou změnu ``firma``. Bez ``previousValue`` by server
vzal odeslané ``nazFirmy`` doslovně (nepřepočítal by jej), protože nemá jak
poznat, že ke změně došlo. V JSON: sourozenecký klíč ``"{pole}-previousValue"``.
Lze uvést více najednou.

Datum poslední změny
-------------------------

Každý záznam má ``lastUpdate`` (používá i ABRA Flexi Sync k detekci změn) —
lze použít i ve filtru. Pro skutečné sledování změn/synchronizaci ale
doporučeno spíše specializované :doc:`changes_api`.

Výpočet DPH — kontrolní vzorce
-------------------------------------

U položkového dokladu je celkové DPH součtem DPH jednotlivých položek, na
výsledek se aplikuje zaokrouhlení. Musí platit (s ohledem na zaokrouhlení):

.. code-block:: text

   sumDphCelkem = sumDphSniz + sumDphZakl
   sumCelkem = sumOsv + sumZklSniz*szbDphSniz + sumZklZakl*sumDphZakl
   sumCelkZakl = sumZklZakl * sumDphZakl
   sumCelkSniz = sumZklSniz * sumDphSniz
   sumZklCelkem = sumOsv + sumZklSniz + sumZklZakl

Stejná sada s příponou ``Men`` platí pro částky v cizí měně (musí navíc
odpovídat i přepočtu mezi měnami). Chyba "Zadaná hodnota [...] vlastnosti
[sumCelkem] se liší od vypočtené hodnoty [...]" znamená porušení některé z
těchto identit. Nejjednodušší je uvádět jen základy a nechat zbytek
dopočítat AbraFlexi.
