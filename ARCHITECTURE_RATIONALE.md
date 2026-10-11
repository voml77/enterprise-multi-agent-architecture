# Architecture Rationale

This document explains not only what the architecture contains, but **why certain capabilities deliberately remain non-agentic**, why authority is separated from autonomous reasoning, and how enterprise data, knowledge, governance, and model execution are kept within explicit architectural boundaries.

The architecture is not intended as a universal blueprint or a prescription for a specific technology stack. It is a reference architecture for exploring how autonomous reasoning can be introduced into enterprise systems without making autonomy the owner of orchestration, authority, enterprise state, or trust decisions.

The diagrams in this repository describe the structural views of the system. This document complements them with design rationale, technical reference choices, rejected alternatives, and the trade-offs behind those decisions.

## 1. A hybrid architecture by design

A central design decision is to avoid treating deterministic software and agentic systems as competing architectural paradigms.

The architecture deliberately combines **deterministic platform control with bounded agentic reasoning**.

Autonomous agents are used where the task benefits from adaptive planning, iterative reasoning, intermediate evaluation, and dynamic capability selection. Deterministic services remain responsible where predictable authority, enforcement, lifecycle management, persistence, validation, or reproducibility are more important than autonomy.

This distinction leads to a simple design criterion:

> **A capability becomes an agent only when autonomy adds value.**

In practice, this produces three bounded agent archetypes — Domain Support, Analysis, and Research — surrounded by deterministic platform capabilities for orchestration, identity, policy, data access, retrieval, approval, knowledge lifecycle management, audit, and model execution governance.

The hybrid approach extends to model execution itself. The architecture does not assume that enterprise AI must choose between local models and external frontier models as a system-wide strategy. Local, private or sovereign, and approved external runtimes can coexist.

Runtime selection is therefore not based on a preferred provider or deployment model. A runtime must first belong to the intersection of:

- what the current disclosure and governance policy **permits**,
- what has been qualified to satisfy the required capability,
- what enterprise policy allows for the execution context, and
- what is operationally available.

Only within that eligible set should secondary concerns such as model size, quality, latency, and cost influence selection.

> **Runtime eligibility is an intersection, not a ranking.**

This makes hybrid execution an architectural property rather than a fallback mechanism. Sensitive source data does not automatically imply local execution, just as access to an external frontier model does not automatically justify sending enterprise data to it. The decisive question is which validated representation may be disclosed for the intended processing task and which qualified runtime may process that representation.

The architecture therefore applies the same underlying philosophy at two levels:

**Autonomy is introduced where reasoning benefits from it. Runtime flexibility is introduced where trust and capability permit it.**

Neither decision transfers authority away from the platform.

## 2. Deterministic orchestration instead of a supervisor agent

A multi-agent system requires coordination, but coordination does not automatically require another agent.

A common pattern is to introduce a supervisor agent that interprets a request, decides which specialist agent should handle it, delegates work, and potentially evaluates the result. This can be useful in systems where flexible delegation itself is part of the reasoning problem.

For this architecture, however, orchestration is deliberately treated as a **platform responsibility rather than an autonomous role**.

The orchestration plane owns the execution lifecycle. It coordinates responsibilities such as:

- request and intent routing,
- identity and authorization context,
- policy evaluation,
- task creation and state transitions,
- capability delegation,
- context scoping,
- runtime eligibility and invocation,
- failure handling and retry boundaries,
- and the correlation of execution with audit and observability.

These responsibilities affect authority, state, and governance. Making them the responsibility of a supervisor agent would combine probabilistic reasoning with control over the boundaries within which other autonomous components operate.

The architecture therefore separates two fundamentally different questions:

> **What reasoning should be performed?**

and:

> **What is allowed to happen next?**

An agent may reason that another capability is required. It may request additional knowledge, operational data, research, or a governed action. The platform evaluates whether that capability is available and permitted within the current identity, task, policy, and data context.

This means that agents can influence the path of execution without owning the execution lifecycle itself.

### Probabilistic context assessment without acquisition authority

Context sufficiency is not always a deterministic question. An agent may express a need for additional information, but that expression is neither evidence that acquisition is necessary nor permission to acquire it.

The **Context Need Assessment Service** evaluates the available task context probabilistically and produces assessment evidence about whether additional governed context may be needed and which context classes or capability needs could address the insufficiency.

The assessment remains independent of physical stores and acquisition execution. It does not query canonical knowledge, operational systems, the enterprise graph, or external research sources, and it cannot authorize those operations.

Its output is evidence for the platform, not an executable retrieval plan or a policy decision.

The **Policy Decision Service** remains the deterministic authority for deciding whether a proposed acquisition is permitted under the effective identity, purpose, task, classification, and source constraints.

The **Orchestration Service** coordinates the authorized acquisition through the appropriate bounded capability.

The **Context Assembly Service** assembles permitted, task-scoped acquisition results into execution context while preserving provenance, classification, and applicable usage constraints. It neither acquires information nor grants permissions.

> **Assessment estimates. Policy authorizes. Orchestration executes.**

An assessment of insufficient context does not automatically trigger retrieval or external research.

Research is a separate trust-boundary crossing and requires its own explicit authorization.

A valid platform decision may also be to proceed with existing context, request clarification, report insufficient information, or deny further acquisition.

### Why not a supervisor agent?

The decision is not based on the assumption that supervisor agents are inherently unsuitable. It follows from the authority model of this particular architecture.

A supervisor agent with authority to route requests, select unrestricted tools, delegate privileges, approve actions, modify shared state, or determine trust boundaries would become both a reasoning component and a governance authority.

That creates several problems at enterprise scale:

- authorization boundaries become harder to reason about,
- probabilistic model behavior can affect control-plane decisions,
- task ownership becomes coupled to an agent instance,
- audit trails must reconstruct implicit model decisions,
- delegation can accidentally become privilege escalation,
- and changing the supervisor model can change platform behavior beyond reasoning quality.

The alternative is not static orchestration. Agents may still plan, adapt, request capabilities, evaluate intermediate results, and change their reasoning path within a bounded task.

The boundary is authority:

> **The model provides cognition. The agent provides agency. The platform defines the boundaries within which that agency may operate.**

This also makes the architecture less dependent on any particular orchestration framework or model family. Agents and runtimes can evolve without transferring ownership of enterprise task state or governance to them.

### Task ownership

A consequence of this decision is that durable task state belongs to the platform rather than to an agent.

A canonical task record can contain, for example:

- `task_id`
- `request_id`
- `parent_task_id`
- initiator and authorization context references
- assigned capability
- current lifecycle state
- context and artifact references
- policy decisions
- execution attempt
- timestamps
- result references

A relational store such as **PostgreSQL** is a suitable reference implementation for this durable task state.

Agents receive the scoped state required for their work. They do not become the authoritative persistence layer for the workflow.

> **The platform owns the task, not the agent.**

## 3. Bounded agents instead of agentifying every capability

Once orchestration and authority are treated as platform responsibilities, the next question is which capabilities actually benefit from becoming agents.

This architecture deliberately uses a narrow definition of agency. A component qualifies as an agent when it needs to operate autonomously within a bounded task by combining several of the following behaviors:

- interpreting a task in context,
- planning multiple reasoning or execution steps,
- evaluating intermediate results,
- deciding which approved capabilities are needed next,
- adapting its approach when intermediate results change the problem,
- and determining when sufficient evidence exists to produce a result or request another capability.

The presence of an LLM alone does not make a component an agent.

A classifier may use a model. A retrieval service may use embeddings or reranking models. A transformation service may use model-assisted techniques. An evaluation service may even use model-based evaluation. None of these components needs autonomous ownership of a task merely because probabilistic computation occurs inside it.

> **Agentic behavior is defined by bounded autonomy, not by the presence of a model.**

### Three agent archetypes

Applying this criterion results in three primary agent archetypes.

#### Domain Support Agent

The Domain Support Agent provides user-facing reasoning within a bounded business domain.

It can interpret domain-specific questions, combine multiple approved knowledge and data capabilities, evaluate intermediate results, and express which additional information it believes may be needed before producing an answer.

The architecture does not require a separate hard-coded agent implementation for every department. Domain specialization can instead be expressed through **Domain Contracts** that define the capabilities, knowledge scopes, policies, and interaction boundaries available for a particular domain.

A Controlling-oriented configuration, for example, might combine:

- governed knowledge retrieval,
- knowledge graph queries,
- KPI and semantic-model lookup,
- and approved operational data queries.

The agent reasons within that capability envelope; it does not define the envelope itself.

#### Analysis Agent

The Analysis Agent handles tasks where the path from question to result cannot always be predetermined.

It may formulate intermediate analytical questions, request additional datasets, compare results, test explanations, and iteratively refine an analysis.

This autonomy does not imply unrestricted access to enterprise data.

The agent expresses **what information or capability it believes it needs** to continue its task. This expression is a request, not an authorization or proof that additional context must be acquired.

Where additional context is in question, the Context Need Assessment Service may evaluate context sufficiency and produce probabilistic assessment evidence. The Policy Decision Service retains deterministic authority over whether the proposed acquisition is permitted.

If authorized, the Orchestration Service coordinates the appropriate governed acquisition capability. The Enterprise Data Access Service mediates purpose-scoped access to operational data through approved contracts and source-level constraints.

> **The agent expresses a need. Assessment evaluates sufficiency. Policy authorizes acquisition. Governed capabilities provide permitted context.**

The same boundary applies to persistence. Analyses, reports, findings, and evidence can be created by the agent, while platform services remain responsible for durable storage and provenance.

#### Research Agent

The Research Agent exists because external research and enterprise retrieval represent different trust operations.

Retrieval searches knowledge that has already entered the governed enterprise knowledge lifecycle. Research deliberately crosses that boundary to investigate information that is not yet part of trusted enterprise knowledge.

A Research Agent can therefore explore approved external sources, compare evidence, resolve uncertainty, and produce structured findings. Those findings do not become canonical knowledge merely because the agent considers them reliable.

> **Research may extend what the system knows. It may never redefine what the enterprise considers true by itself.**

### Why the other capabilities remain services

Several responsibilities in the architecture could technically be implemented using autonomous agents. That alone is not sufficient justification for doing so.

Identity resolution, policy enforcement, enterprise data access, retrieval, approval, knowledge promotion, graph lifecycle management, index maintenance, audit, and runtime eligibility have deliberately constrained responsibilities and authority boundaries.

Turning these components into agents would add autonomy where the architecture primarily requires predictable enforcement, reproducibility, or controlled state transitions.

