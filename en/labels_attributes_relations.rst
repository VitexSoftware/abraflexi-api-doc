Labels, attributes and user relations
============================================

Labels
----------

Labels ("štítky") can be attached to almost any object (documents, address
book, jobs, ...), or even to sub-states (e.g. payment method) — useful for
signalling an external system.

A label must first exist in the label codebook before it can be assigned.

Working with labels is technically a relation emulated as an item
collection — the same ``removeAll="true"`` mechanism as line items (see
:doc:`writing_data`):

.. code-block:: xml

   <adresar><id>14</id><stitky removeAll="true"/></adresar>  <!-- clears all -->
   <stitky removeAll="true">LABEL1,NEW_LABEL</stitky>          <!-- replaces the whole set -->

Without ``removeAll``, labels are just added (existing ones kept). JSON:
``"stitky@removeAll": "true", "stitky": "LABEL1,NEW_LABEL"``.

**Label groups**: a label can belong to a group; if the group is configured
"only one label allowed", assigning a new label from that group
automatically removes any other label from the same group — a simple way
to emulate a state machine. Export by group:
``?skupina-stitku=GROUP1,GROUP2`` — the output annotates the ``<stitky>``
element with per-group attributes:

.. code-block:: xml

   <stitky GROUP1="LABEL1" GROUP2="LABEL2">LABEL1,LABEL2,LABEL3</stitky>

Attributes (custom fields on price list & address book)
----------------------------------------------------------------

Free-form custom fields for ``cenik`` (price list) and ``adresar`` (address
book) records, via a dedicated ``atribut`` evidence. Address book
attributes: REST API only for create/edit/delete (though viewing them is
also exposed in the desktop app). Price list attributes: full CRUD in both
API and desktop/web app.

Export attributes of one record (id-only, no general filtering):

.. code-block:: text

   GET /c/{company}/cenik/{id}/atributy.xml
   GET /c/{company}/adresar/{id}/atributy.xml

Export via the generic ``atribut`` evidence (supports normal filtering by
code or id):

.. code-block:: text

   GET /c/{company}/atribut/(cenik='code:CENIK').xml
   GET /c/{company}/atribut/(adresar='code:FIRMA').xml

Create:

.. code-block:: xml

   <atribut>
     <hodnota>LEATHER</hodnota>
     <cenik>code:SUITCASE</cenik>  <!-- or <adresar>code:FIRMA</adresar> -->
     <typAtributu>code:MATERIAL</typAtributu>
   </atribut>

Update: same shape + ``<id>``. Delete: same shape + ``<id>`` +
``action="delete"`` on the ``<atribut>`` element (see :doc:`actions_locking`).

User-defined relations
---------------------------

Links any object to any other, tagged with a relation type. Two kinds:
manual (created via UI/import) and automatic (auto-populated per a saved
filter configured on the relation type).

Read: ``GET /c/{company}/{evidence}/{id}/uzivatelske-vazby``. The linked
object can be included directly in the export
(``?detail=full&includes=/winstrom/uzivatelska-vazba/object``), or via the
owning record's ``relations=`` (``?relations=uzivatelske-vazby``).

Create (nested under the owning record):

.. code-block:: xml

   <adresar>
     <id>109</id>
     <uzivatelske-vazby>
       <uzivatelska-vazba>
         <id>ext:VAZBA:TESTEXTID-CEN</id>
         <evidenceType>cenik</evidenceType>
         <object>code:SKL-0001/2022</object>
         <popis>description</popis>
         <poznam>note</poznam>
         <vazbaTyp>code:ADRCEN</vazbaTyp>
       </uzivatelska-vazba>
     </uzivatelske-vazby>
   </adresar>

.. code-block:: json

   {"winstrom": {"interni-doklad": [{"id": "1054", "uzivatelske-vazby": [
     {"vazbaTyp": "code:INT-FAV", "evidenceType": "faktura-vydana", "object": "code:VF1-0073/2022"}
   ]}]}}

Delete (standalone on the relation's own evidence, not nested):

.. code-block:: xml

   <uzivatelska-vazba action="delete"><id>ext:VAZBA:TESTEXTID-CEN</id></uzivatelska-vazba>
