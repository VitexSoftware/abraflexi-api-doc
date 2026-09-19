Stock recalculation
===================

Warehouse recalculation checks and recalculates stock levels and prices for
the selected accounting period. It can be triggered via REST API in the same
way as in the application. Source: `podpora.flexibee.eu
<https://podpora.flexibee.eu/en/articles/5098676-warehouse-recalculation-rest-api>`_.

Calling the service
-------------------

The service is available via ``PUT`` and ``POST`` at:

.. code-block:: text

   /c/{company}/sklad/prepocet

Supported output formats are XML and JSON.

Parameters
----------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Parameter
     - Description
   * - ``ucetniObdobi``
     - **Required.** Identifies the period for which you want to
       recalculate the warehouse. Specified as an identifier in the form
       ``code:2024``.
   * - ``dry-run``
     - Optional. Used to determine whether the recalculation has been
       completed. If so, returns HTTP status ``200``. If not, returns
       HTTP status ``409`` along with information about when and by whom
       the recalculation was started.

Result
------

To determine whether the service was executed successfully, check either
the HTTP status of the response or the ``success`` property in the returned
document.

On success, HTTP status ``200`` is returned with a standard response
document:

.. code-block:: json

   {"winstrom": {"@version": "1.0", "success": "true"}}

On failure, status ``4xx`` or ``5xx`` is returned along with a message
explaining the reason.

Sample calls
------------

.. code-block:: text

   PUT /c/{company}/sklad/prepocet.xml?ucetniObdobi=code:2024
   PUT /c/{company}/sklad/prepocet.json?ucetniObdobi=code:2024
   PUT /c/{company}/sklad/prepocet?ucetniObdobi=code:2024

For the last call without an extension, the format is determined by the
``Accept: application/xml`` or ``Accept: application/json`` header.
