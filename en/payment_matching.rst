Payment matching
====================

A bank (``banka``) or cash (``pokladni-pohyb``) document can be matched
against one or more issued or received invoices.

.. code-block:: xml

   <banka>
     <id>code:BANKA1</id>
     <!-- other normal document fields allowed too -->
     <sparovani>
       <!-- repeat <uhrazovanaFak> per invoice paid; all invoices in one
            <sparovani> must be same type (all faktura-vydana OR all
            faktura-prijata) -->
       <uhrazovanaFak type="faktura-vydana" castka="1000">code:FV1</uhrazovanaFak>
       <zbytek>ignorovat</zbytek>
     </sparovani>
   </banka>

Multiple invoices can be paid in one ``<sparovani>`` (all must be the same
type). Without a ``castka`` attribute, the invoice's full remaining balance
is applied. If ``castka`` is less than the remaining balance, the invoice
becomes partially paid. If it equals the remaining balance exactly, it
behaves as if omitted. With multiple invoices, the paying amount is
consumed in the order listed.

.. warning::

   **The JSON encoding differs** from the flat ``field@attr`` sibling-key
   convention used elsewhere (e.g. for labels). When an element needs both
   attributes and a value, the value goes under a nested ``"filter"`` key:

   .. code-block:: json

      {"winstrom": {"banka": {"id": "code:BANKA1", "sparovani": {
        "uhrazovanaFak": {"@castka": "500.0", "@type": "faktura-vydana", "filter": "code:FV2"},
        "zbytek": "ignorovat"
      }}}}

Remainder handling — the amounts don't match exactly
-------------------------------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 24 25 25 25

   * - ``zbytek`` value
     - remainder = 0 (exact match)
     - remainder > 0 (paying doc has more)
     - remainder < 0 (paying doc has less)
   * - ``ne``
     - fully paired
     - ERROR 400 (amounts don't match)
     - ERROR 400
   * - ``zauctovat``
     - fully paired
     - paired + internal document for the remainder
     - paired + internal document for the remainder
   * - ``ignorovat``
     - fully paired
     - paying document stays unpaired
     - same
   * - ``castecnaUhrada``
     - fully paired
     - ERROR 400 (makes no sense)
     - amount consumed in listed order; invoices that run out of funds stay unpaired
   * - ``castecnaUhradaNeboZauctovat``
     - fully paired
     - paired + internal document for the remainder
     - partial payment
   * - ``castecnaUhradaNeboIgnorovat``
     - fully paired
     - paying document stays unpaired
     - partial payment

Optional overrides on ``<sparovani/>`` (else taken from company settings):
``krTypDokl``/``krTypDoklZisk``/``krTypDoklZtrata``/``krRada``
(FX-difference document), ``zbTypDokl``/``zbTypDoklZisk``/``zbTypDoklZtrata``/
``zbRada`` (remainder document).

Cross-currency matching: a home-currency document can pay foreign-currency
invoices (all must share the same foreign currency) — the paying document
is auto-converted at the rate implied by paying amount ÷ total invoiced amount.

Unpairing
-------------

.. code-block:: xml

   <banka>
     <id>code:BANKA1</id>
     <odparovani>
       <uhrazovanaFak type="faktura-vydana">code:FV1</uhrazovanaFak>  <!-- optional, repeatable -->
     </odparovani>
   </banka>

If ``<uhrazovanaFak>`` is omitted entirely, everything linked to that
document is unpaired. Matching is **idempotent** (safe to repeat).

Automatic matching
-----------------------

.. code-block:: text

   PUT /c/{company}/banka/automaticke-parovani
   PUT /c/{company}/banka/({filter})/automaticke-parovani

Parameters:

- ``mod=`` matching strategy: ``varCasUcet`` (variable symbol + amount +
  account), ``varCas`` (variable symbol + amount, default), ``jenVar``
  (variable symbol only), ``jenCastka`` (amount matches but VS doesn't)
- ``obdobi=`` which accounting periods to search: ``aktualni`` (current),
  ``aktualni-predchozi`` (current + previous), ``vsechna`` (all —
  **API default**; note the app's own default is ``aktualni-predchozi``)
- ``ignorovat-rozdil-castka=`` tolerance for amount mismatch (default 0.0;
  ignored in ``mod=jenVar``); in the currency of the bank document.
- ``zauctovat-rozdil=`` (default ``true``) whether to post an internal
  document for the difference when merging payments with mismatched amounts.

.. code-block:: text

   /c/{company}/banka/automaticke-parovani?mod=jenVar&obdobi=aktualni&ignorovat-rozdil-castka=1.5&zauctovat-rozdil=true

Legacy REST-only endpoint (pre-XML-import matching, still supported)
-----------------------------------------------------------------------------

.. code-block:: text

   /c/{company}/parovani-uhrad

.. code-block:: xml

   <sparovani>
     <uhrazovanaFak type="faktura-prijata">code:FP1</uhrazovanaFak>
     <uhrazujiciDokl type="banka">code:BANKA1</uhrazujiciDokl>
     <zbytek>ignorovat</zbytek>
   </sparovani>

.. code-block:: xml

   <odparovani>
     <uhrazujiciDokl>code:foo</uhrazujiciDokl>  <!-- required -->
     <uhrazovanaFak>code:bar</uhrazovanaFak>    <!-- optional, repeatable -->
   </odparovani>
