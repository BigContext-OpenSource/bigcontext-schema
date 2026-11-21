# Conformance cases

The cases `conformance.md` names, for checking an implementation of BigContext Schema. The documents in
`../examples/` are valid cases too.

| Folder | What each case holds | An implementation gets it right when |
|---|---|---|
| `documents/valid/<case>/` | `document.yaml`, `source.txt`, `expected.yaml` (`conforms: true`) | it accepts the document |
| `documents/invalid/<rule>-<case>/` | the same, with `breaks:` the rule the document breaks (D1 to D10) and what the reference checker says | it rejects the document for that rule |
| `producers/<rule>-<case>/` | a document that conforms but whose producer does not, and the lines it leaves unaccounted for | it reports those lines |
| `profiles/compilable/conforming/<case>/` | `document.yaml`, `source.txt`, `expected.yaml` (`profile: compilable`, `conforms: true`) | it finds the document in the compilable profile (`conformance.md`, C1 to C17) |
| `profiles/compilable/not-conforming/<rule>-<case>/` | the same, with `breaks:` the profile rule the document breaks (C1 to C18) and what the reference checker says; `earlier.yaml`, when `read_with` names it: the statements stored before the document, which the rule reads | it accepts the document as conforming, and finds it out of the profile for that rule |
| `profiles/compilable/normalize/<rule>-<case>/` | a document in a form a tool may rewrite (C10, C11, C12), `normalized.yaml` (the rewritten document, which is in the profile), and in `expected.yaml` the changes the reference tools report | it finds the document out of the profile for that rule, and a tool that rewrites gives `normalized.yaml` |
| `profiles/compilable/expressions.yaml` | one table, its columns, and expressions of a total on it, each with `in_the_profile` and, when false, `breaks` (C14 or C15) | it finds each expression in the profile or out of it for that rule; a compiler accepts the first kind and refuses the second |
| `repositories/not-conforming/<rule>-<case>/` | the files that differ from the repository `../examples/context-repository/`, and `expected.yaml`: `based_on`, `removes` (files of the example to take out), `breaks:` the rule the result breaks (R1 to R10) and `reference_checker_says` | it accepts the example repository, and rejects the example with the case's files in place for that rule |
| `graph/<example>/<date>/` | `stated.nt` and `inferred.nt`: the stated and worked-out facts for that date, sorted N-Triples; `answers.yaml`: the answers to the questions in `../queries/`, by subject; for a 1.2 case, `in_force.txt`: the ids in the in-force graph, and `connections.yaml`: the rows of `../queries/record/connections.rq`, as ids | its stated facts, worked-out facts, answers, in-force set and links are the same |

Each graph case uses the address `graph.md` gives: the source's `base_iri`, or `urn:bigcontext-schema:<source id>/`.
The cases are made from the examples by the reference tools (published with the free tools, coming soon), and
checked against them on every change.
