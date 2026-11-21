# Changelog

What changed in each version of BigContext Schema. Versions follow the rules in the README: patch, minor and major,
with drafts (`0.9.x-draft`) before 1.0.

## 1.4.0 (2026-11-21)

A minor version: it adds allowed values and nothing else. Every 1.3.0 document is valid and
keeps its meaning and its graph facts. The guide gives the forms a compiler reads to run a rule, and `conformance.md`
names them as a profile a document may be checked against.

Schema
- Thirteen standard attributes for `HasProperty` (`StandardAttributeEnum`), each for a fact about a kind of thing
  that no attribute held: `environment`, `platform` and `credential_ref` (a system, a data container); `external_id`
  (the id something has in another system); `nullable` (a field); `version` (a model, a tool, a document, a
  calendar); `side_effect`, `timeout` and `idempotent` (a tool, a job); `schedule` (a job, a refresh); `language` and
  `digest` (a document, a model's file); and `null_handling` (how empty values are treated when a metric or a
  dimension is computed). A document of 1.3 or earlier that uses one is refused, as for every addition. Cases:
  `tests/documents/valid/added-in-1-4/` and `tests/documents/invalid/D1-a-1-4-value-in-a-1-3-document/`.
- D2: a `HasProperty` with `nullable` or `idempotent` gives true or false
  (`tests/documents/invalid/D2-nullable-not-true-or-false/`).

A repository
- A conforming repository (`conformance.md`, "A conforming repository"): rules R1 to R10 for an organization's and its
  teams' context kept as one document per file, with the level and the kind of a file given by its folders, a
  registry of kinds that is the repository's own, a view for the organization and for each team, and what stands in a
  view on a day. It is optional: a conforming document need not be in a repository.
- `examples/context-repository/`: a repository of 11 files with a registry of nine kinds, an organization and one
  team's version of a metric. `tests/repositories/not-conforming/`: one case for each of R1 to R10, as the files that
  differ from the example.
- A kind's `complete_with` in the registry says what a complete file of the kind holds: statement types, a statement
  type with a field or a value it gives, fields of the file's own element, procedure or statement, alternatives, and
  the words a note uses for each. A file that lacks one conforms; a check may note it.
- `repository.md` says how a repository's files are made: one thing per file, `external` for
  what another file declares, ids that say what a statement is about, a team's version, and a change that holds from
  a day.

Conformance
- The compilable profile (`conformance.md`, "The compilable profile"): rules C1 to C18, the one form of each of
  seventeen meanings a compiler reads. It is optional: a conforming document need not be in it, and a document does not
  declare it. For C10, C11 and C12 a tool may rewrite the other form; it keeps every id, every quote and the stated
  facts.
- Cases in `tests/profiles/compilable/`: one document in the profile, one change to it for each of C1 to C11 and C13
  to C17, three documents in a form a tool may rewrite, each beside its rewritten form, and `expressions.yaml`:
  expressions of a total on one table, each in the profile or breaking C14 or C15, for a checker and a compiler.
- C14: the `expression` of a definition a reader computes is one SQL expression (names, literals, `+ - * /`,
  comparisons, `AND`, `OR`, `NOT`, `IS NULL`, `CASE WHEN`, `COALESCE`, `CAST`; `*` for a count of rows), in ANSI SQL or
  the statement's `dialect`. C15: each name in it is one declared element, a total's on its `base` table, so a
  column's table is read from fields. C16: a join is a `JoinsTo` and nothing else holds one; an `ImplementedBy` gives
  no `expression`, and a join's condition is given once, in `key_pairs` or, for what key pairs cannot say, in `keys`.
- C17: a rule that calls for a label (`must` or `should`, verb `label`) says in fields when the label applies: no
  condition, a state named in a condition's `about`, a condition a reader runs, or a dated `period`.
- C18: how a metric's numbers are written is a `HasProperty` with `standard_attribute: format` whose value is a number
  pattern (`0.0%`, `#,##0`, `$#,##0.00`), a field a tool applies; a format in words breaks the rule. The guide says so
  under `HasProperty`. No schema change.
