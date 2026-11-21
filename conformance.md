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
  period gives at least one of `start`, `end` and `named`. From 1.3, a period may give `last` or `previous` in place of
  those, never both and never with `start` or `end`; a key pair's `comparator` is equal, not_equal, more_than,
  at_least, less_than or at_most; and a document gives no field, value or statement type added in a later version
  than its own (the reference check reads the schema's `added_in` annotations). (The SHACL shapes check the fields
  and values but not these.)
- **D2** Each HasValues statement gives `values` or `members`; each HasProperty gives `standard_attribute` or
  `attribute`; each CreatedBy gives `object`, `members` or `text`. From 1.1: a condition with `compare_to` gives
  `field` and `comparator`; a ComputedAs gives at most one of a value with `value_role: window` and `grain_to_date`;
  a value with `value_role: window` is on a cumulative or conversion metric, and one with `value_role: offset` on a
  derived metric with exactly one input, and one with `value_role: percentile` on a percentile aggregation; a
  conversion metric gives `numerator` and `denominator`; a condition with `party_responsibility` is in a Rule's
  `when` or `unless`; a key pair's `normalize` gives at most one of `cast_to_text` and `cast_to_number`; a RuleSet
  gives `subject` or `members`. From 1.3: a key pair marked `nearest` is in a JoinsTo, is the only one there, has a
  comparator that orders (more_than, at_least, less_than, at_most), and the join's other pairs are equal; a
  RecordMatch's key pairs are equal; a period with `last` or `previous` gives `time_grain`, and one with `time_grain`
  or `calendar` gives `last` or `previous`; a HasProperty with `week_pattern` gives 4-4-5, 4-5-4 or 5-4-4, with
  `day_start` an HH:MM time, with `week_start` a day of the week in English; an ImplementedBy with `filters` names a
  table or view as its object, when the document declares it. From 1.4: a HasProperty with `nullable` or `idempotent`
  gives true or false.
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

## The compilable profile

Added in 1.4. A profile is a named set of rules beside the rules above. A document does not declare a profile:
whoever checks it names one, and a conforming document need not be in any.

BigContext Schema lets some meanings be written in more than one form. The **compilable** profile gives each of
seventeen meanings one form, for a reader that works by code: a compiler that turns a metric and the rules on it into a
query, or an agent that plans from them. A document is in the profile when it conforms and rules C1 to C18 hold. The
rules use no field added after 1.3. They are read with the statements the document's writer was shown (earlier
statements of the same context), when there are any: a segment's filters, a dimension's values or a metric's earlier
definition may be stated there.

In these rules, a *rule about what a metric counts* is a Rule with `modality: must_not` and the verb `include`,
`count`, `use` or `select`, or `modality: must` and the verb `exclude`, that names a metric in `scope` or in its
action's `to`. A *dimension* is a concept of `concept_type: dimension`, a concept a HasValues lists the values of, or
a concept an ImplementedBy without `filters` implements by a field a HasValues lists the values of; a metric, a
segment, a state, a period and a calendar are never one. A *total* is a ComputedAs that gives `aggregation`. A field's
*name* is the last part of its `physical_name` (without its double quotes), and its table is the one a Contains gives
it, else an IdentifiedBy that lists it, else a JoinsTo key pair, else the table whose id its own id begins with.

- **C1** The rows a filter or a condition picks. Each entry of `filters` gives `field`, `comparator`, and `values`
  or `compare_to` (`is_null` and `is_not_null` take neither), unless a Gap about the statement's subject says what is
  not known. In a rule about what a metric counts whose `objects` name no table, field or metric, each condition of
  `when`, `when_any` and `unless` gives the same, or names in `about` what it is about (the segment of rows it means).
  A filter, and a condition of a Rule or a step, whose `description` names a declared column as an identifier (its
  name in capitals, or `table.column`) gives that column as `field`.
- **C2** The rows a rule leaves out of a metric. In a rule about what a metric counts, each segment named in the
  action's `objects` or in a condition's `about` has an ImplementedBy with `filters`, or a Gap about it; and the
  action's `objects` name no metric.
