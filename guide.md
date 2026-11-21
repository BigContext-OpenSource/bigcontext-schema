<!-- serves: F-056 — Express any context in BigContext Schema -->
# Expressing a text in BigContext Schema

This guide is for anyone, person or AI agent, who turns a source text into a BigContext Schema document.
**Faithfulness beats coverage.** If something does not fit, record it as `unmapped` with the statement type you
would have needed. Never bend a statement type to make it fit, and never invent content the text does not say.
When only part of a sentence fits, write the statement with what fits, keep the rest in its words (a condition's
`description`, the statement's `text`), and record that part as `unmapped` too: its quote, the field you would have
needed, and why ("the data product's owner": a party named through another element).

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
- A label is a name: the name the text gives the element, or, when the text describes it and gives it no name, a
  short name of your own, the words of its id (`c.order_value`: order value). It is never a formula or a condition:
  for "Sales is AMOUNT minus DISCOUNT_AMOUNT for each order shipped in the week, less the value of items sent back",
  the first part is `c.order_value`, labelled "order value", with the text's phrase "AMOUNT minus DISCOUNT_AMOUNT for
  each order shipped in the week" in `aliases` and as its evidence, and `AMOUNT - DISCOUNT_AMOUNT` in its
  definition's `expression`. A label the text does not hold is a name its writer gave: a reader may show it as such,
  and the people who own the context may rename it.
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
tool, channel (a Slack channel, a mailing list), job (a pipeline, a dbt job, a load), report (a report or dashboard people
read), `ml_model` (a statistical or machine-learning model: a churn model, a demand forecast; a dbt model is a table or
view), place, product, other. An environment (dev, staging, prod) is a data_container; a table kept in several is one
thing per copy, each `PartOf` its environment, with its own `physical_name`. A generic post ("a Director") is one post per office it
heads, with `HoldsRole` from the post to the role concept.

Concepts: entity_type, metric, dimension, segment, category_value, state, role, activity (a kind of work,
analysis or question: the use case a pattern or procedure serves; also something an organization does to change an
outcome, "a promotion", "free shipping", whose effect is an `Influences` from it), `event` (a kind of event that happens or is
recorded: "Order Completed", "a payment is captured"; a status or stage is a state), area, calendar, period, party_attribute
(something about whoever is acting, filled in when a rule is checked: see conditions), term, other.

## Statement types (the predicate) and when to use each

Meaning
- `Definition`: what a term or a named thing is, in words. `subject`, `text`, optional `object` (its category).
  A table's "Role:" line is a Definition of the table, and a line saying what a document is or does ("This policy
  sets who may see which data") is a Definition of the document.
- `Overlaps`: two roles or kinds the same individual can be at once ("the buyer is often also the recipient":
  `frequency: often`). Neither is a kind of the other; that would be `IsA`.
- `IsA`: X is a Y. Putting something in a level or category the source names ("customer emails are Restricted",
  "this is a P2 issue") is `IsA` that category; `HasProperty` is only for literal values. `SynonymOf`: another
  word for an element (`term`, `subject`, `usage` always | sometimes | abbreviation | former; use `frequency` for
  "usually" or "often"; `language`, a BCP 47 tag, for a word in another language: "Umsatz is the German word for
  revenue", `language: de`). A source written in one language gives it on `source.language`.
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
  From 1.4: a system's `platform` (PostgreSQL), its `environment` (production, test) and its `credential_ref`, where
  the secret that gives access is kept (a name in a secret store; never write the secret); the `external_id`
  something has in another system (a person's id in the directory); whether a field is `nullable` and whether a tool
  or a job is `idempotent`, doing it again changes nothing more (each `value: "true"` or `"false"`, in quotes); the
  `version` of a model, a tool, a document or a calendar; a tool's `side_effect`, what using it changes, in the
  text's words, and its `timeout` (`{value: "30", unit: seconds}`); the `schedule` a job or a refresh runs on, in the
  text's words; a document's `language`, as a tag (en), and the `digest` of its content (sha256:9f2c1ab4); and the
  `null_handling` of a metric or a dimension, how empty values are treated when it is computed.
  A calendar concept's settings are `year_start` (in the text's words: "the Sunday nearest 1 February"),
  `week_start` (the day, in English: Monday), `week_pattern` (4-4-5, 4-5-4 or 5-4-4) and `day_start` (when a business day starts, HH:MM:
  "a sales day runs from 04:00", with its zone a time_zone property; in YAML write the time in quotes, `value: "10:00"`, since
  YAML reads 10:00 without quotes as the number 600). A unit that differs by row is the value's
  `unit_from`, the column that holds it ("amount is in the currency given by currency_code": `standard_attribute: unit`,
  `property_value: {value: currency, unit_from: t.shop.orders.currency_code}`); in a threshold the value keeps its
  amount. A currency the text names is its ISO 4217 code (US dollars: USD); a unit the text leaves vague stays its words.
  How a metric's numbers are written is its `format`, as a number pattern: `0` or `#,##0` (with thousands
  separators) for the whole part, `.` and one `0` for each decimal shown, `%` at the end for a percentage (the value
  times 100), a currency sign or code before it when one is shown ("show gross margin as a percentage with one
  decimal": `subject: c.gross_margin`, `standard_attribute: format`, `property_value: {value: "0.0%"}`; whole dollars
  with separators: `"$#,##0"`). A sentence that makes it a duty ("always show it as...") is also a `Rule` with the
  verb show; the format is the field a tool applies, and both quote the sentence.
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
  | check with, consult or clear it with Y **before** X ("clear any discount with Finance before you quote it") | `must_not` X, `unless` checked with Y (`about` Y and the state the check gives, a concept of `concept_type: state`), as for an approval (not `must` check, `when` before X) |
  | **only** these may do X ("only managers may approve") | `may`, with `exclusive: true` when the parties are named; when they are defined by a responsibility for what is acted on ("only the metric's owner may change it"), `must_not` X `unless` a condition with `party_responsibility`; "only through the tool" or "only for fraud checks" is `must_not` X `unless` through or for it |
  | Y counts as X **only** if a column has a value ("an order is a test order only if IS_TEST is 1": which rows a segment is) | no strength: the segment's `ImplementedBy` with `filters` (see rules about what a metric counts), not a rule about labelling |
  | required to do X **only** when Y ("only required to submit receipts over $50": only limits the duty) | `must` X, `when` Y; nothing is required otherwise |

  Instruction or fact: when the text tells the reader to do something, write a `Rule`; when it describes how
  things are, write the fact. Do not write both for the same words. A definition that also states a norm
  ("Code Freeze: only critical fixes are merged") is a `Definition` quoting the defining words and a `Rule` quoting
  the norm's words.

  A range a metric or a load is expected to stay within ("weekly sign-ups stay within 15% of the week before") is a
  `Rule`, not a definition of the metric: `must` with `verb: check`, the metric in `objects` and in `scope`, what it is
  compared with in `detail`, the bound as a value with `value_role: maximum` (or `minimum`), and `importance` when the
  text says how much a miss matters ("a miss here matters a lot": `high`). A value a metric should reach ("revenue
  should grow 10% a year through 2027") is a `Rule` `should` with the metric in `objects` and in `scope`, the value
  with `value_role: target`, and `due_by` when it should be reached.

  Who must act goes in `binds` (a step's in `performer`), never in the action's `by`. A list of duties for a role
  ("Managers are responsible for...", "Team members must...") is one `Rule` per duty binding the role when the text
  states it as a norm (must, should, is expected to); a standing area of work stated without a norm ("Accounting
  handles reimbursements") is `ResponsibleFor`. "X needs to be approved by Y" and "X must be nominated by Y" are
  conditions on X, not duties on Y: a `Rule` that X `must_not` go ahead `unless` Y approves (or nominates) it, the
  `unless` naming in `about` both Y and the approved state (a concept of `concept_type: state`, "refund approved by a
  manager"), which an approval step grants; Y is not bound to approve anything. "Y or higher" adds
  `or_more_senior: true`. A vote threshold ("passing requires a strict majority", "at least two-thirds") is a condition
  with a threshold value:
  `{value: "2/3", value_role: threshold, comparator: at_least, unit: "of votes cast"}`. A consequence with no one named as acting ("they are removed", "the council
  is dissolved", "it is moved out automatically") is a `Transition` to the new state with `automatic: true` when
  the text says it happens by itself; never invent who does it. When the text names the check, job or system whose
  event sets it off ("when the uniqueness test fails, the load is marked failed"), it is that one's `Triggers`, as
  under Data operations. Which source wins over another ("the finance team's formula is the one that runs"; "the payments system is the source of truth for refunds"; "tax filings use the ledger") is a
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
  order, "first #help, then the duty analyst", is a chain: the problem escalates to #help, and #help to the duty analyst),
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
  describes it is `DescribedIn`; `filters` when the concept is the rows of a table or view that pass them: "active
  customers are customers whose status is active"), `JoinsTo` (`keys`, `cardinality`, `dedup`, `join_type`,
  `recursive`). A filter may compare its field with another column (`compare_to`), on the concept's table or on a table
  it joins to ("late orders are orders shipped after their promised date": shipped_date `more_than` promised_date). A
  range ("on or between A and B") is two filters, `at_least` A and `at_most` B; all of a statement's filters must hold.
- A member concept of a dimension (in a `HasValues` `members`) whose value the text or an earlier statement gives is
  linked to that value by an `ImplementedBy` from the member to the dimension's table with one filter, the same form
  as a segment (the region North: `{field: orders.region, comparator: equal, values: [{value: North}]}`). When the
  value is not given, write a `Gap` about the member. Code then finds a row's member, and through `ResponsibleFor` its
  owner, without matching labels.
- Several elements that together correspond to one ("the Silver and Gold plans together roughly match the CRM's
  Premium tier"): name the group as a concept, list its members with `Groups` (`complete: true` for "together"), and
  map the group once (`match: close` for "roughly"). One mapping per member loses "together". When each maps on its
  own ("Bronze is Basic and Platinum is Elite"), write one mapping each.
- `Contains`: a table holds a field, concept or entity, as a key | attribute | label | dimension | time_dimension
  | measure, with `time_grain` for a time dimension. Use it for "the table includes X, Y, Z". Do not add a statement just because a field id names its table.
  `partition: true` on the column that splits a table into partitions ("events is partitioned by event_date").
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
  allow for whose cause names no element is one Caveat with its cause in its text. A cause between two named
  elements ("when fct_invoices has gaps, the usual cause is the payment provider sending its files late") is
  `Influences`: the cause in `subject`, the effect in `object` (the gaps in fct_invoices, never a condition), "usually"
  in `frequency`.
- `JoinsTo` join_type: none for an ordinary (inner) join, `left`, `semi` (keeps the rows of the first that have a
  match, adding no columns) or `anti` (keeps the rows of the first that have none: "customers with no order"); record
  another as unmapped. Its `cardinality` takes the pair values (one_to_one, one_to_many, many_to_one, many_to_many)
  and is what the data has; `expected_cardinality` is what it should be when the text says the data breaks it
  ("should be one to one, but split payments create duplicates": one_to_many, expected one_to_one).
- A key pair that is not equal gives its `comparator` (`equal`, `not_equal`, `more_than`, `at_least`, `less_than`,
  `at_most`): a
  validity range is two pairs ("the customer_history row whose valid_from and valid_to include the order date": order_date
  at_least valid_from, and order_date at_most valid_to). The latest row on or before a date is the pair with
  `nearest: true` and its comparator ("the latest rate on or before the order date": order_date at_least rate_date), the
  join's other pairs equal; only a JoinsTo takes `nearest`, and a RecordMatch's pairs are equal. `recursive: true` when
  the join can be followed again and again ("manager_id points to the employee's manager, to any depth"). A measure
  split across a join ("split_pct gives each rep's share of a deal's amount") is a `ComputedAs` of the measure times
  the share column, both in `inputs` (outside the compilable profile, whose totals read the columns of one table).
  A key pair's `normalize` says what is done to both columns before they are compared (`trim`, `ignore_case`,
  `cast_to_text` or `cast_to_number`, always in that order). `keys` holds, as the text writes it, only a condition key
  pairs cannot say (a function on a column: `DATE(orders.ORDER_TS) = days.DAY`), and no key pair is then written for
  that condition; a comparison of two columns is a key pair, and is never given in `keys` as well. `role` names the
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
- An `expression` is one SQL expression, whatever words the text uses: "AMOUNT minus DISCOUNT_AMOUNT" is
  `AMOUNT - DISCOUNT_AMOUNT`, and "AMOUNT, taking 0 for an order whose STATUS is sent back" is
  `CASE WHEN STATUS = 'sent back' THEN 0 ELSE AMOUNT END`. It is made of names, numbers, text in single quotes,
  `+ - * /`, parentheses, comparisons, `AND`, `OR`, `NOT`, `IS NULL`, `CASE WHEN`, `COALESCE` and `CAST`, in ANSI SQL
  unless `dialect` names another. The quote keeps the text's words. An aggregate, a join and a query are never in it:
  the aggregate is `aggregation`, a join is a `JoinsTo`, and a count of rows is `aggregation: count` with
  `expression: "*"`. When the text gives no formula over columns or metrics it names ("hours to deliver", with no
  column for either time), keep its words and add a `Gap` about the metric that says what is not given.
- Each name in an `expression` is a declared element, so the table a column comes from is read from fields, never
  from words. In a definition with `aggregation`, a name is a column of `base`, written as its `physical_name` or its
  label gives it (`AMOUNT`; `"Order Date"`, in double quotes); list the fields it reads in `inputs`
  (`inputs: [t.shop.orders.status, t.shop.orders.amount]`). In a `derived` metric, a name is the last part of an
  input's id (`sales` for `c.sales`; in double quotes when it is not a plain word, `"7d_orders"`), and every input is
  named. An amount over the columns of two tables is one metric for each table and a `derived` metric over them.
- A definition that needs another table names only the column it reads there, and the join is a statement of its
  own: "Member sales adds up AMOUNT over the orders of customers whose TIER is member" is a `ComputedAs` with `base`
  the orders table and a filter on `t.shop.customers.tier`, beside a `JoinsTo` from orders to customers with its
  `key_pairs` ("each order belongs to one customer, by its CUSTOMER_ID"). An `ImplementedBy` likewise gives its column
  as `object` and its rows as `filters`, and no `expression`.
- A rolling or to-date metric is `cumulative`: its input's aggregation applied over a trailing window, a value with
  `value_role: window` ("distinct visitors over the last 7 days": 7 days, distinct over the 7 days, not a sum of daily
  counts), or from the start of a grain, `grain_to_date` ("sales year to date": year), not both; `inputs` names the
  metric it is taken from. When its grains follow a calendar other than the ordinary one ("fiscal year to date"),
  `calendar` names that calendar (a concept of type calendar); an export that only knows the ordinary calendar
  reports such a metric instead of writing it.
- A comparison with an earlier period is two metrics: the earlier one is a `derived` ComputedAs with one input and a
  value with `value_role: offset` ("sales the same week last year": 1 year, `unit` "year" or "fiscal year"), and the
  comparison is a `derived` metric over both. The earlier one's `expression` is its input's name (`sales`), with the
  grain in `reporting_grain`; words there read as a formula of their own. The comparison's `expression` is a formula
  over the two names when the text says how they compare. A comparison and a threshold on it, in a rule or a step, use
  one unit: "when weekly sales differ by over 10% from the same week last year" is a percent, so the expression
  multiplies by 100 (`(sales - sales_last_year) / sales_last_year * 100`) and the threshold is `10` with `datatype:
  percent`; a comparison written as a fraction (`(sales - sales_last_year) / sales_last_year`) takes a fraction
  threshold (`0.1`, no `datatype`). When the threshold is judged for each value of a dimension ("when a region's
  weekly sales differ by over 10% from the same week last year"), the rule's action names that dimension in `by`; it
  may also be named in the condition's `about`, beside the comparison. When an earlier statement you are shown already
  defines the comparison, list its id in `external` and write no second version, unless the text changes how it is
  computed.
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
  `expression`, in words when the text gives no formula, each then with a `Gap` that says which columns are not given),
  even when the text names neither as a metric.
- What an empty period shows ("days with no sales show 0") is a value with `value_role: default`.
- An attribute taken from the first or last of several rows ("a visit's channel is the channel of its first page
  view", "an order's status is its latest status") is a `ComputedAs` on that attribute (a dimension concept) with
  `aggregation` first or last, even when the text gives no full formula; its `expression` is the column taken
  (`CHANNEL`).
- `JoinsTo`: `key_pairs` that point at the column elements (`from_field`, `to_field`), never key text for a
  comparison of two columns; its `cardinality` when the text or a table's key gives it. A join the
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
  that cannot be written as metrics and `JoinsTo` statements, and needs joins or subqueries to run, keeps its SQL in
  `expression`, with `dialect`, and no computable fields; such a statement is outside the compilable profile.

The expected shape, with the fields to give when the text says them:

```yaml
things:
  - {id: t.shop.orders, label: orders, thing_type: table, physical_name: "acme.shop.orders", evidence: [...]}
  - {id: t.shop.orders.order_ts, label: ORDER_TS, thing_type: field, evidence: [...]}
  - {id: t.shop.orders.amount, label: AMOUNT, thing_type: field, evidence: [...]}
  - {id: t.shop.orders.status, label: STATUS, thing_type: field, evidence: [...]}
  - {id: t.shop.promotions.starts_on, label: STARTS_ON, thing_type: field, evidence: [...]}
  - {id: t.shop.promotions.ends_on, label: ENDS_ON, thing_type: field, evidence: [...]}
concepts:
  - {id: c.revenue, label: Revenue, concept_type: metric, evidence: [...]}
  - {id: c.promotion_order, label: order placed during its promotion, concept_type: segment, evidence: [...]}
statements:
  - {id: s.T.1, predicate: Contains, subject: t.shop.orders, object: t.shop.orders.order_ts, data_role: time_dimension, evidence: [...]}
  - {id: s.T.2, predicate: Contains, subject: t.shop.orders, object: t.shop.orders.status, data_role: dimension, evidence: [...]}
  - id: s.M.1
    predicate: ComputedAs
    subject: c.revenue
    metric_type: simple
    aggregation: sum
    expression: AMOUNT                        # what is aggregated: SQL over the columns of base
    inputs: [t.shop.orders.amount]            # the fields the expression reads
    base: t.shop.orders
    time_dimension: t.shop.orders.order_ts    # the date it is counted by; may be left out when the table has one
    filters:
      - {description: "status is not Cancelled", field: t.shop.orders.status, comparator: not_equal, values: [{value: Cancelled}]}
    evidence: [...]
  - id: s.M.2                                 # a segment: orders placed on or between their promotion's dates
    predicate: ImplementedBy
    subject: c.promotion_order
    object: t.shop.orders
    filters:                                  # all hold; promotions is reached by its JoinsTo from orders
      - {description: "placed on or after the promotion starts", field: t.shop.orders.order_ts, comparator: at_least, compare_to: t.shop.promotions.starts_on}
      - {description: "placed on or before the promotion ends", field: t.shop.orders.order_ts, comparator: at_most, compare_to: t.shop.promotions.ends_on}
    evidence: [...]
```

Keep every version of a definition the text gives, with `HasStatus` (canonical, variant, deprecated...) and the
decision group; only the canonical one is exported. When a metric has several definitions, each `HasStatus` has
the definition's statement id as its `subject`; when the whole metric is deprecated or an alias, the concept is the
subject. Several definitions with none marked canonical are reported and none is exported. Mark a definition
`canonical` only when the text says so: when the other definitions are deprecated or variants, the one left in force
is exported without it.

## Data operations

One form for each kind of sentence in a data team's runbook; the same fact in other words takes the same form. A job
is a thing of type `job`, a report or dashboard one of type `report`.

| Sentence | Form |
|---|---|
| Job and schedule: "The invoicing pipeline loads fct_invoices every day at 04:00 UTC." | `Triggers`: the job in `subject`; `action` with `verb: load` and the table it writes in `objects`; `recurrence`. A source and a target ("loads raw.invoices into fct_invoices") are the source in `objects` and the target in `to`. |
| Readiness: "The invoice load is ready when run_log shows state 'ok' for the day and the row count is at least 95% of the 14-day median." | `Transition`: `subject` what changes state, `to_state` the state concept ("invoice load ready"), `when` the conditions, each naming in `about` what it tests (a field, a metric with its `ComputedAs`), with its threshold as a value. |
| Freshness: "Finance dashboards must show data loaded by 09:00 local time on working days." | `Rule` with the dashboards in `scope` (`binds` is who must comply) and `due_by` the deadline in the text's words. A maximum age ("no more than 3 hours old") is a check: `verb: check`, the dashboards in `objects`, `detail` freshness, the age as a value with `value_role: maximum`. |
| Gate: "Do not publish the Weekly Collections Report to country leads until the invoice load is ready." | `Rule` `must_not`, the report in `objects`, the leads in `to`, `unless` the state. "Until" a state ("every hour until it is contained") is `unless` that state. |
| Quality check: "A dbt test checks that INVOICE_ID in fct_invoices is never null." | An action with `verb: check`, the checked table or field in `objects` (never in `by`), what is checked in `detail`, a tolerance as a value with `value_role` minimum or maximum: in a `Rule` for a duty to check, in a `Triggers` for a monitor or test that runs by itself, its subject the test or monitor as a thing of type `job`. |
| Check failure: "If the null test fails, the load stops and an alert is raised automatically." | `Triggers` with the check in `subject` (a thing of type `job`), also when the text says no one acts ("without anyone raising it"): its condition names in `about` the failure state, the checked table, and the field when the check names one; what fails in its `action` (`verb: stop`, `specific_verb: fail`); what it creates in a `then` action with `verb: create`. |
| Monitor: "Collections are low when weekly collections are more than 15% below their 12-week average." | `Transition` to the state ("collections low"), its condition about the metric, with the threshold value. |
| Issue creation: "If the invoice load is not ready by 08:00 CET, a data issue should be logged." | `Rule` `should`, `verb: create`, the issue concept in `objects`, `unless` the state with `time_of_day` 08:00 and `time_zone` CET on that condition. |
| Severity: "P2: a finance dashboard is wrong, or more than 6 hours late." | `Transition` to the severity state, its alternatives in `when_any`: this defines the severity. Putting one incident the text names in a severity ("this is a P2") is `IsA`. |
| Routing: "A P1 pages the duty analyst within 10 minutes." | `Rule` `must` when the text names no system that does it, `Triggers` when it does; `verb: notify` (`specific_verb` page, post), the recipient or channel in `to`, `within` counted from the event the text names, or from the state the condition names when it names none. |
| Escalation: "If nobody acknowledges a P1 within 20 minutes, escalate to the analytics manager." | `EscalatesTo`, also when the text says it as an instruction ("escalate to"), not a `Rule`: from the party who escalates (the one paged, when the text does not say) to the next, `unless` the acknowledged state with the duration as a value counted from the P1 state; a path in order is a chain of them. Whom a party answers to for a responsibility is `ResponsibleFor`'s `answers_to`. |
| Lifecycle and updates: "An issue is reported, then triaged, then fixed, then verified. For a P1, update the finance team every hour." | One `Transition` per step (`from_state`, `to_state`); a `Rule` with `when` the P1 state, `to` the team and `recurrence`. |
| Known cause: "When fct_invoices has gaps, the usual cause is the payment provider sending its files late." | `Influences`, as under Statement types: the cause in `subject`, the effect in `object`, `frequency: usually`. A cause or effect named after a thing ("gaps in fct_invoices") has a `BelongsTo` to that thing. |
| Consumers: "The Weekly Collections Report is built from fct_invoices and goes to country leads every Monday." | `DerivedFrom` from the table; a `Rule` (or a `Triggers`, when the text names what sends it) with `verb: share`, the leads in `to` and `recurrence`. A job that builds one table from another gives both: the job's `Triggers` and the table's `DerivedFrom`. |
| Change and deprecation: "Column renames in fct_invoices must be announced in #analytics-changes one week before they ship. reporting.invoices_old is retired on 2027-03-31." | `Rule` with `verb: tell`, the changes in `objects` and the table in `scope`, the channel in `to`, `due_by` the text's words; `HasStatus` retired with `valid_from`. |
| Freeze and restatement: "Do not reload history during month-end close, unless the issue is P1. If a reload changes last quarter's collections by more than 0.5%, tell the controller." | `Rule` `must_not` with `verb: load` (`specific_verb` reload), `when` month-end close, `unless` the P1 state; `Rule` with `when` about the change in the metric and its threshold. |
| Dated change: "From 2027-01-01, data issues must be logged in #analytics-issues." | The new statement, whole, with `valid_from` and `supersedes` the one it replaces. |

- A state concept belongs to one subject: "invoice load ready", "P1 issue", never "ready" alone. When no
  `Transition` has that thing as its `subject` (a state or event only named, "late arrival of the supplier file"), a
  `BelongsTo` from the concept to the thing gives it, quoting the words that name them.
- A condition on a check's result names the failure state and the checked table in `about`, and the field when the
  check names one ("the null test on INVOICE_ID failed": the failure state, fct_invoices, INVOICE_ID).
- A later text that changes part of a statement ("from today, page the analytics manager instead") is a new statement
  that repeats every part that still holds, changes the part that changed, and `supersedes` the old one.
- A duration defined between two events with no number ("the time between an entry made upstream and the data
  available in PROD") is a `ComputedAs` with both events in `inputs`.
- A negation where no `unless` can hold it (inside `when_any`, `so_that`, an action's, branch's or case's `when`, or a
  procedure's `trigger`) is `negated: true` on that condition; a statement's own condition uses `unless`, and a
  filter negates with its comparator (`not_equal`, `not_in`). A statement that says something is not so ("a reload
  that finishes on time is not an issue") takes the statement's own `negated`.
- A time of day inside a condition is the condition's `time_of_day` (HH:MM, 24-hour) and `time_zone` (the text's
  zone).
- A stretch of time counted back from when the statement is applied is its `period` with `last` or `previous` (see
  Qualifiers): "the last 3 days of sales are provisional". These have no field, and are each a part recorded as
  `unmapped` beside the statement: a date relative to the day checked inside a condition ("this morning's invoice
  count", "for the same day last month"); an order relative to a deadline ("before
  the cut-off"); a party named through another element ("the analyst who owns the broken report"); a count of runs in
  a row ("misses two loads in a row"); a window counted back from the end of a period ("the last 5 working days of a
  year").
- The same fact in other words keeps one form: an automatic reaction is `Triggers`, never a `Habit` (Habit is what a
  party usually does); a cause between named elements is `Influences`, and `Indicates` and `CorrelatesWith` only as
  Statement types says; an escalation path is `EscalatesTo` or `answers_to`; a recipient or destination goes in the
  action's `to`; a category the text names is `IsA`.

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
  duration ("within 30 days"), and the event it is counted from goes in its `counted_from` ("within 24 hours of the
  source update": the source update), never in `due_by` text; `recurrence` is a duty or an automatic behaviour that recurs ("every month", "daily at 02:00 UTC"); `cadence` is how a rotation
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
check", "pay close attention to") | minor ("a minor point", "low priority"), `negated`, `currently` ("right now",
"currently"), `valid_from`,
`valid_to`, `valid_while` ("for the duration of the incident": a named period or state the statement holds through,
such as "during the freeze" or "while Jo is on leave"; a recurring window, "during business hours", is a `when`;
a list, like the other conditions), `stated_by` (a list), `period` and `recorded_on` (below).

Five dates say different things. `valid_from` and `valid_to` say when the statement holds. `period` says what
stretch of data or business time it is about: the days data is missing ("order data is missing from 1 to 3 June":
`period: {start: 2026-06-01, end: 2026-06-03}`), the quarter a target is for, the years a table covers; give
`start`, `end` (its last day) or `named`, a concept of type period for one the text names without dates ("Q3",
"the holiday season"). A stretch counted back from when the statement is applied gives `time_grain` and one of
`last` (the most recent that many grains, the current one included as far as it has gone: "the last 3 days" is
`{last: 3, time_grain: day}`, "this month" `{last: 1, time_grain: month}`, "year to date" `{last: 1, time_grain:
year}`) or `previous` (that many whole grains just before the current one: "last month" is `{previous: 1,
time_grain: month}`), with `calendar` for a fiscal one; they count from the statement's `as_of`, else the source's,
else the day the statement is applied, and a rolling window is days ("the last 90 days"). A metric's own trailing
window stays a value with `value_role: window`. Figures that may still change are a `Caveat` with the `period` they
cover. A caveat about early June still holds in July. `as_of` says when what it describes was
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

Rules about what a metric counts: a rule that leaves rows out of a metric, or counts them only when something holds,
is `must_not` with verb `include`, `count`, `use` or `select`, or `must` with verb `exclude`, with the metric in
`scope`. It names the rows as a segment concept in its action's `objects`, and an exception in
`unless`, naming a segment in `about` ("test orders are never included in revenue"; "a promotion order counts in
promotion sales only if it was bought during its promotion": `must_not` count promotion orders, `unless` about the
orders bought during their promotion). Each segment such a rule names has an `ImplementedBy` from the segment to
its table, with `filters`, whenever the text or an earlier statement names the column and the value or the other
column: "the day it was ordered" is the table's time dimension, and "a marketplace order" is the column that says
where an order came from, with that value. When neither says which rows, write a `Gap` about the segment. Rows
defined as failing a range ("promotion orders placed outside their promotion") stay on the segment of the whole set,
with `unless` naming the in-range segment; filters must all hold, so no segment is written for the complement. A state the
data records by dates ("until the promotion is extended") is read against those dates: an extended promotion is one
whose dates cover the order, so the sentence restates the in-range segment's exception and adds no rule with a state
in `unless`. A field in `objects` ("do not use DISCOUNT_AMOUNT in revenue": `must_not` use the field, the metric in
`scope`) is about the field and needs no segment. A metric in `objects` is not rows: write the rows it means as a
segment, or the field. A definition that leaves an amount out ("before shipping", "do not take off returns") says
so by its formula, which does not add that amount, and adds no rule: a rule that leaves rows out names rows the metric
counts (rows of its table, or of a table each of them joins to once), never another table's rows such as returns
against an order amount.

A definition limited to the rows another metric counts ("average basket size, for the baskets counted in revenue")
puts that metric in its `scope`; the definition then takes that metric's filters and the rules bound to it.

The forms a compiler reads (a filter's `field`, a rule's segments and the metric in its `scope`, a member's value, one
unit, an approved state, a dated period, an earlier-period metric's `expression`, the dimension in `by`, an
`expression` in SQL over declared names, a join in a `JoinsTo` alone, the state a label applies in) are the compilable
profile: `conformance.md`, rules C1 to C18.

Sign-offs, restatements and the approvals they need: a period's sign-off ("Q1 sales were signed off") is a
`Transition` with `subject` the metric, `to_state` its signed-off state (a concept of `concept_type: state`), and
`period` with `named` (a concept of `concept_type: period`) and its `start` and `end`. A fiscal period is dated from
the context's fiscal calendar ("our fiscal year starts on 1 February": fiscal Q1 2026 is 2026-02-01 to 2026-04-30);
while the calendar is known, every period a rule, a label or a sign-off names carries both dates. A restatement is a
`Transition` of the same form, with `to_state` the restated state. "Nobody edits a signed-off figure without the
controller's approval" is a `Rule` that the change `must_not` go ahead `unless` the controller approves, its `unless`
naming in `about` the controller and the approved state, as for any approval. A label a state calls for ("an edited
figure carries the mark revised in every report") is a `Rule` with verb `label`, the label in its `values`, the metric
in `objects`, and `when` about the state the change produces (the restatement's `to_state`). A label always says, in
`when`, the state its object is in while the label applies, or it has no condition and applies always: "a figure
that is still open carries the mark draft" names the open state (a concept of type state, with the `Transition` that
puts the figure in it) in the condition's `about`, never only the closed state in `unless`.

An owner's answer about comparing across a change in a definition ("compare both years on the current definition")
is a `Rule` about comparisons, not a restated definition: `must`, verb `use`, the metric in `scope`, the definition
chosen in the action's `objects` (the id of its `ComputedAs` statement, when you are shown it), and `when` about a
comparison of the metric with an earlier period (the metric and its earlier-period metric in `about`), saying both
periods are computed with the definition in force on the day of the comparison. It has no `period` and leaves the definition's own `valid_from` as it is, so the earlier
definition stays on record and a rule about a signed-off period still applies. "Compare each year on its own
definition" is the same rule, each period computed with the definition in force in it. A new `ComputedAs` without
`valid_from` would hold on every day and replace the earlier definition on earlier days too; one with a `period` would
give the metric two definitions in force.

A threshold in a condition ("if returns rise by more than 10%", "orders over $50") is a value in the condition's
`values` that carries its own comparison: `{value: "10", datatype: percent, value_role: threshold, comparator: more_than}`.
`value` is the number alone; its kind goes in `datatype` (percent, number) and anything else in `unit` ("USD", "of
votes cast"). The condition's own `comparator` is only for a data filter, with `field`. A condition on a measured amount names what it
measures in `about`: a metric concept ("returns", "p-value", "week-over-week change in orders"), with its
`ComputedAs` when the text says how it is calculated; a condition that something is in a state or category ("the
issue is P1", "the data is late") names that state concept. A time since an event ("after 7 days") needs
neither; the event goes in the value's `counted_from` when the text names it ("7 days after the incident is
resolved": the resolved state). This is what lets a rule's condition be checked against data.

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
short.

A field holds the standard form of what the text says, and the quote keeps the text's own words. Where the schema
gives a field, a closed list or a typed value for something, fill it, in its one form, and do not copy the sentence
into a text field: a formula is SQL in `expression` ("AMOUNT minus DISCOUNT_AMOUNT": `AMOUNT - DISCOUNT_AMOUNT`); a
date is an ISO date; an amount is a `value` with its `datatype`, `unit` and `comparator` ("over 10%": `10`, `percent`,
`more_than`); a condition on a column is `field`, `comparator` and `values`; a join is `key_pairs`; a verb is one of
the closed list, with the text's own in `specific_verb`. Words go in a text field only when the schema has no field
for what they say. A `description` or a `detail` beside complete fields is words for people: no meaning sits in the
words alone. `note` is never part of the meaning; use it only to flag a choice you were unsure of (notes are counted).

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