- A check may give advice that keeps no document out of the profile; the reference check's four notes are listed.

Guide
- An `activity` is also something an organization does to change an outcome ("a promotion"), with its effect as an
  `Influences`. A range a metric is expected to stay within is a `Rule` with a check and the bound as a value, not a
  definition of the metric; a value a metric should reach is a `Rule` with a `target` value and `due_by`.
- A field holds the standard form of what the text says, and the quote keeps its words ("Free text"): where the
  schema has a field, a closed list or a typed value, the sentence is not copied into a text field.
- A label is a name, never a formula or a condition: an element the text describes without naming gets a short name,
  the words of its id, and the text's phrase is an alias. A label the text does not hold is a name its writer gave.
- An `expression` is one SQL expression, with a `Gap` when the text gives no formula; its names are columns of `base`
  or the inputs' names, with the fields a total reads in `inputs`; a definition that needs another table names the
  column, and the join is a `JoinsTo`; `keys` holds only a condition key pairs cannot say.
- A label a rule calls for names, in `when`, the state its object is in while the label applies.
- An owner's choice of definition for comparing periods names the definition's statement in the action's `objects`
  and the metrics compared in the condition's `about`.
- A filter of an `ImplementedBy` may compare its field with another column (`compare_to`), on the concept's table or
  on a table it joins to; a range is two filters, `at_least` and `at_most`. The metric example gains such a segment.
- A member concept of a dimension whose value is given has an `ImplementedBy` to the dimension's table with one
  filter, or a `Gap` when the value is not given.
- Rules about what a metric counts: `must_not` with verb `include`, `count`, `use` or `select`, or `must` with verb
  `exclude`, with the metric in `scope`. Their rows are segments, each with an `ImplementedBy` and `filters`, or
  a `Gap`; rows outside a range stay on the whole set's segment with `unless`; a field in `objects` needs no segment,
  and a metric there is not rows. The strength table's "only" row points there.
- A definition limited to the rows another metric counts names that metric in `scope`.
- An amount a definition leaves out is left out of its formula; a rule that leaves rows out names rows the metric counts.
- A comparison with an earlier period: the earlier metric's `expression` is its input's name; the comparison's
  `expression` is a formula when the text says how they compare; the comparison and a threshold on it use one unit
  (`* 100` with `datatype: percent`, or a fraction); a threshold judged for each value of a dimension names that
  dimension in the rule's action, in `by`; an earlier statement that defines the comparison is reused.
