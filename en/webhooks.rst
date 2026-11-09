Web Hooks
=========

Web Hooks let AbraFlexi notify your application about changes in near real
time (usually within a few seconds) instead of you polling the
:doc:`Changes API <changes_api>`. For every registered hook the server sends
an HTTP ``POST`` to the hook's URL; the body lists the changes since the
previous call, in the same format as the Changes API.

Notifications sent to hooks do not count towards the daily API request limit.

Prerequisites
-------------

* The :doc:`Changes API <changes_api>` must be enabled for the company.
* Hooks must be enabled on the server. On self-hosted installations set
  ``enableHooks`` to ``true`` in ``flexibee-server.xml`` (cloud customers
  have this configured already).

Without enabled hooks every ``/hooks`` endpoint returns ``400`` with the
message "Hooks are not enabled in flexibee-server.xml".

Registering a hook
------------------

.. code-block:: text

   PUT or POST /c/{company}/hooks

.. list-table::
   :header-rows: 1
   :widths: 25 15 60

   * - Parameter
     - Required
     - Description
   * - ``url``
     - yes
     - URL the server will call.
   * - ``format``
     - yes
     - ``XML`` or ``JSON`` — format of the notification body.
   * - ``lastVersion``
     - no
     - Start sending from the version following this one. Defaults to the
       current ``globalVersion``; valid range is ``[0, globalVersion]``.
   * - ``secKey``
     - no
     - Secret sent with every notification in the ``X-FB-Hook-SecKey`` HTTP
       header, so you can verify the origin of the call.
   * - ``skipUrlTest``
     - no
     - ``true`` skips the URL test performed at registration.

.. code-block:: bash

   curl -k -L -u user:password -X PUT \
     "https://server:5434/c/company/hooks.xml?url=https://example.com/hook&format=JSON&secKey=s3cret" \
     -H Content-Length:0

At registration the server sends an **empty test notification** to the URL.
If the response is not ``2xx``, the hook is not registered. Success returns
``200``; failure returns ``400`` with a description. HTTPS virtual hosts are
supported (SNI) since version 2017.1.1.

A hook cannot be filtered by record or evidence — it receives **every**
change, and your application has to pick the relevant ones itself.

Listing and unregistering
-------------------------

.. code-block:: text

   GET    /c/{company}/hooks          — list registered hooks
   DELETE /c/{company}/hooks/{id}     — unregister a hook

Notification body
-----------------

The body is the same change listing as returned by ``/c/{company}/changes``
(see :doc:`changes_api`): ``globalVersion``, the changed records with
``in-version`` / ``operation`` (``create`` / ``update`` / ``delete``) and ids,
and ``next``. The notification only identifies *what* changed — fetch the
current data of the record through the regular API.

Failures, retries and redirects
-------------------------------

* A failed call is retried; while failures continue the delay between
  attempts grows (a "penalty").
* Hooks are stored in the database and survive a server restart. No change is
  lost — all changes are delivered once the endpoint recovers.
* Current penalty: ``GET /c/{company}/hooks/{id}``.
* Reset the penalty and call immediately: ``PUT /c/{company}/hooks/{id}/retry``.

Response codes of your endpoint with special meaning:

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - Code
     - Effect
   * - ``2xx``
     - Notification accepted.
   * - ``301`` / ``308``
     - The hook's URL is updated to the redirect target; notifications resume
       there after a short penalty.
   * - ``410``
     - The hook is considered permanently cancelled and is unregistered
       automatically.
   * - other
     - Failure — retried with penalty.

Receiver recommendations
------------------------

* Delivery is *best effort*: expect delays and **duplicates**; use
  ``globalVersion`` to deduplicate.
* Answer quickly — aim for under 15 seconds, the hard limit is 30 seconds.
  Violating it penalizes the hook and may eventually disable it.
* Return ``200`` (or another ``2xx``) with an empty body.
* Persist the received changes immediately and process them asynchronously.
* Verify the ``X-FB-Hook-SecKey`` header if you registered a ``secKey``.
* After downtime, or if you suspect a gap, resynchronize through the
  Changes API (``?start=`` the last processed version).

Company restore
---------------

When restoring a company, the ``disableWebHooks`` option deregisters all
hooks (see :doc:`company_management`).
