Batch API (admin)
=================

Pro partnerská řešení, která spravují instance AbraFlexi (zejména v
cloudu), admin **Batch API** přijme seznam operací nad uživateli a firmami
a vykoná je atomicky na jednom serveru. Odlišné od
:doc:`davky_transakce` (hromadné úpravy uvnitř databáze firmy). Zdroj:
`podpora.flexibee.eu
<https://podpora.flexibee.eu/cs/articles/4786921-batch-api>`_.

.. warning::

   Stav API je zatím **beta**. Před produkčním použitím důkladně ověřte
   na testovacím prostředí. Operace jsou idempotentní — opakování přeskočí
   již provedenou práci.

Endpoint
--------

.. code-block:: text

   PUT https://server:7000/admin/batch
   Content-Type: application/xml

Verzeované cesty ``/v2/admin/batch`` a ``/v3/admin/batch`` přijímají i
běžně přihlášeného uživatele s právy ``manageAll`` a ``licenseMgmt``
(omezeno na jeho licenční skupiny). Neverzeovaná ``/admin/batch`` zůstává
vyhrazena serverové autorizaci.

Autorizace
----------

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Způsob
     - Kde
   * - Serverové jméno/heslo
     - Jen vlastní instalace — ``/etc/flexibee/server-auth.xml``
       (heslo ≥ 15 znaků).
   * - Klientský certifikát
     - Cloud (HTTPS port **7000**); SHA1 fingerprint u podpory.
   * - Přihlášený administrátor
     - Jen verzeované cesty; cizí licenční skupina → ``FAILED``.

Impersonace po serverové autorizaci: hlavička
``X-FlexiBee-Authorization: username``.

Ukázka dávky
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

Typické akce ``user`` / ``company``: ``create-update`` (výchozí),
``delete``, blokace (``blocked``), skrytí/zobrazení firmy (``show``),
změny rolí přes ``defaultRole`` / ``access``.

Standardní role: ``ADMIN``, ``SUPERUZIVATEL``, ``MZDOVYUCETNI``,
``UCETNI``, ``OBCHODNIK``, ``SKLADNIK``, ``SKLADNIKSPOKLADNOU``,
``UZIVATEL``, ``JENCIST``, ``ZABLOKOVAN``.

Organizační ``type``: ``PODNIKATELE``, ``PODNIKATELE+PU``,
``PODNIKATELE+DE``, ``ROZPOCTOVE``, ``NEZISKOVE``, ``PODNIKATELIA`` (SK).

Hash hesel: ``sha256`` (výchozí), ``sha512``, ``sha1``, ``md5``,
``pbkdf2``. Digest z ``salt + ":" + heslo``, lowercase hex; uloženo jako
``hash:salt:digest``.

Odpověď
-------

HTTP **200** pro celou dávku **neznamená**, že všechny položky uspěly.
Každý ``<entry>`` má vlastní stav (``CREATED``, ``SKIPPED``, ``FAILED``,
…) — vždy je kontrolujte.
