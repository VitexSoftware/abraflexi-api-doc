Validation and error handling
===================================

Data validation
--------------------

Saving runs validation with three severity levels:

- **error** — the record cannot be saved because of it; the whole operation
  is cancelled.
- **warning** — a problem was found, but the record **was saved**.
- **info** — extra information, the record was saved.

On error, processing stops immediately. On warnings/infos, the full import
proceeds and all resulting statuses are returned at the end. To make
warnings block saving too, add ``?fail-on-warning=true``. To validate
without saving, use ``?dry-run=true`` (see :doc:`requests`).

Example response with a warning and an info:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <success>true</success>
            <result>
              <id>105</id>
              <warnings>
                <warning for="radekDph">The record has no VAT line filled in, so the document won't be posted.</warning>
              </warnings>
              <infos>
                <info>A serial number was auto-selected.</info>
              </infos>
            </result>
            <result><id>103</id></result>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "success": true,
                  "results": [
                      {
                          "id": "105",
                          "warnings": [
                              {"for": "radekDph", "message": "The record has no VAT line filled in, so the document won't be posted."}
                          ],
                          "infos": [
                              {"message": "A serial number was auto-selected."}
                          ]
                      },
                      {
                          "id": "103"
                      }
                  ]
              }
          }

The ``for`` attribute on ``<warning>`` points to the field the message
concerns.

Error handling — HTTP status codes
----------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 15 60

   * - Code
     - Meaning
   * - 200 OK
     - Operation succeeded.
   * - 201 Created
     - Record was created; ``Location`` header + identifier in the body.
   * - 304 Not Modified
     - Record wasn't modified (used with ``If-Modified-Since``).
   * - 400 Bad Request
     - Bad request, typically a PUT referencing a non-existent object.
   * - 401 Unauthorized
     - Login is required.
   * - 402 Payment Required
     - The target system doesn't have the write REST API activated
       (read operations return 404 instead).
   * - 403 Forbidden
     - User has no permission, or it's not allowed by the license.
   * - 404 Not Found
     - Record (evidence or specific record) not found.
   * - 405 Method Not Allowed
     - A disallowed method was used (e.g. POST where only GET is allowed).
   * - 406 Not Acceptable
     - The target format isn't supported for this resource (e.g. exporting
       an address book as ISDOC).
   * - 500 Internal Server Error
     - Internal server error — always a bug in AbraFlexi's code, please report it.

Example error response:

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <?xml version="1.0"?>
          <winstrom version="1.0">
            <success>false</success>
            <result>
              <id>105</id>
              <error>A numeric ID was expected, but 'null' is not a number</error>
            </result>
          </winstrom>
     - .. code-block:: json

          {
              "winstrom": {
                  "success": false,
                  "results": [
                      {
                          "id": "105",
                          "error": "A numeric ID was expected, but 'null' is not a number"
                      }
                  ]
              }
          }

The error message format is the same as the validation message format above.