This does not prevent these services from using machine learning or language models internally where useful. It only means that such implementation choices do not change their architectural authority.

The distinction can therefore be summarized as:

> **Use agents for bounded adaptive reasoning. Use services for governed authority and deterministic lifecycle responsibilities.**

### Agent contracts and replaceability

An agent is also not synonymous with the model that currently executes its reasoning.

The architectural contract of an agent should describe its purpose, permitted capabilities, expected inputs and outputs, authority boundaries, and evaluation requirements independently of a particular model provider.

A Domain Support Agent remains the same architectural role whether its cognitive runtime is provided by a local model, a private or sovereign deployment, or an approved external model — provided that the runtime is both qualified for the required capability and eligible for the execution context.

This separation allows models to evolve without redefining the surrounding architecture.

> **Agent ≠ Runtime.**

## 4. Authority and capability boundaries

Autonomy is useful only when the authority surrounding it remains explicit.

The architecture therefore separates **reasoning capability from authority**. Being able to determine that an action would be useful does not imply permission to perform that action. Similarly, being able to access one resource does not imply permission to persist, promote, modify, or execute against it.

Four forms of authority are deliberately distinguished:

- **Read authority** — permission to obtain a scoped representation of information.
- **Write authority** — permission to create or modify state within a defined boundary.
- **Execution authority** — permission to cause an external side effect.
- **Approval authority** — permission to authorize a governed state transition or side effect.

These authorities are not inherited through agent delegation.

> **Agent delegation must never imply privilege escalation.**

### Authorization travels with the request

Every capability request remains bound to the identity, authorization, task, policy, and data context under which it originated.

An agent cannot increase the authority of a request by delegating work to another agent or service. A downstream capability receives only the authority required and permitted for the specific operation.

This is particularly important when agents dynamically decide which capabilities they need. Dynamic planning may change the reasoning path, but it does not change the authorization boundary.

The Enterprise Knowledge Graph can contribute relationship and ownership context, but it does not grant permissions.

> **Knowledge Graph describes relationships. IAM grants authority.**

Enterprise IAM therefore remains the authoritative source for identity, roles, groups, and entitlements. A platform such as **Microsoft Entra ID** is one possible enterprise implementation; the architecture itself is not coupled to a specific IAM product.

### Resource authority

The resulting authority model can be summarized as follows:

| Resource | Domain Support Agent | Analysis Agent | Research Agent | Knowledge Curation | Platform / Governance |
|---|---|---|---|---|---|
| Canonical Knowledge | Scoped read | Scoped read | Scoped read | Read | Promote / update |
| Candidate Knowledge | Limited read | Limited read | No direct access | Create / normalize | Approve / reject |
| Semantic Index | Indirect read | Indirect read | Indirect read | No direct write | Build / delete / rebuild |
| Enterprise Knowledge Graph | Scoped read | Scoped read | Scoped read | Propose relationship candidates | Canonical write |
| Operational Data | Scoped read | Scoped read | Normally no access | No access | Source-system authority |
| User / Request Context | Scoped | Scoped | Minimum necessary | No direct access | Context and IAM services |
| Task State | Scoped | Scoped | Scoped | Scoped where required | Orchestrator write |
| Generated Artifacts | Create | Create | Create | Read | Artifact service persists |
| Findings / Evidence | Create | Create | Create | Consume | Evidence service persists |
| Workflow Actions | Request | Request | Normally no execution | No execution | Workflow service executes |
| Policies | Effective result only | Effective result only | Effective result only | Read where required | Governance write |
| IAM | No direct access | No direct access | No direct access | No direct access | IAM authority |
| Audit | Emit attributable events | Emit attributable events | Emit attributable events | Emit attributable events | Append-only audit service |
| Runtime Cache | Scoped | Scoped | Scoped | Scoped where required | Ephemeral only |

“Scoped read” does not imply direct database access. Access is mediated through platform services under the effective authorization and policy context of the request.

### Side effects cross an explicit boundary

Reasoning about an action and executing that action are separate operations.

An agent may conclude that a workflow action would help complete a task. It can create an action request, but the request must cross the platform's execution boundary:

**Agent → Action Request → Policy → Approval if required → Workflow Service → Enterprise System**

The Policy Service determines whether the requested action is permitted and whether human approval is required. The Approval Service coordinates that decision where necessary. Only the Workflow Service executes the approved side effect against the enterprise system.

This keeps adaptive reasoning upstream from execution authority.

> **Agents may request actions. They do not grant themselves permission to execute them.**

### Three categories of state

The same authority model also distinguishes state by its enterprise significance.

**Ephemeral state** includes caches, locks, temporary coordination data, and task-local scratch state. Losing it may interrupt execution, but it must not destroy enterprise truth.

**Durable work products** include reports, analyses, generated files, findings, and evidence packages. Agents may create these artifacts, while platform services persist them together with provenance and lifecycle metadata.

**Canonical enterprise state** includes governed knowledge, policies, authoritative graph relationships, identity and authorization information, and other approved enterprise truth. Autonomous agents do not directly mutate this state.

This distinction prevents a common architectural shortcut in which every persistent output produced by an agent gradually becomes shared enterprise memory.

> **Persisted artifact ≠ enterprise knowledge.**

## 5. Enterprise knowledge is governed state

Enterprise knowledge is not treated as a shared memory space that autonomous agents can freely extend.

Information becomes enterprise knowledge only after it has crossed an explicit lifecycle boundary. This distinction is important because generated output, retrieved content, external research, semantic similarity, and approved enterprise truth have fundamentally different levels of authority.

The architecture therefore separates:

- **Canonical Knowledge** — approved, versioned, governed enterprise knowledge.
- **Candidate Knowledge** — information proposed for possible inclusion in canonical knowledge.
- **Findings and Evidence** — work products that may support a candidate but are not knowledge by themselves.
- **Semantic Indexes** — derived representations used to locate relevant knowledge.
- **Enterprise Knowledge Graph** — governed entities and relationships used for relationship-aware navigation and reasoning.
- **Operational Data** — authoritative business data that remains owned by existing enterprise systems.

These domains may reference one another, but they do not become interchangeable merely because an agent can access them.

> **Memory ≠ Knowledge ≠ Signals ≠ Evidence.**

### Canonical and candidate knowledge

Canonical Knowledge represents the approved knowledge state of the enterprise.

A suitable reference implementation is **PostgreSQL** for structured metadata, lifecycle state, provenance, versioning, ownership, classification, and stable artifact identifiers. Larger document bodies or generated binary artifacts can be stored in enterprise **object storage**, while PostgreSQL maintains their authoritative metadata and references.

A canonical knowledge record might contain information such as:

- `artifact_id`
- artifact type
- title and ownership
- source and provenance
- version
- lifecycle status
- information classification
- validity period
- and an object-storage reference where applicable.

Candidate Knowledge can use the same underlying database technology, and potentially even the same PostgreSQL cluster, while remaining a **separate trust domain** with distinct schemas, permissions, lifecycle rules, and promotion semantics.

Physical proximity does not imply equal authority.

An agent therefore cannot make something true for the enterprise by writing it into a shared database.

### Knowledge curation and promotion

Agents produce findings and evidence. They do not directly create canonical knowledge.

The governed lifecycle is:

**Finding / Evidence → Knowledge Curation → Candidate → Validation / Review → Promotion → Canonical Knowledge**

The **Knowledge Curation Service** converts suitable findings into structured candidates. Depending on the domain, this can include responsibilities such as:

- schema normalization,
- provenance verification,
- duplicate and similarity detection,
- information classification,
- sensitive-data handling,
- retention checks,
- domain assignment,
- and assessment of whether the finding is appropriate for durable enterprise knowledge.

Promotion is a separate authority. Only after the applicable validation, review, and policy requirements have been satisfied can a candidate become canonical.

> **Agents produce findings. Curation creates candidates. Policy promotes canonical knowledge.**

This separation also allows human review to be introduced where required without making every knowledge update dependent on manual intervention.

### Semantic retrieval is derived state

Semantic retrieval is deliberately separated from canonical storage.

A vector index exists to locate potentially relevant knowledge efficiently. It does not become authoritative merely because it provides the best semantic match.

> **Vector Index ≠ Source of Truth.**

For an initial enterprise implementation, **PostgreSQL with pgvector** is a pragmatic reference choice because canonical metadata and semantic indexing can remain operationally close while preserving their architectural separation.

At larger scale or under different latency, distribution, or retrieval requirements, a dedicated vector platform such as Qdrant, Weaviate, or Milvus could replace pgvector without changing the authority model.

The important property is not the vector technology. It is the direction of authority:

**Canonical Knowledge → Index Maintenance → Derived Semantic Index**

The Index Maintenance Service reads canonical state and creates or updates its semantic representation. Retrieval uses the index as a locator and rehydrates authoritative artifacts from canonical storage.

Canonical Knowledge does not depend on the continued existence of the vector index. The index can be deleted and rebuilt.

### The Enterprise Knowledge Graph

Not every enterprise question is primarily a semantic-similarity problem.

Questions about ownership, responsibility, dependencies, organizational relationships, systems, datasets, KPIs, reports, processes, or policies often require explicit relationships between governed entities.

The architecture therefore includes an **Enterprise Knowledge Graph** as a separate knowledge representation.

A graph database such as **Neo4j** is a suitable reference implementation, but the architectural role is not vendor-specific.

Representative entities might include:

- Person
- Team
- Department
- Role
- Capability
- Application
- System
- Data Product
- Dataset
- Semantic Model
- KPI
- Report
- Business Process
- Project
- Policy
- Knowledge Artifact

Representative relationships might include:

- `MEMBER_OF`
- `HAS_ROLE`
- `OWNS`
- `PRODUCES`
- `FEEDS`
- `DEFINES`
- `USED_IN`
- `SUPPORTS`
- `GOVERNED_BY`
- `DESCRIBES`

The graph is not a replacement for Canonical Knowledge, IAM, or operational source systems. It provides governed relationship semantics across enterprise entities.

Stable identifiers connect graph entities and relationships to their authoritative artifacts and provenance where appropriate.

Agents may discover potentially useful relationships, but they do not directly create canonical graph relationships. Relationship findings enter the curation lifecycle and are applied through the **Graph Lifecycle Service** only after the required validation and promotion.

### Operational data remains operational data

Enterprise AI does not require duplicating every operational source into an agent-owned database.

ERP, CRM, DWH, Lakehouse, Data Lake, semantic models, and other enterprise platforms remain authoritative for the operational data they own.

