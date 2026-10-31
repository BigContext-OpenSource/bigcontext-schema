# BigContext Schema

**An open standard for writing down how a business actually works: its rules, processes, decisions and
responsibilities. People, software and AI agents all read it the same way, and every statement points back to the
exact words it came from.**

Status: version 1.0.0. Licence: Apache 2.0, free for anyone to use and build on.

---

## In one minute

Every company runs on context that is written down in many places and fully in none: in wikis, policies,
playbooks, chat threads and people's heads. *Which revenue number goes to the board. When a drop is serious enough
to investigate. Who has to check a figure before it reaches the executives. What changed last month, and who
decided it.*

AI agents are now asked business questions every day. Today's data standards can tell an agent **how to calculate**
a number. They cannot tell it **the rules around that number**: when to act, what to do first, what is not allowed,
who to tell, and what changed. So the agent guesses, or a person has to step in.

BigContext Schema is a common format for writing that context down as small, clear statements, each one quoting
the sentence it came from. A person can read every statement as a plain-English sentence. A program can check it,
query it and act on it. An AI agent can answer from it and show its source.

## Why it is needed

Take a sentence from an ordinary analytics playbook:

> Do not share a preliminary cause with the executive team unless Finance has checked the numbers.

A semantic layer, the part of the data stack that defines metrics, has nowhere to put this sentence. A wiki page
can hold it as prose, but no system can check it, enforce it, or notice when it changes. Multiply that by every
rule, step, threshold, owner and exception in a company, and you get the gap that BigContext Schema fills:

- **Context is scattered.** It lives in documents and conversations, so nobody can see all of it at once.
- **Prose cannot be checked.** A program cannot tell whether two pages contradict each other, or which rule applies
  on a given date.
- **Rules change quietly.** A threshold moves from 15% to 10%, and older copies keep saying 15%.
- **Answers cannot be traced.** When an agent gives advice, nobody can see which sentence it relied on.

## What you get

- **One format for every kind of context.** Definitions, rules, step-by-step procedures, who reports to whom, who
  owns what, which data source wins for which purpose, known data problems, open questions.
- **Every statement traceable.** Each one quotes the exact words of its source. An answer always comes with where it
  came from.
- **It knows what holds today.** Statements carry their dates, who proposed and who decided them, and what they
  replaced, so you can ask "what applied in June?" and get the June rule.
- **Readable by people.** Every statement can be shown back as a plain-English sentence, so the people who own the
  context can review it without learning a format.
- **Checkable by machines.** A checker rejects anything malformed or untraceable and explains why, in plain English.
- **Works with what you already use.** Metric definitions export to dbt's semantic layer and to OSI; rules export to
  the W3C policy language ODRL; everything loads into a knowledge graph (RDF, OWL, Cypher).
- **Open and vendor-neutral.** Anyone can write, read or build tools for it.

## How it differs from semantic layers and other formats

A semantic layer, such as dbt's or OSI, says **how to calculate a number**. BigContext Schema says **everything
around it**. It includes the metric definitions too, so it can feed the semantic layer rather than replace it.

| What people need to know | Semantic layer | BigContext Schema |
|---|---|---|
| How is net revenue calculated? | Yes | Yes, and exports it to the semantic layer |
| Which definition does the board use, and which does Finance? | No | Yes |
| When should someone investigate a drop? | No | Yes |
| What must be done first, and what is never allowed? | No | Yes |
| Who may share a number, with whom, and who must approve it first? | No | Yes |
| Who owns this, and who do I escalate to? | No | Yes |
| What changed, when, and who decided? | No | Yes |
| What known data problems should I allow for? | No | Yes |
| Which sentence does each answer come from? | No | Yes, the exact quote |

**Knowledge formats** such as Google Cloud's OKF package pages of prose together with who wrote and verified them.
BigContext Schema records what those pages *say*, as statements a program can use. A BigContext Schema document can
travel inside such a package.

**Ontology languages** such as OWL can express anything once someone designs the vocabulary. BigContext Schema is
that vocabulary for business context. It is published as OWL, and its building blocks are mapped to the W3C
standards for policies (ODRL), organizations (ORG), concepts (SKOS) and provenance (PROV).

## A small example

The sentence:

> Refunds over $500 must be approved by the Finance controller, unless the customer is on the VIP list.

becomes one statement:

