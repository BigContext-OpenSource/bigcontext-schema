<!-- serves: F-057 — Ask questions across company structure, data, metrics and rules through standard graph formats -->
# BigContext Schema as a knowledge graph (draft 0.9)

A BigContext Schema document becomes an RDF graph in four named parts. Anyone can produce or read the same graph
from this description; the free tools do it with `bigcontext-schema graph`.

| Graph | What it holds |
|---|---|
| `<base>record` | Every element and statement with all their fields and quotes, in the schema's own terms (`bcs:`); each statement typed by its statement type (`bcs:Rule`) and its parent types. Checked with the SHACL shapes in `generated/bigcontext_schema.shacl.ttl` |
| `<base>stated` | One direct link per statement in force on the chosen date, in the fact vocabulary (`bcf:`, `bigcontext_facts.yaml`). Reasoning runs on this graph |
| `<base>inferred` | What an OWL 2 RL reasoner works out from the stated facts with `generated/bigcontext_facts.owl.ttl`; never mixed into the stated graph |
| `<base>provenance` | Each fact as a reified triple with `prov:wasDerivedFrom`: a stated fact names its statements, a worked-out fact names the facts it follows from (always facts reached earlier) and `bcf:worked_out_by` says how. `<base>stated bcf:as_of` gives the date |

`<base>` is the source's address, such as `https://acme.example/context/order-tracking-policy/`; element and
statement ids are appended to it, so the sections of one source share elements and different sources never merge.

## The record graph

The record graph is the document read as JSON-LD with `generated/bigcontext_schema.context.jsonld` and `@base` set
to `<base>`, once every object in it has its class. A statement's class is the one its `predicate` names; the
context maps `predicate` to `@type`, so this needs no extra step. Any other object takes the class that the JSON
Schema gives the field it sits in: a `things` entry is a `bcs:Thing`, an `action` a `bcs:Action`, a `when` entry a
`bcs:Condition`, an `evidence` entry a `bcs:Evidence`. Each node is then also typed with the parent classes in
`generated/bigcontext_schema.owl.ttl` (a `bcs:Rule` is a `bcs:Statement`). The SHACL shapes select nodes by these
classes, so a graph whose objects have no class is checked against nothing.

## Which statements become facts

A statement becomes a fact only when, on the chosen date (the one asked for, else the source's `as_of`, else
today), it holds: its `valid_from` and `valid_to` include the date (a year or month runs to the end of that
period; a date that cannot be read leaves the statement out), it is not negated, the text does not say it no longer holds (`currently: false`), its certainty is stated (not
likely, possible or unknown), it is not someone's view (`held_by`), its decision status is none, decided or
ratified, and no statement in force on the date supersedes it. A link that is conditional (`when`, `when_any`,
`unless`, `valid_while`), scoped (`scope`) or about each member of a class (`each`) stays in the record only. A
dotted line becomes `dotted_line_to` and a backup or delegate becomes `backs_up`; reasoning follows neither.

| Statement | Facts (`bcf:`) |
|---|---|
| PartOf, ReportsTo, Heads, MemberOf, HoldsRole, EscalatesTo, DerivedFrom, ImplementedBy, GovernedBy, JoinsTo | `part_of`, `reports_to`, `heads`, `member_of`, `holds_role`, `escalates_to`, `derived_from`, `implemented_by`, `governed_by`, `joins_to` |
| ResponsibleFor (with an object) | one per responsibility value: `owns`, `accountable_for`, `manages`, `approves`, `decides`, `supervises`, `coordinates`, `reviews`, `advises`, `assists`, `performs`, `responsible`; all kinds of `responsible_for` |
| HasAccess | `can_use`, `can_read`, `can_admin`, `can_see_masked`, `access_granted`; all kinds of `has_access` (`none` stays in the record) |
| IsA, and Definition with an object (its category) | `is_a`, transitive: whatever is in a kind is in every category that kind is in |
| Mapping with match exact, decided (within a source, or across sources through `linked_sources`) | `same_as`, symmetric and transitive |
| Contains (the object a field), IdentifiedBy, Groups | `has_column`; `time_column` for a time dimension and `key_column` for a key (both kinds of `has_column`); `key_column` for each IdentifiedBy member; `has_member` |
| ComputedAs (the definition that would be exported) | `has_input`, `has_numerator`, `has_denominator`, `aggregates_over`, `aggregates_column` (columns of the base table the expression names), `counted_by`, `filters_on`: all kinds of `depends_on` |
| Influences | `increases`, `decreases`, `influences`: kinds of `drives`, kept apart from `depends_on` |
| Rule | `binds` for each party in `binds` and each party in `scope`; `about` for the action's objects; `overrides`, a rule set's members standing for the set |
| RuleSet | `in_rule_set` for each member; when one set overrides another, each member overrides each member of the other |

## What the reasoner works out

- Transitive: `part_of`, `reports_to`, `depends_on`, `derived_from`, `overrides`. Symmetric: `joins_to`.
- Inverses: `has_part`, `has_report`, `headed_by`, `has_party_member`, `column_of`, `feeds`.
- A member of a team is a member of every unit the team is part of (`member_of` then `part_of`).
- A person reports along the line of the post they hold (`holds_role` then `reports_to`).
- A rule applies to whom it binds, to their sub-units and to their members (`applies_to`).
- Whoever owns, is accountable for, manages or heads something answers for it and all its parts, columns and
  members (`answers_for`). Advisers, reviewers, assistants and coordinators answer for nothing by inheritance.

The fact ontology is within OWL 2 DL (checked with HermiT), so any OWL reasoner can use it.

## Questions

`queries/` holds the questions as SPARQL, run on the stated and worked-out facts together with `?subject` bound to
an element: `reports_to_chain`, `units_of_member`, `members_of_unit`, `heads_of_unit`, `who_answers_for`,
`escalation_path`, `rules_that_apply`, `overrides`, `who_may_use`, `table_columns`, `joins_of_table`, `lineage`,
`metric_depends_on`, `metrics_fed_by`, `drivers_of`, `in_category`, `same_as`.

## As a property graph (Cypher)

The same stated and worked-out facts load into property-graph databases, so Cypher engines answer the same
questions without a reasoner. Every node is an `Element` with `id`, `label` and `kind` (a thing or concept type,
or a statement type for rules). Every fact is a relationship named after the fact in capitals (`PART_OF`,
`ANSWERS_FOR`), carrying its provenance: `statements` (the statement ids, `;`-separated) for a stated fact;
`worked_out: true`, `how` and `premises` (the facts it follows from, as `from TYPE to`) for a worked-out one.

`cypher/` holds the questions in openCypher with `$subject`; each answers what its SPARQL twin in `queries/`
answers. They were checked against Neo4j 5.26, Memgraph 3.14 and PuppyGraph on the company example: all 17 cases
gave the same answers as SPARQL. In PuppyGraph a node's key is not a property, so a schema maps the id column twice:
as the key and as the `id` property.

