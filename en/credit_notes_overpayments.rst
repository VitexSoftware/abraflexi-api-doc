Credit notes and overpayments
=============================

This chapter describes linking credit notes to invoices and creating an
overpayment from a payment via the REST API. Mutual set-offs and the
``zbytek`` parameter are in :doc:`payment_matching`. Sources:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/4744457-dobropisy>`_ and `Creating
an overpayment via REST API
<https://podpora.flexibee.eu/cs/articles/6091847-vytvoreni-preplatku-pomoci-rest-api>`_
(both in Czech).

Credit notes
------------

A credit note is tied to its invoice by a link. Via the REST API you can
either attach an existing credit note to an invoice
(``vytvor-vazbu-dobropis``), or have the whole credit note created from
selected items of the original document (``dobropisuj``). Both elements are
used when importing ``faktura-vydana`` and ``faktura-prijata``. The target
document must be of the credit-note type, otherwise the import fails with
``parovaniDobropisuNeniDobropis``.

Attaching an existing credit note
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:DOBROPIS1</id>
       <vytvor-vazbu-dobropis>
         <dobropisovanyDokl>code:FAKTURA1</dobropisovanyDokl>
       </vytvor-vazbu-dobropis>
     </faktura-vydana>
   </winstrom>

One credit note can be linked to only one invoice (a second attempt fails
with ``parovaniDobropisuLzeJenJednou``). The link covers the header only,
not the items.

Creating a credit note from invoice items
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

* ``polozkyDokladu`` is mandatory, otherwise ``validace.notNull``.
* With ``dobropisuj`` quantities are given as positive numbers. A credit
  note created by a regular import, on the other hand, requires negative
  quantities (``polDoklDobropisChybaZaporneMnozstvi``).
* Serial and set numbers are passed in ``vyrobniCislaId`` and
  ``vyrobniCislaSad``.
* With ``?dry-run=true`` the test returns ``id`` = ``-1``.

Automatic set-off
~~~~~~~~~~~~~~~~~

Since version 2025.4.0, both ``dobropisuj`` and ``vytvor-vazbu-dobropis``
accept an optional ``<vytvorZapocet>true</vytvorZapocet>`` element, which
also creates a set-off. It must be accompanied by
``<typDoklZapocet>code:ZAPOCET</typDoklZapocet>``, otherwise the import fails
with ``importXmlEmptyIdentifier``.

Removing the link
~~~~~~~~~~~~~~~~~

.. code-block:: xml

   <winstrom version="1.0">
     <faktura-vydana>
       <id>code:DOBROPIS1</id>
       <zrus-vazbu-dobropis/>
     </faktura-vydana>
   </winstrom>

Only a link created with ``vytvor-vazbu-dobropis`` can be removed; a link
created by ``dobropisuj`` fails with ``parovaniDobropisuNelzeZrusit``.

Errors (all HTTP 400)
~~~~~~~~~~~~~~~~~~~~~

``parovaniDobropisuNeniDobropis``,
``parovaniDobropisuNenalezenDobropisovanyDoklad``,
``parovaniDobropisuLzeJenJednou``, ``parovaniDobropisuNelzeZrusit``,
``polDoklDobropisChybaNotFound``, ``polDoklDobropisChybaMaxReal``,
``polDoklDobropisChybaZaporneMnozstvi``, ``validace.notNull``,
``importXmlEmptyIdentifier``.

Overpayment from a payment
--------------------------

The ``<preplatek>`` element on a payment document (``banka``,
``pokladni-pohyb``, ``vzajemny-zapocet``) moves the unmatched part of the
payment to a receivable (for an expense) or a payable (for an income).
``typDokl`` is required, ``rada`` is optional.

.. warning::

   On any other evidence ``<preplatek>`` is silently ignored — the call
   returns ``200`` but nothing is created.

.. code-block:: xml

   <winstrom version="1.0">
     <banka>
       <id>code:B+0001/2021</id>
       <preplatek>
         <typDokl>code:OST. ZÁVAZKY</typDokl>
       </preplatek>
     </banka>
   </winstrom>

The result is a ``zavazek`` with the description "Přeplatek (B+0001/2021)"
and a link to the payment. For an expense document (``code:B-0001/2022``)
and the type ``code:OST. POHLEDÁVKY`` a ``pohledavka`` is created
analogously. The new payable or receivable is already matched with the
payment, so the payment is not offered among unmatched paying documents.
