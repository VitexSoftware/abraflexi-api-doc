Autentizace
===========

AbraFlexi nabízí dva základní způsoby autentizace přes REST API a jeden
pokročilý pro serverová řešení.

HTTP autentizace
-----------------

Nejjednodušší způsob — odešlete standardní hlavičku ``Authorization: Basic``
s každým požadavkem:

.. code-block:: bash

   curl -u winstrom:winstrom \
     'https://demo.flexibee.eu:5434/c/demo/adresar.json?detail=custom:kod&limit=1'

Pokud hlavička chybí, server přesměruje na přihlašovací formulář, případně
vrátí ``401 Authorization required``. Přihlašovací údaje lze zaslat i přímo
v URL: ``https://jmeno:heslo@server:5434/c/firma/evidence``. Parametr
``?auth=http`` vynutí HTTP autentizaci i tam, kde by se jinak nabízelo SSO;
``?auth=html`` vynutí přihlašovací formulář.

JSON autentizace (autentizační sezení)
------------------------------------------

Vhodné, pokud budete provádět více požadavků a nechcete opakovaně posílat
heslo. Získání tokenu:

.. code-block:: text

   POST /login-logout/login.json

Tělo požadavku (raw JSON, ne formulářová data):

.. code-block:: json

   {
       "username": "novak",
       "password": "heslo",
       "otp": "123456"
   }

``otp`` je nepovinné (jednorázové heslo, pokud je vyžadováno dvoufázové
přihlášení). Metoda vrací výsledek pouze ve formátu JSON.

Úspěšná odpověď:

.. code-block:: json

   {
       "success": true,
       "authSessionId": "00112233445566778899aabbccddeeff..."
   }

Neúspěšná odpověď:

.. code-block:: json

   {
       "success": false,
       "errors": {"reason": "Bylo zadáno chybné uživatelské jméno či heslo."}
   }

Získaný token lze u dalších požadavků předávat třemi způsoby:

- Cookie: ``authSessionId=00112233...``
- HTTP hlavička: ``X-authSessionId: 00112233...``
- URL parametr: ``?authSessionId=00112233...`` (pozor: v tomto případě se
  přihlašovací údaje logují na serveru)

Aby token zůstal platný, je potřeba jej udržovat pravidelným voláním
``GET /login-logout/session-keep-alive.js`` (doporučeno každých cca 60 s,
stačí i jednou za 30 minut). Pokud máte k dispozici ``refreshToken``, lze
nové ``authSessionId`` získat i requestem ``GET /login-logout/check`` s tímto
tokenem v cookie.

Odhlášení konkrétního uživatele:

.. code-block:: text

   POST /status/user/{username}/logout

Vlastní přihlašovací formulář lze umístit i na cizí stránku pomocí prostého
HTML formuláře odesílajícího na ``/login-logout/login.html`` (podporuje
parametr ``returnUrl`` a u dvoufázového přihlášení i ``otp``; s SSO — OpenID
nebo SAMLv2 — tuto metodu nelze použít).

.. note::

   Praktická poznámka: u některých HTTP klientů (curl, Postman) je pro
   ``/login-logout/login.json`` nutné nastavit hlavičku
   ``application/x-www-form-urlencoded`` nebo ``multipart/form-data``, jinak
   tělo požadavku nemusí být správně rozpoznáno.

Serverová autorizace (impersonace)
--------------------------------------

Pro důvěryhodné server-to-server integrace na vlastní instalaci lze vytvořit
``/etc/flexibee/server-auth.xml`` se servisním účtem:

.. code-block:: xml

   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
   <properties>
     <comment>WinStrom server configuration</comment>
     <entry key="username">server-admin</entry>
     <entry key="password">heslo</entry>
   </properties>

Poté lze hlavičkou ``X-FlexiBee-Authorization`` určit, pod kterým uživatelem
má být požadavek zpracován (impersonace). Tato funkce je plánovaná k náhradě
autentizací pomocí SSL klientského certifikátu; import SSL certifikátu přes
API je s touto autorizací možný i bez přihlášení uživatele.

Přístupová práva a role
----------------------------

Webové rozhraní (a REST API stejně tak) automaticky uplatňuje přístupová
práva definovaná u uživatelské role:

- Uživatel nemusí mít k evidenci přístup vůbec, nebo jen pro čtení.
- Vidět/měnit může jen některé záznamy (např. jen svého střediska).
- Vidět/měnit může jen některé sloupečky (např. bez nákupních cen).
- Licence aplikace nemusí danou funkci vůbec povolovat.

Pokud import modifikuje i pole, na která uživatel nemá právo, jsou tyto
změny tiše ignorovány; pokud by šlo o modifikaci celého záznamu bez práva,
operace je s chybou zamítnuta celá.

Role samotné jsou přístupné přes evidenci ``role``:

.. code-block:: text

   GET  /c/{firma}/role                — seznam rolí
   GET  /c/{firma}/role/{ID}           — role včetně všech přístupových práv
   PUT/POST /c/{firma}/role            — vytvoření/úprava role

Nová (uživatelská, ``standard=false``) role musí mít ``kod``, ``nazev`` a
``otecRole`` (výchozí/rodičovská role, ze které přebírá práva, pokud nejsou
v požadavku explicitně přepsána). Standardní role (``standard=true``) jsou
neměnné, jejich práva mají identifikátor ve tvaru ``uuid:{kódRole}-{klíčPráva}``.

Ukázka nastavení konkrétního práva existující roli (faktury vydané jen pro
čtení, faktury přijaté zcela nepřístupné):

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

Hodnoty ``typeK``: ``typPristPrav.plny`` (plný přístup), ``nepripustne``
(nepřístupné), ``pouzeCist`` (jen číst), ``upresneni`` (upřesnění přes
``featureK`` — Pridavat/Menit/Mazat/Export/Import/OteviratDetail/Sloupce/
Kusovnik/Storno/SlevaZmenaCeny/Sumace/Sluzby/Vazby/HromZmeny/NakupCena/...).

Uživatelé jako evidence
----------------------------

Uživatelé jsou přístupní jako evidence ``uzivatel``; při zakládání nového
uživatele je nutné (navíc oproti běžnému exportu) vyplnit shodné
``password``/``passwordAgain``:

.. code-block:: xml

   <uzivatel>
     <id>code:einstein</id>
     <kod>einstein</kod>
     <jmeno>Albert</jmeno>
     <prijmeni>Einstein</prijmeni>
     <password>heslo</password>
     <passwordAgain>heslo</passwordAgain>
     <role>code:JENCIST</role>
   </uzivatel>

Poslední přihlášení je vidět v poli ``lastLoginDate`` (běžní uživatelé) /
``lastApiDate`` (API uživatelé), dostupném přes ``GET /u.json?detail=full``
(prefix ``/u/`` = server-level, mimo konkrétní firmu).
