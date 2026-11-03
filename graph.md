<!-- serves: F-057 — Ask questions across company structure, data, metrics and rules through standard graph formats -->
# BigContext Schema as a knowledge graph

A BigContext Schema document becomes an RDF graph in four named parts. Anyone can produce or read the same graph
from this description; the free tools (coming soon) do it with `bigcontext-schema graph`.

| Graph | What it holds |
|---|---|
| `<base>record` | Every element and statement with all their fields and quotes, in the schema's own terms (`bcs:`); each statement typed by its statement type (`bcs:Rule`) and its parent types. Checked with the SHACL shapes in `generated/bigcontext_schema.shacl.ttl` |
| `<base>stated` | One direct link per statement in force on the chosen date, in the fact vocabulary (`bcf:`, `bigcontext_facts.yaml`). Reasoning runs on this graph |
| `<base>inferred` | What an OWL 2 RL reasoner works out from the stated facts with `generated/bigcontext_facts.owl.ttl`; never mixed into the stated graph |
| `<base>provenance` | Each fact as a reified triple with `prov:wasDerivedFrom`: a stated fact names its statements, a worked-out fact names the facts it follows from (always facts reached earlier) and `bcf:worked_out_by` says how. `<base>stated bcf:as_of` gives the date |

`<base>` is the source's address: its `base_iri` when the document gives one
(`https://acme.example/context/order-tracking-policy/`), otherwise `urn:bigcontext-schema:<source id>/`, so every
reader of the same document builds the same graph. Element and statement ids are appended to it, so the sections of
one source share elements and different sources never merge. A reference `prefix:id` to a linked source's element
is appended to that source's `base_iri` instead (`linked_sources`). Documents from different sources are turned
into graphs one source at a time, unless one address is given for all of them.

## The record graph

The record graph is the document read as JSON-LD with `generated/bigcontext_schema.context.jsonld` and `@base` set
to `<base>`, once every object in it has its class. A statement's class is the one its `predicate` names; the
context maps `predicate` to `@type`, so this needs no extra step. Any other object takes the class that the JSON
Schema gives the field it sits in: a `things` entry is a `bcs:Thing`, an `action` a `bcs:Action`, a `when` entry a
`bcs:Condition`, an `evidence` entry a `bcs:Evidence`. Each node is then also typed with the parent classes in
`generated/bigcontext_schema.owl.ttl` (a `bcs:Rule` is a `bcs:Statement`). The SHACL shapes select nodes by these
classes, so a graph whose objects have no class is checked against nothing.

## Which statements become facts

**The date.** Facts are worked out for one date: the one asked for, else the latest `as_of` among the sources (a
statement's own `as_of` does not count). When
neither is given the date is unknown and no facts are worked out; a reader never assumes today, so the same
documents always give the same facts.

**In force on the date.** A statement is in force when all of these hold:

- its `valid_from` and `valid_to` include the date (a year or a month runs to the end of that period); a date that
  cannot be read leaves the statement out;
- it is not `negated`, and the text does not say it no longer holds (`currently: false`);
- its `certainty` is absent or `stated` (`likely`, `possible` and `estimated` are not facts);
- it is not someone's view (`held_by`);
- its `decision_status` is absent, `decided` or `ratified` (a `superseded` statement that gives its `valid_to`
  stays in force up to that day);
- no statement in force on the date names it in `supersedes`.

A statement's own `as_of` says when what it describes was observed; it does not change whether it is in force.
Neither do `period` (what the statement is about: a caveat about 1 to 3 June still holds in July) and `recorded_on`
(when it was recorded). The graph answers what holds on a date. What was known on a date is a different question,
which a store answers by leaving out the statements recorded after it. In a document that follows 1.0, a Covers'
`valid_from` and `valid_to` are also its period, as the 1.0 guide defined them; they still decide when the Covers is
in force, as before, so no result changes. In a document that follows 1.1 or later they say only when it holds, and
its data period is its `period`.
`HasStatus` (canonical, variant, deprecated, retired and so on) decides which metric definition is exported to a
semantic layer, not which statements are facts.

**Links and rules.** The link statement types are PartOf, ReportsTo, Heads, MemberOf, HoldsRole, EscalatesTo,
DerivedFrom, ImplementedBy, GovernedBy, JoinsTo, ResponsibleFor, HasAccess, Contains, IdentifiedBy, Groups,
Influences, IsA, Definition and Mapping. A link in force becomes a fact only when it is unconditional: one with
`when`, `when_any`, `unless`, `valid_while`, `scope` or `period` (limited to part of the data), or about the members
of a class (`each` or `quantifier`), stays in the record only; so, in a document that follows 1.1 or later, does
one whose `frequency` is anything but `always`, since it holds only some of the time (in a 1.0 document frequency
changes nothing, as before). Other statement types (Habit, Overlaps, CorrelatesWith and RecordMatch among them) stay
in the record, as do conditions with `party_responsibility`. A policy engine checks those against the
ResponsibleFor statements in force in the record (so `consulted` and `kept_informed` count, though they give no
facts): whoever is acting holds a responsibility for an element when such a statement gives it, for that element, to
them, to a post they hold (HoldsRole) or to a team they are a member of (MemberOf). A Rule is not a link: its conditions stay on the rule in the record, and in force it gives the facts
in the table below, its parties being everyone in `binds` and every element of its `scope` whose `thing_type` is a
party (person, team, unit, post, organization, agent or access_group); other elements of a rule's scope (a purpose,
a section) stay in the record. A dotted line becomes `dotted_line_to` and a backup or delegate becomes
`backs_up`; reasoning follows neither. Fields under `extensions` stay in the record and never become facts. A
RecordMatch is never a fact and never `same_as`: records matching is not two elements meaning the same. Access
limited to some rows (HasAccess with `filters`) is still the access fact; the rows stay in the record.

