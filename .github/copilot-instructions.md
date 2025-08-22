# GitHub Copilot Code Review Guidelines

## Commit Message Review Checklist

When reviewing pull requests, ensure that each commit message adheres to the following rules:

1. **Length**: The subject line must not exceed 50 characters.
2. **Capitalization**: The subject line must start with a capital letter.
3. **Punctuation**: The subject line must not end with a period.

### How to Handle Violations

If a commit message violates any of these rules:
- Leave a comment on the specific commit.
- Clearly mention each rule that was violated.
- Suggest a fix for each violation.
- Include the specific commit hash in your comment to allow GitHub to link to it.
- Mention the commit subject line in your comment.

### Exception

Ignore these checks for pull requests created by `dependabot[bot]`.
