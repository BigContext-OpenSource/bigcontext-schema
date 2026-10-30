<!-- serves: F-056 — Express any context in BigContext Schema -->
# Expressing a text in BigContext Schema (draft 0.9)

This guide is for anyone, person or AI agent, who turns a source text into a BigContext Schema document.
**Faithfulness beats coverage.** If something does not fit, record it as `unmapped` with the statement type you
would have needed. Never bend a statement type to make it fit, and never invent content the text does not say.

The schema is `bigcontext_schema.yaml` (LinkML), beside this guide. This guide explains how to use it.

## What you produce

One YAML file, a `ContextDocument`:

```yaml
source: {id: <corpus id>, title: <title>, as_of: <the date the source is true as of, if it says>}
revisions: [...]     # the source's own change history: {version, date, by, summary, evidence}
external: [...]      # ids you refer to that another section of the same source declares (see Ids)
things: [...]        # named individuals: people, teams, units, posts, organizations, agents, systems, tables, fields, channels
concepts: [...]      # business words and categories: customer, revenue, approved refund, Paid Search, data analyst
statements: [...]    # one claim each; the predicate is the statement type
procedures: [...]    # ordered steps, as instructions (do this) or descriptions (how work happens)
conflicts: [...]     # statements that contradict each other: {statements: [ids], reason}
unmapped: [...]      # claims BigContext Schema could not express, with what would have been needed
skipped: [...]       # text with nothing to express: headings, formatting, metadata, navigation, logs
```

**Nothing is dropped.** Every non-blank line of the text should be accounted for by the evidence of something: a
thing, concept, statement, step, unmapped item or skipped item.

## Evidence

Every statement, step, unmapped and skipped item needs `evidence: [{quote: "..."}]`; things and concepts should
have one too. The quote must be copied **word for word** from the source (whitespace and curly versus straight
quotes are forgiven, nothing else). Quote the part each claim comes from: a long paragraph is usually quoted
sentence by sentence across several statements. A quote may run across several lines. Several statements may
share one quote when one sentence makes several claims.

**Always put quotes and other text in double quotes.** In YAML, a `#` after unquoted text starts a comment and
silently cuts the rest off; the checker rejects that.

Headings: a heading that names what follows can be the evidence of that concept; a block title that limits the
statements under it is their `scope`; other headings are `skipped`.

## Ids

- Concepts `c.<slug>`, things `t.<slug>`, procedures `p.<slug>`, slugs in lower case with underscores, made from
  the label: `c.approved_refund`, `t.acme`, `p.order_tracking`. Other sections use the same
  convention, so the same slug means the same element across files. Reuse the obvious slug.
- Tables and views: `t.<schema>.<table>`, dropping any database or project prefix. If the schema is not given but
  the same table is described elsewhere in the source with its schema, use that id; otherwise `t.table.<table>`.
- Fields: `t.<schema>.<table>.<field>` when the table is known, otherwise `t.field.<field>`. Never guess.
- Statements `s.<SECTION>.<n>`; steps `<procedure id>.<SECTION>.<n>`. `<SECTION>` names the part of the text a
  file covers, so ids stay unique when a long text is split across several files.
- Declare every thing and concept you refer to in your own file. The exception: a statement or procedure that
  another section declares (a rule you override, a procedure you call) goes in `external` instead.

## Thing and concept types

Things: person, team, unit (an office, division or department inside an organization), post (a position people
hold or rotate through: "Director, Office of Federal Activities", "Engineer On Call"), organization, agent,
system, data_container (database, project, schema, dataset), data_product (a curated, owned set of data assets
offered for named uses), table, view, field, access_group (a group,
database role, IAM role or policy tag that grants access), meeting (a meeting or other dated event), document,
tool, channel (a Slack channel, a mailing list), place, product, other. A generic post ("a Director") is one post per office it
heads, with `HoldsRole` from the post to the role concept.

Concepts: entity_type, metric, dimension, segment, category_value, state, role, activity (a kind of work,
analysis or question: the use case a pattern or procedure serves), area, calendar, period, term, other.

## Statement types (the predicate) and when to use each

