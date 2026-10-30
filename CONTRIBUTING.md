# Contributing

Thank you for helping BigContext Schema cover more of the context real organizations write down. How changes are
decided is in [GOVERNANCE.md](GOVERNANCE.md). Everyone taking part follows the
[code of conduct](CODE_OF_CONDUCT.md); report a problem to opensource@bigcontext.com.

## Ways to help

- **Something the specification cannot express, expresses only roughly or explains unclearly:** open an issue with
  the [enhancement form](.github/ISSUE_TEMPLATE/enhancement.yml). A real example sentence is the most useful thing
  you can give; remove anything confidential first, since issues are public. If you used
  `bigcontext-schema generate`, the `.unmapped.md` file beside your document has the examples ready.
- **An error in the specification** (a contradiction, a wrong example, a broken link): open an ordinary issue.
- **A change you have made:** open a pull request.

## Pull requests

- Change the schema (`bigcontext_schema.yaml`), the guide (`guide.md`), the examples and the conformance cases
  (`tests/`) together, so they never disagree. If you cannot regenerate `generated/` and `tests/`, say so in the pull
  request and a maintainer will.
- Keep each pull request to one change, and link the issue it settles.
- Write for the people who use the specification: plain words, and an example for every new building block.

## Licence of contributions

The specification is under the Apache License 2.0. As section 5 of that licence says, anything you submit for
inclusion is under the same licence, with no further terms. Sign off each commit to confirm you may submit it, as
the [Developer Certificate of Origin](https://developercertificate.org) describes: `git commit -s` adds the
`Signed-off-by` line.
