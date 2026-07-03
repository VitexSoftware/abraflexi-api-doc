Period initialization (year-end closing)
=========================================

Distinct from :doc:`actions_locking` — this is the equivalent of the
"Accounting > Next period initialization" desktop menu: it carries forward
closing balances into the next accounting period, and can be invoked
repeatedly (e.g. once at year-end without revaluation to carry the warehouse
forward, then again once the closing FX rate is known).

Triggering initialization
--------------------------

.. code-block:: text

   GET /c/{company}/ucetni-obdobi/inicializace-noveho-obdobi.json

If it has all the data it needs, the call starts a background job and
returns **HTTP 202 Accepted**. There is no dedicated job-status endpoint —
poll the ``lastUpdate`` field of the relevant record in the ``ucetni-obdobi``
evidence (``GET /c/{company}/ucetni-obdobi.json?detail=custom:kod,lastUpdate``)
until it changes.

If the next accounting period doesn't exist yet, it fails with:

.. code-block:: json

   {
       "winstrom": {
           "@version": 1,
           "success": false,
           "message": "Neexistuje následující účetní období. Prosím založte ho."
       }
   }

Required parameters
--------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Parameter
     - Description
   * - ``ucetOtv``
     - Opening account code (must have ``druhUctuK = "druhUctu.otevknih"``).
   * - ``ucetZav``
     - Closing account code (``druhUctuK = "druhUctu.uzavknih"``).
   * - ``ucetPre``
     - Profit/loss transfer account (``druhUctuK = "druhUctu.prhosvys"``).
   * - ``ucetVys``
     - Result-in-approval account (``druhUctuK = "druhUctu.pasivhvy"``).

.. note::

   For companies of type **daňová evidence** (tax record / cash-basis
   accounting, as opposed to double-entry bookkeeping), none of the four
   account parameters above are required.

If a parameter is missing:

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "K provedení operace je vyžadován parametr 'ucetOtv'"}}

If an account is the wrong kind (e.g. ``ucetZav`` pointing at an account
without ``druhUctuK = 'druhUctu.uzavknih'``):

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "Parametr 'ucetZav' má nepodporovanou hodnotu! Zvolte jednu z následujících možností: [Zvolený účet musí mít druhUctuK 'druhUctu.uzavknih']"}}

Optional parameters
--------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Parameter
     - Description
   * - ``ucetniObdobi``
     - Code of the period to close. Defaults to the current period.
   * - ``preceneni``
     - ``true``/``false`` — revalue unpaid foreign-currency documents. See
       *Currency revaluation* below.
   * - ``prevodSkladu``
     - ``true``/``false`` — carry the warehouse forward. Skipping this means
       warehouse items won't be offered in the new period.
   * - ``vynechatNulove``
     - ``true``/``false`` — skip stock cards with a zero balance.
   * - ``dnyBezPohybu``
     - Integer — number of days without movement, used together with
       ``vynechatNulove`` to decide which cards to skip.
   * - ``zrusitStare``
     - ``true``/``false`` — remove unused old cards in the new period.
   * - ``typDokl``
     - Document-type ID used to generate lease-installment liabilities.
       **Required** if unpaid liabilities exist for the next period, and the
       chosen type must have a document series with a yearly numbering entry
       for that period, otherwise the call fails.
   * - ``kontrolaZaokrouhleni``
     - ``true``/``false`` (default ``true``) — set to ``false`` to suppress
       the VAT-rounding-configuration warning (equivalent of clicking "Yes"
       in the desktop wizard) instead of fixing rounding on document types.

All boolean parameters default to ``false``. Sending non-standard VAT
rounding without ``kontrolaZaokrouhleni=false`` fails with a message listing
the offending document types.

Currency revaluation
----------------------

When ``preceneni=true``, unpaid foreign-currency documents are revalued
using a closing rate. Check what rate will be used first:

.. code-block:: text

   GET /c/{company}/ucetni-obdobi/meny-pro-preceneni.json?ucetniObdobi={code}

.. code-block:: json

   {
       "meny-pro-preceneni": {
           "datumPreceneni": "2023-12-31T00:00:00+01:00",
           "meny": {
               "mena": [
                   {"symbol": "€", "kod": "EUR", "kurz": "24.725", "kurzMnozstvi": "1.0"},
                   {"symbol": "", "kod": "THB", "kurz": "65.107", "kurzMnozstvi": "100.0"}
               ]
           }
       }
   }

A currency with ``kurz`` (or ``kurzMnozstvi``) equal to ``0.0`` has no known
rate and one must be supplied explicitly, or initialization tries to fetch
it from the central bank and fails if that also comes up empty:

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "Nebyly zadány všechny potřebné kurzy platné k poslednímu dni účetního období,\nkteré jsou nutné pro přecenění neuhrazených pohledávek/závazků."}}

Supply rates on the initialization call itself, one pair of parameters per
currency code:

.. code-block:: text

   ?preceneni=true&kurz[EUR]=24.52&kurzMnozstvi[EUR]=1.0&kurz[HUF]=6.12&kurzMnozstvi[HUF]=100.0

Both ``kurz[CODE]`` and ``kurzMnozstvi[CODE]`` are required together; they
are persisted as a new rate record under
``/c/{company}/kurz-pro-preceneni/(platiOdData, mena)``.

Bank accounts / cash registers in a currency other than their configured
currency or the local currency can't be revalued and cause:

.. code-block:: json

   {"winstrom": {"@version": 1, "success": false,
    "message": "Následující bankovní účty a pokladny nelze přecenit:\n• <list>\nPřeceňovány mohou být pouze bankovní účty a pokladny, které mají pohyb v měně, ve které jsou vedeny nebo v tuzemské měně."}}

Suppress that by excluding the offending accounts from revaluation instead:
``preceneniVynechatBanAPokSChybnouMenou=true``.

Full example
--------------

.. code-block:: text

   GET /c/demo/ucetni-obdobi/meny-pro-preceneni.json?ucetniObdobi=2022
   GET /c/demo/ucetni-obdobi/inicializace-noveho-obdobi.json
       ?ucetniObdobi=2022&ucetOtv=701000&ucetZav=702000&ucetPre=710000&ucetVys=431001
       &preceneni=true&kurz[EUR]=25&kurzMnozstvi[EUR]=1

For a **daňová evidence** company the same call simply omits the four
``ucet*`` parameters.

See also :doc:`actions_locking` for locking the period once initialization
and closing work are complete.
