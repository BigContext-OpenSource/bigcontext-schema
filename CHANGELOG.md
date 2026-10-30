# Changelog

What changed in each version of BigContext Schema. Versions follow the rules in the README: patch, minor and major,
with drafts (`0.9.x-draft`) before 1.0.

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
