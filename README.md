# DraftMode Flutter Facade

This repository is the umbrella facade that lets apps import DraftMode features via stable `package:draftmode/...` names while the real implementations live in sibling repositories.

## Wrapped Packages
- [`draftmode_worker`](https://github.com/draftm0de/flutter.worker) — iOS background-task helper exposing `DraftModeWorker` and `DraftModeWorkerEvents` for starting, cancelling, and observing timer-driven work.
- [`draftmode_example`](https://github.com/draftm0de/flutter.example) — Minimal Cupertino host app showcasing DraftMode demo widgets inside a reusable `DemoPage` shell.
