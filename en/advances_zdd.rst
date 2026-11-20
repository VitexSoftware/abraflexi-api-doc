Deducting advances and ZDD
==========================

This chapter describes working with advance invoices and advance tax
documents (ZDD, *zálohový daňový doklad*) via the REST API: deduction
on an issued invoice, listing the amounts available for deduction,
creating a ZDD from a payment, creating an invoice from paid advances,
and ZDD links. Source: `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/4729457-odpocet-zaloh-a-zdd-api>`_
and related articles (see the sections below; the sources are in Czech).

Advance deduction
-----------------

A deduction is entered when importing an issued invoice, in the
``odpocty-zaloh`` element (``odpocet`` items).

.. list-table::
   :header-rows: 1
   :widths: 22 78

   * - Element
     - Meaning
   * - ``castkaMen``
     - Amount to deduct, in the document currency.
   * - ``doklad``
     - Identifier of the advance document.
   * - ``id``
     - External ID of the created deduction item.

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <faktura-vydana>
              <id>code:VF-123/2021</id>
              <typDokl>code:FAKTURA</typDokl>
              <polozkyFaktury>
                <faktura-vydana-polozka>
                  <cenik>code:CANON XS1</cenik>
                  <typPolozkyK>typPolozky.katalog</typPolozkyK>
                  <mnozMj>1.0</mnozMj>
                  <sklad>code:SKLAD</sklad>
                </faktura-vydana-polozka>
              </polozkyFaktury>
              <odpocty-zaloh>
                <odpocet>
                  <castkaMen>16300.0</castkaMen>
                  <doklad>code:ZALOHA0001/2010</doklad>
                  <id>ext:odpocet1</id>
                </odpocet>
              </odpocty-zaloh>
            </faktura-vydana>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "@version": "1.0",
                  "faktura-vydana": [{
                      "id": "code:VF-123/2021",
                      "typDokl": "code:FAKTURA",
                      "polozkyFaktury": [{
                          "cenik": "code:CANON XS1",
                          "typPolozkyK": "typPolozky.katalog",
                          "mnozMj": "1.0",
                          "sklad": "code:SKLAD"
                      }],
                      "odpocty-zaloh": [{
                          "castkaMen": 16300,
                          "doklad": "code:ZALOHA0001/2021"
                      }]
                  }]
              }
          }

ZDD deduction
-------------

For a ZDD, amounts are given per VAT rate. The created items get the
suffix ``-ZAKL``, ``-SNIZ``, ``-SNIZ2`` or ``-OSV`` appended to the
external ID.

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:VF-12/2014</id>
       <typDokl>code:FAKTURA</typDokl>
       <odpocty-zaloh>
         <odpocet>
           <castkaZaklMen>400.0</castkaZaklMen>
           <castkaSnizMen>400.0</castkaSnizMen>
           <castkaSniz2Men>400.0</castkaSniz2Men>
           <castkaOsvMen>400.0</castkaOsvMen>
           <doklad>code:ZDD0001/2010</doklad>
           <id>ext:odpocet1</id>
           <castkyBezDph>true</castkyBezDph>
           <skupPlneni>code:TEPLO</skupPlneni>
           <prijmoutDoporuceni>true</prijmoutDoporuceni>
           <castkyVseDostupne>true</castkyVseDostupne>
         </odpocet>
       </odpocty-zaloh>
     </faktura-vydana>
   </winstrom>