Meaning
- `Definition`: what a term or a named thing is, in words. `subject`, `text`, optional `object` (its category).
  A table's "Role:" line is a Definition of the table, and a line saying what a document is or does ("This policy
  sets who may see which data") is a Definition of the document.
- `IsA`: X is a Y. Putting something in a level or category the source names ("customer emails are Restricted",
  "this is a Sev2 incident") is `IsA` that category; `HasProperty` is only for literal values. `SynonymOf`: another
  word for an element (`term`, `subject`, `usage` always | sometimes | abbreviation; use `frequency` for "usually"
  or "often").
- `Groups`: a named group made of members (a data product's tables, a region's countries, or several values that
  together match another: see `Mapping`). `HasValues`: the values a field or dimension takes ("segments are Enterprise,
  Mid-market and SMB"; `values` literals and/or `members` concepts). The people, teams or posts that make up a team or
  body are `MemberOf` it, one statement each. Groups and HasValues take `complete`: true when the text says the list is
  complete, false when it says "such as", "including" or "etc."
- `ComputedAs`: how something is calculated: `expression`, `inputs`, `values` (weights, thresholds: each with
  `role`, `comparator`, `applies_to`), and `cases` for step-wise scoring ("over 10% gives -2 points": one case per
  row, `{when, value}`).
- `Sequence`: items in order: funnel | levels | derivation | lifecycle | format, optional `complete`.
- `HasProperty`: a literal value for an attribute **that no other statement type covers**. Use
  `standard_attribute` when one fits: row_count, distinct_count, null_rate, minimum, maximum, data_type, format,
  unit, time_zone, freshness, retention, aggregation, sensitivity, response_time, location, address, headcount.
  Only otherwise name an `attribute` concept. Grain, coverage and status have their own types below.
- `UsedFor`: what something is for (`negated: true` for "not for").

Rules
- `Rule`: a norm. `modality`; `action`; `when` (all must hold), `when_any` (any one is enough), `unless`,
  `even_if`, `because`, `so_that`; `overrides`; `binds` (who must comply, when not the reader); `absolute: true`
  for a "hard rule" or "hard ban".
- `RuleSet`: a named group of rules sharing a scope, strength or precedence ("Privacy Rules, which override
  team guidelines"). `members` the rule ids, `overrides`, `absolute`. Write the precedence once here.

  Strength, decided by the words used:

  | Text says | modality |
  |---|---|
  | must, shall, always, required, mandatory, will (in an instruction), a plain instruction ("use X for Y") | `must` |
  | we pledge to, we commit to, is committed to, we will (an organization promising its readers) | `must`, binding the organization: a promise is a duty it takes on, never `unmapped` |
  | it is your responsibility to ensure, you are responsible for (said to the reader) | `must` |
  | never, do not, must not, banned, not allowed, not permitted, prohibited, is not acceptable | `must_not` |
  | should, prefer, for preference, it is better to, can and should, generally/typically + an instruction | `should` |
  | is expected to, we ask that, please, we recommend, useful (of things to use) | `should` |
  | is encouraged to, shall work to, aims to, strives to, ideally, is intended to, we'd like to (an aim, not a duty) | `should` |
  | it is important to, it is critical to | `should`, with `importance: high` |
  | avoid, should not, rather not | `should_not` |
  | can, may, is acceptable, feel empowered to, should be free to (a permission) | `may` |
  | may, can, might, possibly (it might happen, not a permission) | no strength: write the fact with `certainty: possible` |
  | will, is (describing what a role or system does, not telling anyone to) | no strength: write the fact (`ResponsibleFor`, `Triggers`, `Transition`) |
  | need not, does not have to, is not required | `need_not` |
  | by default, default to, unless otherwise specified, assume | `by_default` |
  | **only** do X when Y / X **only** if Y (only limits when the act is allowed) | `must_not` X, `unless` Y (not `must`) |
  | check with, consult or clear it with Y **before** X ("clear any discount with Finance before you quote it") | `must_not` X, `unless` checked with Y (`about` Y), as for an approval (not `must` check, `when` before X) |
  | **only** these may do X ("only managers may approve") | `may`, with `exclusive: true` |
  | required to do X **only** when Y ("only required to submit receipts over $50": only limits the duty) | `must` X, `when` Y; nothing is required otherwise |

  Instruction or fact: when the text tells the reader to do something, write a `Rule`; when it describes how
  things are, write the fact. Do not write both for the same words. A definition that also states a norm
  ("Code Freeze: only critical fixes are merged") is a `Definition` quoting the defining words and a `Rule` quoting
  the norm's words.

  Who must act goes in `binds` (a step's in `performer`), never in the action's `by`. A list of duties for a role
  ("Managers are responsible for...", "Team members must...") is one `Rule` per duty binding the role when the text
  states it as a norm (must, should, is expected to); a standing area of work stated without a norm ("Accounting
  handles reimbursements") is `ResponsibleFor`. "X needs to be approved by Y" and "X must be nominated by Y" are
  conditions on X, not duties on Y: a `Rule` that X `must_not` go ahead `unless` Y approves (or nominates) it; Y is
  not bound to approve anything. "Y or higher" adds `or_more_senior: true`. A vote threshold ("passing requires a
  strict majority", "at least two-thirds") is a condition with a threshold value:
  `{value: "2/3", role: threshold, comparator: at_least, unit: "of votes cast"}`. A consequence with no one named as acting ("they are removed", "the council
  is dissolved", "it is moved out automatically") is a `Transition` to the new state with `automatic: true` when
  the text says it happens by itself; never invent who does it. Which source wins over another ("the finance team's formula is the one that runs"; "Snowflake is the source of truth for fiscal revenue"; "tax filings use the ledger") is a
  `Rule` to use one source, with the purpose it is for ("fiscal revenue", "tax filings") in `scope`, not `when`,
  and `overrides` when it names the rule or source it beats.

Actions (in rules, steps and triggers): `verb` from the closed list (the class), `specific_verb` with the text's
own verb when it is more specific (page, recommend, deduplicate, invite, merge), `objects`, `by` (breakdown
dimensions only: "spend by channel"; never who acts), `via` (channel, tool or intermediary), `to` (recipient or destination),
`values`, `options_in_order`, `alternatives` (either/or, each with its own `when`), `then` (actions that follow in
the same instruction: "stop and ask"), and `detail` only for what the rest cannot carry.

Company structure
- `PartOf` (transitive; `complete` when the text says "consists of"), `MemberOf` (`role`), `HoldsRole`,
  `ReportsTo` (transitive; `direct`), `HasAccess` (`access` admin | read | none | masked | use | granted, when
  the text does not say what kind). Who can see, read or use a resource is `HasAccess`, also when the text says
  "may access" or "may see"; a `Rule` with `may` is permission for another act (grant, export, approve). A post
  inside a team or unit (the Release Team's Enhancements Lead) is `PartOf` it; people are `MemberOf` their teams.
- `Heads`: a person or post heads a unit, team or organization. This is a structure link, like `ReportsTo`;
  use it for "headed by", "under the direction of", "head of". Use `ResponsibleFor` for other duties.
- `ResponsibleFor`: `responsibility` owns | manages | accountable | responsible | performs | approves |
  decides | supervises | coordinates | reviews | advises | assists; `object` or `text`; `answers_to` for
  "responsible to X for Y".
- `Appoints` (`with_consent_of`), `EscalatesTo` (an escalation path, not a reporting line; `via`, `when`; a path in
  order, "first #help, then the on-call engineer", is a chain: the problem escalates to #help, and #help to on-call),
  `WorksWith` (coordinates, liaises, works closely with; `text` the topic), `Represents` (`audience`),
  `Serves` (places or populations a unit serves), `GovernedBy` (a law, policy, agreement or document).

Lifecycles and automatic behaviour
- `Transition`: `subject` what changes state, `from_state`, `to_state` (state concepts), `when`, `performer`.
  A lifecycle the text gives only as an order of states ("draft, then in review, then published") is a `Sequence`
  with `sequence_type: lifecycle`; a change of state the text says more about (a condition, a performer, an
  automatic move) is a `Transition`.
- `Triggers`: when something happens (`when`), a system or party does something automatically (`action`). Not a
  norm.

Mapping and data
- `Mapping` (`match` exact | close | broad | narrow | related, read as in SKOS: broad when the object is the broader
  term, narrow when it is the narrower one; `justification`), `ImplementedBy` (`expression`,
  `primary`; also code or a model that computes it: "the SQL lives in the dbt model churn_monthly"; a document that
  describes it is `DescribedIn`), `JoinsTo` (`keys`, `cardinality`, `dedup`, `join_type`).
- Several elements that together correspond to one ("the Silver and Gold plans together roughly match the CRM's
  Premium tier"): name the group as a concept, list its members with `Groups` (`complete: true` for "together"), and
  map the group once (`match: close` for "roughly"). One mapping per member loses "together". When each maps on its
  own ("Bronze is Basic and Platinum is Elite"), write one mapping each.
- `Contains`: a table holds a field, concept or entity, as a key | attribute | label | dimension | time_dimension
  | measure, with `time_grain` for a time dimension. Use it for "the table includes X, Y, Z". Do not add a statement just because a field id names its table.
- `HasGrain`: what one row stands for (`text`, `members` when named). `IdentifiedBy`: a unique key.
- `Covers`: which platforms, populations or places a table or system covers (`members`, `complete` for "only"),
  for which period (`valid_from`, `valid_to`); `primary: true` when it is the source of truth for them.
- `HasStatus`: canonical | variant | alias | broken | deprecated | retired. Whether a statement was proposed or
  adopted is its `decision_status`, not a status.
- `DerivedFrom`, `Has` (cardinality one_to_many | many_to_one | exactly_one | one_or_more | zero_or_more; "can
  have" is zero_or_more), `Caveat` (`object` for a second element it concerns). A known problem a reader must
  allow for is one Caveat with its cause in its text, even when it names a behaviour ("the feed sometimes sends
  rows twice, which causes duplicates").
- `JoinsTo` join_type: left (the only one any text has needed so far; record another as unmapped).

Belief, patterns, gaps and examples
- `Indicates` (pattern in `when`, with its thresholds in that condition's `values`; conclusion in `text`; `subject`
  what the conclusion is about), `Influences` (`direction`).
- `Template`: a reusable pattern (a sample query, a message or report outline) **linked to its use case**:
  `subject` the use case (an activity concept or a procedure), `text` the pattern as given, `inputs` the
  tables, fields, metrics and joins it uses, `outputs` what it produces, `values` its placeholders (`role:
  parameter`) and its one-off sample values (`role: example`), `when` the situation it is for. An instruction to use
  it ("Use this query for ...") is also a `Rule` (must use) with the Template's id in its action's `objects`. Use
  `Example` only for an illustration that is not meant to be reused.
- `Gap`: something missing, unknown or future work.
- `CreatedBy`: who created, founded or wrote something ("the project was started by Guido", "PEP 8016, written
  by Nathaniel Smith and Donald Stufft"): `object` the creator, `members` when several, `text` for unnamed ones.
- `DescribedIn`: where something is described in full when the text only points there ("the process is described
  in PEP 8000", "see the cherry-pick process"): `object` the document, page or section.

A sequence of levels (`Sequence` with `sequence_type: levels`) keeps the order the text gives (a ladder numbered from
mildest stays mildest first). "Including X" widens what the statement is about: add X to its objects or members, never
to `even_if`. Dates in `valid_from`, `valid_to` and `as_of` are ISO dates: "October 2027" is `2027-10`, "31 October
2027" is `2027-10-31`; the quote keeps the text's own words. A former holder or member the text names without dates
("emeritus", "former", "previously") is the statement with `currently: false`. A state that may end in one of several
ways ("deleted, aggregated or de-identified") is a `Transition` with `to_state` the first and `alternative_states` the
others. A web address is `HasProperty` with `standard_attribute: web_address`. A source's own metadata
line ("Status: Active", "Created: 2018-12-16") goes in `source` when it gives the source's date or version: "Last
updated", "Last reviewed" and "Created" dates in `date`, "Effective" and "as of" dates in `as_of`, a version number in
`version`. The `source` block holds no quote, so list that line in `skipped` with `reason: metadata` as well. An
"Owner:" line is a claim: `ResponsibleFor` with `responsibility: owns` from the owner to the document (a thing with
`thing_type: document`). An "Approved by X on DATE" line is a `revisions` entry (`by`, `date`). Other metadata lines
are `skipped` as metadata. A step's time limit is its `within`; a period's start and length
are `HasProperty` with `standard_attribute` start or duration.

## Metric and join definitions that can run

When the text defines a metric or a join precisely enough to run, also give the computable fields, so the
definition can be exported to a semantic layer:

- `ComputedAs` on a metric: `aggregation` (sum, count, count_distinct, average, min, max, median, percentile,
  sum_boolean) over `expression` on the `base` table; `metric_type` simple | ratio | derived; `numerator` and
  `denominator` for a ratio; `inputs` for a derived metric; `time_dimension`; `filters` as conditions that give
  `field`, `comparator` and `values` (`ORDER_STATUS != 'Cancelled'`); `dialect` of the expression.
- `JoinsTo`: `key_pairs` that point at the column elements (`from_field`, `to_field`), not only key text.
- `Contains`: `data_role` dimension | time_dimension | measure, with `time_grain` for a time dimension.
- A table's name in its system goes in the thing's `physical_name` (`acme-prod.shop.fact_orders`).
- Every date or time column a table has is `Contains` with `data_role: time_dimension` (and `time_grain` when the
  text gives one): its type is DATE, DATETIME or TIMESTAMP, the text gives a date range, or its name says so
  (ORDER_TIMESTAMP, SPEND_DATE). This is what lets a measure on that table be reported over time.
- `time_dimension` on a measure is the date it is counted by. Give it when the text says, and look for it when the
  base table has no time column or several: the checker notes those measures. Leave it out when the text does not
  say; never guess. A ratio or derived metric takes its dates from its parts.
- A formula that combines aggregations (`SUM(a) - SUM(b)`) is one simple metric per aggregation and a `derived`
  metric whose `expression` uses their names (the last part of their ids) and whose `inputs` lists them. A formula
  that needs joins or subqueries to run keeps its SQL in `expression`, with `dialect`, and no computable fields.

The expected shape, with the fields to give when the text says them:

```yaml
things:
  - {id: t.shop.orders, label: orders, thing_type: table, physical_name: "acme.shop.orders", evidence: [...]}
  - {id: t.shop.orders.order_ts, label: ORDER_TS, thing_type: field, evidence: [...]}
  - {id: t.shop.orders.amount, label: AMOUNT, thing_type: field, evidence: [...]}
  - {id: t.shop.orders.status, label: STATUS, thing_type: field, evidence: [...]}
concepts:
  - {id: c.revenue, label: Revenue, concept_type: metric, evidence: [...]}
statements:
  - {id: s.T.1, predicate: Contains, subject: t.shop.orders, object: t.shop.orders.order_ts, data_role: time_dimension, evidence: [...]}
  - {id: s.T.2, predicate: Contains, subject: t.shop.orders, object: t.shop.orders.status, data_role: dimension, evidence: [...]}
  - id: s.M.1
    predicate: ComputedAs
    subject: c.revenue
    metric_type: simple
    aggregation: sum
    expression: AMOUNT                        # what is aggregated, as the text gives it
    base: t.shop.orders
    time_dimension: t.shop.orders.order_ts    # the date it is counted by; may be left out when the table has one
    filters:
      - {description: "status is not Cancelled", field: t.shop.orders.status, comparator: not_equal, values: [{value: Cancelled}]}
    evidence: [...]
```

Keep every version of a definition the text gives, with `HasStatus` (canonical, variant, deprecated...) and the
decision group; only the canonical one is exported. When a metric has several definitions, each `HasStatus` has
the definition's statement id as its `subject`; when the whole metric is deprecated or an alias, the concept is the
subject. Several definitions with none marked canonical are reported and none is exported. Mark a definition
`canonical` only when the text says so: when the other definitions are deprecated or variants, the one left in force
is exported without it.

## Tools and what agents learn

- A tool (an MCP tool, an API operation) is a thing with `thing_type: tool` and `physical_name` its name in its
  server, `PartOf` the server (a `system`). Record what the tool is for (`UsedFor`), who may use it (`HasAccess`
  with `access: use`; "only" is `exclusive: true`), when it must or must not be used (`Rule`), and sample calls
  (`Template`). Do not copy its parameters, endpoint or version: the server defines those.
- A data product is a thing with `thing_type: data_product`: its tables (`Groups`), its owner (`ResponsibleFor`),
  its approved uses (`UsedFor`) and its metrics (`ComputedAs`).
- A log of one run, call or conversation is `skipped` with `reason: log`; it belongs in a trace store. A learning
  taken from it is a statement only once a person approves it, with `proposed_by` the agent, `decided_by` the
  person, `decided_on` and `decision_status`.

## Shared groups any statement can carry

These groups exist so that a new kind of context becomes a few fields on an existing statement, not a new
statement type.

- **Decision group**: who stands behind a statement and how far it got. `held_by` (whose preference, view or
  wish it is), `proposed_by`, `decided_by`, `decided_on`, `decided_in` (the meeting, channel, ticket or document),
  `ratified_by`, `endorsed_by` (+1, "fine for now"), `disputed_by`, `informed` ("Alex knows"),
  `decision_status` proposed | under_discussion | decided | ratified | rejected | withdrawn | superseded, and
  `supersedes` (the statements it replaces). A wish or proposal that was not adopted is still written as what it
  asks for (a `Rule`, a `ComputedAs`...), with `decision_status` saying so; it is never written as a plain rule.
  `ratified_on` and `ratified_in` say when and where it was ratified.
  A person's preference is a statement with `held_by` that person (usually a `Rule` with `by_default`); a
  judgement ("holds its own weight", "not all that bad") is the statement it judges, usually a `HasProperty` with
  the quality as its attribute, with `held_by` the person who judged.
  An action item is a `Rule` binding its owner, with `due_by` its deadline, `progress` how far it has got
  (pending | in_progress | nearly_done | done | overdue | blocked | dropped) and `decided_in` the meeting.
- **Work and time**: `due_by` is a deadline ("by 30 November", "by the end of each fiscal quarter"), also one relative
  to an event, in the text's words ("two days before launch", "before the review starts"; but "check with Y before X"
  is a condition, as in the strength table); `within` is a
  duration ("within 30 days"); `recurrence` is a duty or an automatic behaviour that recurs ("every month", "daily at 02:00 UTC"); `cadence` is how a rotation
  turns over; `frequency` is how often something is true. A step can carry `due_by` and `recurrence` too.
- **Classes and questions**: a statement about each member of a class ("nine offices, each headed by an
  Assistant Administrator") names the class and has `each: true`. An open question is a `Gap`; a statement that
  answers it has `answers` with the Gap's id.
- **Meetings**: who attended is `MemberOf` from the person to the meeting with `role` an attendee, regrets or
  absent concept. A renaming is `SynonymOf` with `usage: former` and `valid_to`; a reorganization is the old and
  new `PartOf`, `ReportsTo` or `Heads` with their dates, the new one `supersedes` the old.
- **Assignment group**, on roles, memberships, reporting lines, headship and responsibilities: `capacity`
  substantive | acting | interim | primary | backup | delegate, `acting_for` (whom an acting holder stands in
  for), `line` solid | dotted (a dotted line is not followed when walking the chart), `share` (a value: 50%),
  `cadence` for a rotation ("weekly, Monday 09:00 ET"; the people who rotate each hold the post).
- **Snapshot**: the source's `as_of` date applies to every statement that has no date of its own. A statement
  true as of a different date (a profile from February) carries its own `as_of`. Dated changes use `valid_from`
  and `valid_to` (`valid_to` is the last day it held).
- **Service and scope**: `within` (a time limit: "answer within 4 business hours"), `via` (the channel or tool a
  party is reached through), `exclusive: true` ("only analysts", "the only channel with carts").

## Qualifiers every statement can carry

`when`, `when_any`, `unless`, `even_if`, `because`, `so_that` (lists of `{description, about}`), `scope`,
`frequency` always | usually | often | sometimes | rarely (how often or how widely), `certainty` stated |
likely | possible | estimated, `importance` critical | high ("VERY IMPORTANT", "the core of your
analysis", "of particular interest"), `negated`, `currently` ("right now", "currently"), `valid_from`,
`valid_to`, `valid_while` ("for the duration of the incident": a named period or state the statement holds through,
such as "during the freeze" or "while Jo is on leave"; a recurring window, "during business hours", is a `when`),
`stated_by`.

A threshold in a condition ("if returns rise by more than 10%", "orders over $50") is a value in the condition's
`values` that carries its own comparison: `{value: "10", datatype: percent, role: threshold, comparator: more_than}`.
`value` is the number alone; its kind goes in `datatype` (percent, number) and anything else in `unit` ("USD", "of
votes cast"). The condition's own `comparator` is only for a data filter, with `field`. A condition on a measured amount names what it
measures in `about`: a metric concept ("returns", "p-value", "week-over-week change in orders"), with its
`ComputedAs` when the text says how it is calculated; a condition that something is in a state or category ("the
incident is Sev1", "the data is late") names that state concept. A time since an event ("after 7 days") needs
neither. This is what lets a rule's condition be checked against data.

An amount an action must reach or stay within ("keep the page up for at least 30 days", "spend no more than $500") is
a value on the action with `role` minimum or maximum and no comparator; add `comparator` more_than or less_than only
when the amount itself does not count ("more than 3 days", "under $500"). A data-quality expectation ("the null rate
of EMAIL should stay at most 1%", "SKU must be unique") is a `Rule` with the strength its words give, `verb: check`,
the table or field in `objects`, what is checked in `detail`, and its tolerance as a value with `role` minimum or
maximum.

## Procedures

When the text gives steps, make a `procedure`: `mode` instruction | description, optional `modality`, `goal`,
`performer`, `trigger`, `scope`, `when`, `unless`, `because`, `so_that`, `inputs`, `outputs`, `steps`. Each step:
`order` (1, 2, 3 within your file), `source_label` (the text's own number or letter: "3a", "4."), optional
`modality`, `action`, `performer`, `also_performed_by`, `automatic` (a system does it), `when`, `when_any`, `unless`,
`even_if`, `because`, `so_that`, `next`, `branches` (`{when, go_to}` or `{when, outcome}`), `calls`, `consumes`,
`produces`, `evidence`. A step that runs a sample query has the `Template` statement's id in its action's
`objects`. If a procedure continues from or into another section, use the same procedure id; fragments are
joined later. One instruction that gives different actions for different cases ("for a refund, approve it within a
day; for an exchange, log it") is one step per case, each with its own `when` and `within`, sharing the text's
`source_label`.

## Free text

Free text is allowed only in: `Definition.text`, `UsedFor.text`, `Indicates.text`, `Gap.text`, `Example.text`,
`Template.text`, `Caveat.text`, `DerivedFrom.text`, `Influences.text`, `ResponsibleFor.text`, `WorksWith.text`,
`GovernedBy.text`, `HasGrain.text`, `ComputedAs.expression`, `ImplementedBy.expression`, `Mapping.justification`,
`Condition.description`, `Action.detail`, `Action.specific_verb`, `goal` and `note`. Keep conditions and details
short. `note` is never part of the meaning; use it only to flag a choice you were unsure of (notes are counted).

## Conflicts

When two statements in your section contradict each other (two formulas for one metric, two defaults that
cannot both hold), keep both and add `{statements: [ids], reason}` to `conflicts`. When the text itself says two
things conflict ("this does not match the figure above"), also quote that sentence in a `Caveat` on the element they
disagree about.

## Linking across sources

Each source is expressed on its own, so the same thing in two sources has two ids (`c.active_customer` in a
metrics handbook and in an access policy). Linking them is a step of its own, once both are expressed: a linking
document lists the sources it links in `linked_sources` (`{prefix, base_iri}`, the prefix standing for that
source's base IRI) and refers to their elements as `prefix:id`. Each link is a `Mapping` with its `match` and
`justification`, quoting the words in the sources that show the match (check it with `--source` naming each source's
text). An agent may propose links (`proposed_by`, `decision_status: proposed`); a person decides them
(`decided_by`, `decided_on`, `decision_status: decided`). Only a decided exact match becomes a `same_as` fact in the
graph. A prefix may not be one the graph already uses: bcs, linkml, odrl, org, skos, prov, dcat, dqv, oa, dcterms.

## Before you finish

Run the checker and fix everything it reports:

```
uv run python -m bigcontext_schema.check <your document>.yaml --source <the source text file>
```