- **C3** Which rows a segment is. A Definition of a segment whose `text` names a declared column as an identifier is
  written as an ImplementedBy from the segment to its table, with `filters`.
- **C4** A definition limited to another metric's rows. A ComputedAs names that metric in `scope`. It never names
  there its own metric, or a metric it is a part of (an input, a numerator or a denominator, at any depth).
- **C5** A dimension's member whose value its column holds. A member (in a HasValues `members`) whose label or
  alias is one of the dimension's listed values, ignoring case, has an ImplementedBy with `filters` (one filter,
  `equal` that value), or a Gap about it.
- **C6** A comparison and its threshold, in one unit. A value with `value_role: threshold` in a condition about a
  derived metric has `datatype: percent` when the metric's `expression` multiplies by 100, and is a fraction when it
  does not: a percent threshold on an expression without `* 100`, and a threshold of 1 or more without `datatype:
  percent` on one with it, break the rule.
- **C7** An approval a rule requires. An `unless` condition of a Rule whose `about` names who approves (a party, or
  a role) also names the approved state, a concept of `concept_type: state`.
- **C8** An owner's choice of definition for comparing periods. It is a Rule (`must`, verb `use`, the metric in
  `scope`), and the definition's dates are untouched. A ComputedAs for a metric that already has a definition, and
  that changed state for a period (a Transition with a `period`), gives `valid_from` and no `period`.
- **C9** A period a rule or a change of state names. While the context dates a calendar (a HasProperty `year_start`
  on a calendar concept, or an exact Mapping between two calendar concepts), a Rule or a Transition whose `period`
  gives `named` also gives `start` and `end`, unless `each` is true.
- **C10** An earlier-period metric. A `derived` ComputedAs with one input and a value with `value_role: offset` has
  that input's name (the last part of its id) as its `expression`. A formula over the earlier value is a second
  derived metric over it.
- **C11** The metric a rule about what a metric counts binds. It is in `scope`, not in the action's `to`.
- **C12** The dimension a threshold on a metric is judged by. In a Rule with a condition that holds a threshold and
  names a metric in `about`, a dimension is in the action's `by`, not in `scope`; a dimension named beside a metric in
  a condition's `about` is also in the action's `by`.
