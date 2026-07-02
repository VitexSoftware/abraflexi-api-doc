Attachments
===========

Export
----------

List of a record's attachments:

.. code-block:: text

   /c/company/adresar/12/prilohy

Metadata of one specific attachment:

.. code-block:: text

   /c/company/adresar/12/prilohy/75

Binary attachment content (the response includes the correct
``Content-Type`` header):

.. code-block:: text

   /c/company/adresar/12/prilohy/75/content

Thumbnail (image attachments only; 404 if none exists):

.. code-block:: text

   /c/company/adresar/12/prilohy/75/thumbnail

Uploading a binary file
----------------------------

.. code-block:: text

   PUT /c/company/adresar/12/prilohy/new/<filename>
   Content-Type: image/jpeg

The binary data must be directly in the request body. An existing
attachment cannot be modified — it must be deleted and re-created.

Import via XML/JSON
------------------------

Importing an attachment embedded (base64) in the parent record's XML/JSON
is also supported, with restrictions: a new attachment must be part of
another object (can't be a root tag), and only metadata can be changed, not
the attachment's data itself. Use the parent evidence's endpoint for this
(e.g. ``/c/company/faktura-vydana.xml``), not the binary endpoint above.

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom>
            <faktura-vydana>
              <id>11925</id>
              <prilohy>
                <priloha update="ignore">
                  <id>ext:DPH-KONTROLA:faktura-vydana:11925</id>
                  <contentType>text/html</contentType>
                  <nazSoub>vies-CZ18239617-2023-01-19.html</nazSoub>
                  <typK>typPrilohy.ostatni</typK>
                  <content encoding="base64">PGh0bWw+PG...</content>
                </priloha>
              </prilohy>
            </faktura-vydana>
          </winstrom>
     - .. code-block:: json

          {
            "winstrom": {
              "faktura-vydana": {
                "id": "11925",
                "prilohy": {
                  "priloha": {
                    "id": "ext:DPH-KONTROLA:faktura-vydana:11925",
                    "contentType": "text/html",
                    "nazSoub": "vies-CZ18239617-2023-01-19.html",
                    "typK": "typPrilohy.ostatni",
                    "content@encoding": "base64",
                    "content": "PGh0bWw+PG..."
                  }
                }
              }
            }
          }

.. note::

   If you import an XML attachment, the API automatically switches to XML
   communication (the JSON header is then ignored).

Exporting an attachment as part of its parent object (base64):

.. code-block:: text

   /c/company/faktura-vydana/1.xml?relations=prilohy

Image support
-----------------

An uploaded attachment of type ``image/jpeg``, ``image/gif`` or
``image/png`` automatically gets a generated thumbnail. Primary image of an
object (404 if none exists):

.. code-block:: text

   /c/company/cenik/12/thumbnail.png?w=<width>&h=<height>

Company settings attachments (logo, signature and stamp)
----------------------------------------------------------------

A special, separate mechanism (not the generic attachment evidence):

.. code-block:: text

   GET    /c/company/nastaveni/1/logo             — check/redirect to existing logo (303) or 404
   PUT/POST /c/company/nastaveni/1/logo           — upload logo (only if none exists yet, else 400)
   DELETE /c/company/nastaveni/1/logo             — delete logo

Successful upload: 201 + ``Location`` header with the new attachment's URL.
Signature and stamp work identically, using ``podpis-razitko`` instead of
``logo``.
