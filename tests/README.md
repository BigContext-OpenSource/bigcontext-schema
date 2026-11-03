# Conformance cases

The cases `conformance.md` names, for checking an implementation of BigContext Schema. The documents in
`../examples/` are valid cases too.

| Folder | What each case holds | An implementation gets it right when |
|---|---|---|
| `documents/valid/<case>/` | `document.yaml`, `source.txt`, `expected.yaml` (`conforms: true`) | it accepts the document |
| `documents/invalid/<rule>-<case>/` | the same, with `breaks:` the rule the document breaks (D1 to D10) and what the reference checker says | it rejects the document for that rule |
| `producers/<rule>-<case>/` | a document that conforms but whose producer does not, and the lines it leaves unaccounted for | it reports those lines |
| `graph/<example>/<date>/` | `stated.nt` and `inferred.nt`: the stated and worked-out facts for that date, sorted N-Triples; `answers.yaml`: the answers to the questions in `../queries/`, by subject; for a 1.2 case, `in_force.txt`: the ids in the in-force graph, and `connections.yaml`: the rows of `../queries/record/connections.rq`, as ids | its stated facts, worked-out facts, answers, in-force set and links are the same |

Each graph case uses the address `graph.md` gives: the source's `base_iri`, or `urn:bigcontext-schema:<source id>/`.
The cases are made from the examples by the reference tools (published with the free tools, coming soon), and
checked against them on every change.
