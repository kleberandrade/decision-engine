# decision_engine engineering workflow

- Keep the core pure Dart with no runtime dependencies, IO or Flutter imports.
- Follow doc/architecture.md; compose DecisionMethod and DecisionConstraint.
- Preserve immutable inputs, results and independent evaluation state.
- Validate configuration, observed values and custom strategy output boundaries.
- Use public-entry-point tests with independent expected calculations.
- Add a regression test before a behavioral fix and observe its expected failure.
- Document APIs and changes in English and Portuguese; synchronize examples.
- Add user-facing changes under Unreleased; never rewrite published notes.
- Use semantic commits and keep doc/engineering_log.md concise and factual.
- Run CONTRIBUTING.md checks before pushing completed work to the main line.
- Never claim a release, hosted publication or validation that has not occurred.
- Do not alter unrelated repositories, worktrees, caches or uncommitted work.