The architecture accesses those systems through an **Enterprise Data Access Service** that mediates approved queries, views, APIs, semantic models, or other governed interfaces.

Agents express data requirements rather than receiving arbitrary production-database connectivity.

This preserves an important distinction:

> **Enterprise knowledge describes what the organization knows. Operational systems remain authoritative for what the organization operates.**

### Artifacts and evidence are separate from knowledge

Reports, analyses, generated files, research findings, and evidence packages can be valuable durable outputs without automatically becoming enterprise knowledge.

An **Artifact / Evidence Service** persists these work products and their provenance. Large payloads can reside in object storage while structured metadata remains in a relational store.

Useful provenance can include:

- artifact identifier,
- producing agent or capability,
- model runtime,
- input references,
- source and evidence references,
- applicable policy version,
- and creation timestamp.

This makes generated work reproducible and attributable while preserving the boundary between work products and canonical knowledge.

### Ephemeral state stays ephemeral

Distributed agent execution also requires transient coordination state: caches, locks, rate limits, short-lived session data, or temporary execution context.

**Redis** is a suitable reference technology for this role.

It is deliberately not used as authoritative enterprise storage.

> **If losing Redis destroys enterprise truth, we designed it wrong.**

This principle is intentionally simple: infrastructure optimized for transient coordination should remain replaceable and disposable without corrupting the enterprise knowledge model.

### Reference technologies, not architectural dependencies

The technologies named in this section illustrate one practical implementation of the architectural responsibilities:

| Responsibility | Reference technology |
|---|---|
| Canonical and Candidate Knowledge metadata | PostgreSQL |
| Durable Task State | PostgreSQL |
| Semantic Index | pgvector initially |
| Enterprise Knowledge Graph | Neo4j |
| Large documents, artifacts and evidence | S3-compatible / enterprise object storage |
| Ephemeral coordination and cache | Redis |
| Version-controlled policies, contracts and configuration | Git + PostgreSQL |
| Enterprise identity and authorization | Existing IAM, e.g. Microsoft Entra ID |
| Operational enterprise data | Existing ERP, CRM, DWH, Lakehouse, Data Lake and semantic platforms |

These choices are intentionally replaceable.

The architectural dependency is on the **responsibility and authority of each component**, not on a particular database or vendor.

> **Stores hold state. Services perform lifecycle operations.**

## 6. Retrieval is not research

Retrieval and research can both provide information to an agent, but they represent fundamentally different trust operations.

Retrieval operates inside the governed enterprise knowledge boundary. Research deliberately reaches beyond that boundary.

Treating both as interchangeable forms of “search” would hide an important architectural distinction: one accesses information that has already passed through enterprise governance, while the other acquires information whose trustworthiness, provenance, classification, and long-term relevance have not yet been established.

> **Retrieval searches what the enterprise already knows. Research investigates what it does not yet know.**

### Governed context acquisition is broader than retrieval

A context need is not necessarily a knowledge gap. A task may require additional canonical knowledge, governed relationship context, operational data, or explicitly authorized external evidence.

These are different acquisition classes with different source authorities, constraints, and trust boundaries.

The **Context Need Assessment Service** may produce probabilistic evidence that the current task context is insufficient and identify relevant context classes or capability needs.

This evidence does not select physical stores, authorize acquisition, or execute any acquisition capability. An agent may likewise express a need without granting itself access.

The **Policy Decision Service** determines whether a proposed acquisition is permitted for the current identity, task, purpose, classification, and source constraints.

The **Orchestration Service** coordinates only authorized acquisition.

The **Context Assembly Service** assembles the permitted, task-scoped results while preserving provenance, classification, and usage constraints. It is not an acquisition authority.

The architecture distinguishes four acquisition classes:

- **Knowledge Retrieval** — locates eligible canonical enterprise knowledge using governed semantic retrieval and resolves hits against authoritative artifacts.
- **Graph Query** — provides authorized relationship context from the governed Enterprise Knowledge Graph without treating graph relationships as permission grants.
- **Enterprise Data Access** — mediates purpose-scoped operational data access through approved interfaces and data contracts.
- **External Research** — obtains evidence from approved external sources only under explicit task-scoped authorization, crossing a separate trust boundary.

### Acquisition minimization

Acquisition is minimized before context assembly.

Source scope, query contracts, filters, projection, aggregation, and result bounds should prevent unnecessary information from entering the execution context.

This **acquisition minimization** is distinct from the later **disclosure minimization** that controls which representation a model runtime may receive.

> **Assessment estimates. Policy authorizes. Orchestration executes. Acquisition capabilities return bounded evidence or data.**

Neither a low assessment score nor an empty retrieval result automatically triggers another acquisition class or external research.

A valid outcome is to proceed with existing context, ask for clarification, report insufficiency, or deny further acquisition.

### Governed retrieval

The **Knowledge Retrieval Service** locates eligible canonical enterprise knowledge through policy-governed, task-scoped semantic retrieval.

The Semantic Index acts as a locator. Relevant hits are resolved against authoritative canonical artifacts, including their provenance, version, lifecycle status, classification, and validity.

Relationship-oriented context is obtained separately through the **Graph Query Service**, which executes authorized, task-scoped queries against the governed Enterprise Knowledge Graph.

A semantic search result is therefore not returned to an agent as an authoritative statement merely because it has a high similarity score.

This preserves the separation between acquisition authority and knowledge authority:

**Policy-Authorized Retrieval Task → Orchestration Service → Knowledge Retrieval Service → Semantic Index → Canonical Artifact**

The Semantic Index locates potentially relevant knowledge. The Knowledge Retrieval Service resolves eligible results against authoritative canonical artifacts. Neither semantic similarity nor retrieval execution grants acquisition authority.

The retrieved content remains reference data.

It does not become an instruction merely because it is injected into a model context.

> **Retrieved data ≠ instructions.**

This distinction reduces the risk that documents, indexed text, or retrieved external content accidentally influence orchestration or governance behavior as if they were system-level directives.

### Knowledge gaps are explicit events

Retrieval can fail in several ways.

No relevant knowledge may exist. Existing knowledge may be incomplete, contradictory, outdated, or insufficient for the requested level of confidence.

The architecture treats this condition as a **knowledge gap**, rather than silently allowing an agent to improvise or automatically search the internet.

A knowledge gap is evidence about governed knowledge coverage. It is neither an authorization nor an instruction to initiate research.

The platform evaluates whether additional governed context acquisition is necessary and permitted for the task.

External research is considered only when explicitly proposed and authorized for the task. It may also be authorized directly for research-oriented tasks without a preceding retrieval failure.

Conceptually:

**Knowledge Gap → Assessment Evidence / Task Decision → Policy Authorization → Optional Governed Acquisition**

This is a possible decision path, not a mandatory sequence. Context assessment does not have to precede every authorized acquisition, and a knowledge gap does not require further acquisition.

If research is not permitted, the system should remain transparent about the limitation.

A valid outcome can be:

- insufficient trusted information,
- research not permitted for this request,
- additional user input required,
- or escalation to another approved capability.

The ability to say “I do not know based on governed knowledge” is an architectural capability, not a failure mode.

### Research crosses a trust boundary

When external research is explicitly authorized for the task, the Orchestration Service may delegate that bounded research task to the Research Agent.

Authorization is required regardless of whether a knowledge gap was previously observed.

External sources are not treated as trusted enterprise knowledge simply because they are publicly accessible or because a model considers them credible.

The Research Agent can:

- identify relevant approved sources,
- gather evidence,
- compare conflicting information,
- evaluate source quality,
- resolve uncertainty,
- and produce structured findings.

Its output is therefore a **Finding / Evidence Package**, not a canonical knowledge artifact.

The boundary is explicit:

**Authorized Research Task → Research Agent → Finding / Evidence → Optional Knowledge Curation**

Research ends when sufficiently supported findings have been produced. Knowledge governance begins when those findings enter curation.

### Research does not bypass knowledge governance

A successful research result may be immediately useful for answering the current task while still remaining unapproved for long-term enterprise reuse.

This distinction allows the platform to separate two questions:

> **Is this evidence sufficient to support the current response?**

and:

> **Should this information become reusable enterprise knowledge?**

The first can be answered within the task context.

The second belongs to the knowledge lifecycle.

Only the Knowledge Curation and Promotion path can convert suitable research findings into canonical enterprise knowledge.

This prevents a common failure mode in which a research-capable agent gradually turns transient external information into an ungoverned shared memory.

> **Research may extend what the system knows. It may never redefine what the enterprise considers true by itself.**

### Evidence remains first-class

Research findings should preserve enough provenance for later evaluation.

A Finding / Evidence Package can include:

- finding identifier,
- research question or knowledge gap,
- source references,
- retrieval timestamps,
- extracted claims,
- supporting and conflicting evidence,
- confidence or uncertainty indicators,
- producing agent and runtime,
- applicable policy context,
- and evidence required for later validation.

The exact schema can vary by domain, but the principle remains the same:

**A claim without provenance is not promotion-ready enterprise knowledge.**

### External research sources are governed capabilities

Within an explicitly authorized research task, the Research Agent may select among permitted research capabilities.

The platform determines which capabilities are available and what task-scoped request context may be disclosed to them.

Approved research sources, search capabilities, APIs, or external tools remain subject to enterprise policy, data-disclosure rules, network restrictions, contractual constraints, and audit requirements.

This means that “external research” is not synonymous with unrestricted web browsing.

This follows the same boundary already established for operational data:

> **The agent proposes a capability. The platform authorizes its use and governs what it may receive and do.**

### Retrieval and research remain separate even when technology overlaps

The implementation technologies behind retrieval and research may overlap.

Both might use search engines, embeddings, rerankers, language models, document parsers, or knowledge extraction pipelines.

That technical overlap does not collapse their architectural roles.

The difference is defined by authority and trust:

| Aspect | Retrieval | Research |
|---|---|---|
| Information domain | Governed enterprise knowledge | Approved external information sources |
| Primary purpose | Locate existing governed knowledge | Investigate an explicitly authorized external research question |
| Trust boundary | Inside enterprise knowledge boundary | Crosses external trust boundary |
| Typical output | Governed knowledge artifacts | Findings and evidence |
| Direct canonical write | No | No |
| Curation required for canonical enterprise reuse | Already governed | Yes — before promotion to Canonical Knowledge |
| Failure behavior | No eligible governed result; report insufficiency or request a separately authorized next step | No permitted source or insufficient evidence; report limitations |

