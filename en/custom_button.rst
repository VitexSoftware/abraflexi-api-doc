Custom buttons
====================

A custom button (``custom-button`` evidence, "uživatelské tlačítko" in the
UI) registers a button shown in an evidence's list or detail view. Clicking
it opens a URL — built from a template with the current record's data
substituted in — either in an external browser or an internal panel.
Source: `podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/4786901-uzivatelske-tlacitko>`_,
cross-checked against the `Flexplorer
<https://github.com/VitexSoftware/Flexplorer>`_ reference implementation
(``getbuttonxml.php`` / ``Flexplorer\xml\FelexiBeeButtonXML``), which
generates and installs a full set of these buttons via the REST API.

Fields
----------

- ``id`` — identifies the button for create/update/delete, same rules as
  any other evidence identifier (``code:``, ``ext:`` or a numeric ABRA
  Flexi id); a ``code:`` identifier is required on create.
- ``url`` — the target URL, in absolute form (scheme + domain). Wrap it in
  ``<![CDATA[ ]]>`` to avoid XML-escaping issues with ``&`` in query
  strings. The ``file://`` scheme is rejected on import.
- ``title`` — button label.
- ``description`` — tooltip text.
- ``evidence`` — which evidence's records show the button (e.g.
  ``adresar``, ``faktura-vydana``; for a line-item evidence use e.g.
  ``faktura-vydana-polozka``).
- ``location`` — ``list`` (record overview) or ``detail`` (single record
  card). Create two separate ``custom-button`` records to show the button
  in both places.
- ``browser`` *(optional)* — ``desktop`` (open in an external browser) or
  ``automatic`` (internal panel, falling back to external; this is the
  default). Ignored by the web interface.

Every field except ``browser`` is required.

Create
----------

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <winstrom version="1.0">
            <custom-button>
              <id>code:JUSTICECZ</id>
              <url><![CDATA[https://or.justice.cz/ias/ui/rejstrik-$firma?ico=${object.ic}]]></url>
              <title>Obch. rejstřík</title>
              <description>Display company record in commercial registry</description>
              <evidence>adresar</evidence>
              <location>detail</location>
              <browser>desktop</browser>
            </custom-button>
          </winstrom>
     - .. code-block:: json

          {"winstrom": {"@version": "1.0", "custom-button": [{
              "id": "code:JUSTICECZ",
              "url": "https://or.justice.cz/ias/ui/rejstrik-$firma?ico=${object.ic}",
              "title": "Obch. rejstřík",
              "description": "Display company record in commercial registry",
              "evidence": "adresar",
              "location": "detail",
              "browser": "desktop"
          }]}}

Update: submit only the ``id`` plus the fields to change, same as any other
evidence (see :doc:`writing_data`). Delete: ``action="delete"`` on the
``custom-button`` element plus its ``id`` (see :doc:`actions_locking`):

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - XML
     - JSON
   * - .. code-block:: xml

          <custom-button action="delete"><id>code:JUSTICECZ</id></custom-button>
     - .. code-block:: json

          {"winstrom": {"custom-button": [
              {"@action": "delete", "id": "code:JUSTICECZ"}
          ]}}

URL template variables
----------------------------

The ``url`` field is a template evaluated per record; available variables:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Variable
     - Meaning
   * - ``${object}``
     - Attributes of the current record (only when a single record is
       targeted — mutually exclusive with ``${objectIds}``).
   * - ``${objectIds}``
     - Comma-separated list of selected record IDs (list view, multiple
       selection).
   * - ``${user}``
     - Data of the currently logged-in user.
   * - ``${url}``
     - Full REST API URL of the record.
   * - ``${companyUrl}``
     - Base REST API URL of the current company.
   * - ``${evidence}``
     - Name of the evidence the button is shown on.
   * - ``${authSessionId}``
     - Authentication token, usable to call the API from the opened page.
   * - ``${customerNo}``
     - License customer number.
   * - ``${licenseId}``
     - License identifier.
   * - ``${flexiUrl}``
     - URL of the web interface.
   * - ``${language}``
     - Language of the desktop application.

For example ``${object.ic}`` inserts the ``ic`` (company ID number) field
of the current record, and
``query.php?evidence=${evidence}&id=${objectIds}`` (as used by Flexplorer's
own installer) builds a link back to every selected record at once.
