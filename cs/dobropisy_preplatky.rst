Dobropisy a přeplatky
=====================

Kapitola popisuje provázání dobropisů s fakturami a vytvoření přeplatku
z platby přes REST API. Vzájemné zápočty a parametr ``zbytek`` jsou v kapitole
:doc:`parovani_plateb`. Zdroj: `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/4744457-dobropisy>`_ a `Vytvoření
přeplatku pomocí REST API
<https://podpora.flexibee.eu/cs/articles/6091847-vytvoreni-preplatku-pomoci-rest-api>`_.

Dobropisy
---------

Dobropis je s fakturou svázán vazbou. Přes REST API lze buď připojit již
existující dobropis k faktuře (``vytvor-vazbu-dobropis``), nebo nechat celý
dobropis vytvořit z vybraných položek původního dokladu (``dobropisuj``).
Oba elementy se používají při importu ``faktura-vydana`` a ``faktura-prijata``.
Cílový doklad musí být typu dobropis, jinak import skončí chybou
``parovaniDobropisuNeniDobropis``.

Připojení existujícího dobropisu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:DOBROPIS1</id>
       <vytvor-vazbu-dobropis>
         <dobropisovanyDokl>code:FAKTURA1</dobropisovanyDokl>
       </vytvor-vazbu-dobropis>
     </faktura-vydana>
   </winstrom>

Jeden dobropis lze svázat jen s jednou fakturou (podruhé
``parovaniDobropisuLzeJenJednou``). Vazba se týká jen hlavičky, nikoli
položek.

Vytvoření dobropisu z položek faktury
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <typDokl>code:DOBROPIS</typDokl>
       <dobropisuj>
         <dobropisovanyDokl>code:VF1-0001/2021</dobropisovanyDokl>
         <polozkyDokladu>
           <polozka>
             <id>123</id>
             <mnozMj>1</mnozMj>
           </polozka>
         </polozkyDokladu>
       </dobropisuj>
     </faktura-vydana>
   </winstrom>

* ``polozkyDokladu`` je povinné, jinak ``validace.notNull``.
* Množství se u ``dobropisuj`` zadává kladné. Dobropis vytvářený běžným
  importem naopak vyžaduje záporné množství
  (``polDoklDobropisChybaZaporneMnozstvi``).
* Výrobní čísla a čísla sad se předávají v ``vyrobniCislaId`` a
  ``vyrobniCislaSad``.
* S ``?dry-run=true`` vrací test ``id`` = ``-1``.

Automatický zápočet
~~~~~~~~~~~~~~~~~~~

Od verze 2025.4.0 přijímají ``dobropisuj`` i ``vytvor-vazbu-dobropis``
nepovinný element ``<vytvorZapocet>true</vytvorZapocet>``, který vytvoří také
zápočet. Je k němu nutné uvést
``<typDoklZapocet>code:ZAPOCET</typDoklZapocet>``, jinak import skončí chybou
``importXmlEmptyIdentifier``.

Zrušení vazby
~~~~~~~~~~~~~

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:DOBROPIS1</id>
       <zrus-vazbu-dobropis/>
     </faktura-vydana>
   </winstrom>

Zrušit lze jen vazbu vytvořenou přes ``vytvor-vazbu-dobropis``; vazba z
``dobropisuj`` skončí chybou ``parovaniDobropisuNelzeZrusit``.

Chyby (všechny HTTP 400)
~~~~~~~~~~~~~~~~~~~~~~~~

``parovaniDobropisuNeniDobropis``,
``parovaniDobropisuNenalezenDobropisovanyDoklad``,
``parovaniDobropisuLzeJenJednou``, ``parovaniDobropisuNelzeZrusit``,
``polDoklDobropisChybaNotFound``, ``polDoklDobropisChybaMaxReal``,
``polDoklDobropisChybaZaporneMnozstvi``, ``validace.notNull``,
``importXmlEmptyIdentifier``.

Přeplatek z platby
------------------

Element ``<preplatek>`` na platebním dokladu (``banka``, ``pokladni-pohyb``,
``vzajemny-zapocet``) přesune nespárovanou část platby do pohledávky (u
výdaje) nebo závazku (u příjmu). ``typDokl`` je povinné, ``rada`` volitelné.

.. warning::

   Na jiné evidenci se ``<preplatek>`` tiše ignoruje — volání vrátí ``200``,
   ale nic se nevytvoří.

.. code-block:: xml

   <winstrom version="1.0">
     <banka>
       <id>code:B+0001/2021</id>
       <preplatek>
         <typDokl>code:OST. ZÁVAZKY</typDokl>
       </preplatek>
     </banka>
   </winstrom>

Výsledkem je ``zavazek`` s popisem „Přeplatek (B+0001/2021)“ a vazbou na
platbu. Pro výdajový doklad (``code:B-0001/2022``) a typ
``code:OST. POHLEDÁVKY`` vznikne analogicky ``pohledavka``. Nový závazek nebo
pohledávka je už s platbou spárována, takže se platba nenabízí mezi
nespárovanými úhradami.