The architecture therefore models Retrieval and Research as separate capabilities even when parts of their technical implementation might eventually share infrastructure.

> **A shared technology stack does not imply a shared trust model.**

## 7. Model execution is governed by trust and capability

Selecting a model runtime is not merely an optimization problem.

In an enterprise architecture, model execution is a trust decision because the runtime receives a representation of enterprise data, user context, task context, or generated intermediate state.

A capable model is not automatically an eligible model.

The architecture therefore separates two questions:

> **Can this runtime perform the required capability reliably?**

and:

> **May this runtime receive this execution payload?**

The first question belongs to **capability qualification**.

The second belongs to **model execution policy**.

> **Policy says what MAY. Evaluation says what CAN.**

### Classification comes before disclosure

The decision about model execution begins with the actual execution context.

Relevant data, context, and intermediate representations are classified according to enterprise rules before runtime eligibility is determined.

The classification step can consider properties such as:

- business sensitivity,
- personal or identifying information,
- contractual restrictions,
- confidentiality level,
- source-system classification,
- jurisdictional or sovereignty requirements,
- task purpose,
- and applicable enterprise policy.

This classification does not by itself determine the runtime.

Instead, it establishes the disclosure constraints that must be satisfied before the payload can leave its current trust boundary.

### Disclosure transformation policy precedes transformation

Sensitive source data does not automatically require local execution.

In many real enterprise scenarios, a task may benefit from a capability that is only available, or significantly stronger, in a private, sovereign, or approved external runtime.

The architecture therefore includes a deliberate disclosure-transformation step before runtime eligibility is evaluated.

The **Disclosure Transformation Policy Service** determines the minimum viable representation permitted for the authorized processing purpose.

It evaluates source classification, disclosure constraints, intended processing class, capability requirements, task utility, and applicable governance restrictions.

The policy may authorize a particular representation and the required transformation methods, or deny disclosure entirely.

This decision is separate from both performing a transformation and validating its result.

The **Data Transformation Service** applies only the policy-selected transformation or approved combination of transformations.

It does not independently decide what may be disclosed, and a technically successful transformation never constitutes disclosure permission.

> **Disclosure is a policy decision about the minimum viable representation of information for an authorized processing purpose.**

Depending on the task and policy, the payload can be transformed through techniques such as:

- redaction,
- masking,
- pseudonymization,
- aggregation,
- generalization,
- attribute removal,
- or other approved disclosure-reduction mechanisms.

The goal is not to relabel sensitive information as harmless.

The goal is to reduce the disclosed representation to the minimum information required for the approved processing task.

> **The transformation method is selected according to task utility and permitted disclosure, not by a one-size-fits-all anonymization rule.**

A transformed payload must still preserve enough task-relevant information for the requested capability to remain useful.

This creates a deliberate tension between **data minimization** and **task utility**, which the architecture treats as a policy problem rather than leaving it to an agent or model.

### Transformation requires validation

Transformation is not considered sufficient merely because a masking or pseudonymization step was executed.

The transformed representation must be independently validated against the policy-approved disclosure constraints before it can be considered for downstream model execution.

The **Transformation Validation Service** assesses residual disclosure and re-identification risk and produces validation evidence.

It cannot relax the approved disclosure representation, grant additional permissions, or override a policy denial.

A failed or inconclusive validation blocks the affected disclosure path.

The platform must not silently substitute a less restrictive transformation or runtime to bypass that failure.

> **Transformation changes representation. Validation assesses the result. Neither grants disclosure authority.**

The **Transformation Validation Service** can evaluate properties such as:

- whether required identifiers were actually removed or replaced,
- which attributes remain,
- whether transformed values remain reversible,
- residual re-identification risk,
- policy compliance,
- and whether the representation satisfies the required processing class.

A transformation result can therefore be represented by metadata such as:

- `transformation_type`,
- `removed_identifiers`,
- `retained_attributes`,
- `reversibility`,
- `reidentification_risk`,
- `validation_status`,
- and `permitted_processing_classes`.

The exact schema is implementation-specific. The architectural requirement is that transformation and validation remain separate responsibilities.

> **The selected runtime receives the validated transformed representation, not the original source payload.**

### Runtime eligibility is an intersection

After successful transformation validation, the **Model Execution Policy Service** determines which runtimes are eligible for the current execution.

Its decision is constrained by the approved disclosure representation, validation evidence, capability qualification, enterprise governance, and operational eligibility.

A runtime is eligible only when all applicable constraints are satisfied.

If no compliant runtime remains, execution is denied for that path.

The platform must not silently fall back to a less restrictive runtime, weaken disclosure constraints, or disclose the original source payload.

Eligibility is not produced by ranking all available models and selecting the best one.

A runtime must satisfy several independent constraints:

**Disclosure permission**  
Can the validated representation be disclosed to this runtime class?

**Capability qualification**  
Has the runtime been shown to satisfy the required capability contract?

**Enterprise governance**  
Is the runtime permitted for the current business, contractual, regulatory, sovereignty, and execution context?

**Operational eligibility**  
Is the runtime currently available and suitable for execution?

Only runtimes that satisfy all applicable constraints enter the eligible set.

Conceptually:

**Eligible Runtimes = Disclosure-Permitted ∩ Capability-Qualified ∩ Governance-Permitted ∩ Operationally-Eligible**

Selection happens only after this intersection exists.

Within the eligible set, the platform can optimize for concerns such as:

- expected quality,
- model size,
- latency,
- cost,
- throughput,
- locality,
- or workload-specific preference.

> **Use the smallest approved model that reliably satisfies the capability contract.**

This preserves efficiency without allowing cost or model preference to override trust boundaries.

### Local, private, and external runtimes are first-class options

The architecture models three broad execution classes:

#### Local runtime

A runtime operated within the controlled local or enterprise environment.

This can provide strong data locality, reduced external disclosure, predictable deployment control, and independence from external provider availability.

Local execution is not assumed to be inherently superior. It must still satisfy the required capability contract.

#### Private or sovereign runtime

A controlled runtime deployed through a private, regional, sovereign, or otherwise contractually constrained environment.

This class can provide stronger isolation or jurisdictional guarantees while retaining access to capabilities that may exceed locally deployable models.

The exact infrastructure can vary from self-hosted clusters to dedicated cloud or sovereign-provider deployments.

#### Approved external runtime

An external model provider explicitly permitted for a particular processing class.

External execution is not treated as unrestricted cloud access. The runtime remains subject to disclosure transformation, validation, contractual policy, capability qualification, and enterprise governance.

The presence of sensitive source data therefore does not automatically exclude an external runtime.

The relevant question is:

> **Can an approved transformation reduce the disclosed representation to an acceptable residual risk for the intended processing class?**

If the answer is no, the external runtime is ineligible.

If no remaining runtime satisfies both trust and capability requirements, the system should degrade transparently rather than silently weakening policy.

### Capability qualification remains independent from trust

A runtime can be trusted but incapable.

A runtime can be highly capable but not permitted.

These are independent failure modes.

The **Evaluation Service** therefore measures whether a runtime can satisfy a defined capability contract using appropriate evaluation criteria, benchmarks, regression tests, or domain-specific validation.

The **Model Execution Policy Service** consumes that qualification result together with the validated disclosure context and enterprise policy.

This keeps model quality from becoming a proxy for trust.

> **A stronger model is not automatically a more eligible model.**

Likewise, a local model does not become the preferred runtime solely because it is local.

The architecture avoids both forms of assumption.

### Processing class influences transformation

Transformation cannot be chosen without knowing what type of execution is intended.

The architecture does not need to select the final model instance before transformation, but it must know enough about the intended **processing or runtime class** to determine the required disclosure controls.

For example, the policy requirements for:

- local execution,
- private or sovereign execution,
- and external frontier reasoning

may differ substantially.

This creates the following trust path:

**Execution Request  
→ Data & Context Classification  
→ Authorized Purpose / Capability and Processing-Class Requirements  
→ Disclosure Transformation Policy (approve representation or deny)  
→ Data Transformation (policy-selected methods)  
→ Independent Transformation Validation (residual risk)  
→ Model Execution Policy (eligible runtime intersection or deny)  
→ Runtime Selection and Execution**

The exact implementation order may evaluate some constraints in parallel, but the architectural dependency remains the same:

**Runtime eligibility is based on the validated representation that will actually be disclosed.**

Not merely on the classification of the original source data.

### No transformed-payload store by default

The transformed representation is execution-scoped.

The architecture therefore does not introduce a dedicated persistent store for transformed payloads by default.

Persisting such representations would create an additional data lifecycle, retention responsibility, and potential disclosure surface.

Where regulatory, evidentiary, debugging, or reproducibility requirements demand persistence, the payload or transformation evidence can be stored explicitly under an applicable artifact and retention policy.

Otherwise, the safer default is:

**Transform → Validate → Execute → Dispose**

### Sovereignty through portability

AI sovereignty is treated as an architectural property rather than a commitment to a specific model vendor.

A sovereign design should preserve:

- model portability,
- data locality,
- runtime independence,
- provider substitutability,
- and policy-controlled disclosure.

This matters because model quality, licensing, deployment options, provider strategy, and regulatory conditions can change faster than enterprise architecture.

The platform should therefore be able to replace a model or provider without redefining agent roles, authority boundaries, or enterprise knowledge governance.

> **Sovereignty is an architectural property, not a model vendor choice.**

### The trust path remains platform-owned

Agents may request capabilities that eventually require model execution.

They do not decide unilaterally which representation may leave the enterprise boundary or which runtime is trusted to receive it.

That decision remains a platform responsibility.

> **The agent may request a capability. The platform decides what representation may be disclosed to the runtime executing it.**

This preserves the same architectural separation used throughout the system:

**Reasoning proposes. Policy constrains. Validation verifies. The platform executes.**

## 8. Operational data access is mediated, not delegated

Enterprise agents often need access to operational data, but providing useful data access does not require granting agents unrestricted access to production systems.

The architecture deliberately separates **analytical intent from physical data access**.

An agent may express what operational information it believes is needed to continue reasoning.

That expression is a request, not a determination that acquisition is necessary or permitted.

Where context sufficiency is uncertain, the **Context Need Assessment Service** may provide probabilistic assessment evidence.

The **Policy Decision Service** authorizes or denies the proposed acquisition under the effective identity, task, purpose, classification, and source constraints.

The **Orchestration Service** coordinates authorized acquisition, while the **Enterprise Data Access Service** enforces approved query contracts and source-level constraints.

