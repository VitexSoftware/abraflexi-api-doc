Authentication
==============

AbraFlexi offers two basic REST API authentication methods, plus an
advanced one for server-side solutions.

HTTP authentication
-----------------------

The simplest method — send a standard ``Authorization: Basic`` header with
every request:

.. code-block:: bash

   curl -u winstrom:winstrom \
     'https://demo.flexibee.eu:5434/c/demo/adresar.json?detail=custom:kod&limit=1'

If the header is missing, the server redirects to a login form, or returns
``401 Authorization required``. Credentials can also be sent directly in the
URL: ``https://user:password@server:5434/c/company/evidence``. The
``?auth=http`` parameter forces HTTP auth even where SSO would otherwise be
offered; ``?auth=html`` forces the login form.

JSON authentication (login session)
-----------------------------------------

Useful when making multiple requests and you don't want to resend the
password each time. Obtaining a token:

.. code-block:: text

   POST /login-logout/login.json

Request body (raw JSON, not form data):

.. code-block:: json

   {
       "username": "novak",
       "password": "password",
       "otp": "123456"
   }

``otp`` is optional (one-time password, if two-factor login is required).
This method only returns results as JSON.

Successful response:

.. code-block:: json

   {
       "success": true,
       "authSessionId": "00112233445566778899aabbccddeeff..."
   }

Failed response:

.. code-block:: json

   {
       "success": false,
       "errors": {"reason": "Wrong username or password was entered."}
   }

The obtained token can be passed on subsequent requests in three ways:

- Cookie: ``authSessionId=00112233...``
- HTTP header: ``X-authSessionId: 00112233...``
- URL parameter: ``?authSessionId=00112233...`` (careful: in this case
  credentials get logged on the server)

To keep the token alive, periodically call
``GET /login-logout/session-keep-alive.js`` (recommended every ~60s, though
once every 30 minutes should suffice). If you have a ``refreshToken``, a new
``authSessionId`` can be obtained via ``GET /login-logout/check`` with that
token sent as a cookie.

Logging out a specific user:

.. code-block:: text

   POST /status/user/{username}/logout

A custom login form can be embedded on another site via a plain HTML form
posting to ``/login-logout/login.html`` (supports a ``returnUrl`` parameter,
and ``otp`` for two-factor login; not usable with SSO — OpenID or SAMLv2).

.. note::

   Practical note: some HTTP clients (curl, Postman) require the
   ``application/x-www-form-urlencoded`` or ``multipart/form-data`` header
   for ``/login-logout/login.json``, otherwise the request body may not be
   recognized correctly.

Server-side authorization (impersonation)
-----------------------------------------------

For trusted server-to-server integrations on a self-hosted install, create
``/etc/flexibee/server-auth.xml`` with a service account:

.. code-block:: xml

   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
   <properties>
     <comment>WinStrom server configuration</comment>
     <entry key="username">server-admin</entry>
     <entry key="password">password</entry>
   </properties>

Then the ``X-FlexiBee-Authorization`` header can specify which user the
request should be processed as (impersonation). This feature is planned to
be superseded by SSL client-certificate authentication; SSL certificate
import via the API is possible without a logged-in user using this server auth.

Access rights and roles
----------------------------

The web interface (and REST API the same way) automatically enforces access
rights defined on the user's role:

- A user might have no access to an evidence at all, or read-only access.
- They might see/edit only some records (e.g. only their own department).
- They might see/edit only some columns (e.g. without purchase prices).
- The application license might not permit a feature at all.

If an import modifies fields the user has no rights to, those changes are
silently ignored; if it would modify a whole record without rights, the
whole operation is rejected with an error.

Roles themselves are accessible via the ``role`` evidence:

.. code-block:: text

   GET  /c/{company}/role                — list of roles
   GET  /c/{company}/role/{ID}           — a role including all its permissions
   PUT/POST /c/{company}/role            — create/update a role

A new (user-defined, ``standard=false``) role must have ``kod``, ``nazev``
and ``otecRole`` (base/parent role it inherits permissions from, unless
explicitly overridden in the request). Standard (``standard=true``) roles
are immutable; their permission ids have the form ``uuid:{roleCode}-{permissionKey}``.

Example: set a specific permission on an existing role (issued invoices
read-only, received invoices fully inaccessible):

.. code-block:: json

   {
     "winstrom": {
       "role": {
         "id": "code:ADMIN_COPY",
         "pristPrava": {
           "pristupove-pravo": [
             {"groupKey": "dDoklFak$$FAV", "typeK": "typPristPrav.pouzeCist"},
             {"groupKey": "dDoklFak$$FAP", "typeK": "typPristPrav.nepripustne"}
           ]
         }
       }
     }
   }

``typeK`` values: ``typPristPrav.plny`` (full access), ``nepripustne``
(no access), ``pouzeCist`` (read-only), ``upresneni`` (refined, via
``featureK`` sub-features — Pridavat/Menit/Mazat/Export/Import/
OteviratDetail/Sloupce/Kusovnik/Storno/SlevaZmenaCeny/Sumace/Sluzby/Vazby/
HromZmeny/NakupCena/...).

Users as an evidence
-------------------------

Users are a normal evidence (``uzivatel``); creating a new user additionally
requires matching ``password``/``passwordAgain``:

.. code-block:: xml

   <uzivatel>
     <id>code:einstein</id>
     <kod>einstein</kod>
     <jmeno>Albert</jmeno>
     <prijmeni>Einstein</prijmeni>
     <password>password</password>
     <passwordAgain>password</passwordAgain>
     <role>code:JENCIST</role>
   </uzivatel>

Last login is tracked in ``lastLoginDate`` (regular users) /
``lastApiDate`` (API users), visible via ``GET /u.json?detail=full``
(the ``/u/`` prefix = server-level, outside any specific company).
