Kopie dokladu, tiskové sestavy a QR kódy
===============================================

Kopie dokladu
------------------

Server umí doklad zkopírovat přímo (efektivnější a spolehlivější než
načtení celého záznamu a jeho opětovné vložení klientem) — atribut
``sourceId`` na novém elementu:

.. code-block:: xml

   <winstrom version="1.0">
     <skladovy-pohyb sourceId="1179">
       <datVyst>2022-09-11</datVyst>
     </skladovy-pohyb>
   </winstrom>

``sourceId`` je ID kopírovaného záznamu; libovolná další uvedená pole (zde
``datVyst``) přepíší hodnoty zkopírované z originálu.

Export tiskových sestav (PDF / XLSX)
------------------------------------------

.. code-block:: text

   /c/<firma>/<evidence>.pdf                     — sestava přes celý výpis
   /c/<firma>/<evidence>/<ID>.pdf                 — sestava pro jeden záznam
   /c/<firma>/<evidence>.xls
   /c/<firma>/<evidence>/<ID>.xls

Konkrétní sestava: ``?report-name=...``. Jazyk sestavy: ``?report-lang=``
(``cs``, ``sk``, ``en``, ``de``). Elektronický podpis (vyžaduje právě jeden
uložený certifikát v AbraFlexi): ``?report-sign=true``.

.. code-block:: text

   /c/firma/faktura-vydana/1.pdf?report-name=dodaciList
   /c/firma/faktura-vydana/1.pdf?report-name=dodaciList&report-lang=en
   /c/firma/faktura-vydana/1.pdf?report-name=dodaciList&report-sign=true

Přehled podporovaných sestav dané evidence: ``GET /c/{firma}/{evidence}/reports``
— výstup obsahuje ``reportId`` (hodnota pro ``report-name``), ``reportName``
(lokalizovaný název), ``isDefault``, ``predvybranyPocet`` (1 nebo N —
sestava pro jeden záznam, nebo přehledová), ``rozsiritelna`` (existuje
rozšířená verze?), ``sumovana`` (podporuje sumaci?).

Formát ISDOC.PDF: PDF výstupy faktur (ne přehledové) obsahují vložený
dokument ISDOC, který lze zpětně použít pro import faktur z ISDOC.

QR kód dokladu
-------------------

Standard schválený Českou bankovní asociací, čitelný mobilními aplikacemi
většiny českých bank přímo z obrazovky. Podporováno pro přijaté (vlastní
platba) i vydané (platba klientem) doklady; **pouze platby v rámci ČR**,
měna libovolná.

.. code-block:: text

   GET /c/<firma>/<evidence>/<ID>/qrcode.png?size=200

``size`` 1–1500 px; server přidává okraj pro čisté černobílé přechody.
