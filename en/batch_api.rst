Batch API (admin)
=================

For partner solutions that manage AbraFlexi instances (especially in the
cloud), the admin **Batch API** accepts a list of user and company
operations and executes them atomically on one server. Distinct from
:doc:`batch_transactions` (bulk edits inside a company database). Source:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/en/articles/4786921-batch-api>`_.

.. warning::

   Status is currently **beta**. Verify thoroughly on a test environment
   before production use. Operations are idempotent — retries skip work
   already done.

Endpoint
--------

.. code-block:: text

   PUT https://server:7000/admin/batch
   Content-Type: application/xml

Versioned paths ``/v2/admin/batch`` and ``/v3/admin/batch`` also accept a
regularly logged-in user with ``manageAll`` and ``licenseMgmt`` rights
(limited to their licence groups). The non-versioned ``/admin/batch``
remains reserved for server authorization.

Authorization
-------------

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Method
     - Where
   * - Server username/password
     - Self-hosted only — configure
       ``/etc/flexibee/server-auth.xml`` (password ≥ 15 characters).
   * - Client certificate
     - Cloud (HTTPS port **7000**); SHA1 fingerprint registered with
       support.
   * - Logged-in administrator
     - Versioned paths only; foreign licence groups → ``FAILED``.

Impersonation after server auth: header
``X-FlexiBee-Authorization: username``.

Sample batch
------------

.. code-block:: xml

   <?xml version="1.0"?>
   <flexibee-batch id="abc-123">
     <user>
       <username>anna.mlada</username>
       <password hash="sha256" salt="xyz987">af123bd35</password>
       <email>anna.mlada@firma.cz</email>
       <givenName>Anna</givenName>
       <familyName>Mladá</familyName>
       <permissions>
         <manageAll>true</manageAll>
         <createCompany>true</createCompany>
         <deleteCompany>true</deleteCompany>
         <createUser>false</createUser>
         <changePassword>false</changePassword>
         <grantPermission>true</grantPermission>
         <licenseManagement>false</licenseManagement>
       </permissions>
       <defaultRole>UZIVATEL</defaultRole>
     </user>
     <company action="create-update">
       <id>moje_firma_s_r_o_</id>
       <name>Moje Firma s.r.o.</name>
       <country>CZ</country>
       <regNo>123</regNo>
       <vatId>CZ123</vatId>
       <type>PODNIKATELE</type>
       <adminUser>anna.mlada</adminUser>
     </company>
     <company action="delete">
       <id>demo_a_s_</id>
     </company>
   </flexibee-batch>

Typical ``user`` / ``company`` actions: ``create-update`` (default),
``delete``, block/unblock (``blocked``), hide/show company (``show``),
role changes via ``defaultRole`` / ``access``.

Standard roles: ``ADMIN``, ``SUPERUZIVATEL``, ``MZDOVYUCETNI``,
``UCETNI``, ``OBCHODNIK``, ``SKLADNIK``, ``SKLADNIKSPOKLADNOU``,
``UZIVATEL``, ``JENCIST``, ``ZABLOKOVAN``.

Organization ``type``: ``PODNIKATELE``, ``PODNIKATELE+PU``,
``PODNIKATELE+DE``, ``ROZPOCTOVE``, ``NEZISKOVE``, ``PODNIKATELIA`` (SK).

Password hashes: ``sha256`` (default), ``sha512``, ``sha1``, ``md5``,
``pbkdf2``. Digest of ``salt + ":" + password``, lowercase hex; stored as
``hash:salt:digest``.

Response
--------

HTTP **200** for the batch overall does **not** mean every item succeeded.
Each ``<entry>`` carries its own status (``CREATED``, ``SKIPPED``,
``FAILED``, …) — always inspect them.
