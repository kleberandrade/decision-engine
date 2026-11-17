# Validation evidence

Local validation uses Dart 3.11.5 on macOS arm64. Dependencies were resolved
offline from the preinstalled cache into an isolated writable cache because
outbound DNS and writes to the global SDK/cache are restricted in this session.

| Check | Result |
| --- | --- |
| Dart formatter | Passed |
| `dart analyze --fatal-infos` | Passed, no issues |
| Public-API behavioral tests | 27 passed |
| Provider selection, weighted sum, custom method examples | Passed |
| Compile provider example to JavaScript and execute with Node | Passed |
| Minimum SDK 3.3.0 | Configured in CI; not executed locally |
| Flutter application integration | Not executed; no Flutter lab included yet |
| Publication dry-run | Attempted; dependency re-resolution blocked by network |
| Hosted publication / pub points | Not performed or claimed |
| Git clone/push | Clone blocked: Could not resolve host github.com |

Tests include independent weighted-sum and TOPSIS calculations, both criterion
directions, signed/zero/extreme finite observations, constant columns, zero
weights, eligibility order, all rejection reasons, empty and singleton sets,
immutability, repeated evaluations, malformed custom output and exact tie order.
A signed-zero regression was first observed failing, then fixed and revalidated.

The source CI matrix covers Dart 3.3.0 and stable, examples, JavaScript compilation
and stable publication dry-run. Configuration alone does not mean remote checks
have run. Once network access is available, run the complete CONTRIBUTING checks
and inspect GitHub Actions before any release.