The **Context Assembly Service** incorporates only permitted results into task context.

> **The agent expresses a need. Assessment informs. Policy authorizes. Data access enforces source constraints.**

### Existing enterprise systems remain authoritative

The architecture assumes that a large enterprise already has an established and heterogeneous data landscape.

This may include:

- ERP and CRM platforms,
- operational databases,
- data warehouses,
- data lakes and lakehouses,
- analytical platforms,
- semantic models,
- reporting systems,
- data products,
- domain APIs,
- and specialized business applications.

These systems remain authoritative for the data they own.

The multi-agent platform does not introduce a new universal database merely to make enterprise data easier for agents to consume.

Instead, the Enterprise Data Access Service provides a governed abstraction over approved access paths.

### Agents request information, not infrastructure

An Analysis Agent should not need to know whether the requested information ultimately comes from PostgreSQL, SQL Server, Snowflake, Databricks, SAP, a Power BI semantic model, a REST API, or another enterprise platform.

Its request should express the **semantic data requirement** rather than infrastructure-specific access instructions wherever possible.

For example, an agent may need:

- monthly claims by product group,
- the current value and definition of a KPI,
- revenue aggregated by region,
- the records associated with a governed business case,
- or a comparison between two approved reporting periods.

The platform can then map that requirement to an approved query contract, view, API, semantic model, data product, or other governed interface.

This reduces coupling between agent reasoning and the physical enterprise data landscape.

### Query contracts before arbitrary query generation

Allowing an agent to generate arbitrary SQL against production systems creates more than a security problem.

It also transfers assumptions about:

- schema semantics,
- joins,
- row-level security,
- temporal validity,
- business definitions,
- data quality,
- query cost,
- and operational impact

into probabilistic reasoning.

The architecture therefore favors **governed query contracts and approved access patterns** over unrestricted query execution.

A query contract can define, for example:

- the business capability it exposes,
- accepted parameters,
- underlying approved source,
- output schema,
- applicable authorization rules,
- classification,
- aggregation requirements,
- execution limits,
- and provenance metadata.

This does not prohibit dynamically generated queries in every implementation.

It means that dynamic generation must still execute within an explicitly governed boundary rather than becoming equivalent to unrestricted database authority.

> **Dynamic query generation may be flexible. Data authority remains constrained.**

### Semantic layers are first-class access paths

Where an enterprise already maintains governed semantic models or data products, the architecture can use them as preferred access paths.

This is particularly valuable for analytical questions because business concepts such as revenue, margin, claim ratio, customer segment, or reporting period frequently contain semantics that are not recoverable from physical database schemas alone.

A technically valid SQL query can still produce a semantically incorrect business answer.

The Data Access Service can therefore resolve an agent's information request against:

- approved semantic models,
- governed metrics,
- certified datasets,
- data-product contracts,
- curated views,
- or controlled APIs

before falling back to lower-level access mechanisms.

This keeps business semantics closer to their authoritative owners.

### Authorization remains request-scoped

The Data Access Service does not possess a universal entitlement that agents inherit.

Every request remains bound to the effective identity and authorization context of the originating task.

Relevant controls can include:

- user and service identity,
- role and group membership,
- source-system entitlements,
- row- or object-level security,
- data classification,
- permitted processing purpose,
- task context,
- and applicable policy decisions.

The Policy Decision Service determines whether the proposed acquisition is authorized under the effective request context.

The Enterprise Data Access Service enforces that authorization together with approved query contracts, source-system entitlements, and source-level constraints. It returns only the data permitted within the authorized acquisition scope.

Agent delegation does not widen the result set.

> **Authorization travels with the request.**

### Data minimization begins before model execution

The Model Execution & Trust Policy described in the previous section governs what representation may ultimately reach a model runtime.

Data minimization, however, should begin earlier.

The Enterprise Data Access Service should avoid retrieving unnecessary data merely because a later transformation service could remove it again.

Where possible, filtering, aggregation, projection, or purpose-specific query contracts reduce the data exposed to the agentic execution path from the beginning.

This creates two complementary controls:

**Acquisition minimization** limits what is obtained from operational sources and subsequently enters the task context, using source-scoped filters, projections, aggregation, bounded results, and approved query contracts.

**Disclosure minimization** limits the representation that may be provided to a model runtime for an authorized processing purpose.

The **Disclosure Transformation Policy Service** determines the permitted representation.

The **Data Transformation Service** applies the selected methods.

The independent **Transformation Validation Service** assesses the result before the **Model Execution Policy Service** determines runtime eligibility.

These controls operate at different trust boundaries.

Permission to acquire operational data does not imply permission to disclose the same representation to a model runtime.

> **Do not retrieve what the task does not need. Do not disclose what the runtime does not need.**

### Structured results remain attributable

Data returned to an agent should retain enough metadata to explain where the result came from and under which governed access path it was produced.

Depending on the implementation, a result envelope can include:

- source-system reference,
- query or data-product contract identifier,
- execution timestamp,
- applicable data version or reporting period,
- classification,
- authorization decision reference,
- transformation or aggregation metadata,
- and lineage or provenance references.

The agent does not need unrestricted access to all underlying implementation details, but downstream analysis should remain attributable to governed source data.

This becomes particularly important when an Analysis Agent produces a durable report or evidence package.

The resulting artifact can reference the governed data results from which its conclusions were derived.

### Operational access and workflow execution remain separate

Reading operational data and changing operational state are different capabilities.

The Enterprise Data Access Service provides governed read access.

Side-effecting operations remain behind the Workflow Service and the explicit policy and approval boundary described earlier.

This prevents analytical access from silently becoming execution authority.

Conceptually:

**Read path**

**Agent Request  
→ Policy Authorization  
→ Orchestration  
→ Enterprise Data Access Service  
→ Approved Data Interface  
→ Operational System  
→ Context Assembly**

**Write / side-effect path**

**Agent → Action Request → Policy → Approval if required → Workflow Service → Operational System**

The distinction remains explicit even when both paths ultimately interact with the same enterprise application.

### The data layer absorbs infrastructure change

A mediated access layer also provides architectural insulation.

Enterprise systems evolve. Databases are migrated, semantic models are replaced, APIs change, platforms move between cloud providers, and new data products appear.

If agent contracts depend directly on those physical systems, every infrastructure change can become an agent change.

By placing governed data access behind stable capability contracts, the architecture allows the enterprise data landscape and the agent layer to evolve at different speeds.

> **Agents depend on governed capabilities, not on database topology.**

## 9. Auditability and observability are different responsibilities

A governed multi-agent platform must be able to explain both **what happened** and **how the system behaved while it happened**.

These are related questions, but they are not the same architectural responsibility.

The architecture therefore separates **Audit** from **Observability**.

Audit provides durable evidence of governed actions, decisions, approvals, and state transitions.

Observability provides operational insight into execution behavior, performance, reliability, and system health.

> **Observability explains system behavior. Audit establishes accountable history.**

### Audit follows authority and state transitions

Audit is required wherever a significant governed decision or state transition occurs.

Representative audit events include:

- orchestration and routing decisions,
- context-need assessment references and outcomes,
- governed context acquisition authorization decisions,
- acquisition capability selection and execution outcomes,
- policy decisions and denials,
- approval outcomes,
- workflow execution,
- knowledge curation decisions,
- candidate promotion or rejection,
- semantic-index maintenance,
- graph lifecycle changes,
- disclosure transformation policy decisions,
- transformation execution and validation outcomes,
- residual disclosure-risk assessment references,
- runtime eligibility decisions,
- and references to resulting artifacts or evidence.

The architecture therefore models the **Audit Service** as an append-only platform responsibility.

An audit event should preserve enough context to reconstruct why a governed action occurred without requiring the original agent reasoning transcript to become the authoritative explanation.

Depending on the event type, useful audit metadata can include:

- event identifier,
- timestamp,
- request and task identifiers,
- initiating identity or service,
- affected resource,
- action or decision type,
- policy and configuration versions,
- approval reference,
- source and result references,
- runtime or capability reference where relevant,
- and the resulting state transition.

This supports traceability across a distributed execution without turning every internal model token or reasoning step into an enterprise record.

> **Governed decisions should be attributable without making hidden model reasoning part of the control plane.**

### Assessment evidence is not authorization evidence

Probabilistic assessments and deterministic governance decisions have different evidentiary roles.

The **Context Need Assessment Service** may produce assessment evidence about context sufficiency, uncertainty, and potentially relevant acquisition classes.

This evidence can inform subsequent platform decisions, but it does not authorize acquisition.

Audit records must therefore distinguish between:

- probabilistic assessment evidence,
- deterministic policy authorization or denial,
- orchestration decisions and execution outcomes,
- acquisition capability results,
- disclosure transformation policy decisions,
- transformation validation evidence,
- and model execution eligibility decisions.

Where an assessment contributes to a governed decision, the platform should preserve an attributable reference to the relevant assessment result and its versioned configuration.

A probabilistic assessment must not be recorded or interpreted as if it were an authoritative policy decision.

> **Assessment provides evidence. Policy establishes authority. Audit preserves the distinction.**

### Observability follows execution

Observability addresses a different class of questions.

Examples include:

- Which service or agent is slow?
- Where did an execution fail?
- How long did retrieval or model execution take?
- Which runtime was selected?
- How often are capability requests retried?
- Which dependency is producing errors?
- How frequently are knowledge gaps encountered?
- What are the latency and throughput characteristics of a workflow?
- How much model capacity or execution cost is being consumed?
- Are policy or transformation stages becoming operational bottlenecks?

These questions require telemetry rather than governance records.

Representative telemetry can include:

- distributed traces,
- service and agent execution latency,
- request counts,
- error rates,
- retry counts,
- queue depth,
- runtime latency,
- token or compute consumption,
- retrieval latency and result counts,
- transformation latency,
- workflow duration,
- cache effectiveness,
- and infrastructure health metrics.

The architecture already establishes an **Observability Service** as the boundary responsible for this operational telemetry.

### Business payloads are not telemetry by default

Agentic systems make indiscriminate logging particularly dangerous.

Prompts, retrieved documents, user context, intermediate reasoning artifacts, operational records, model inputs, and model outputs may contain sensitive enterprise or personal information.

The existence of a tracing system does not justify copying those payloads into it.

The architecture therefore treats telemetry metadata and business content as separate concerns.

> **Observability follows actions and decisions without indiscriminately logging business content.**

A trace can record that the Retrieval Service returned five governed artifacts without necessarily storing the complete contents of those artifacts.

