Workflow a procesy
========================

.. note::

   Pokročilá funkcionalita vyžadující konfiguraci přes integračního partnera
   ARIT. Většina integrací ji nepotřebuje — tato kapitola je záměrně
   stručná; podrobnosti viz oficiální dokumentace "Workflow a procesy".

Základem je nástroj Activiti (BPMN engine); jeho REST API je zpřístupněno na
``/c/{firma}/activiti/``. Omezení: přihlašování probíhá autorizací AbraFlexi
(Activiti ``/login`` není podporováno), správa uživatelů/skupin/členství jde
jen přes AbraFlexi, nahrání nové definice procesu musí projít přes AbraFlexi
(kvůli definici platností workflow) — aktualizace existujících procesů už
lze dělat přímo přes Activiti API.

Endpointy na straně AbraFlexi
-----------------------------------

.. code-block:: text

   GET /c/{firma}/{evidence}/workflows.xml                            — definice workflow evidence
   PUT /c/{firma}/{evidence}/{id}/workflows/{processId}/start          — spuštění (+ ?param1=value1...)
   GET /c/{firma}/{evidence}/{id}/udalost                              — události/úkoly objektu
   GET /c/{firma}/{evidence}/{id}/udalost.xml?includes=udalost/actRuTask
   GET /c/{firma}/udalost@ukoly-k-realizaci                            — úkoly aktuálního uživatele
   GET /c/{firma}/{evidence}/{id}/workflow-signal/{signalId}?param1=value
   GET /c/{firma}/{evidence}/{id}/workflow-message/{messageId}?param1=value
   POST /c/{firma}/udalost/{id}/{claim,unclaim,complete,assign,add-comment}.xml

Výrazový jazyk (BPMN)
---------------------------

Definice procesu může využívat helpery jako ``flexibee.object(evidenceType)``,
``flexibee.query(evidenceType).filter(...).list()/.sum()/.count()/.max()/.min()/.avg()``,
``flexibee.settings()``, ``flexibee.user(username)``, ``flexibee.importXml(xml)``,
proměnné ``initiator``/``authenticatedUserId``/``now``/``task``/``execution`` — pro
větvení logiky procesu a pro zápis zpět do AbraFlexi (např. stornování
faktury nebo nastavení schvalovacího štítku) pomocí service tasků typu
``flexibee-xml``.