.. list-table::
   :header-rows: 1
   :widths: 26 74

   * - Element
     - Meaning
   * - ``castkaZaklMen``, ``castkaSnizMen``, ``castkaSniz2Men``, ``castkaOsvMen``
     - Amounts at the basic, first reduced, second reduced and
       VAT-exempt rate.
   * - ``doklad``
     - ZDD identifier.
   * - ``id``
     - External ID prefix of the created items.
   * - ``castkyBezDph``
     - Optional; ``true`` = amounts are without VAT (default
       ``false``). Sending amounts without VAT is recommended, since ZDD
       deduction is calculated internally without VAT.
   * - ``skupPlneni``
     - Optional; VAT grouping. A group code, ``ALL`` (or omitted = no
       filter) or ``OTHER`` (other group). Use ``OTHER`` when the
       invoice rates differ from the ZDD rates; items are then created
       directly with the ZDD rates. An empty value counts only items
       without a group.
   * - ``prijmoutDoporuceni``
     - Optional; ``true`` = automatically accept the suggested invoice
       corrections.
   * - ``castkyVseDostupne``
     - Optional; ``true`` = deduct everything not yet deducted instead
       of the ``castka*Men`` fields.

Processing happens in two steps: first, items are created from the
invoice's own lines using the invoice VAT rates; any remainder is then
created as overpayment items using the ZDD VAT rates.