- A period's sign-off and a restatement are a `Transition` with a dated `period`; an approval's `unless` names the
  approver and the approved state (also in the strength table's "check with" row); a label a state calls for is a
  `Rule` with verb `label` and `when` about that state.
- An owner's choice of definition for comparing periods is a `Rule` about comparisons, not a restated definition.

Examples and conformance
- `examples/agent-context` (`s.1.3`) and `tests/documents/valid/added-in-1-1` (`s.30`): each approval's `unless`
  names the approved state beside the approver, a new concept of `concept_type: state`.

## 1.3.0 (2026-11-06)

Every 1.0, 1.1 and 1.2 document is valid under 1.3.0 and keeps its meaning and its graph facts. The additions come
from enterprise data context that 1.2 held only in words. Each has a line in the guide and is used in the conformance
case `tests/documents/valid/added-in-1-3/`.

Joins
- `comparator` on a key pair (equal, not_equal, more_than, at_least, less_than, at_most): a join on a range, such as
  a validity range (order_date at_least valid_from, and at_most valid_to).
- `nearest` on a key pair: of the rows its comparator lets through, the one whose column is nearest ("the latest rate
  on or before the order date"); the join's other pairs are equal. Only in a JoinsTo.
- `recursive` on a JoinsTo: the join can be followed to any depth (a manager's manager).

Data
- `unit_from` on a value: the column that holds each row's unit or currency (link role `unit_from`).
- `partition` on a Contains: this column splits the table into partitions.
- `filters` on an ImplementedBy: the concept is the rows of a table or view that pass them ("active customers are
  customers whose status is active"). It still gives the `implemented_by` fact.

Time
- `last` and `previous` on a period, with `time_grain` and `calendar`: a stretch counted back from the statement's
  `as_of`, else the source's, else the day it is applied ("the last 3 days", "last month").
- Standard attributes `year_start`, `week_start`, `week_pattern` and `day_start` for a calendar's settings.

Names and types
- `language` on a SynonymOf and on the source, as a BCP 47 tag.
- Concept type `event`; thing type `ml_model`; importance `minor`, which the `importance` description already named.

Versions
- Each 1.3 addition carries an `added_in` annotation, as `BelongsTo` (1.2) now does. The reference check refuses a 1.3
  field or value in a document that follows an earlier version, saying where it is, as it refuses `BelongsTo` in a 1.0
  or 1.1 document; it does not judge such a field by the 1.3 rules, and lists the allowed values of the document's own
  version. The 1.1 and 1.2 field and value additions carry no `added_in`, so the reference check does not refuse them
  in an earlier document; D1 already said a document is valid against its own version's files. The link table carries
  the annotations (`added_in`).

The guide gives a form, with no new field, for a measure split across a join (a ComputedAs of the measure times the
share column), an environment such as dev or prod (a data_container, one thing per copy of a table) and figures that
may still change (a Caveat with its period).

The reference check
- It no longer stops on a malformed document: where a part of the wrong form made a rule raise an error, the rule
  reads the document's well-formed parts, whose shape problems it reports. A document 1.2 checked without an error
  gets the same messages, apart from two: `statements` given as a mapping or as empty text is now reported as not a
  list, and a period that gives a start, an end or a name in the wrong form (not an ISO date, not text, or beside a
  field a period does not have) is reported as that, not as a period with no start, end or named period.
- From 1.3, the message for an empty period names `last` and `previous`.

## 1.2.2 (2026-11-05)

Wording only: in the data operations example, the Sev1 line reads "a figure shown to customers" in place of "a
customer-facing number", and its two states are `c.customer_figure_wrong` and `c.customer_figure_missing`. Every 1.2
document stays valid, and no field, value or statement type changed.

## 1.2.1 (2026-11-04)

Wording only: the README's comparison with knowledge formats says, for each question, what OKF records and what it
has no field for ("As free text" in place of "In prose"), and the permanent address `https://w3id.org/bigcontext-schema`
is live. Every 1.2.0 document stays valid, and no field, value or statement type changed.

## 1.2.0 (2026-11-04)

Every 1.0 and 1.1 document is valid under 1.2.0 and keeps its meaning, its graph facts and every message of the
reference checker. The additions come from data operations runbooks: jobs and schedules, states and checks,
incidents, routing, impact and cause. Each has a line in the guide and is used in the conformance case
`tests/documents/valid/added-in-1-2/`.

Conditions and values
- `negated` on a condition: it holds when its description does not, where no `unless` can say it (inside
  `when_any`, `so_that`, an action's, branch's or case's `when`, a procedure's `trigger`).
- `time_of_day` and `time_zone` on a condition ("not complete by 07:00 ET").
- `counted_from` on a value: the event a duration is counted from ("within 24 hours of the source update").

Thing types
- `job` (a pipeline, a dbt job, a load; close to `prov:Plan`) and `report` (a report or dashboard people read).

Statement types
- `BelongsTo`: a state or event concept is of one thing and named after it ("late arrival of the supplier file" is
  of the supplier file), where no `Transition` has the thing as its subject; fact `belongs_to`. The reference check
  refuses it in a document that follows 1.0 or 1.1.

Links
- Every link between a statement and an element its fields name, and the fact it gives, is written once, as
  annotations on the schema's fields (`links`, `condition`, `condition_role`, `from_self`, `provenance`, `fact_link`,
  `fact_backup`, `fact_dotted`, `party`). Annotations change no document's validity and no generated file; the link
  table `generated/bigcontext_links.json` and the question `queries/record/connections.rq` are generated from them.
- Each link role's meaning, once, in `bigcontext_link_roles.yaml`; the build refuses a role with no meaning; carried
  into the link table (`roles`) and graph.md's roles table.
- The in-force graph: a named graph typing each statement and procedure in force `bcf:InForce` (fact vocabulary
  1.1.0); questions on the record graph read only these (graph.md, "Questions on the record graph"; conformance G1,
  G4).
- The reference check also reads, in documents of 1.2 and later, the elements named in `divided_by`, `ratified_in`,
  `within`, `share`, a case's `result`, a condition's `values[].applies_to`, and an action condition's `field`,
  `compare_to` and `values[].per`.

Guide
- "Data operations": one form for each kind of runbook sentence. A cause between two named elements is
  `Influences`; a `Caveat` holds a known problem whose cause names no element. A consequence that a named check, job
  or system sets off is its `Triggers`, also when the text says no one acts (a consequence with no source named stays
  a `Transition` with `automatic: true`); an instruction to escalate is `EscalatesTo`, not a `Rule`.
  What a freshness rule applies to (the dashboards) is its `scope`; `binds` is who must comply. The reference check notes
  a thing other than a party, or a metric, dimension, state, calendar, period or term, in `binds`, in `EscalatesTo`'s
  or `ReportsTo`'s subject or object, or in `ResponsibleFor`'s subject or `answers_to`.

## 1.1.0 (2026-10-31)

Every 1.0 document is valid under 1.1.0 and keeps its meaning and its graph facts. The additions come from real
analytics context packs and from an expert test of hard cases; each has a line in the guide and is used in the
conformance case `tests/documents/valid/added-in-1-1/`. One published wording narrows: `frequency` now means only how
often, and how many members of a class a statement holds for is the new `quantifier`; for a document that follows
1.1, a link that holds only some of the time stays in the record (graph.md).

What people do and how often
- `Habit`: what a party usually does, described rather than required, including what people ask about (verb `ask`)
  and the usual breakdowns of an analysis (verb `analyze` with `by`).
- `quantifier` (most | some | few) for statements about some members of a class; `especially_when` for conditions
  under which a statement holds most strongly.

Relations
- `Overlaps`: two roles or kinds the same individual can be at once. `CorrelatesWith`: two measures that move
  together without a stated cause.
- `RecordMatch`: when records count as the same individual, never the same element. Key pairs take `normalize`
  (trim, ignore_case, cast_to_text, cast_to_number). IdentifiedBy takes `primary` (false for an alternate key) and
  `stable` (false when the key can change). RecordMatch compares key pairs; `expression` holds a rule they cannot say.
- `divided_by` on Groups; `role` on JoinsTo; join type `anti`; JoinsTo's `expected_cardinality`; cardinalities
  `one_to_one`, `many_to_many` and `more_than_one`; status `certified`; responsibilities `consulted` and
  `kept_informed`; RuleSet `members` may be left out when its `subject` names it.

Time
- `period` (`start`, `end`, `named`): the stretch of data or business time a statement is about, which never ends it.
  `recorded_on`: when a fact was recorded or restated. A table's data period goes in `period`; in a document that
  follows 1.0, a Covers' `valid_from` and `valid_to` are also its period. A link limited to a period stays in the
  record, as a scoped one does.

Metrics a semantic layer can hold
- Metric types `cumulative` and `conversion`; value roles `window`, `offset` (an offset is its own derived metric over
  one metric) and `percentile`; aggregations `first`, `last` and `percentile_discrete`; `grain_to_date`,
  `reporting_grain`, `calendar` (a fiscal or other calendar), `entity` (what a conversion follows), and
  `non_additive` (`across`, `take`, `per`) for a stored measure. What an empty period shows is a value with role
  `default`.

Conditions on another field or on whoever is acting
- A condition's `compare_to` (instead of written values) and the concept type `party_attribute`; a condition's
  `party_responsibility` (whoever is acting must hold it, for what the rule acts on or for the element a column names);
  HasAccess `filters` for row-level access; a value's `distinct` (a count of different people) and `per` (a limit for
  each).

Conformance
- D1 also rejects a condition with more than one of values, `compare_to` and `party_responsibility`, and an empty
  period, through the JSON Schema. D2 gains clauses for `compare_to`, windows, offsets, percentiles, conversions,
  `party_responsibility` (only in a Rule's conditions), casts in `normalize`, and rule sets.

Guide
- Amounts follow one rule (`value_role` and `comparator`); a cap is a prohibition. Lines for forbidden joins, colour
  sentences, references to other sections, quoted and case-sensitive physical names and colliding ids, and the five
  dates. The guide's lists of concept types, standard attributes, usages, date fields and free-text fields are
  complete again, and the README's example uses `value_role`.
- A ratio's or conversion's counts and the amount a percentile is taken over may be ones the text only implies; a
  quoted column's label is its name without the quotes. Two more examples are rewritten in the guide's own
  online-store setting.

## 1.0.1 (2026-10-30)

Wording only: the examples in the guide and in the schema's descriptions are rewritten in the guide's own
online-store setting. Every 1.0.0 document stays valid, and no field, value or statement type changed.

## 1.0.0 (2026-10-30)

The first stable version. From here on a minor version (1.1) only adds statement types, fields or allowed values and
leaves every 1.0 document valid; anything else is a major version (2.0). The content is that of 0.9.5-draft, with
the titles and examples no longer marked draft.

## 0.9.5-draft (2026-10-30)

- `conformance.md`: what a conforming document (D1 to D10), producer (P1 to P3) and graph builder (G1 to G4) must do.
- `tests/`: the cases that check it: valid and invalid documents (each invalid one breaking one rule), a producer
  case, and for three documents and their dates the stated and worked-out facts and the answers to all 17 questions.
- `GOVERNANCE.md`, `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1): who decides what changes and
  how, the terms for contributions (Apache 2.0, signed off), and how everyone taking part behaves.
- Every statement traces to its words or to who stated it: `evidence` (at least one quote, never blank) or
  `stated_by` (rule D10); a step quotes its words or belongs to a procedure with `stated_by`. A document is
  source-bound when every statement and step quotes its text; context written from a text is source-bound.
- `decided_on` and `ratified_on` are ISO dates. `aliases`, statement-level `via` and `due_by` say when to use them.

## 0.9.4-draft (2026-10-30)

Changes that would otherwise need a breaking change after 1.0.

- One meaning per field name: a value's `role` is `value_role`, a revision's `by` is `revised_by`, HasProperty's
  `value` is `property_value`, a case's `value` is `result`, and an unmapped item's and a conflict's `reason` is
  `why`. One comparator list serves values and filters. In the OWL no property is both a link and a literal.
- A source may give `base_iri`; without it a document's graph address is `urn:bigcontext-schema:<source id>/`, so
  every reader builds the same graph. Ids and source ids have a fixed shape.
- Every document names its `schema_version`; `extensions` (keys `prefix:name`) carry an organization's own fields.
  The README defines patch, minor and major versions.
- `graph.md` states exactly which statements are facts on a date, and a date must be given when the source has none.
- `performer`, `stated_by`, `valid_while` and `answers` are lists; `also_performed_by` is folded into `performer`;
  the source's `date` is `created`, `modified` and `reviewed`.

## 0.9.3-draft (2026-10-30)

- An enhancement form for issues, and a "Propose an enhancement" section in the README.
- The guide: several elements that together correspond to one are a group (`Groups`, complete) mapped once; "is
  committed to" is a duty the organization takes on, never unmapped.

## 0.9.2-draft (2026-10-30)

- The OWL ontologies are named by their permanent addresses, `https://w3id.org/bigcontext-schema` and
  `https://w3id.org/bigcontext-schema/facts`.

## 0.9.1-draft (2026-10-30)

- The JSON-LD context maps `predicate` to `@type`, so a graph made with the context alone types each statement by
  its statement type; `graph.md` describes the record graph.

## 0.9-draft (2026-10-30)

- The first public draft: the schema in LinkML with its generated JSON Schema, OWL, SHACL shapes and JSON-LD
  context; the guide; the knowledge-graph description with its questions in SPARQL and Cypher; three examples.
