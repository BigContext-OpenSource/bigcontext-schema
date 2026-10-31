<!-- serves: F-056 — Express any context in BigContext Schema -->
# Expressing a text in BigContext Schema

This guide is for anyone, person or AI agent, who turns a source text into a BigContext Schema document.
**Faithfulness beats coverage.** If something does not fit, record it as `unmapped` with the statement type you
would have needed. Never bend a statement type to make it fit, and never invent content the text does not say.

The schema is `bigcontext_schema.yaml` (LinkML), beside this guide. This guide explains how to use it.

## What you produce

One YAML file, a `ContextDocument`:

```yaml
schema_version: "1.1.0"   # the version of BigContext Schema this document follows
source: {id: <corpus id>, title: <title>, as_of: <the date the source is true as of, if it says>}
revisions: [...]     # the source's own change history: {version, date, revised_by, summary, evidence}
external: [...]      # ids you refer to that another section of the same source declares (see Ids)
linked_sources: [...] # other sources you link into: {prefix, base_iri} (see Linking across sources)
things: [...]        # named individuals: people, teams, units, posts, organizations, agents, systems, tables, fields, channels
concepts: [...]      # business words and categories: customer, revenue, approved refund, Express, store manager
statements: [...]    # one claim each; the predicate is the statement type
procedures: [...]    # ordered steps, as instructions (do this) or descriptions (how work happens)
conflicts: [...]     # statements that contradict each other: {statements: [ids], why}
unmapped: [...]      # claims BigContext Schema could not express: {evidence, proposed_predicate, why}
skipped: [...]       # text with nothing to express: headings, formatting, metadata, navigation, logs
extensions: {...}    # fields of your own, keys prefix:name (see Fields of your own)
```

**Nothing is dropped.** Every non-blank line of the text should be accounted for by the evidence of something: a
thing, concept, statement, step, unmapped item or skipped item.

## Evidence

Every statement, step, unmapped and skipped item written from a text needs `evidence: [{quote: "..."}]`; things and
concepts should have one too. A quote is never empty. Context someone states directly, with no text to quote (a rule
typed into a product, a decision an agent records), gives `stated_by` instead: the person, team or system that
stated it (for a procedure, on the procedure). Every statement has one or the other. The quote must be copied
**word for word** from the source (white space, curly versus straight quotes, long dashes versus hyphens and
no-break spaces are forgiven, nothing else). Quote the part each claim comes from: a long paragraph is usually quoted
sentence by sentence across several statements. A quote may run across several lines. Several statements may
share one quote when one sentence makes several claims.

**Always put quotes and other text in double quotes.** In YAML, a `#` after unquoted text starts a comment and
silently cuts the rest off; the checker rejects that.

