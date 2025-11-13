# DraftMode Flutter Facade

This repository is the umbrella facade that lets apps import DraftMode features via stable `package:draftmode/...` names while the real implementations live in sibling repositories.

- [`draftmode_worker`](https://github.com/draftm0de/flutter.worker) — iOS background-task helper exposing `DraftModeWorker` and `DraftModeWorkerEvents` for starting, cancelling, and observing timer-driven work.
- [`draftmode_example`](https://github.com/draftm0de/flutter.example) — Minimal Cupertino host app showcasing DraftMode demo widgets inside a reusable `DemoPage` shell.
- [`draftmode_formatter`](https://github.com/draftm0de/flutter.formatter) — Common formatter utilities (e.g., tokenized `DraftModeFormatterDateTime`) for consistent textual representations across apps.
- [`draftmode_localization`](https://github.com/draftm0de/flutter.localization) — Shared `DraftModeLocalizations` bundle extracted to its own repo, re-exported here for consistent translated strings and `flutter_localizations` wiring.
- [`draftmode_ui`](https://github.com/draftm0de/flutter.ui) — Cross-cutting DraftMode widgets and themes collected into a single UI toolkit facade.
