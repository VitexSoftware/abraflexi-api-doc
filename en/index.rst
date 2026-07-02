.. image:: _static/abraflexi.svg
   :align: center
   :width: 140px
   :alt: AbraFlexi logo
   :target: https://github.com/VitexSoftware/abraflexi-api-doc

AbraFlexi REST API Reference
================================

This guide summarizes the AbraFlexi (FlexiBee) REST API — not any specific
client library, but the HTTP interface of the AbraFlexi server itself, as
usable by any client in any language.

Content is compiled and translated from the official documentation at
`podpora.flexibee.eu <https://podpora.flexibee.eu/cs/collections/2592813-dokumentace-rest-api>`_
and cross-checked against the reference PHP AbraFlexi library. It focuses on
generic REST API mechanics applicable across evidences; it does not cover
business-domain-specific topics of individual modules (payroll, VAT filing,
warehouse internals, etc.) or the XML schema — examples throughout use
**JSON**.

.. toctree::
   :maxdepth: 2

   authentication
   requests
   listing_filtering
   identifiers
   writing_data
   validation_errors
   actions_locking
   batch_transactions
   attachments
   changes_api
   company_management
   labels_attributes_relations
   payment_matching
   copy_reports_qr
   workflow
   evidence_list
   agenda_permissions

Quick overview
------------------

Basic URL shape:

.. code-block:: text

   https://server:port/c/<company identifier>/<evidence>/<record ID>.<format>

- **Authentication**: HTTP Basic, or a JSON login session token (``authSessionId``).
- **Format**: JSON and XML are both fully supported (CSV, XLS, PDF, ISDOC,
  EDI, vCard, iCalendar for export); this guide sticks to JSON.
- **Reading**: GET on a listing (no ID) or detail (with ID) URL, with
  optional filtering, sorting, pagination and detail level.
- **Writing**: PUT/POST with the same data shape as reading; AbraFlexi
  doesn't distinguish create from update — it's determined by whether the
  identifier already exists.
- **Deleting**: HTTP DELETE, or the more general ``action="delete"`` on any evidence.

Resources
---------

- Official documentation: https://podpora.flexibee.eu/cs/collections/2592813-dokumentace-rest-api
- Demo instance: https://demo.flexibee.eu (user/password ``winstrom``/``winstrom``)
