# Conformance

The key words MUST, MUST NOT, SHOULD and MAY are to be read as in RFC 2119 and RFC 8174 when they appear in
capitals.

Three kinds of thing can conform to BigContext Schema: a **document**; a **producer**, which writes documents from a
text (a person, a program or an AI model); and a **graph builder**, which turns documents into a knowledge graph and
answers questions over it. Each rule has a name (D1, P2, G3) that the cases in `tests/` point to, so any
implementation can check itself against the same cases. The reference tools (coming soon) pass all of them.

## A conforming document

A document conforms to a version of BigContext Schema, the one its `schema_version` names, when:

- **D1** It is valid against that version's `generated/bigcontext_schema.schema.json` (JSON Schema 2019-09): its
  fields, required fields, allowed values and statement types, and the shape of its ids, dates and addresses; from
  1.1, also that a condition gives at most one of `values`, `compare_to` and `party_responsibility`, and that a
  period gives at least one of `start`, `end` and `named`. (The SHACL shapes check the fields and values but not these two.)
- **D2** Each HasValues statement gives `values` or `members`; each HasProperty gives `standard_attribute` or
  `attribute`; each CreatedBy gives `object`, `members` or `text`. From 1.1: a condition with `compare_to` gives
  `field` and `comparator`; a ComputedAs gives at most one of a value with `value_role: window` and `grain_to_date`;
  a value with `value_role: window` is on a cumulative or conversion metric, and one with `value_role: offset` on a
  derived metric with exactly one input, and one with `value_role: percentile` on a percentile aggregation; a
  conversion metric gives `numerator` and `denominator`; a condition with `party_responsibility` is in a Rule's
  `when` or `unless`; a key pair's `normalize` gives at most one of `cast_to_text` and `cast_to_number`; a RuleSet
  gives `subject` or `members`.
- **D3** Every id of a thing, concept, statement, procedure and step is used once in the document.
- **D4** Every reference names something the document declares, an id listed in `external` (declared by another
  section of the same source), or `prefix:id` with a prefix declared in `linked_sources`. A reference in
  `attribute`, `role`, `from_state`, `to_state`, `alternative_states`, `calendar` or a period's `named` names a
  concept; one in `calls` names a procedure.
- **D5** Each linked source's prefix is declared once and is none of the prefixes the graph's vocabularies use (bcs,
  linkml, odrl, org, skos, prov, dcat, dqv, oa, dcterms), and its `base_iri` ends in `/` or `#`.
- **D6** No PartOf or ReportsTo chain leads back to where it started.
- **D7** In each procedure, no two steps share an `order`; every `next` and `go_to` names a step of the same
  procedure; and every branch either goes to a step or gives an `outcome`.
- **D8** Every evidence quote appears in the source text. Quote and text are compared after turning curly quotes
  into straight ones, long dashes into hyphens, a no-break space into a space, and every run of white space into one
  space; nothing else is forgiven.
- **D9** Every key under `extensions` has the form `prefix:name` (`acme:priority`).
- **D10** Every statement has a quote (`evidence`) or names who stated it (`stated_by`), and every step has a quote
  or belongs to a procedure that names who stated it. A quote list is never empty and a quote never blank (D1).

A document is **source-bound** when, besides conforming, every statement and every step quotes the text it came
from. Context written from a text is source-bound; context someone states directly, with no text to quote, conforms
without being source-bound. A reader that needs every claim traced to words can require source-bound documents.

A reader MUST keep a document's `extensions` and MAY ignore them. A reader that knows an earlier version and is
given a document of a later minor version validates it against the later version's files, or keeps what it
understands and reports the rest.

## A conforming producer

- **P1** Every document it writes conforms, and when it writes from a text the document is source-bound.
- **P2** It accounts for every non-blank line of the text it expresses: the quotes found on a line, in any thing,
  concept, statement, step, unmapped or skipped item, cover at least 90% of that line's letters and digits.
- **P3** It writes only what the text says. What no building block fits goes in `unmapped` with the statement type
  that would be needed and `why`, and is never forced into a statement that changes its meaning. This rule needs a
  person to judge; the guide (`guide.md`) says how each kind of sentence is expressed.

## A conforming graph builder

- **G1** It builds the record graph as `graph.md` describes ("The record graph"), at the address `graph.md` gives;
  the record graph of a conforming document passes `generated/bigcontext_schema.shacl.ttl`.
- **G2** For a date, it states exactly the facts `graph.md` lists ("Which statements become facts").
- **G3** It works out exactly the facts that follow from the stated ones under OWL 2 RL with
  `generated/bigcontext_facts.owl.ttl`, and keeps them apart from the stated facts.
- **G4** Its answers to the questions in `queries/` (SPARQL) or `cypher/` (openCypher) are the expected ones.

## The cases

`tests/` holds the cases (see `tests/README.md`). Each invalid document breaks exactly one rule, the one at the start
of its folder's name, and its `expected.yaml` also gives what the reference checker says, as an example: an
implementation matches the rule, not the wording. The graph cases give, for an example and a date, the stated and
worked-out facts as N-Triples and the answers to the questions. An implementation conforms when it gets every case
right.