- **C13** An amount a definition leaves out. It is absent from the formula, and no rule is written for it: a rule
  about what a metric counts names no segment implemented with `filters` on a table that a JoinsTo with a stated
  `cardinality` joins many to one to a table the metric is counted over (the `base` of its definition or of a part's),
  unless the metric is counted over that table too.

- **C14** A definition's formula. The `expression` of a ComputedAs that a reader computes is one SQL expression:
  names, numbers, text in single quotes, `+ - * /`, a leading minus, parentheses, `= <> > >= < <=`, `AND`, `OR`, `NOT`,
  `IS NULL`, `CASE WHEN … THEN … ELSE … END`, `COALESCE` and `CAST` to a type named by one word (and the other
  spellings of these the dialect has); or `*` alone. It is read as ANSI SQL unless the statement gives `dialect`,
  whose letters name the dialect whatever their case (`Snowflake`, `BigQuery`, `ANSI_SQL`). Operator words (`minus`,
  `divided by`), any other function, a query, quoted text alone and a comment break the rule. A reader computes a
  ComputedAs whose subject is a metric, or that gives `aggregation`, `metric_type`, `base`, `numerator` or
  `denominator`, or `inputs` without `cases`; an earlier-period metric is C10's. The rule is not read on a statement
  with a Gap about its subject, which says what the text does not give. A calculation only described (a column's
  meaning, a table of cases) may stay in words.
- **C15** The names in a formula. Each name in the `expression` of a ComputedAs (an earlier-period metric's aside)
  is one declared element. In a total, a name is an element of `inputs`, by the last part of its id, else the field of
  `base` with that name, else the field of `base` with that label; the element is a field of `base`, or a concept one
  field of `base` implements; a name written `table.column` gives the name or the label of `base`. In any other
  definition, a name is an element of `inputs`, the `numerator` or the `denominator`, by the last part of its id or, for
  a field, its name or label. No two of these share a name the expression uses. Every element of `inputs` is named in
  the expression, and `inputs` lists every field a total's expression reads or none of them (not read on a
  `cumulative` or `conversion` metric, beside `cases`, or on `*`). `*` is a count's alone. So the table a column comes
  from is read from fields: `base` in a total, and for a metric named in the expression, its own definition. Not read
  on a statement with a Gap about its subject, or one that names an element nothing declares.
- **C16** A join. It is a JoinsTo statement, and nothing else holds one. An ImplementedBy gives no `expression`: the
  column is its `object`, the rows are its `filters`. A JoinsTo gives each condition once: a comparison of two columns
  as a key pair (`comparator` and `normalize` when it is not a plain equality), and in `keys` only a condition key
  pairs cannot say (a function on a column), with no key pair that leaves a part of it out. `keys` beside `key_pairs`,
  and `keys` with an entry that is one equality of two declared columns written `table.column`, break the rule. A
  query inside an `expression` breaks C14.
- **C17** A label a rule calls for. A Rule with `modality: must` or `should` whose action's verb is `label` says in
  fields when the label applies to its `objects`. It has no condition (the label always applies); or a condition of
  `when` or `when_any` names in `about` a state (a concept of `concept_type: state`), or gives `field` and
  `comparator`, or holds a threshold and names a metric in `about`; or its only conditions are in `unless` and each
  gives `field` and `comparator`; or its `period` gives `start` and `end`. A condition in words that names no state,
  and an exception that names a state, do not say when the label applies.
- **C18** A metric's format. A `HasProperty` with `standard_attribute: format` whose `subject` is a metric gives, as
  its `property_value`'s `value`, a number pattern: `0` or `#,##0` (thousands separators) for the whole part, then
  optionally `.` and one `0` for each decimal shown, then optionally `%` (the value is shown times 100), with at most
  four characters of a currency sign or code before it (`0.0%`, `#,##0`, `$#,##0.00`). A format given in words
  ("one decimal") breaks the rule.

Four things are read from text, and nothing else is: a declared column named as an identifier (C1, C3), a member's
label equal to a listed value (C5), `* 100` in an expression (C6), and an `expression` and a `keys` entry read as SQL
(C14 to C16).

A check MAY also give advice that keeps no document out of the profile. The reference check gives four notes: a
quote that says a definition counts in another metric whose `scope` does not name it (C4); a concept whose label
names, as an identifier, a column its own ComputedAs or ImplementedBy reads, and is more than that name (a formula or
a condition used as a name); a described calculation whose `expression` is words; and a ComputedAs or an
ImplementedBy that reads, in `filters` or `time_dimension`, a column of another table with no JoinsTo with
`key_pairs` between the two tables among the statements read.

A tool MAY rewrite a document into the profile's form for three of the rules, and no other:

- **C10** An `expression` that is absent, or is the input's name written another way (another case, in backticks or
  quotes, with spaces for underscores, or the input's label or an alias), becomes the input's name. Any other
  expression may hold a formula and is not rewritten.
- **C11** When the action's `objects` name only concepts that are not metrics, or nothing, a metric in the action's
  `to` moves to `scope`. A rule about a table or a field is not rewritten.
- **C12** A dimension in `scope` moves to the action's `by`, and a dimension named beside a metric in a condition's
  `about` is added to the action's `by`.

A tool that rewrites MUST keep every statement, thing and concept, each one's id and `evidence`, and the facts the
document states (`graph.md`, "Which statements become facts"); it MUST change no field other than `expression`,
`scope` and the action's `to` and `by`; and rewriting its own output MUST change nothing.

## A conforming producer

- **P1** Every document it writes conforms, and when it writes from a text the document is source-bound.
- **P2** It accounts for every non-blank line of the text it expresses: the quotes found on a line, in any thing,
  concept, statement, step, unmapped or skipped item, cover at least 90% of that line's letters and digits.
- **P3** It writes only what the text says. What no building block fits goes in `unmapped` with the statement type
  that would be needed and `why`, and is never forced into a statement that changes its meaning. This rule needs a
  person to judge; the guide (`guide.md`) says how each kind of sentence is expressed.

## A conforming graph builder

- **G1** It builds the record graph as `graph.md` describes ("The record graph"), at the address `graph.md` gives;
  the record graph of a conforming document passes `generated/bigcontext_schema.shacl.ttl`. From 1.2, for a date it
  also builds the in-force graph (`graph.md`, "Questions on the record graph"): exactly the statements and procedures
  in force are `bcf:InForce`.
- **G2** For a date, it states exactly the facts `graph.md` lists ("Which statements become facts").
- **G3** It works out exactly the facts that follow from the stated ones under OWL 2 RL with
  `generated/bigcontext_facts.owl.ttl`, and keeps them apart from the stated facts.
- **G4** Its answers to the questions in `queries/` (SPARQL) or `cypher/` (openCypher) are the expected ones; from
  1.2, so are those of `queries/record/connections.rq`, run on the record and in-force graphs: exactly the links the
  link annotations give, for the statements and procedures in force.

## A conforming repository

A repository is a folder that holds the context of one organization and of its teams as documents, one per file, so
that it can be kept in version control and changed the way code is. It is optional: a conforming document need not
be in one. `examples/context-repository/` is one, and `repository.md` says how its files are made.

The root holds two files beside the documents. `bigcontext.yaml` is the manifest. `registry.yaml` is the repository's
registry: the kinds of context it holds. Each kind gives its `folder`; whether it is held in a repository (`git`);
the thing types (`things`), concept types (`concepts`) or statement types (`statements`) a file of the kind holds, or
the `mode` of the procedures it holds (`procedures`); thing types declared inside another kind's file (`members`, with
`member_of` on the member's own kind); and `conflict`, which is `org` or `narrowest` (R8). A kind may also give
`complete_with`: what a complete file of the kind holds, as a list, or as a mapping that gives each item the words a
note uses for it. An item is a statement type about the file's element or procedure (`ComputedAs`), with `(object)`
when the element is the statement's object (`Heads(object)`); a statement type with a field it gives, or with a word
it gives as the value of a field (`ComputedAs.time_dimension`, `HasProperty.unit`); or a field of the file's own
element, procedure or statement (`physical_name`, `trigger`). Items joined by `|` are alternatives. A kind may give
`links` too: what a complete instance of the kind is linked to, as a list of items. A thing is linked to another when a
statement of its view names both in fields, by the field's link role (`graph.md`, the roles table), or by a fact that
follows from several statements (`graph.md`, "Facts from several statements"). An item gives `words` (what a note
calls the link) and a test: `by`, the roles or facts of which one is enough, a role alone (`part_of`) or with its
statement type (`HasGrain.members`); `to`, the kinds of what the thing names; `from`, the kinds of what names the
thing (`any` for every kind); `any`, several tests of which one is enough; `of`, the element or statement types the
item is asked of. An item with `worth: true` is a link worth having, which a check lists and does not note. Added in
1.5. The registry is the repository's own: this specification names no kind.

A repository conforms when:

- **R1** The root holds `bigcontext.yaml`, which gives `schema_version`, `source` (with `id`), `organization` (the id
  of an organization the org's files declare) and `accountable` (R10), and `registry.yaml`.
- **R2** A file's level is its path. A file under `org/` is the organization's. A file under `teams/<team>/` is that
  team's, and the org's files declare a team or unit whose id is `t.<team>`.
- **R3** Under its level folder, each file sits in the folder the registry gives one kind whose `git` is true. The
  elements it declares are of the types that kind lists; a file of a kind that holds statements or procedures holds
  those types, and statements about what the file holds.
- **R4** A file is named after what it holds: the id without its first part (`orders.yaml` for `c.orders`,
  `shop.orders.yaml` for `t.shop.orders`). A file whose kind holds statements is named by the part of its statement's
  id between `s.` and the statement type. A file that declares no element is named after the one element its
  statements, or the members it declares, belong to. A name is at most 100 characters, and no two paths differ only
  in letter case.
- **R5** Each file is a conforming document (D1 to D10) of the manifest's `schema_version`, with the texts under
  `sources/` as its source text. Its `source.id` is the manifest's: the repository is one source and each file a
  section of it, so a file lists in `external` every id it refers to and does not declare.
- **R6** No statement id is used twice in the repository. A team's statement ids start `s.team-<team>.`, and no other
  id has a second part that starts `team-`. An element id has one type in the repository. An element is declared by
  the org's files, or by a team's for an element the org's do not declare.
- **R7** A view is the org's files, or the org's files and one team's. Each view, read as one document with `external`
  left out, conforms: every reference names something the view declares. So an org file refers to no team's id, and
  a team's file to no other team's.
- **R8** The repository holds decided context: no statement has `decision_status` `proposed`, `under_discussion`,
  `rejected` or `withdrawn`. No statement names itself in `supersedes`. What stands in a view on a day is, first, what
  is in force on that day (`graph.md`, "Which statements become facts"). Then, of the statements in force that have
  the same key, one stands: the team's where the kind of its file has `conflict: narrowest`; the org's where it has
  `conflict: org`; within a level, the one whose `valid_from` is latest, and of two with the same `valid_from` the one
  with the smaller id. The versions of one key at one level do not overlap: each ends, by `valid_to`, before the next
  begins. A team's statement that names an org statement in `supersedes` stands in its place in that team's view,
  unless the org statement's kind has `conflict: org`: naming it there, in `supersedes` or `overrides`, breaks this
  rule.
- **R9** In a file that declares elements or holds a procedure, each statement is about one of them, one of its
  members or its steps (its `subject`, or for a `ResponsibleFor` its `object`), or about another statement of the
  file. A team's file may hold statements about an element the org declares, and members of a table the org
  declares; it does not declare that element.
- **R10** `accountable` names, for each level that holds a file, a declared person or post by `default`, and may name
  one by kind or by layer: `{org: {default: t.dana}, teams: {support: {default: t.dana}}}`. The most specific entry
  is the one accountable.

Two statements have the same key when neither gives a condition (`when`, `when_any`, `unless`, `scope`, `period`,
`valid_while`, `even_if`), neither is negated, somebody's view (`held_by`), uncertain or said to hold no longer
(`currently: false`), and they are both: a `ComputedAs` with the same `subject` and `base`; a `Definition` or a
`HasGrain` with the same `subject`; an `ImplementedBy` with the same `subject` and `object`; a `HasProperty` with the
same `subject` and attribute; a `JoinsTo` with the same `subject`, `object` and `role`; a `HasStatus` with the same
`subject` and `status`; an `IdentifiedBy` with the same `subject`, unless one gives `primary: false`; or a
`ResponsibleFor` with `responsibility: owns` and the same `object`. A statement of no such form has no key and stands
beside the others.

A check may give notes that keep no repository from conforming. The reference check gives five: a team's statement
that the org's stands in place of; a team's statement that says what the org's says; two statements of one level
with one key and the same `valid_from`; a team's rule about the action of an org rule; and a file that does not hold
what its kind's `complete_with` lists, or whose thing lacks a link its kind's `links` lists, looked for among the
statements of the file's view.

## The cases

`tests/` holds the cases (see `tests/README.md`). Each invalid document breaks exactly one rule, the one at the start
of its folder's name, and its `expected.yaml` also gives what the reference checker says, as an example: an
implementation matches the rule, not the wording. The graph cases give, for an example and a date, the stated and
worked-out facts as N-Triples and the answers to the questions. An implementation conforms when it gets every case
right.

`tests/profiles/compilable/` holds the profile's cases, apart from those: one document in the profile; for each of
C1 to C11 and C13 to C18, that document with one change, which conforms and breaks that rule alone; for C10, C11 and
C12 a document in a form a tool may rewrite, beside its rewritten form; and `expressions.yaml`, expressions of a total
on one table, each in the profile or breaking C14 or C15, which a checker and a compiler both get right. An implementation that checks the profile gets
these right; one that does not check it still conforms.

`tests/repositories/not-conforming/` holds the repository cases: for each of R1 to R10, the files that differ from
`examples/context-repository/` and an `expected.yaml` with `breaks:` the rule. The example with those files in place
(and the ones under `removes:` taken out) is a repository that breaks that rule. An implementation that checks
repositories gets these right; one that does not check them still conforms.