A model-execution span can record runtime class, latency, token usage, capability, transformation reference, and outcome without automatically persisting the complete execution payload.

Where payload-level diagnostics are genuinely required, they should cross an explicit policy, classification, retention, and access-control boundary rather than being enabled as a default debugging convenience.

### Assessment and transformation evidence remain data-minimized

Context-need assessments, acquisition requests, transformation operations, and disclosure-risk validation can themselves involve sensitive task context or information about protected enterprise data.

Auditability does not require indiscriminate persistence of the underlying business payloads, prompts, assessment inputs, transformed representations, or model execution content.

By default, audit and observability should preserve attributable metadata and references rather than complete payloads.

Depending on the governed operation, relevant evidence may include:

- assessment outcome, uncertainty indicators, and assessment configuration reference,
- authorization decision identifier and policy version,
- acquisition capability, source class, and approved scope,
- query-contract or source-interface reference,
- disclosure transformation policy decision and permitted representation class,
- transformation method and validation status,
- residual-risk category or validation reference,
- eligible runtime class and execution decision,
- and task, request, artifact, or evidence correlation identifiers.

The exact evidence retained must remain proportionate to the applicable accountability, security, privacy, and retention requirements.

Where detailed payload-level evidence is necessary, its persistence requires explicit authorization and an appropriate retention and access-control policy.

> **Audit the governed decision without automatically retaining the governed data.**

### Correlation provides end-to-end traceability

The architecture contains multiple asynchronous and distributed responsibilities.

A single user request can involve orchestration, one or more agents, retrieval, operational data access, model execution, workflow actions, artifacts, and knowledge lifecycle operations.

Stable correlation identifiers therefore become important architectural infrastructure.

A request can be traced through identifiers such as:

- `request_id`
- `task_id`
- `parent_task_id`
- `artifact_id`
- `finding_id`
- policy-decision references,
- approval references,
- runtime-execution references,
- and trace or span identifiers.

These identifiers allow audit records, operational telemetry, artifacts, and lifecycle events to be correlated without collapsing them into one universal log.

This preserves separation of concerns while still supporting end-to-end investigation.

### Model and agent telemetry require different interpretation

Model execution introduces telemetry that conventional service architectures do not always expose.

Useful measurements can include:

- runtime selected,
- model and model-version reference,
- capability contract,
- execution latency,
- token or compute consumption,
- context size,
- retry or fallback behavior,
- qualification version,
- and evaluation outcome references.

Agent execution introduces another layer.

Useful signals can include:

- capabilities requested,
- number of reasoning or tool-use iterations,
- task completion state,
- failure category,
- knowledge-gap frequency,
- escalation frequency,
- and generated artifact references.

These measurements should not automatically be interpreted as quality metrics.

For example, fewer reasoning steps do not necessarily imply better reasoning, and higher token usage does not necessarily imply worse execution.

Operational telemetry describes behavior. Quality remains the responsibility of explicit evaluation.

> **Telemetry measures execution. Evaluation measures fitness.**

### Audit retention and telemetry retention are different

Audit and observability also have different lifecycle requirements.

Audit records may need long-term retention because they establish accountability for governed decisions, approvals, knowledge changes, or enterprise actions.

High-volume telemetry may have a much shorter useful lifetime and can often be aggregated or sampled over time.

Treating both as the same storage problem either makes observability unnecessarily expensive or makes audit evidence insufficiently durable.

The architecture therefore does not require both responsibilities to share the same persistence technology.

Their storage, retention, access controls, and integrity requirements should follow their respective purposes.

### Technology remains implementation-specific

The architecture deliberately does not prescribe a complete observability stack as part of the current reference architecture.

A concrete enterprise implementation could use technologies and standards such as:

- OpenTelemetry for traces, metrics, and context propagation,
- Prometheus-compatible metric collection,
- Grafana or equivalent operational visualization,
- enterprise logging and SIEM platforms,
- cloud-native monitoring services,
- or existing organization-wide observability infrastructure.

These are implementation choices rather than architectural dependencies.

The important requirement is that telemetry can cross component boundaries using stable correlation semantics while preserving the distinction between operational metadata and governed business content.

### Future evolution: Telemetry & Observability Plane

The current architecture establishes the **Audit Service**, the **Observability Service**, representative telemetry relationships, and the architectural boundary between operational telemetry and governed business state.

It deliberately does not yet prescribe a complete **Telemetry & Observability Plane**.

A future refinement can expand this area to cover topics such as:

- end-to-end distributed tracing conventions,
- service, agent, workflow, and runtime metrics,
- SLI and SLO definitions,
- alerting and incident integration,
- cost and capacity telemetry,
- model-runtime telemetry,
- agent execution traces,
- privacy-aware diagnostic sampling,
- telemetry retention and aggregation,
- and integration with enterprise monitoring and SIEM platforms.

This is an extension of an existing architectural boundary rather than a missing governance responsibility.

The current views therefore remain valid without introducing an additional architecture view dedicated to telemetry and observability.

> **The architecture defines where observability belongs. Further refinement can define how deeply it is implemented.**

## 10. Evaluation and controlled evolution

A governed agentic system should improve over time without allowing operational feedback to silently redefine its own architecture, policies, or authority boundaries.

The architecture therefore separates **observation, evaluation, qualification, and change**.

Operational telemetry can reveal how the system behaves. User and business feedback can reveal where results are useful or insufficient. Evaluation can determine whether an agent, model runtime, prompt, retrieval strategy, or capability satisfies an expected quality threshold.

None of these signals directly authorizes a production change.

> **Feedback informs change. It does not authorize change.**

### Evaluation is an explicit platform responsibility

The Evaluation Service provides a controlled mechanism for determining whether a capability or runtime satisfies defined expectations.

Evaluation can operate at several levels:

- model and runtime capability,
- agent task performance,
- context-need assessment quality and calibration,
- governed context acquisition effectiveness and minimization,
- retrieval and graph-query quality,
- groundedness and evidence quality,
- analytical correctness,
- disclosure transformation effectiveness and task utility,
- transformation validation reliability,
- workflow outcome quality,
- and regression behavior across system changes.

The architecture does not prescribe one universal evaluation metric because different capabilities require different definitions of success.

A Domain Support Agent answering policy questions may require strong groundedness and citation quality.

An Analysis Agent may require numerical correctness, reproducibility, and appropriate source selection.

A Research Agent may require evidence diversity, source quality, uncertainty handling, and provenance completeness.

Model-runtime qualification may instead focus on whether a particular runtime reliably satisfies a defined capability contract.

Evaluation is therefore attached to **capabilities and expected behavior**, not merely to model names.

### Probabilistic context assessment requires calibration

The Context Need Assessment Service produces probabilistic evidence about context sufficiency and potentially relevant acquisition needs.

Its quality cannot be evaluated solely by whether an additional acquisition was subsequently performed.

An authorized acquisition may be unnecessary, while a denied acquisition may still have been correctly identified as potentially useful.

Evaluation must therefore distinguish assessment quality from policy authorization and orchestration outcomes.

Representative evaluation dimensions include:

- calibration of estimated context insufficiency,
- false-positive and false-negative assessment behavior,
- accuracy of suggested context classes,
- sensitivity to task complexity and available evidence,
- unnecessary acquisition recommendations,
- missed information needs,
- and robustness across domains and task types.

Evaluation scenarios should include tasks where sufficient context already exists, tasks requiring additional governed context, and tasks where further acquisition is unavailable or prohibited.

Assessment thresholds and configurations should be versioned, evaluated, and changed through controlled governance.

> **Assessment quality is measured against evidence and outcomes, not inferred from whether policy permitted acquisition.**

### Acquisition and disclosure controls require distinct evaluation

Governed context acquisition and model disclosure transformation operate at different trust boundaries and must be evaluated separately.

Acquisition evaluation examines whether the platform obtained appropriate, authorized, task-relevant context without unnecessary source access.

Representative dimensions include:

- relevance and sufficiency of acquired context,
- correct acquisition-class selection,
- adherence to source and query-contract constraints,
- unnecessary or excessive acquisition,
- provenance and classification preservation,
- and behavior when acquisition is denied or produces insufficient results.

Disclosure evaluation examines whether the policy-approved representation satisfies disclosure constraints while preserving sufficient utility for the authorized processing purpose.

Representative dimensions include:

- compliance with the approved disclosure representation,
- effectiveness of required transformation methods,
- residual disclosure and re-identification risk,
- independence and reliability of transformation validation,
- preservation of task-relevant information,
- and correct denial when no compliant runtime remains.

Evaluation results may inform changes to assessment configurations, acquisition contracts, transformation methods, validation criteria, or capability qualification.

They do not independently authorize broader acquisition, weaker disclosure constraints, or expanded runtime eligibility.

> **Evaluate what was acquired, what was disclosed, and whether each boundary remained effective.**

### Capability qualification is versioned

A runtime that performed adequately six months ago should not remain qualified forever merely because its name has not changed.

Models, providers, prompts, tools, retrieval pipelines, context strategies, and surrounding dependencies can evolve.

Qualification should therefore refer to a versioned execution configuration rather than an abstract model label.

A qualification record can reference information such as:

- capability contract,
- runtime and model version,
- evaluation specification,
- prompt or agent-contract version,
- tool and retrieval configuration where relevant,
- evaluation dataset or scenario set,
- measured results,
- acceptance thresholds,
- qualification status,
- and evaluation timestamp.

This makes qualification reproducible and allows the Model Execution Policy Service to consume a concrete statement about capability fitness.

> **Qualification belongs to an execution configuration, not to a model name.**

### Feedback is evidence, not policy

User feedback, reviewer corrections, operational incidents, failed tasks, knowledge gaps, and observed quality regressions are valuable signals.

They can identify where the system needs improvement.

They should not directly rewrite:

- agent contracts,
- orchestration rules,
- prompts,
- policies,
- authorization boundaries,
- knowledge lifecycle rules,
- model eligibility criteria,
- or canonical enterprise knowledge.

Instead, feedback becomes evidence for a controlled change process.

Conceptually:

**Feedback / Telemetry / Evaluation  
→ Improvement Candidate  
→ Review / Validation  
→ Versioned Change  
→ Evaluation  
→ Approval  
→ Activation**

The exact engineering workflow can vary, but the architectural principle remains stable.

> **Feedback improves the system through controlled evaluation, not autonomous self-modification.**

### Agent evolution and knowledge evolution are separate

Improving how an agent behaves is not the same as changing what the enterprise knows.

