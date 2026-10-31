# Changelog

What changed in each version of BigContext Schema. Versions follow the rules in the README: patch, minor and major,
with drafts (`0.9.x-draft`) before 1.0.

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