.. note::

   Sending ``castkyBezDph`` for a non-accounting advance fails with
   HTTP 400 and code ``zalohyXmlZalohaCastkyBezDph`` ("Amounts without
   VAT cannot be used for non-accounting advances").

Automatic deduction
-------------------

Deducts all advances and ZDDs whose document type has automatic
deduction enabled.

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <typDokl>code:FAKTURA</typDokl>
       <odpocty-zaloh>
         <automaticky-odpocet>true</automaticky-odpocet>
       </odpocty-zaloh>
     </faktura-vydana>
   </winstrom>

* The advance/ZDD document type must have "Allow automatic deduction
  when creating a new document" ticked.
* When importing several invoices with automatic deduction in one XML,
  use ``atomic="false"`` on the ``faktura-vydana`` element.
* For rounding problems, first import the invoice alone with
  ``atomic="false"`` and ``<id>ext:myId</id>``, then send a second
  ``faktura-vydana`` with the same ``ext:myId`` containing
  ``automaticky-odpocet``.

Amounts available for deduction
-------------------------------

Available since ABRA Flexi 2024.3.

.. code-block:: text

   GET /c/{company}/faktura-vydana/{ID}/zalohy-k-odpoctu.xml
   GET /c/{company}/faktura-vydana/{ID}/castky-k-odpoctu.xml
   GET /c/{company}/faktura-vydana/{ID}.xml?relations=zalohy-k-odpoctu
   GET /c/{company}/faktura-vydana/{ID}.xml?relations=castky-k-odpoctu
   GET /c/{company}/faktura-vydana/{ID}/zalohy-k-odpoctu.xml?relations=doporuceni

Both sub-evidences share the same properties: ``zaloha``, ``ucetni``,
``sumOsv``, ``sumZklZakl``, ``sumZklSniz``, ``sumZklSniz2``,
``sumDphZakl``, ``sumDphSniz``, ``sumDphSniz2``, ``sumCelkZakl``,
``sumCelkSniz``, ``sumCelkSniz2``. Amounts are in the document currency.
``ucetni=true`` means deduction as a ZDD; ``false`` a non-accounting
advance, which carries its amount in ``sumOsv`` only. The ``doporuceni``
relation returns the suggested invoice corrections.

.. code-block:: json

   {"winstrom": {"@version": "1.0", "castky-k-odpoctu": [{
       "zaloha": "code:VF1-0005/2024",
       "ucetni": "true",
       "sumOsv": "0.0",
       "sumZklZakl": "3305.79"
   }]}}

(abbreviated). List attributes via the singular names
``zaloha-k-odpoctu/properties`` and ``castky-k-odpoctu/properties``; the
plural ``zalohy-k-odpoctu/properties`` returns 500 because it is a
relation name, not an evidence. An empty result is a valid response. A
misspelled relation name returns 404 ``adresaNeplatnaUrl``.

Creating a ZDD from a payment
-----------------------------

The ``vytvorZDD`` element on a payment document (``banka``,
``pokladni-pohyb``, ``vzajemny-zapocet``) creates a ZDD. On other
evidences the element is silently ignored (200 response, no ZDD
created). The payment must be fully paired with the advance invoice.

.. code-block:: xml

   <winstrom version="1.0">
     <banka>
       <id>code:B-0001/2021</id>
       <vytvorZDD>
         <typDokl>code:ZDD</typDokl>
         <rada>code:FAKTURY</rada>
         <clenDph>code:40-41</clenDph>
         <prenasetCisDosle>true</prenasetCisDosle>
         <castkyDph>
           <zklZakl>100</zklZakl>
           <dphZakl>21</dphZakl>
           <celkZakl>121</celkZakl>
         </castkyDph>
       </vytvorZDD>
     </banka>
   </winstrom>

All parameters are optional; an empty ``<vytvorZDD/>`` (``{}`` in JSON)
works if the company settings define a default document type.

* ``typDokl`` — received/issued invoice type; defaults to the company
  setting.
* ``rada`` — numbering series; derived from the document type.
* ``clenDph`` — VAT classification; derived from the advance.
* ``castkyDph`` — ``zklZakl``, ``dphZakl``, ``celkZakl``, ``zklSniz``,
  ``dphSniz``, ``celkSniz``, ``zklSniz2``, ``dphSniz2``, ``celkSniz2``,
  ``osv``.
* ``prenasetCisDosle`` — ``true``/``false``; if omitted, the received
  number is not carried over.

The result is a new ``faktura-prijata`` with the ZDD ``typDokl`` and a
payment ↔ ZDD link. If the payment is not fully paired, the error is
"Doklad není kompletně spárován. Nelze vygenerovat ZDD."

Invoice from paid advances
--------------------------

A new invoice is created from advances that are already paid. Unlike in
the desktop application, the ID of the **payment** is given, not the
advance.

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <typDokl>code:FAKTURA</typDokl>
       <cisDosle>123</cisDosle>
       <datSplat>2022-01-17</datSplat>
       <vytvorZUhrazenychZaloh>
         <uhrazujiciDokl>code:B+0005/2022</uhrazujiciDokl>
         <uhrazujiciEvidence>banka</uhrazujiciEvidence>
       </vytvorZUhrazenychZaloh>
     </faktura-vydana>
   </winstrom>

* ``uhrazujiciDokl`` — ID of the paying document.
* ``uhrazujiciEvidence`` (mandatory) — ``banka``, ``pokladni-pohyb`` or
  ``vzajemny-zapocet`` (cash is ``pokladni-pohyb``, not ``pokladna``).
* Also works for ``faktura-prijata``.

Restrictions (all HTTP 400): wrong evidence (``akceEvidenceList``);
payment and new document with different movement types (issue ×
receipt); action on an existing document (only new documents are
supported); advances with production numbers are not supported.

ZDD links
---------

A ZDD links to a payment strictly 1:1. Create the link with the
``vytvor-vazbu-zdd`` element on the ZDD:

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:VF1-0001/2017</id>
       <vytvor-vazbu-zdd>
         <uhrada type="banka">code:B+0001/2017</uhrada>
       </vytvor-vazbu-zdd>
     </faktura-vydana>
   </winstrom>

For cash use ``type="pokladni-pohyb"``; without ``type`` the payment is
treated as a bank document. An unknown payment returns 400
``parovaniZddNenalezenUhrazujiciDoklad``. Remove the link with an empty
element:

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:VF1-0001/2017</id>
       <zrus-vazbu-zdd/>
     </faktura-vydana>
   </winstrom>

Related articles: `Amounts for deduction
<https://podpora.flexibee.eu/cs/articles/9148386-castky-k-odpoctu-rest-api>`_,
`Creating a ZDD
<https://podpora.flexibee.eu/cs/articles/6092533-tvorba-zdd-pres-rest-api>`_,
`Invoice from paid advances
<https://podpora.flexibee.eu/cs/articles/6091865-tvorba-faktury-z-uhrazenych-zaloh>`_,
`ZDD links
<https://podpora.flexibee.eu/cs/articles/4731203-vazby-zdd>`_.