A corrected business definition belongs to the governed knowledge lifecycle.

A better reasoning strategy belongs to the agent or prompt lifecycle.

A new runtime qualification belongs to the evaluation and model-execution lifecycle.

A changed authorization rule belongs to governance.

Keeping these change domains separate prevents one form of feedback from accidentally modifying another form of authority.

For example, repeated user disagreement with a policy answer may indicate:

- outdated canonical knowledge,
- poor retrieval,
- inadequate agent reasoning,
- an ambiguous business definition,
- or an incorrect policy implementation.

The architecture should diagnose which layer requires change rather than allowing the agent to modify whichever layer is easiest to reach.

### Evaluation should include failure behavior

A system should not be evaluated only on successful answers.

Controlled failure is part of system quality.

Evaluation should therefore include scenarios where the correct behavior is to:

- report insufficient governed knowledge,
- refuse an unauthorized data request,
- request human approval,
- reject an unsafe transformation,
- exclude an otherwise capable external runtime,
- avoid executing an unauthorized side effect,
- or escalate uncertainty rather than fabricate an answer.

This is particularly important for agentic systems because apparent task completion is not always the desired outcome.

> **A system that knows when not to act can be more reliable than one optimized only to complete tasks.**

### Changes are activated deliberately

Architecture, policy, agents, models, and knowledge will evolve.

The architecture does not attempt to prevent that evolution. It attempts to make significant changes **explicit, versioned, evaluable, and reversible where practical**.

Git is a suitable reference mechanism for version-controlled artifacts such as:

- agent contracts,
- policy definitions,
- prompt templates,
- evaluation specifications,
- and deployment configuration.

A relational store such as PostgreSQL can complement this with operational state such as:

- active versions,
- approval state,
- capability registry entries,
- runtime configuration,
- and qualification results.

This separates version-controlled definitions from their currently active operational state.

### Continuous improvement without autonomous governance

Nothing in this architecture prevents sophisticated automated evaluation, experimentation, candidate generation, or recommendation.

The boundary is activation authority.

A system may automatically discover that another prompt performs better.

It may automatically identify a stronger model.

It may automatically propose a new retrieval configuration.

It may even generate a candidate policy or agent contract.

But generating a candidate and activating it are different authorities.

> **The system may automate discovery of improvements without automating away governance over their activation.**

This keeps the platform evolvable without turning production behavior into an uncontrolled consequence of its own feedback loops.

## 11. Deliberately rejected shortcuts and architectural trade-offs

Every architectural boundary introduces complexity.

The design choices in this reference architecture are therefore not presented as universally superior patterns. They deliberately optimize for explicit authority, governed enterprise state, runtime portability, traceability, and controlled autonomy.

Those properties come at a cost.

Several simpler architectural patterns were considered conceptually and deliberately not adopted as the baseline design.

### A supervisor agent as the central control plane

A central supervisor agent could simplify delegation by combining request interpretation, agent selection, tool routing, and execution planning in one autonomous component.

This can be an effective pattern when flexible delegation itself is the primary problem.

It was not chosen as the control plane for this architecture because the same component would then risk accumulating both reasoning responsibility and platform authority.

The chosen alternative separates deterministic orchestration from bounded agent reasoning.

**Benefit:**
- clearer authority boundaries,
- explicit task ownership,
- more predictable policy enforcement,
- easier auditability,
- and reduced coupling between model behavior and control-plane behavior.

**Trade-off:**
- more explicit orchestration logic,
- additional platform services,
- and less freedom for agents to dynamically redefine the execution topology.

The architecture accepts this additional platform complexity because enterprise authority should remain explicit.

### One agent for every capability

Another possible design is to represent retrieval, routing, SQL generation, policy evaluation, memory management, model selection, validation, and other responsibilities as individual agents.

This can produce a visually and conceptually uniform system in which almost every operation is expressed as agent collaboration.

It was deliberately rejected as the baseline.

Capabilities whose primary responsibility is deterministic enforcement, lifecycle management, persistence, or authority do not gain architectural value merely by becoming autonomous.

The chosen architecture therefore contains relatively few agent archetypes and many explicit services.

**Benefit:**
- autonomy is concentrated where adaptive reasoning adds value,
- service responsibilities remain testable and reproducible,
- and authority does not become distributed across probabilistic components.

**Trade-off:**
- the architecture is intentionally hybrid rather than uniformly agentic,
- and some workflows require explicit coordination between agents and deterministic services.

> **More agents do not automatically create more useful agency.**

### Letting agents or context assessment authorize acquisition

An agent can identify missing information, and a probabilistic Context Need Assessment can estimate whether additional context would help.

Neither is a sufficient basis for granting access to enterprise knowledge, graph relationships, operational data, or external sources.

The architecture deliberately rejects a shortcut in which an agent's request or an assessment score directly triggers acquisition without a separate policy decision.

The chosen alternative keeps context-need evidence, deterministic authorization, and acquisition execution separate. The Policy Decision Service authorizes the proposed task-scoped acquisition; Orchestration coordinates its execution through the appropriate governed capability.

**Benefit:**
- probabilistic assessment cannot silently become access authority,
- acquisition remains purpose-scoped and auditable,
- and unnecessary or prohibited acquisition can be declined without treating the assessment itself as incorrect.

**Trade-off:**
- an additional decision boundary can increase latency and coordination,
- and some useful context may remain unavailable when policy denies acquisition.

> **Assessment estimates need. Policy grants permission. Orchestration executes only what is authorized.**

### Direct agent access to enterprise databases

Direct SQL or database access can make an analytical agent extremely flexible.

It also couples the agent to physical schemas, source-specific semantics, credentials, authorization behavior, query cost, and operational risk.

The Policy Decision Service determines whether the proposed acquisition is authorized under the effective request context.

The Enterprise Data Access Service enforces that authorization together with approved query contracts, source-system entitlements, and source-level constraints. It returns only the data permitted within the authorized acquisition scope.

**Benefit:**
- stronger authorization boundaries,
- better semantic consistency,
- reduced infrastructure coupling,
- controlled query behavior,
- and improved provenance.

**Trade-off:**
- new analytical capabilities may require new or extended access contracts,
- and the platform must maintain an abstraction layer over heterogeneous enterprise systems.

This deliberately exchanges unrestricted flexibility for governed flexibility.

### A vector database as enterprise memory

A single vector database can provide a simple implementation for document retrieval and semantic memory.

It was rejected as the authoritative enterprise knowledge model.

Embeddings and similarity indexes are optimized for locating information, not for representing approval state, versioning, ownership, provenance, validity, lifecycle, or enterprise authority.

The architecture therefore keeps canonical knowledge separate from its semantic representation.

**Benefit:**
- semantic indexes can be rebuilt or replaced,
- canonical state remains independently governable,
- and retrieval technology can evolve without redefining enterprise truth.

**Trade-off:**
- retrieval requires rehydration of canonical artifacts,
- index maintenance becomes an explicit responsibility,
- and multiple representations of knowledge must remain synchronized.

> **Canonical state survives semantic infrastructure change.**

### Automatic promotion of agent findings into shared knowledge

Allowing agents to write useful discoveries directly into shared memory can create rapid adaptation.

It can also turn hallucinations, transient external information, misunderstood business context, or low-quality findings into persistent enterprise state.

The architecture therefore introduces Candidate Knowledge, Knowledge Curation, validation, and Promotion.

**Benefit:**
- provenance and lifecycle remain explicit,
- knowledge can be reviewed and corrected,
- and autonomous reasoning cannot silently redefine enterprise truth.

**Trade-off:**
- knowledge acquisition becomes slower,
- curation requires additional infrastructure,
- and some information may remain task-local even when it appears immediately useful.

This is intentional.

> **Fast learning is not valuable if the system cannot distinguish learning from contamination.**

### Treating retrieval and research as the same search capability

A unified search mechanism could make the system simpler: search internal sources first and automatically extend to external sources when necessary.

The architecture deliberately keeps these operations separate.

Internal retrieval accesses governed knowledge. External research crosses a trust boundary and produces evidence whose authority has not yet been established.

**Benefit:**
- external information cannot silently acquire internal trust,
- research eligibility remains policy-controlled,
- and provenance is preserved through the knowledge lifecycle.

**Trade-off:**
- knowledge gaps become explicit workflow states,
- research requires an additional policy decision,
- and some questions may terminate without an answer when external research is not permitted.

The architecture accepts that outcome.

An explicit unknown is preferable to silently changing the trust model.

### Selecting the strongest available model by default

A straightforward runtime strategy is to route difficult tasks to the most capable available model.

This was rejected because capability is only one dimension of runtime eligibility.

A model can be capable but not permitted to receive the required representation. Conversely, a permitted local model can be insufficient for the required capability.

The architecture therefore evaluates trust and capability independently before optimization.

**Benefit:**
- model quality cannot override disclosure policy,
- local execution is not preferred merely for ideological reasons,
- external execution remains possible where transformation and policy permit it,
- and providers remain replaceable.

**Trade-off:**
- runtime selection requires classification, transformation, validation, qualification, and policy evaluation,
- and the globally strongest model may deliberately not be selected.

> **The best model is the best eligible model for the task, not the strongest model in the catalog.**

### Treating transformation or validation as disclosure permission

A simpler execution path could transform sensitive data, check that the transformation succeeded, and then assume the result is safe to send to whichever model can complete the task.

The architecture deliberately rejects this shortcut.

The Disclosure Transformation Policy Service first determines the minimum viable representation permitted for the authorized purpose and intended processing class. The Data Transformation Service applies the approved methods. The independent Transformation Validation Service assesses the resulting representation and residual disclosure risk without granting new permission or overriding a denial.

Only then does the Model Execution Policy Service determine the intersection of disclosure permission, capability qualification, governance, and operational eligibility. No eligible runtime is a valid denial outcome, not a reason to weaken the constraints.

**Benefit:**
- disclosure permission remains a policy decision rather than a technical side effect,
- transformation defects and residual risks are assessed independently,
- and runtime selection cannot bypass disclosure restrictions.

**Trade-off:**
- more explicit checks are required before execution,
- and an otherwise useful model may remain ineligible even after transformation.

> **Transformation changes data. Validation evaluates risk. Neither authorizes disclosure.**

### Persisting transformed payloads by default

Persisting transformed execution payloads could simplify debugging, replay, and reproducibility.

The architecture deliberately avoids introducing a transformed-payload store as a default component.

Every persisted representation creates another lifecycle involving access control, retention, deletion, classification, and potential re-identification risk.