| Statement | Facts (`bcf:`) |
|---|---|
| PartOf, ReportsTo, Heads, MemberOf, HoldsRole, EscalatesTo, DerivedFrom, ImplementedBy, GovernedBy, JoinsTo | `part_of`, `reports_to`, `heads`, `member_of`, `holds_role`, `escalates_to`, `derived_from`, `implemented_by`, `governed_by`, `joins_to` |
| ResponsibleFor (with an object) | one per responsibility value: `owns`, `accountable_for`, `manages`, `approves`, `decides`, `supervises`, `coordinates`, `reviews`, `advises`, `assists`, `performs`, `responsible`; all kinds of `responsible_for` (`consulted` and `kept_informed` stay in the record) |
| HasAccess | `can_use`, `can_read`, `can_admin`, `can_see_masked`, `access_granted`; all kinds of `has_access` (`none` stays in the record) |
| IsA, and Definition with an object (its category) | `is_a`, transitive: whatever is in a kind is in every category that kind is in |
| Mapping with match exact, decided (within a source, or across sources through `linked_sources`) | `same_as`, symmetric and transitive |
| Contains (the object a field), IdentifiedBy, Groups | `has_column`; `time_column` for a time dimension and `key_column` for a key (both kinds of `has_column`); `key_column` for each IdentifiedBy member; `has_member` |
| ComputedAs (the definition that would be exported) | `has_input`, `has_numerator`, `has_denominator`, `aggregates_over`, `aggregates_column` (columns of the base table the expression names), `counted_by`, `filters_on` (a filter's field, and the field it is compared with when `compare_to` names a field): all kinds of `depends_on`; `depends_on` itself for a conversion's `entity` and a non-additive measure's `across` and `per` |
| Influences | `increases`, `decreases`, `influences`: kinds of `drives`, kept apart from `depends_on` |
| Rule | `binds` for each party in `binds` and each party in `scope`; `about` for the action's objects; `overrides`, a rule set's members standing for the set |
| RuleSet | `in_rule_set` for each member; when one set overrides another, each member overrides each member of the other; a set with no `members` field stands for itself, as the source and the target of overrides; an override that names a rule set's `subject` concept (as another section does) names that set |

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

## Questions on the record graph

`queries/record/connections.rq` returns every link of every statement and procedure in force: an element one of its
fields names, with the link's role. It runs on the record graph and the in-force graph together, and is generated
from the link annotations on the schema's fields (`links`, `condition`, `condition_role`, `from_self`), the same
annotations that give the facts in the table above. Bind `?element` to ask for one element.

A link is read from the statement's `subject` to the element, or from the statement itself for Rule, RuleSet,
Procedure and Step. A step's links belong to its procedure, and their field is named by the step's order
(`steps.2.produces`); a nested action's field by its last nesting field (`action.alternatives.objects`). An element of
a condition in `when`, `when_any`, `unless`, `even_if`, `especially_when`, `valid_while`, a procedure's `trigger`, or
an action's or a branch's `when` has the role `reacts_to` (in a Transition `state_input`, in an Indicates `causes`)
and carries that slot and the condition's description. A statement or procedure with a condition in one of those
slots of its own marks each of its links with them, and a procedure marks its steps' links too; an action or a branch
with its own `when` marks the links under it. A condition in `because`, `so_that`, `filters` or a case's `when` marks
nothing.

The named graph `in_force` types each statement and procedure in force `bcf:InForce`: the statements in force on the
graph's date by the rule above (a superseded or proposed statement is not), and every procedure. A caller that keeps
its own versions gives the ids it holds in force instead. The questions on the record graph return only these. Added
in 1.2.

<!-- roles: generated by tools/scripts/build_spec.py from the link annotations; do not edit -->
| Role | Read from |
|---|---|
| `acting_for` | `acting_for` |
| `acts_on` | `action.objects`; `step action.objects` |
| `answers` | `answers` |
| `answers_to` | `answers_to` |
| `attribute` | `attribute` |
| `audience` | `audience` |
| `base` | `base` |
| `because` | `because`; `step because` |
| `binds` | `binds` |
| `by` | `action.by`; `step action.by` |
| `calendar` | `calendar` |
| `calls` | `step calls` |
| `cases` | `cases` |
| `causes` | `especially_when` (Indicates); `even_if` (Indicates); `object` (Influences); `unless` (Indicates); `valid_while` (Indicates); `when` (Indicates); `when_any` (Indicates) |
| `consumes` | `step consumes` |
| `contains` | `object` (Contains) |
| `correlates_with` | `object` (CorrelatesWith) |
| `decided_by` | `decided_by` |
| `decided_in` | `decided_in` |
| `denominator` | `denominator` |
| `derived_from` | `object` (DerivedFrom) |
| `described_in` | `object` (DescribedIn) |
| `disputed_by` | `disputed_by` |
| `divided_by` | `divided_by` |
| `endorsed_by` | `endorsed_by` |
| `entity` | `entity` |
| `escalates_to` | `object` (EscalatesTo) |
| `filters_on` | `filters` |
| `governed_by` | `object` (GovernedBy) |
| `has` | `object` (Has) |
| `has_access` | `object` (HasAccess) |
| `heads` | `object` (Heads) |
| `held_by` | `held_by` |
| `holds_role` | `object` (HoldsRole) |
| `implemented_by` | `object` (ImplementedBy) |
| `informed` | `informed` |
| `inputs` | `inputs` |
| `is_a` | `object` (Definition, IsA) |
| `items` | `items` |
| `joins_to` | `object` (JoinsTo) |
| `key_pairs` | `key_pairs` |
| `maps_to` | `object` (Mapping) |
| `member_of` | `object` (MemberOf) |
| `members` | `members` |
| `non_additive` | `non_additive` |
| `numerator` | `numerator` |
| `object` | `object` (Appoints, Caveat, CreatedBy, RecordMatch, Represents) |
| `options_in_order` | `action.options_in_order`; `step action.options_in_order` |
| `outputs` | `outputs` |
| `overlaps` | `object` (Overlaps) |
| `overrides` | `overrides` |
| `part_of` | `object` (PartOf) |
| `performer` | `performer`; `step performer` |
| `period` | `period` |
| `produces` | `action.objects`; `alternative_states`; `step action.objects`; `step produces`; `to_state` |
| `property_value` | `property_value` |
| `proposed_by` | `proposed_by` |
| `ratified_by` | `ratified_by` |
| `ratified_in` | `ratified_in` |
| `reacts_to` | `action.when`; `especially_when` (Appoints, Caveat, ComputedAs, Contains, CorrelatesWith, Covers, CreatedBy, Definition, DerivedFrom, DescribedIn, EscalatesTo, Example, Gap, GovernedBy, Groups, Habit, Has, HasAccess, HasGrain, HasProperty, HasStatus, HasValues, Heads, HoldsRole, IdentifiedBy, ImplementedBy, Influences, IsA, JoinsTo, Mapping, MemberOf, Overlaps, PartOf, RecordMatch, ReportsTo, Represents, ResponsibleFor, Rule, RuleSet, Sequence, Serves, SynonymOf, Template, Triggers, UsedFor, WorksWith); `even_if` (Appoints, Caveat, ComputedAs, Contains, CorrelatesWith, Covers, CreatedBy, Definition, DerivedFrom, DescribedIn, EscalatesTo, Example, Gap, GovernedBy, Groups, Habit, Has, HasAccess, HasGrain, HasProperty, HasStatus, HasValues, Heads, HoldsRole, IdentifiedBy, ImplementedBy, Influences, IsA, JoinsTo, Mapping, MemberOf, Overlaps, PartOf, RecordMatch, ReportsTo, Represents, ResponsibleFor, Rule, RuleSet, Sequence, Serves, SynonymOf, Template, Triggers, UsedFor, WorksWith); `property_value`; `share`; `step action.when`; `step branches`; `step especially_when`; `step even_if`; `step unless`; `step when`; `step when_any`; `step within`; `trigger`; `unless` (Appoints, Caveat, ComputedAs, Contains, CorrelatesWith, Covers, CreatedBy, Definition, DerivedFrom, DescribedIn, EscalatesTo, Example, Gap, GovernedBy, Groups, Habit, Has, HasAccess, HasGrain, HasProperty, HasStatus, HasValues, Heads, HoldsRole, IdentifiedBy, ImplementedBy, Influences, IsA, JoinsTo, Mapping, MemberOf, Overlaps, PartOf, Procedure, RecordMatch, ReportsTo, Represents, ResponsibleFor, Rule, RuleSet, Sequence, Serves, SynonymOf, Template, Triggers, UsedFor, WorksWith); `valid_while` (Appoints, Caveat, ComputedAs, Contains, CorrelatesWith, Covers, CreatedBy, Definition, DerivedFrom, DescribedIn, EscalatesTo, Example, Gap, GovernedBy, Groups, Habit, Has, HasAccess, HasGrain, HasProperty, HasStatus, HasValues, Heads, HoldsRole, IdentifiedBy, ImplementedBy, Influences, IsA, JoinsTo, Mapping, MemberOf, Overlaps, PartOf, RecordMatch, ReportsTo, Represents, ResponsibleFor, Rule, RuleSet, Sequence, Serves, SynonymOf, Template, Triggers, UsedFor, WorksWith); `values`; `when` (Appoints, Caveat, ComputedAs, Contains, CorrelatesWith, Covers, CreatedBy, Definition, DerivedFrom, DescribedIn, EscalatesTo, Example, Gap, GovernedBy, Groups, Habit, Has, HasAccess, HasGrain, HasProperty, HasStatus, HasValues, Heads, HoldsRole, IdentifiedBy, ImplementedBy, Influences, IsA, JoinsTo, Mapping, MemberOf, Overlaps, PartOf, Procedure, RecordMatch, ReportsTo, Represents, ResponsibleFor, Rule, RuleSet, Sequence, Serves, SynonymOf, Template, Triggers, UsedFor, WorksWith); `when_any` (Appoints, Caveat, ComputedAs, Contains, CorrelatesWith, Covers, CreatedBy, Definition, DerivedFrom, DescribedIn, EscalatesTo, Example, Gap, GovernedBy, Groups, Habit, Has, HasAccess, HasGrain, HasProperty, HasStatus, HasValues, Heads, HoldsRole, IdentifiedBy, ImplementedBy, Influences, IsA, JoinsTo, Mapping, MemberOf, Overlaps, PartOf, RecordMatch, ReportsTo, Represents, ResponsibleFor, Rule, RuleSet, Sequence, Serves, SynonymOf, Template, Triggers, UsedFor, WorksWith); `within` |
| `reports_to` | `object` (ReportsTo) |
| `responsible_for` | `object` (ResponsibleFor) |
| `role` | `role` |
| `routes_to` | `action.to`; `action.via`; `step action.to`; `step action.via`; `via` (Appoints, Caveat, ComputedAs, Contains, CorrelatesWith, Covers, CreatedBy, Definition, DescribedIn, EscalatesTo, Example, Gap, GovernedBy, Groups, Habit, Has, HasAccess, HasGrain, HasProperty, HasStatus, HasValues, Heads, HoldsRole, IdentifiedBy, ImplementedBy, Indicates, Influences, IsA, JoinsTo, Mapping, MemberOf, Overlaps, PartOf, RecordMatch, ReportsTo, Represents, ResponsibleFor, Rule, RuleSet, Sequence, Serves, SynonymOf, Template, Transition, Triggers, UsedFor, WorksWith) |
| `scope` | `scope` |
| `share` | `share` |
| `so_that` | `so_that`; `step so_that` |
| `state_input` | `especially_when` (Transition); `even_if` (Transition); `from_state`; `subject` (Transition); `unless` (Transition); `valid_while` (Transition); `when` (Transition); `when_any` (Transition) |
| `stated_by` | `stated_by` |
| `subject` | `subject` |
| `supersedes` | `supersedes` |
| `time_dimension` | `time_dimension` |
| `used_for` | `object` (UsedFor) |
| `values` | `action.values`; `step action.values`; `values` |
| `via` | `via` (DerivedFrom) |
| `with_consent_of` | `with_consent_of` |
| `within` | `step within`; `within` |
| `works_with` | `object` (WorksWith) |
| `written_by` | `action.objects`; `action.to`; `step action.objects`; `step action.to` |
<!-- end of roles -->

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