A sentence that only adds colour to a statement next to it ("A parcel is anything we ship. Parcels vary a lot in
size.") adds its quote to that statement's evidence, and its words to the statement's text when it has one; it is
not unmapped.

Headings: a heading that names what follows can be the evidence of that concept; a block title that limits the
statements under it is their `scope`; other headings are `skipped`.

## Ids

- Concepts `c.<slug>`, things `t.<slug>`, procedures `p.<slug>`, slugs in lower case with underscores, made from
  the label: `c.approved_refund`, `t.acme`, `p.order_tracking`. Other sections use the same
  convention, so the same slug means the same element across files. Reuse the obvious slug. When two names would make
  the same id (they differ only in case, as the columns "orderId" and "OrderID", or in characters a slug drops), each
  keeps its own capitals: `t.shop.items.orderId`, `t.shop.items.OrderID`.
- Tables and views: `t.<schema>.<table>`, dropping any database or project prefix. If the schema is not given but
  the same table is described elsewhere in the source with its schema, use that id; otherwise `t.table.<table>`.
- Fields: `t.<schema>.<table>.<field>` when the table is known, otherwise `t.field.<field>`. Never guess.
- Statements `s.<SECTION>.<n>`; steps `<procedure id>.<SECTION>.<n>`. `<SECTION>` names the part of the text a
  file covers, so ids stay unique when a long text is split across several files.
- Declare every thing and concept you refer to in your own file. The exception: a statement or procedure that
  another section declares (a rule you override, a procedure you call) goes in `external` instead. So does what
  your lines say about text the other sections hold ("the steps below", "the rest of these instructions"): refer to
  the procedure those lines belong to by its id (`p.<slug>`, which every section makes the same way) and list it in
  `external`, or to a rule set by the concept that names it (its `subject`).

## Thing and concept types

Things: person, team, unit (an office, division or department inside an organization), post (a position people
hold or rotate through: "Director, Office of Federal Activities", "Engineer On Call"), organization, agent,
system, data_container (database, project, schema, dataset), data_product (a curated, owned set of data assets
offered for named uses), table, view, field, access_group (a group,
database role, IAM role or policy tag that grants access), meeting (a meeting or other dated event), document,
tool, channel (a Slack channel, a mailing list), place, product, other. A generic post ("a Director") is one post per office it
heads, with `HoldsRole` from the post to the role concept.

Concepts: entity_type, metric, dimension, segment, category_value, state, role, activity (a kind of work,
analysis or question: the use case a pattern or procedure serves), area, calendar, period, party_attribute
(something about whoever is acting, filled in when a rule is checked: see conditions), term, other.

## Statement types (the predicate) and when to use each

Meaning
- `Definition`: what a term or a named thing is, in words. `subject`, `text`, optional `object` (its category).
  A table's "Role:" line is a Definition of the table, and a line saying what a document is or does ("This policy
  sets who may see which data") is a Definition of the document.
- `Overlaps`: two roles or kinds the same individual can be at once ("the buyer is often also the recipient":
  `frequency: often`). Neither is a kind of the other; that would be `IsA`.
- `IsA`: X is a Y. Putting something in a level or category the source names ("customer emails are Restricted",
  "this is a Sev2 incident") is `IsA` that category; `HasProperty` is only for literal values. `SynonymOf`: another
  word for an element (`term`, `subject`, `usage` always | sometimes | abbreviation | former; use `frequency` for
  "usually" or "often").
- `Groups`: a named group made of members (a data product's tables, a region's countries, or several values that
  together match another: see `Mapping`). `HasValues`: the values a field or dimension takes ("segments are Enterprise,
  Mid-market and SMB"; `values` literals and/or `members` concepts). The people, teams or posts that make up a team or
  body are `MemberOf` it, one statement each. A group a field divides into parts ("returns are divided by reason into
  damaged and unwanted") is `Groups` with the parts as `members`, named as the text names them, and the field in
  `divided_by`; when the text lists the field's values themselves, they are `HasValues` on the field. Groups and HasValues take `complete`: true when the text says the list is
  complete, false when it says "such as", "including" or "etc."
- `ComputedAs`: how something is calculated: `expression`, `inputs`, `values` (weights, thresholds: each with
  `value_role`, `comparator`, `applies_to`), and `cases` for step-wise scoring ("orders over $100 earn 10 points": one case
  per row, `{when, result}`).
- `Sequence`: items in order: funnel | levels | derivation | lifecycle | format, optional `complete`.
- `HasProperty`: a literal value (`property_value`) for an attribute **that no other statement type covers**. Use
  `standard_attribute` when one fits: row_count, distinct_count, null_rate, minimum, maximum, data_type, format,
  unit, time_zone, freshness, retention, aggregation (how a stored column is combined; a metric's aggregation is
  its ComputedAs), sensitivity, response_time, location, address, headcount,
  start, duration (of an element that is itself a period or phase: "the freeze starts on 1 December"), web_address.
  Only otherwise name an `attribute` concept. Grain, coverage and status have their own types below.
- `UsedFor`: what something is for (`negated: true` for "not for").

Rules
- `Rule`: a norm. `modality`; `action`; `when` (all must hold), `when_any` (any one is enough), `unless`,
  `even_if`, `because`, `so_that`; `overrides`; `binds` (who must comply, when not the reader); `absolute: true`
  for a rule nothing may override ("no exceptions", "whatever else applies").
- `RuleSet`: a named group of rules sharing a scope, strength or precedence ("Privacy Rules, which override
  team guidelines"). `subject` the concept that names it, `members` the rule ids when the text lists them (give at
  least one of the two), `overrides`, `absolute`. Write the precedence once here.

  Strength, decided by the words used:

  | Text says | modality |
  |---|---|
  | must, shall, always, required, mandatory, will (in an instruction), a plain instruction ("use X for Y") | `must` |
  | we pledge to, we commit to, is committed to, we will (an organization promising its readers) | `must`, binding the organization: a promise is a duty it takes on, never `unmapped` |
  | it is your responsibility to ensure, you are responsible for (said to the reader) | `must` |
  | never, do not, must not, banned, not allowed, not permitted, prohibited, is not acceptable | `must_not` |
  | should, prefer, it is better to, can and should, generally/typically + an instruction | `should` |
  | is expected to, we ask that, please, we recommend, useful (of things to use) | `should` |
  | is encouraged to, shall work to, aims to, strives to, ideally, is intended to, we'd like to (an aim, not a duty) | `should` |
  | it is important to, it is critical to | `should`, with `importance: high` |
  | avoid, should not, rather not | `should_not` |
  | can, may, is acceptable, feel empowered to, should be free to (a permission) | `may` |
  | may, can, might, possibly (it might happen, not a permission) | no strength: write the fact with `certainty: possible` |
  | will, is (describing what a role or system does, not telling anyone to) | no strength: write the fact (`ResponsibleFor`, `Triggers`, `Transition`, `Habit`) |
  | need not, does not have to, is not required | `need_not` |
  | by default, default to, unless told otherwise, assume | `by_default` |
  | **only** do X when Y / X **only** if Y (only limits when the act is allowed) | `must_not` X, `unless` Y (not `must`) |
  | check with, consult or clear it with Y **before** X ("clear any discount with Finance before you quote it") | `must_not` X, `unless` checked with Y (`about` Y), as for an approval (not `must` check, `when` before X) |
  | **only** these may do X ("only managers may approve") | `may`, with `exclusive: true` when the parties are named; when they are defined by a responsibility for what is acted on ("only the metric's owner may change it"), `must_not` X `unless` a condition with `party_responsibility`; "only through the tool" or "only for fraud checks" is `must_not` X `unless` through or for it |
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
  `{value: "2/3", value_role: threshold, comparator: at_least, unit: "of votes cast"}`. A consequence with no one named as acting ("they are removed", "the council
  is dissolved", "it is moved out automatically") is a `Transition` to the new state with `automatic: true` when
  the text says it happens by itself; never invent who does it. Which source wins over another ("the finance team's formula is the one that runs"; "the payments system is the source of truth for refunds"; "tax filings use the ledger") is a
  `Rule` to use one source, with the purpose it is for ("fiscal revenue", "tax filings") in `scope`, not `when`,
  and `overrides` when it names the rule or source it beats.

Actions (in rules, steps and triggers): `verb` from the closed list (the class), `specific_verb` with the text's
own verb when it is more specific (page, recommend, deduplicate, invite, merge), `objects`, `by` (breakdown
dimensions only: "spend by channel"; never who acts), `via` (channel, tool or intermediary), `to` (recipient or destination),
`values`, `options_in_order`, `alternatives` (either/or, each with its own `when`), `then` (actions that follow in
the same instruction: "stop and ask"; "cap the values before averaging" is cap, then average), and `detail` only
for what the rest cannot carry. "Not summed across regions" is not `by`: it is `non_additive` on the metric (see
metric definitions).

Company structure
- `PartOf` (transitive; `complete` when the text says "consists of"), `MemberOf` (`role`), `HoldsRole`,
  `ReportsTo` (transitive; `direct`), `HasAccess` (`access` admin | read | none | masked | use | granted, when
  the text does not say what kind). Who can see, read or use a resource is `HasAccess`, also when the text says
  "may access" or "may see"; a `Rule` with `may` is permission for another act (grant, export, approve). Access to
  only some rows ("store managers see only their own store's orders") is the HasAccess with those rows in `filters`
  (see conditions on whoever is acting), so who has access stays a plain fact. A post
  inside a team or unit (the Release Team's Enhancements Lead) is `PartOf` it; people are `MemberOf` their teams.
- `Heads`: a person or post heads a unit, team or organization. This is a structure link, like `ReportsTo`;
  use it for "headed by", "under the direction of", "head of". Use `ResponsibleFor` for other duties.
- `ResponsibleFor`: `responsibility` owns | manages | accountable | responsible | performs | approves |
  decides | supervises | coordinates | reviews | advises | assists | consulted | kept_informed (RACI's C and I:
  asked before, told after: a standing part in a piece of work; "consult Legal before you send it", a precondition
  for one act, is a Rule, as in the strength table); `object` or `text`; `answers_to` for "responsible to X for Y".
- `Appoints` (`with_consent_of`), `EscalatesTo` (an escalation path, not a reporting line; `via`, `when`; a path in
  order, "first #help, then the on-call engineer", is a chain: the problem escalates to #help, and #help to on-call),
  `WorksWith` (coordinates, liaises, works closely with; `text` the topic), `Represents` (`audience`),
  `Serves` (places or populations a unit serves), `GovernedBy` (a law, policy, agreement or document).

Lifecycles and behaviour
- `Transition`: `subject` what changes state, `from_state`, `to_state` (state concepts), `when`, `performer`.
  A lifecycle the text gives only as an order of states ("draft, then in review, then published") is a `Sequence`
  with `sequence_type: lifecycle`; a change of state the text says more about (a condition, a performer, an
  automatic move) is a `Transition`.
- `Triggers`: when something happens (`when`), a system or party does something automatically (`action`). Not a
  norm.
- `Habit`: what a party usually does, described rather than required ("wholesale buyers usually order by phone":
  `subject`, `action`, `frequency: usually`); leave `subject` out when the text means people in general. The usual
  breakdowns of an analysis ("sales are often looked at by region and by device") are a `Habit` whose action is
  `analyze` with the breakdowns in its `by`. What people ask about is a `Habit` whose action is `ask`, with what they
  ask about in `objects` ("most shoppers ask about delivery dates": `quantifier: most`; "less often, the refund date":
  `frequency: sometimes`). A norm is a `Rule`.

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
- `HasGrain`: what one row stands for (`text`, `members` when named). `IdentifiedBy`: a unique key; `primary: false`
  for another key that also identifies it (email beside customer_id), and `stable: false` when the key can change.
- `Covers`: which platforms, populations or places a table or system covers (`members`, `complete` for "only"),
  for which period (`period`; in a document that follows 1.0, `valid_from` and `valid_to` give it);
  `primary: true` when it is the source of truth for them.
- `HasStatus`: canonical | variant | alias | broken | deprecated | retired | certified (approved by its owner as
  trusted to use; the subject can be a table or a `JoinsTo` statement, for "the join from orders to invoices is
  certified"). A status is about an element or a definition; whether a statement was proposed or adopted is its
  `decision_status`, not a status. `canonical` picks one definition among several; `primary: true` marks the main
  representation (ImplementedBy), the source of truth (Covers) or the main key (IdentifiedBy).
- `DerivedFrom`, `Has` (cardinality one_to_many | many_to_one | one_to_one | many_to_many | exactly_one |
  one_or_more | more_than_one | zero_or_more: a count for each subject, or a pair value when the text gives both
  directions ("orders and invoices match one to one"); "can have" is zero_or_more, "more than one" is more_than_one), `Caveat` (`object` for a second element it concerns). A known problem a reader must
  allow for is one Caveat with its cause in its text, even when it names a behaviour ("the feed sometimes sends
  rows twice, which causes duplicates").
- `JoinsTo` join_type: none for an ordinary (inner) join, `left`, `semi` (keeps the rows of the first that have a
  match, adding no columns) or `anti` (keeps the rows of the first that have none: "customers with no order"); record
  another as unmapped. Its `cardinality` takes the pair values (one_to_one, one_to_many, many_to_one, many_to_many)
  and is what the data has; `expected_cardinality` is what it should be when the text says the data breaks it
  ("should be one to one, but split payments create duplicates": one_to_many, expected one_to_one).
  A key pair's `normalize` says what is done to both columns before they are compared (`trim`, `ignore_case`,
  `cast_to_text` or `cast_to_number`, always in that order); `keys` is for plain equalities written as text, never for
  what `normalize` says. `role` names the
  part the joined table plays when it is joined more than once ("the buyer" and "the recipient", both customers).
- `RecordMatch`: when records count as the same individual, within one table or across two ("a shop customer and a
  newsletter contact count as one customer when their lowercased emails match"): `subject`, `object`, `key_pairs`
  for the columns compared (with `normalize: [ignore_case]` for "lowercased"), `expression` for a rule key pairs cannot
  say (a similarity function), and outcomes by score in `cases` ("at least 0.9: merge; 0.8 to 0.9: send for
  review"). An exact `Mapping` between two tables says they mean the same, not that their records match.
  Which value the merged record keeps is a `Rule` with `options_in_order` (the newsletter phone, else the shop's) or
  a `ComputedAs` with aggregation last (the latest address).

Belief, patterns, gaps and examples
- `Indicates` (pattern in `when`, with its thresholds in that condition's `values`; conclusion in `text`; `subject`
  what the conclusion is about), `Influences` (`direction`). Two measures that move together where the text does
  not say one causes the other ("basket size tends to rise with product views") are `CorrelatesWith` (`direction`
  increases when they rise together, decreases when one falls as the other rises), never `Influences`.
- `Template`: a reusable pattern (a sample query, a message or report outline) **linked to its use case**:
  `subject` the use case (an activity concept or a procedure), `text` the pattern as given, `inputs` the
  tables, fields, metrics and joins it uses, `outputs` what it produces, `values` its placeholders (`value_role:
  parameter`) and its one-off sample values (`value_role: example`), `when` the situation it is for. An instruction to use
  it ("Use this query for ...") is also a `Rule` (must use) with the Template's id in its action's `objects`. Use
  `Example` only for an illustration that is not meant to be reused.
- `Gap`: something missing, unknown or future work.
- `CreatedBy`: who created, founded or wrote something ("the project was started by Guido", "PEP 8016, written
  by Nathaniel Smith and Donald Stufft"): `object` the creator, `members` when several, `text` for unnamed ones.
- `DescribedIn`: where something is described in full when the text only points there ("the process is described
  in PEP 8000", "see the cherry-pick process"): `object` the document, page or section.

A sequence of levels (`Sequence` with `sequence_type: levels`) keeps the order the text gives (a ladder numbered from
mildest stays mildest first). "Including X" widens what the statement is about: add X to its objects or members, never
to `even_if`. Dates in `valid_from`, `valid_to`, `as_of`, `recorded_on`, `decided_on`, `ratified_on`, a period's
`start` and `end`, and the source's `created`, `modified` and `reviewed` are ISO dates: "October 2027" is `2027-10`, "31 October
2027" is `2027-10-31`; the quote keeps the text's own words. A former holder or member the text names without dates
("emeritus", "former", "previously") is the statement with `currently: false`. A state that may end in one of several
ways ("deleted, aggregated or de-identified") is a `Transition` with `to_state` the first and `alternative_states` the
others. A web address is `HasProperty` with `standard_attribute: web_address`. A source's own metadata
line ("Status: Active", "Created: 2018-12-16") goes in `source` when it gives the source's date or version: "Last
updated" in `modified`, "Last reviewed" in `reviewed`, "Created" in `created`, "as of" dates in `as_of`, a version number in
`version`. An "Effective" date is when the statements start to hold: give it as `valid_from` on the statements it
governs. The `source` block holds no quote, so list that line in `skipped` with `reason: metadata` as well. An
"Owner:" line is a claim: `ResponsibleFor` with `responsibility: owns` from the owner to the document (a thing with
`thing_type: document`). An "Approved by X on DATE" line is a `revisions` entry (`revised_by`, `date`). Other metadata lines
are `skipped` as metadata.

## Metric and join definitions that can run

When the text defines a metric or a join precisely enough to run, also give the computable fields, so the
definition can be exported to a semantic layer:

- `ComputedAs` on a metric: `aggregation` (sum, count, count_distinct, average, min, max, median, percentile,
  sum_boolean, `first`, `last`: first and last take the earliest or latest value in time order, as in first-touch and
  last-touch attribution) over `expression` on the `base` table; `metric_type` simple | ratio | derived | cumulative |
  conversion; `numerator` and `denominator` for a ratio (concepts of their own even when the text names only the
  ratio: "refunds per 100 orders" divides refunds by orders); `inputs` for a derived metric; `time_dimension`; `filters`
  as conditions that give `field`, `comparator` and `values` (`ORDER_STATUS != 'Cancelled'`); `dialect` of the
  expression; `reporting_grain` when the text says what grain it is reported at ("daily sales").
- A rolling or to-date metric is `cumulative`: its input's aggregation applied over a trailing window, a value with
  `value_role: window` ("distinct visitors over the last 7 days": 7 days, distinct over the 7 days, not a sum of daily
  counts), or from the start of a grain, `grain_to_date` ("sales year to date": year), not both; `inputs` names the
  metric it is taken from. When its grains follow a calendar other than the ordinary one ("fiscal year to date"),
  `calendar` names that calendar (a concept of type calendar); an export that only knows the ordinary calendar
  reports such a metric instead of writing it.
- A comparison with an earlier period is two metrics: the earlier one is a `derived` ComputedAs with one input and a
  value with `value_role: offset` ("sales the same week last year": 1 year, `unit` "year" or "fiscal year"), and the
  comparison is a `derived` metric over both.
- A conversion metric ("the share of carts that become orders within 2 days") is `conversion`: `numerator` the
  converting count and `denominator` the starting count (both counts, both required), `entity` the kind of thing it
  follows (the cart), and its window a value with `value_role: window`. "Sales per customer" is a ratio, not a
  conversion. A text often names only the share: its two counts are then metric concepts of their own, named from
  its words (carts started; carts ordered within 2 days), with a ComputedAs each when the text says how they are
  counted. Counts the text only implies are never a reason to write the metric in words.
- A stored measure that must not be summed across a dimension is `non_additive`: `across` the dimensions (left out
  for "across any", as for a pre-counted number of distinct visitors), `take` which value to keep when the text says
  ("stock is the last count of each day": last), `per` what it is kept for (each warehouse). A count_distinct needs
  nothing: it is never summed.
- A percentile is `aggregation: percentile` (interpolated) or `percentile_discrete` (always one of the values), with
  its level as a value with `value_role: percentile` between 0 and 1 ("the 95th percentile": 0.95). "The median and
  the 90th percentile of days to deliver" is two metrics over the same amount (days from order to delivery, the
  `expression`, in words when the text gives no formula), even when the text names neither as a metric.
- What an empty period shows ("days with no sales show 0") is a value with `value_role: default`.
- An attribute taken from the first or last of several rows ("a visit's channel is the channel of its first page
  view", "an order's status is its latest status") is a `ComputedAs` on that attribute (a dimension concept) with
  `aggregation` first or last, even when the text gives no full formula.
- `JoinsTo`: `key_pairs` that point at the column elements (`from_field`, `to_field`), not only key text. A join the
  text forbids ("never join on email") is not a JoinsTo, which would read as a usable path: it is a `Rule`
  `must_not` join with the key fields as `objects`.
- `Contains`: `data_role` dimension | time_dimension | measure, with `time_grain` for a time dimension.
- A table's or column's name in its system goes in the thing's `physical_name`: a table's full path
  (`acme-prod.shop.fact_orders`), a column's own name. Write each part exactly as the system stores it; a part that is
  case-sensitive or holds spaces or other special characters goes in double quotes, the SQL standard's form
  (`"Sales"."Order Items"`, a column `"Order Date"`), with a double quote inside it doubled. The id stays a slug, and
  the label is the name without its quotes (Order Date). A semantic layer that keeps quoting in its own settings (dbt)
  cannot say a name is only case-sensitive, so such a name read from it comes back unquoted.
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
  with `access: use`), when it must or must not be used (`Rule`), and sample calls
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
  Assistant Administrator") names the class and has `each: true`; one about only some of them ("some customers
  pay by invoice") has `quantifier` instead. An open question is a `Gap`; a statement that
  answers it lists the Gap's id in `answers`.
- **Meetings**: who attended is `MemberOf` from the person to the meeting with `role` an attendee, regrets or
  absent concept. A renaming is `SynonymOf` with `usage: former` and `valid_to`; a reorganization is the old and
  new `PartOf`, `ReportsTo` or `Heads` with their dates, the new one `supersedes` the old.
- **Assignment group**, on roles, memberships, reporting lines, headship and responsibilities: `capacity`
  substantive | acting | interim | primary | backup | delegate, `acting_for` (whom an acting holder stands in
  for), `line` solid | dotted (a dotted line is not followed when walking the chart), `share` (a value: 50%),
  `cadence` for a rotation ("every two weeks, from Friday 17:00"; the people who rotate each hold the post).
- **Snapshot**: the source's `as_of` date applies to every statement that gives none of `as_of`, `valid_from` and
  `valid_to`; how the dates differ is under "Five dates" below.
- **Service and scope**: `within` (a time limit: "answer within 4 business hours"), `via` (the channel or tool a
  party is reached through), `exclusive: true` for only these parties (see the strength table), `scope` for what the
  statement is limited to: a party in a rule's scope is one it binds, as `binds` would say; prefer `binds`.

## Qualifiers every statement can carry

`when`, `when_any`, `unless`, `even_if`, `especially_when` ("especially if", "particularly when": it holds most then,
and also without it), `because`, `so_that` (lists of `{description, about}`), `scope` (never a period: that is
`period`),
`frequency` always | usually | often | sometimes | rarely (how often), `quantifier` most | some | few (how many
members of a class it holds for, when not every one: "some customers", "most shoppers"; every one is `each`; a named
kind of a class, "wholesale buyers are customers", is `IsA` from the kind to the class), `certainty` stated |
likely | possible | estimated, `importance` critical | high ("above all", "the most important
check", "pay close attention to"), `negated`, `currently` ("right now", "currently"), `valid_from`,
`valid_to`, `valid_while` ("for the duration of the incident": a named period or state the statement holds through,
such as "during the freeze" or "while Jo is on leave"; a recurring window, "during business hours", is a `when`;
a list, like the other conditions), `stated_by` (a list), `period` and `recorded_on` (below).

Five dates say different things. `valid_from` and `valid_to` say when the statement holds. `period` says what
stretch of data or business time it is about: the days data is missing ("order data is missing from 1 to 3 June":
`period: {start: 2026-06-01, end: 2026-06-03}`), the quarter a target is for, the years a table covers; give
`start`, `end` (its last day) or `named`, a concept of type period for one the text names without dates ("Q3",
"the holiday season"). A caveat about early June still holds in July. `as_of` says when what it describes was
observed (a snapshot; a statement true as of a different date than the source's carries its own). `recorded_on` says when the fact or figure was recorded or restated ("Q1 sales were restated on 10 May":
the new figure with `recorded_on` and `supersedes` the old). `decided_on` says when a decision was made.

Conditions on another field or on whoever is acting: a condition that compares its `field` with something other
than a written value gives `compare_to` instead of `values` (never both), with `comparator`. It may name another
column (an order's ship country with the customer's country) or a party attribute: a concept of type
`party_attribute`, something about whoever is acting when the rule is checked, filled in then (the viewer's store,
their tenant, who they are). Say where it comes from with `ImplementedBy` to the column that holds it. Row access:
`filters: [{field: orders.store_id, comparator: equal, compare_to: c.viewer_store}]` on the HasAccess. Separation of
duties ("whoever requests a refund may not approve it"): a Rule `must_not` approve `when: [{field:
refunds.requested_by, comparator: equal, compare_to: c.acting_person}]`. A limit for each of something ("no more than
3 refunds per customer per calendar month") gives the value `per` (the customer and a calendar-month concept of type
period); a count of different individuals ("two different managers") gives it `distinct: true`. A responsibility
whoever is acting must hold ("only the metric's owner may change it") is a condition with `party_responsibility:
owns` and no values or compare_to, in a Rule's `when` or `unless`. It is held for what the rule acts on, or, with
`field`, for the element that column names on the row. Whoever is acting holds it when a ResponsibleFor in force
gives it to them, to a post they hold or to a team they belong to (graph.md). "Changes stay proposed until the
metric's owner approves them" is two rules: a change `must_not` be adopted `unless` it is approved (`about` the
approved state), and a change `must_not` be approved `unless` `{field: metric_changes.metric_id,
party_responsibility: owns}`: whoever approves owns the metric the change is about.

A threshold in a condition ("if returns rise by more than 10%", "orders over $50") is a value in the condition's
`values` that carries its own comparison: `{value: "10", datatype: percent, value_role: threshold, comparator: more_than}`.
`value` is the number alone; its kind goes in `datatype` (percent, number) and anything else in `unit` ("USD", "of
votes cast"). The condition's own `comparator` is only for a data filter, with `field`. A condition on a measured amount names what it
measures in `about`: a metric concept ("returns", "p-value", "week-over-week change in orders"), with its
`ComputedAs` when the text says how it is calculated; a condition that something is in a state or category ("the
incident is Sev1", "the data is late") names that state concept. A time since an event ("after 7 days") needs
neither. This is what lets a rule's condition be checked against data.

Amounts follow one rule: `value_role` says the part a value plays, and `comparator` how it is compared. In a
condition the value is a `threshold` with its comparator ("orders over $50": more_than; "at least two managers":
at_least). On an action it is the `minimum` or `maximum` the action must reach or stay within ("keep the page up for
at least 30 days", "keep each reply to 200 words or fewer"), with no comparator when the amount itself counts and
more_than or less_than when it does not ("more than 3 days", "under $500"). A cap on how much or how often something
may happen ("spend no more than $500", "no more than 3 refunds per customer a month") is a prohibition, not a duty:
`must_not` the act, with the amount it may not pass as a `threshold` with `comparator: more_than`, `per` what it is
counted for, and the recipient in `to`. A data-quality expectation ("the null rate of EMAIL should stay at most 1%",
"SKU must be unique") is a `Rule` with the strength its words give, `verb: check`, the table or field in `objects`,
what is checked in `detail`, and its tolerance as a value with `value_role` minimum or maximum; a join's expected
cardinality is its `expected_cardinality` instead.

## Fields of your own, and the document's address

`schema_version` is required: the version of BigContext Schema the document follows. A company that needs a field
the standard does not have puts it under `extensions`, on the document or on any thing, concept, statement or
step, with a key that starts with a prefix it owns: `extensions: {acme:priority: high}`. Readers keep extensions
and may ignore them; they never change what the rest of the document means, so use them only for what the standard
cannot say (and propose it as an enhancement). The source may give `base_iri`, the web address its ids are joined to
in a knowledge graph (`https://acme.example/context/policy/`); leave it out unless the text or your organization
gives one.

## Procedures

When the text gives steps, make a `procedure`: `mode` instruction | description, optional `modality`, `goal`,
`performer`, `trigger`, `scope`, `when`, `unless`, `because`, `so_that`, `inputs`, `outputs`, `steps`. Each step:
`order` (1, 2, 3 within your file), `source_label` (the text's own number or letter: "3a", "4."), optional
`modality`, `action`, `performer` (a list: who does it, several when they do it together), `automatic` (a system does it), `when`, `when_any`, `unless`,
`even_if`, `because`, `so_that`, `next`, `branches` (`{when, go_to}` or `{when, outcome}`), `calls`, `consumes`,
`produces`, `evidence`. A step that runs a sample query has the `Template` statement's id in its action's
`objects`. If a procedure continues from or into another section, use the same procedure id; fragments are
joined later. One instruction that gives different actions for different cases ("for a refund, approve it within a
day; for an exchange, log it") is one step per case, each with its own `when` and `within`, sharing the text's
`source_label`.

## Free text

Free text is allowed only in: `Definition.text`, `UsedFor.text`, `Indicates.text`, `Gap.text`, `Example.text`,
`Template.text`, `Caveat.text`, `DerivedFrom.text`, `Influences.text`, `ResponsibleFor.text`, `WorksWith.text`,
`GovernedBy.text`, `HasGrain.text`, `CorrelatesWith.text`, `CreatedBy.text`, `DescribedIn.text`, `ComputedAs.expression`,
`ImplementedBy.expression`, `RecordMatch.expression`, `Mapping.justification`, `Condition.description`, `Action.detail`,
`Action.specific_verb`, `due_by`, `recurrence`, `cadence`, `goal` and `note`. Keep conditions and details
short. `note` is never part of the meaning; use it only to flag a choice you were unsure of (notes are counted).

## Conflicts

When two statements in your section contradict each other (two formulas for one metric, two defaults that
cannot both hold), keep both and add `{statements: [ids], why}` to `conflicts`. When the text itself says two
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

Check the document against the JSON Schema and the rules in `conformance.md`, and fix everything that fails. The
free BigContext Schema tools (coming soon) do this with `bigcontext-schema check <document>.yaml --source <text file>`.
