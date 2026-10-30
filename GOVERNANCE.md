# Governance

BigContext Schema is an open specification under the Apache License 2.0. This page says who decides what changes in
it, and how.

## Maintainers

The maintainers review proposals, decide what changes and publish versions. Big Context & Company appoints them
and holds the name "BigContext Schema" and the address `https://w3id.org/bigcontext-schema` for everyone who uses
the specification. The maintainers today:

- Joji John, Big Context & Company (GitHub: [@joji-figlabs](https://github.com/joji-figlabs))

As other organizations come to depend on the specification, people from them who contribute regularly are invited
to become maintainers.

## How a change is made

1. **Propose it.** Open an issue with the [enhancement form](.github/ISSUE_TEMPLATE/enhancement.yml): a real
   example text, what it should become, and why the specification falls short today. Errors in the specification
   are reported as ordinary issues.
2. **Discuss it in public.** Changes are discussed in the issue. A proposal that adds a building block stays open
   for comment for at least 14 days, and one that would need a major version for at least 30 days.
3. **Make the change.** A pull request changes the schema (`bigcontext_schema.yaml`), the guide (`guide.md`), the
   examples and the conformance cases (`tests/`) together, so they never disagree.
4. **Decide.** The maintainers decide, aiming for agreement among those who took part, and record the decision and
   its reason in the issue. A decision can be raised again when new examples show it was wrong.

## Versions

Versions follow the rules in the README (patch, minor, major). A major version is announced at least 90 days
before it is published, with a note on how to move documents to it. Each published version is a tagged release of
this repository, and its files stay available at that tag.
