Workflow and processes
============================

.. note::

   Advanced functionality that requires configuration through the ARIT
   integration partner. Most integrations won't need it — this chapter is
   deliberately brief; see the official "Workflow a procesy" documentation
   for full detail.

Built on the Activiti BPMN engine; its REST API is exposed at
``/c/{company}/activiti/``. Limitations: login goes through AbraFlexi
authorization (Activiti's own ``/login`` isn't supported); user/group/
membership management only via AbraFlexi; uploading a new process
definition must go through AbraFlexi (for workflow validity-period
definitions) — updates to existing processes can already go directly
through the Activiti API.

Endpoints on the AbraFlexi side
-------------------------------------

.. code-block:: text

   GET /c/{company}/{evidence}/workflows.xml                            — workflow definitions for an evidence
   PUT /c/{company}/{evidence}/{id}/workflows/{processId}/start          — start one (+ ?param1=value1...)
   GET /c/{company}/{evidence}/{id}/udalost                              — an object's events/tasks
   GET /c/{company}/{evidence}/{id}/udalost.xml?includes=udalost/actRuTask
   GET /c/{company}/udalost@ukoly-k-realizaci                            — current user's actionable tasks
   GET /c/{company}/{evidence}/{id}/workflow-signal/{signalId}?param1=value
   GET /c/{company}/{evidence}/{id}/workflow-message/{messageId}?param1=value
   POST /c/{company}/udalost/{id}/{claim,unclaim,complete,assign,add-comment}.xml

Expression language (BPMN)
--------------------------------

A process definition can use helpers such as
``flexibee.object(evidenceType)``,
``flexibee.query(evidenceType).filter(...).list()/.sum()/.count()/.max()/.min()/.avg()``,
``flexibee.settings()``, ``flexibee.user(username)``, ``flexibee.importXml(xml)``,
and variables ``initiator``/``authenticatedUserId``/``now``/``task``/
``execution`` — for branching process logic and for writing back into
AbraFlexi (e.g. cancelling an invoice or setting an approval label) via
``flexibee-xml`` service tasks.