```yaml
- id: s.1.3
  predicate: Rule
  modality: must_not
  action: {verb: other, specific_verb: issue, objects: [c.refund]}
  when:
    - description: the refund is over $500
      about: [c.refund_amount]
      values: [{value: "500", unit: USD, role: threshold, comparator: more_than}]
  unless:
    - {description: the Finance controller has approved it, about: [t.finance_controller]}
    - {description: the customer is on the VIP list, about: [t.vip_list]}
  evidence:
    - quote: Refunds over $500 must be approved by the Finance controller, unless the customer is on the VIP list.
```

and reads back as:

> When the refund is over $500: must not issue refund, unless the Finance controller has approved it; or the
> customer is on the VIP list.

A program can now check the $500 threshold against data, route the approval to the Finance controller, and show the
original sentence to anyone who asks why.

## What it covers

- **Meaning:** definitions, categories, synonyms, groupings, value lists, calculations.
- **Rules:** how strongly a rule holds (must, should, may, by default), its conditions, exceptions, reasons and
  what it overrides; groups of rules that share a precedence.
- **Procedures:** ordered steps with branches, time limits, who performs each step, and the procedures they call.
- **Organization:** units, posts, who heads, reports to, approves for, works with and escalates to whom, including
  acting, backup and dotted-line roles.
- **Data:** what a table holds, its grain, keys, coverage and status; joins; metrics with their aggregation, filters
  and time dimension; data products with their owners and approved uses; data-quality expectations.
- **Tools:** what a tool is for, who may use it, when it must not be used, and sample calls.
- **Standing and time:** who proposed, decided, supported or disputed a statement, its dates, and what it replaced.
- **Links between sources:** the same thing named in two documents, linked once a person confirms it.
- **Evidence:** every statement quotes the exact source text it came from.

## How to use it

**If you want to capture your own context:**

1. **Look at an example.** Each folder in `examples/` holds a short source text beside the document written from it.
2. **Express a text.** Give any AI model `guide.md`, `bigcontext_schema.yaml` and your text, and ask for a
   BigContext Schema document. A person can write one by hand just as well.
3. **Check it.** Any JSON Schema validator checks its structure (see *Checking a document* below).
4. **Use it.** Give the documents to your AI agent, load them into a knowledge graph and ask the questions in
   `queries/` (SPARQL) or `cypher/` (Cypher), or export the metric definitions to your semantic layer.

The free BigContext Schema tools (coming soon) do steps 2 to 4 for you: an extraction prompt
with a check-and-fix loop, a checker that also verifies every quote, a coverage check, a graph export, and
converters to dbt, OSI and ODRL.

**If you want to build a tool that supports it:**

- **A tool that writes documents** (an extractor, an editor, a catalog export) produces documents that pass the
  JSON Schema, whose references point at declared elements, and whose quotes are copied exactly from the source.
- **A tool that reads documents** (an agent, a graph store, a catalog) understands every statement type, and treats a
  statement as in force only by the rules in `graph.md`: its dates, its decision status, what replaced it, whose
  view it is, and how certain it is.
- **A tool that connects to other standards** uses the alignment table below.

## What is in this repository