**Benefit:**
- smaller persistent disclosure surface,
- fewer redundant data representations,
- and simpler retention responsibilities.

**Trade-off:**
- exact execution replay may require explicitly retained evidence,
- and some debugging scenarios become more difficult.

Where persistence is genuinely required, it should be introduced intentionally under an appropriate artifact, evidence, and retention policy.

### Using the Knowledge Graph as an authorization system

An Enterprise Knowledge Graph can represent relationships between people, teams, systems, capabilities, data products, and organizational responsibilities.

Those relationships can look very similar to authorization information.

The architecture deliberately does not make the graph an IAM authority.

A relationship such as `MEMBER_OF`, `OWNS`, or `HAS_ROLE` describes enterprise context. It does not independently grant permission to access a resource.

**Benefit:**
- organizational knowledge and security authority remain independently governed,
- graph errors cannot directly become privilege grants,
- and existing enterprise IAM remains authoritative.

**Trade-off:**
- some decisions require combining graph context with IAM information,
- and apparently redundant organizational representations may exist across systems.

> **Knowledge Graph describes relationships. IAM grants authority.**

### Treating Redis or runtime memory as durable system state

Fast in-memory infrastructure is attractive for task state, session state, agent memory, and distributed coordination.

The architecture uses such infrastructure only for state that is intentionally ephemeral.

Durable task state, enterprise knowledge, evidence, policy state, and other authoritative information belong in durable governed stores.

**Benefit:**
- transient infrastructure can be replaced or rebuilt,
- failover does not redefine enterprise truth,
- and runtime topology remains independent of authoritative state.

**Trade-off:**
- durable persistence introduces additional latency and coordination,
- and the system must explicitly distinguish ephemeral from durable state.

The resulting rule remains intentionally unsophisticated:

> **If losing Redis destroys enterprise truth, we designed it wrong.**

### Logging everything for explainability

Agentic systems can create pressure to persist complete prompts, responses, retrieved documents, tool calls, intermediate states, and model traces in the name of explainability.

The architecture deliberately rejects indiscriminate payload logging.

Auditability should establish accountable decisions and state transitions. Observability should describe execution behavior. Neither responsibility automatically requires storing every business payload processed by the system.

**Benefit:**
- reduced disclosure surface,
- clearer retention boundaries,
- and less accidental replication of sensitive data into telemetry systems.

**Trade-off:**
- some debugging investigations may have less raw historical context,
- and diagnostic payload capture must be explicitly enabled where justified.

Explainability is therefore achieved through provenance, structured decisions, correlation, evidence, and controlled diagnostics rather than universal surveillance of execution content.

### Autonomous self-modification

An adaptive system could theoretically use feedback and evaluation results to modify prompts, agent behavior, routing strategies, policies, or knowledge automatically.

The architecture permits automated discovery and generation of improvement candidates but rejects autonomous production activation as the baseline.

**Benefit:**
- system evolution remains versioned and reviewable,
- regressions can be evaluated before activation,
- and feedback cannot silently modify authority boundaries.

**Trade-off:**
- improvement cycles are slower,
- additional evaluation and approval infrastructure is required,
- and the system sacrifices some forms of autonomous adaptation.

This is a deliberate boundary between **learning about improvement** and **authorizing change**.

### The cumulative trade-off

Taken individually, many of the rejected shortcuts would make an implementation simpler.

Taken together, however, they would concentrate increasing amounts of state, authority, trust, and lifecycle responsibility inside autonomous components.

This architecture deliberately moves in the opposite direction.

Agents receive meaningful autonomy within bounded tasks while the platform retains authority over:

- identity and authorization,
- task lifecycle,
- enterprise state,
- operational execution,
- knowledge promotion,
- disclosure,
- runtime eligibility,
- evaluation,
- and governed change.

The resulting architecture contains more explicit boundaries and services than a minimal multi-agent implementation.

That is the primary cost of the design.

The intended benefit is that autonomous reasoning can evolve without requiring the enterprise to surrender control over the systems, data, knowledge, and decisions surrounding it.

> **Autonomy belongs in reasoning. Authority belongs in the platform.**

## 12. Architectural scope and evolution

This reference architecture describes a governed foundation for enterprise multi-agent systems.

It is intentionally more explicit than a minimal agent implementation, but it is not intended to model every concern required for a production deployment.

The reference model establishes boundaries that should remain stable even as governed context acquisition, model disclosure controls, implementations, infrastructure, and individual use cases evolve.

These include:

- deterministic ownership of orchestration and task state,
- bounded agent autonomy,
- explicit authority and capability boundaries,
- probabilistic context-need assessment without acquisition authority,
- deterministic authorization and orchestration of task-scoped context acquisition,
- governed access to canonical knowledge, graph context, operational enterprise data, and explicitly authorized external evidence,
- acquisition minimization and provenance-preserving context assembly,
- separation of canonical, candidate, derived, and operational state,
- controlled knowledge acquisition and promotion,
- explicit approval boundaries for side effects,
- policy-controlled disclosure representation and transformation,
- independent transformation validation without authorization authority,
- model execution eligibility based on disclosure, capability, governance, and operational constraints,
- independent capability qualification,
- and separation of audit, observability, evaluation, and governed change.

These are the architectural invariants of the reference model.

### What the reference architecture deliberately does not prescribe

The architecture intentionally stops before several implementation-specific concerns.

It does not prescribe:

- a deployment topology,
- Kubernetes or another orchestration infrastructure,
- a specific cloud provider,
- a particular agent framework,
- concrete database schemas,
- API protocols,
- event-bus technology,
- prompt structures,
- context-window strategies,
- embedding models,
- exact evaluation datasets,
- specific policy languages,
- a complete telemetry platform,
- disaster-recovery topology,
- or organization-specific approval processes.

These concerns matter in a production implementation, but they can vary substantially without changing the architectural boundaries described here.

Leaving them open is deliberate.

> **A reference architecture should constrain the decisions that define the system without pretending to decide every implementation detail.**

### Not every implementation needs every component

The diagrams describe architectural responsibilities, not a mandatory list of independently deployed microservices.

Several responsibilities may share a deployment unit in a smaller implementation while remaining logically separate.

For example, classification, disclosure transformation policy, and model execution policy might initially be implemented within one governance service, while retaining distinct decision responsibilities.

The Data Transformation Service and independent Transformation Validation Service may also share deployment infrastructure without collapsing their logical responsibilities.

Canonical and Candidate Knowledge might reside in separate schemas of the same PostgreSQL cluster. Artifact metadata and durable task state might share infrastructure.

The logical boundaries should survive such consolidation.

Conversely, scale, regulatory requirements, organizational ownership, or operational isolation may later justify separating those responsibilities physically.

> **Logical separation does not require physical distribution.**

This distinction allows the architecture to scale in both directions: it can guide an initial implementation without forcing premature infrastructure complexity, while still defining boundaries that remain meaningful when the platform grows.

### Architecture before implementation scale

The architecture can therefore support different maturity stages.

An early implementation may begin with:

- one or two high-value domain capabilities,
- a limited set of governed acquisition capabilities and data interfaces,
- a basic context-need assessment capability where uncertainty warrants it,
- a small canonical knowledge domain,
- a single semantic index,
- one local and one approved external runtime,
- explicit policy authorization for acquisition and disclosure,
- and explicit audit of the most significant governed decisions.

A more mature implementation can progressively introduce:

- additional Domain Contracts,
- broader governed context acquisition across knowledge, graph, operational data, and external evidence,
- calibrated context-need assessment across domains,
- richer knowledge-graph relationships,
- automated curation support,
- more sophisticated disclosure transformation and independent validation,
- more sophisticated runtime qualification,
- sovereign or specialized runtimes,
- expanded evaluation,
- stronger approval workflows,
- and a dedicated Telemetry & Observability Plane.

The important property is that these additions extend existing boundaries rather than requiring the system to redefine where authority lives.

This creates a practical distinction between **architectural completeness** and **implementation completeness**.

A production platform does not need to implement every possible capability on day one.

It does need to know where those capabilities belong when they become necessary.

> **Start with fewer capabilities, not with weaker boundaries.**

### Technology can change without redefining authority

The reference technologies discussed throughout this document are deliberately replaceable.

PostgreSQL may be replaced or complemented by another governed persistence platform.

pgvector may evolve into a dedicated vector database.

Neo4j may be replaced by another graph technology.

Redis may be replaced by another ephemeral coordination mechanism.

Model providers and model families will certainly change.

Agent frameworks may appear, mature, or disappear.

None of these changes should require the enterprise to reconsider fundamental questions such as:

- who owns task state,
- who grants authority,
- who may execute side effects,
- what constitutes canonical knowledge,
- how external findings become trusted,
- what representation may cross a trust boundary,
- or whether an agent may modify enterprise state directly.

Those are architectural decisions rather than product selections.

### Future evolution should preserve invariants

Future versions of this architecture can deepen individual areas without abandoning the established authority, trust, state, acquisition, and disclosure boundaries.

Potential areas of evolution include:

- a dedicated Telemetry & Observability Plane,
- more detailed capability and Domain Contract models,
- formal policy representations,
- richer human-in-the-loop workflows,
- advanced provenance and lineage,
- distributed knowledge lifecycle patterns,
- more detailed model and transformation qualification,
- multi-region and sovereign deployment patterns,
- resilience and disaster-recovery architecture,
- and implementation-level security threat modeling.

New agent archetypes may also emerge.

The architecture does not assume that Domain Support, Analysis, and Research are the only useful forms of enterprise agency forever.

A new capability should become an agent when bounded autonomy genuinely improves its ability to perform the task — not merely because implementing another agent is technically possible.

The same test therefore continues to apply:

> **A capability becomes an agent only when autonomy adds value.**

### A reference architecture, not a finished platform

The architecture views and the rationale in this repository describe a coherent architectural model.

They are not a claim that the resulting platform can be implemented as a single fixed product or delivered through one universal implementation plan.

Actual delivery depends on the enterprise environment, existing systems, data maturity, governance requirements, regulatory constraints, organizational responsibilities, and the capabilities selected for the initial scope.

The purpose of the reference architecture is different.

It provides a stable structure within which those implementation decisions can be made deliberately.

The system can start small.

Its models can change.

Its infrastructure can change.

Its capabilities can expand.

Its agents can improve.

Its knowledge can grow.

But the boundaries around authority, trust, enterprise state, and governed execution should remain explicit while it does so.

> **Build autonomy incrementally. Keep authority explicit from the beginning.**
