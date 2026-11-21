# A context repository

A repository holds an organization's and its teams' context as one document per file (`conformance.md`, "A
conforming repository"; `examples/context-repository/`). A person or a tool writes a document as `guide.md` says, and
a tool places it: it makes the ids below, puts each element and statement in its file, and writes each file's
`external`. Nobody types an id.

- **Level and kind are folders.** `org/meaning/metrics/orders.yaml` is the organization's; a file under
  `teams/support/` is the Support team's. The repository's `registry.yaml` says which folder holds which kind.
- **One file, one thing.** A table's file holds its fields. A file refers to what other files declare by listing the
  ids in `external`: inside a repository a thing or concept is declared once, not in every file that names it.
- **Element ids** are made as `guide.md` says ("Ids"), from the label or the physical name. An id is made once and kept: renaming
  the label later does not change it, and the old label joins `aliases`.
- **Statement ids say what the statement is about**, so the same statement gets the same id each time:
  `s.<subject>.<statement type>`, then the object and what completes its key (`s.orders.computed_as.shop.orders`,
  `s.shop.orders.contains.shop.orders.status`); `s.<object>.responsible_for.owns` for who owns something; and for a
  statement that is a file of its own, `s.<file name>.<statement type>` (`s.shop.shipments__shop.orders.joins_to`).
  Ids are written without their first part and statement types in snake case. A second statement with the same id
  gets `.2`. A team's statement id starts `s.team-<team>.`.
- **A team's version.** To state its own version of what the organization states, a team writes that statement in
  its own file of the same name and declares nothing. It stands in the organization's place for that team where the
  registry gives the kind `conflict: narrowest`.
- **A change that holds from a day** gives the day in `valid_from`. The statement it follows gets `valid_to`, the day
  before, and both are kept. A statement with no `valid_from` that restates one takes its place, and the earlier
  wording is in the repository's history only.
- **What is never in a repository**: a proposal (`decision_status: proposed`), somebody's view (`held_by`), and a
  `Gap`. They belong where the question is being settled.
- **Evidence.** A quote must be found in a text under `sources/`. A statement written with no text to quote, such as
  one a converter wrote from a semantic model or a list of columns, names who stated it in `stated_by`.