| File | What it is |
|---|---|
| `bigcontext_schema.yaml` | The schema, written in [LinkML](https://linkml.io). The single source of truth |
| `guide.md` | How to express a text in the schema, for people and AI models alike |
| `graph.md` | How documents become a knowledge graph, and which statements count as in force on a date |
| `conformance.md`, `tests/` | What a conforming document, producer and graph builder must do, and the cases that check it |
| `CHANGELOG.md`, `GOVERNANCE.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` | What changed in each version; who decides changes and how; how to contribute; how everyone taking part behaves |
| `bigcontext_facts.yaml` | The vocabulary of the graph's facts (reports to, owns, escalates to, same as) |
| `queries/`, `cypher/` | Ready-made questions, in SPARQL and Cypher |
| `generated/` | Files generated from the schema: JSON Schema, OWL, SHACL shapes and a JSON-LD context |
| `examples/` | Example documents, each beside the source text it quotes |

## Checking a document

Any JSON Schema validator that supports draft 2019-09 checks a document's structure, for example (no install
needed with [uv](https://docs.astral.sh/uv/)):

```bash
uvx check-jsonschema --schemafile generated/bigcontext_schema.schema.json examples/order-tracking/document.yaml
```

`conformance.md` lists everything a conforming document must satisfy beyond the JSON Schema, and `tests/` holds the
cases an implementation can check itself against. The free BigContext Schema tools add what a JSON Schema cannot: references that point at nothing, quotes that are
not in the source, lines of the source left unaccounted for, loops in reporting lines and steps out of order, each
explained in plain English.

## Alignment with W3C vocabularies

Where a W3C vocabulary already names an idea, the schema says so: each building block below carries the mapping in
`bigcontext_schema.yaml`, and the generated OWL states it as `skos:exactMatch`, `skos:closeMatch` or
`skos:relatedMatch`. Every term was checked against the published vocabulary; none is deprecated. What maps to
nothing is BigContext Schema's own: the evidence-bound statement, how strongly a rule holds beyond ODRL's three
(should, should not, by default, need not), procedures, lifecycles, metric definitions and the decision group.

| Vocabulary | BigContext Schema → term |
|---|---|
| [ODRL 2.2](https://www.w3.org/TR/odrl-model/) (policies) | Rule → `Rule`; RuleSet → `Policy`; Action → `Action`; Condition → `Constraint`; HasAccess → `Permission`; modality must, must not, may → `Duty`, `Prohibition`, `Permission`; verbs use (exact), include, show, update, retain, delete, de-identify, share, grant, copy → `include`, `display`, `modify`, `archive`, `delete`, `anonymize`, `distribute`, `grantUse`, `reproduce` (close); aggregate, ask, notify → `aggregate`, `obtainConsent`, `inform` (related) |
| [ORG](https://www.w3.org/TR/vocab-org/) (organizations) | MemberOf → `memberOf`, ReportsTo → `reportsTo`, Heads → `headOf` (exact); HoldsRole → `holds` (close); PartOf → `unitOf` (related); thing types unit, organization, post → `OrganizationalUnit`, `Organization`, `Post`; concept type role → `Role` |
| [SKOS](https://www.w3.org/TR/skos-reference/) (concepts) | Mapping matches exact, close, broad, narrow, related → `exactMatch`, `closeMatch`, `broadMatch`, `narrowMatch`, `relatedMatch`; Mapping → `mappingRelation`; Definition → `definition`; IsA → `broader`; SynonymOf → `altLabel`; Example → `example` (close) |
| [PROV-O](https://www.w3.org/TR/prov-o/) (provenance) | DerivedFrom → `wasDerivedFrom` (exact); CreatedBy → `wasAttributedTo` (close); the graph's provenance part uses PROV-O throughout |
| [Dublin Core terms](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/) | PartOf → `isPartOf`, Covers → `coverage`, CreatedBy → `creator` (close); GovernedBy → `conformsTo` (related) |
| [DCAT 3](https://www.w3.org/TR/vocab-dcat-3/) (datasets) | thing type data_product → `Dataset` (close) |
| [DQV](https://www.w3.org/TR/vocab-dqv/) (data quality) | Caveat → `QualityAnnotation` (close) |
| [Web Annotation](https://www.w3.org/TR/annotation-vocab/) | Evidence → `TextQuoteSelector` (close); its quote → `exact` (exact) |

## Propose an enhancement

Found something BigContext Schema cannot express, expresses only roughly, or explains unclearly? Open an issue with
the [enhancement form](https://github.com/BigContext-OpenSource/bigcontext-schema/issues/new?template=enhancement.yml):
the example text, what it should become, and why the standard falls short today. `bigcontext-schema generate`
writes these examples for you, in a `.unmapped.md` file beside each document. Issues are public: remove anything
confidential first.

## Versions

Every document names the version of BigContext Schema it follows in `schema_version`; read and validate it against
that version's files. From 1.0 on, versions follow [semantic versioning](https://semver.org):

- a **patch** version (1.0.1) corrects wording, descriptions or generated files and changes nothing about which
  documents are valid;
- a **minor** version (1.1) only adds statement types, fields or allowed values, and never removes or narrows one,
  so every document valid under 1.0 stays valid under 1.1;
- a **major** version (2.0) is any other change.

A reader that knows 1.0 and is given a 1.1 document validates it against the 1.1 files its `schema_version` names,
or keeps what it understands and reports the rest. A company's own fields go under `extensions`, with keys that
start with a prefix it owns (`acme:priority`); readers keep them and may ignore them, and they never change what the
rest of the document means. A field many people need is proposed as an enhancement and can join the standard in a
minor version. The versions before 1.0 were drafts (`0.9.x-draft`).

Permanent address: `https://w3id.org/bigcontext-schema` (being registered).

## Citing

Big Context & Company (2026). *BigContext Schema*, version 1.0.0. https://w3id.org/bigcontext-schema

`CITATION.cff` gives the same in a form citation tools read.

## Licence

Apache License 2.0. Copyright 2026 Big Context & Company. See `LICENSE` and `NOTICE`.
