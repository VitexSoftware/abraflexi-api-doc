Writing data
================

Required import fields
---------------------------

- Usually, you only need to fill in what you'd have to enter manually when
  creating the record in the app.
- Some fields still need to be given even though the app offers a default —
  import doesn't fill it in on its own.
- Almost always, the document type (``<typDokl/>``) is required — it drives
  many other defaults.
- Only the tag's value matters; ``ref``/``showAs`` attributes are ignored on
  import (export-only decoration).
- When linking to another system, use appropriate identifiers (``code:``,
  ``ext:``, ``ean:``, ...).
- Which fields are required can vary by document type.

Internal field dependencies
--------------------------------

On save, defaults get filled in for anything you don't set. Some fields
depend on others (e.g. document type or VAT country determine VAT rates) —
the server builds a dependency tree and applies values in dependency order,
so the "driving" field is set before fields that derive from it. Thanks to
this, **the order of attributes within one record in XML/JSON does NOT
matter** (but the order *between* separate records in a batch DOES —
e.g. create the customer before the order that references it).

Side effect: saving can change a field's value even if you didn't explicitly
touch it (dependency cascade) — this also applies during incremental
(partial) updates.

Incremental (partial) update
---------------------------------

On update, only include the attributes you want to change. An explicitly
empty element deletes that field's value:

.. code-block:: xml

   <cenik id="123">
     <nazevA>New name</nazevA>
     <ean/>  <!-- clears the value -->
   </cenik>

Line items (e.g. invoice lines): if an item has no identifier, it's matched
by POSITION — risky for updates (inserting at the front shifts everything
and detaches linked data from the wrong row). Always give each line an
external identifier if possible.

Updating items without identifiers always APPENDS new rows. To fully
replace a collection (delete anything not listed), use ``removeAll="true"``:

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

Everything not listed gets deleted; listed items are updated/created.
Direct deletion of specific items: ``action="delete"`` (see
:doc:`actions_locking`). The same mechanism applies to updating labels
(see :doc:`labels_attributes_relations`).

Create/update conflict mode
--------------------------------

The ``update="..."`` attribute controls behaviour depending on whether the
record already exists:

.. list-table::
   :header-rows: 1
   :widths: 20 20 40

   * - Operation
     - Mode
     - Description
   * - Create
     - ``ignore``
     - If the record doesn't exist, ignore the create request.
   * - Create
     - ``fail``
     - If the record doesn't exist, fail the operation.
   * - Create
     - ``ok`` (default)
     - If the record doesn't exist, create it normally.
   * - Update
     - ``ignore``
     - If the record already exists, ignore the update request.
   * - Update
     - ``fail``
     - If the record already exists, fail the operation.
   * - Update
     - ``ok`` (default)
     - If the record exists, update it normally.

.. code-block:: xml

   <faktura-vydana update="ignore"><id>123</id>...</faktura-vydana>

A similar mechanism exists for **relation fields** via the ``if-not-found``
attribute on the relation element:

.. list-table::
   :header-rows: 1
   :widths: 25 55

   * - Value
     - Meaning
   * - ``null``
     - If the referenced record isn't found by code, don't set the relation
       (leave it empty).
   * - ``nearest-invalid``
     - If a coded reference used to exist but is no longer valid, link to
       the most-recently-invalidated matching record (by document/event
       date) — useful when importing historic documents that reference
       now-defunct bank accounts etc.
   * - ``create``
     - Auto-create the referenced record if missing (for codebook-type
       evidences); only fills in ``kod``/``nazev`` from the reference value
       — can't be used if the target evidence has other required fields.

.. code-block:: xml

   <firma if-not-found="null">code:FIRMA</firma>

Previous value — reacting only to a real change
------------------------------------------------------

Used together with ``?dry-run=true`` when building interactive edit forms:
the server only runs a field's dependent-value cascade (see above) if the
value actually *changed* relative to what the client last saw.

.. code-block:: xml

   <faktura-vydana id="123">
     <firma previousValue="code:OTHER COMPANY">code:FIRMA</firma>
     <nazFirmy>Other company</nazFirmy>  <!-- stale value from the form -->
   </faktura-vydana>

The response recomputes ``nazFirmy`` to match the new ``firma`` (returns
``Company``), because the server detected a real change. Without
``previousValue``, the server can't tell whether ``firma`` actually changed,
so it takes the submitted ``nazFirmy`` literally instead of recomputing it.
In JSON: sibling key ``"{field}-previousValue"``. Multiple can be used per request.

Last-update field
----------------------

Every record has ``lastUpdate`` (used by ABRA Flexi Sync to detect changes)
— also usable in filters. For real change tracking/sync, prefer the
dedicated :doc:`changes_api` over polling ``lastUpdate``.

VAT calculation — cross-check identities
-----------------------------------------------

For a line-item document, total VAT is the sum of line-item VATs, with
rounding applied to the total. These identities must hold (give or take
rounding):

.. code-block:: text

   sumDphCelkem = sumDphSniz + sumDphZakl
   sumCelkem = sumOsv + sumZklSniz*szbDphSniz + sumZklZakl*sumDphZakl
   sumCelkZakl = sumZklZakl * sumDphZakl
   sumCelkSniz = sumZklSniz * sumDphSniz
   sumZklCelkem = sumOsv + sumZklSniz + sumZklZakl

The same set with a ``Men`` suffix (foreign-currency amounts) must also
cross-check against the base-currency set. The error "Zadaná hodnota [...]
vlastnosti [sumCelkem] se liší od vypočtené hodnoty [...]" means one of
these identities was violated. Simplest: only supply the bases and let
AbraFlexi compute the rest.
