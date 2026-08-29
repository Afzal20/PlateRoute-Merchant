# Merchant App — Implementation Plan

| Field | Value |
| --- | --- |
| Source design | `backend/docs/design/MERCHANT_APP_UI.md` v1.0 |
| Requirements | PROJECT_PLAN §8.4 (MOB-RST-01..10) + §8.2 common (MOB-C-*) |
| Modules | M2 (catalog) shadows staging, M3 (order board), M5 (money) |
| Default theme | Dark mode ships day one, defaults ON in store settings |

## 1. Requirement analysis

| ID | Requirement | Screens involved | Backend endpoints consumed | Risk notes |
| --- | --- | --- | --- | --- |
| MOB-RST-01 | Onboarding showing approval pipeline states (pending/approved/paused) | S2 | `vendors/`, `branches/` | Gate: blocked staff must still see *why* they're blocked |
| MOB-RST-02 | Menu manager CRUD + signed-URL photo uploads | S5–S8 | `menu/*`, `uploads/` | Optimistic availability writes + sync chip when offline |
| MOB-RST-03 | Availability toggles, immediate sync, stock-out behavior | S5 | `menu/items/` | 48x84 unique switch shape; debounce 500ms |
| MOB-RST-04 | Incoming-order alarm: full-screen persistent ring until acknowledged; structured reject reasons | S3a alarm layer, S3 | FCM high-priority data + local-notification fallback | **Highest-risk item in all three apps**: must survive killed-app; Accept is the only enabled control until fully opened |
| MOB-RST-05 | Accept SLA countdown aligned to backend auto-cancel timer | S3, S4 | WS deltas on accept window | Ring must show "reconnecting" gray on socket loss, never invented numbers |
| MOB-RST-06 | Status progression guarded by allowed transitions (PREPARING → READY) | S4 | `orders/{uuid}/transition/` | Client mirrors state machine; server is truth |
| MOB-RST-07 | Historic order list, filters, CSV export trigger | S6 | `orders/` history | S priority |
| MOB-RST-08 | Payout ledger read-only: periods, gross, commission, net | S9 | PayoutLedger, FR-PAY-07 invoices | Trust surface: every fee line reconcilable, PDF links |
| MOB-RST-09 | Review reply composer | S10 | `reviews/` | S priority |
| MOB-RST-10 | Store-health checklist nudges (missing images, uncovered hours, prep drift) | S5 top | FR-CAT-01 | One fix per visit; nudge frequency capped weekly |
| MOB-C-01..14 | Common requirements incl. idempotency intercept (MOB-C-04) wired globally | cross-cutting | all | Alarm→accept target: p50 ≤ 7s instrumented |

**Critical-path analysis:** the alarm→accept loop (MOB-RST-04/05/06) is the product gate — an SLA breach auto-cancels the order (FR-ORD-01), so every engineering decision serves `alarm_sound_start → accepted_post p50 ≤ 7s`. Menu manager is second; money is the trust surface that prevents churn.

## 2. Page list (13 screens + 1 overlay)

- S1 Login (role-scoped)
- S2 Onboarding / approval pipeline status
- S3 **Orders board** — buckets ACT NOW (amber border + ring) / IN KITCHEN (blue, stage buttons, 6-lane cap) / SCHEDULED / HISTORY; StatStrip capped at 3 (new, active, late-today)
- S3a **Alarm overlay** (full-screen, brand header, order card clone, CountdownRing top-right, tone family A loop ≤45s + triple-pulse vibration; Accept-only enabled)
- S4 Order detail (inline modifier expansion — never a new screen) with RejectReasonSheet (FR-ORD-03 chips + explicit confirm)
- S5 Menu manager list (thumbnails, inline price edit affordance, AvailabilitySwitch, store-health card on top)
- S6 Order history (searchable, dense 14sp variant, CSV export trigger)
- S7 Item editor (photo upload, option groups collapsed under items)
- S8 Numeric price sheet (big keys, old-vs-new confirm row, 1.5s autosave debounce)
- S9 Money tab (period gross, commission bps line, net projected, historical periods, invoice PDFs)
- S10 Reviews list + reply composer
- S11 More: hours & closures
- S12 Staff management
- S13 Settings (dark default, sound families, shift-online override docs)

## 3. Component list

1. `OrderCard` — urgency left border by bucket, monospaced 20/26 number stamp, item summary "3x Kacchi, 2x Borhani", Title S total, zone word, countdown ring slot
2. `CountdownRing` (56dp, 5dp stroke) — neutral >66%, amber 33–66%, red <33% with faster tick; gray "reconnecting" state on socket loss
3. `AlarmLayer` — wakes over any state; face-unlock skip flag per store config; layout shifts prohibited during active alarms
4. `RejectReasonSheet` — FR-ORD-03 codes as single-select chips, confirm button inside sheet bottom
5. `AvailabilitySwitch` — 84×40 track, icon labels at edges, optimistic write + sync chip
6. `StatStrip` — exactly 3 Bold 20 tabular slots with overline captions
7. `StageButtons` — fat PREPARING/READY controls, transition-guarded
8. `OrderLane` — IN-KITCHEN lanes capped 6 visible + honest "+N" counter
9. `PriceEditSheet` — big numeric keys, old/new confirm row
10. `StoreHealthCard` — one fix per visit; weekly nudge cap
11. `PayoutPeriodCard` — gross/commission-bps/net lines, invoice PDF link
12. `ReviewReplyComposer` — from rating detail
13. `ToneFamilyPlayer` — families A–E bundled per flavor; volume floor above media stream for A while online
14. `CoalescingNotifier` — 30s coalescing of rapid identical events unless queue grows
15. Shared core_ui components (overview §3), especially CountdownRing and IdempotentSubmitButton

## 4. Color palette (light + dark, dark defaults ON)

| Token | Light | Dark | Role / rule |
| --- | --- | --- | --- |
| color.primary | #2563EB | #2563EB (buttons) / #60A5FA (links) | Brand, selected tab, links |
| color.actionAccept | #15803D solid | #16A34A + white bold | The single green Accept button per card; deeper than success so white bold clears 4.8:1 on washed screens |
| color.rejectSurface | #FEF2F2 tint + #B91C1C outline | same tint pattern | Rejection entry only — red as pre-step, never confirm |
| color.queuePulse | #F59E0B | #FBBF24 | Amber ring = ball is yours; **reserved exclusively for actionable-now, banned elsewhere** |
| color.lateAlarm | #DC2626 border 3dp + tone C | #DC2626 (holds 3.9:1 as boundary) | Final third of SLA window |
| color.surface / canvas | #FFFFFF / #F1F5F9 | #0F172A / #101A2C | Cooler gray than customer app — separates device-from-counter |
| color.textPrimary / Secondary | #0F172A / #334155 | #F1F5FB / #94A3B8 | Both ≥7:1; darker secondary than consumer theme for arm's-length reading |
| color.success | #16A34A | #16A34A | Done-or-go states |

**Status color grammar (memorize once, apply everywhere):** blue = informational/working · green = done-or-go · amber = yours now · red = error/irreversible/deadline-crisis. No per-screen exceptions; violations fail design review. All critical boundaries use ≥2dp stroke besides color (urgency = position + border width + sound, triple-channel for colorblind staff).

Type: Title L 22/28 headers; order number stamp 20/26 Bold **monospaced** (kitchen callers shout numbers); Body 16/24, Dense 14/20 (history lists only); Countdown digits 22 SemiBold tabular. Touch floors: primary 56dp, secondary 48dp, list rows 64dp; bottom-third targets get double padding tolerance.

## 5. External APIs used

- PlateRoute REST: `auth`, `vendors/branches`, `menu/*`, `uploads/` (signed URLs), `orders/*` (board buckets, transitions, history, CSV), PayoutLedger + invoice endpoints (FR-PAY-07), `reviews/`, `notifications/*`, `chat/threads`, `calls/turn-credentials`, `v1/config`
- PlateRoute WS: order-board deltas (accept countdowns, bucket changes) — "reconnecting" gray on socket loss, never fake counts
- FCM **high-priority data messages** + local-notification fallback (killed-app alarm on both platforms; Android exact-alarm permission decision recorded)
- S3 signed direct uploads (menu photos), Sentry, Firebase Analytics/App Distribution

## 6. Alarm engineering notes (the product gate)

Optimistic accept: re-tint card instantly, idempotency-key guarded (MOB-C-04), rollback sheet only on server reject — never in happy path; haptic .heavy thump through kitchen noise. Coalescing: identical events 30s. Instrumentation: `alarm_sound_start_ms → accepted_post_ms` p50 ≤ 7s; `sla_breach_rate` per branch; `reject_reason_distribution`; `availability_flip_to_order_missed`; `payout_view_frequency` as trust pulse.

## 7. Git commit plan — target **70–90 commits**

| Phase | Content | Commits |
| --- | --- | --- |
| P0 | Scaffold, flavors, dark-default theme wiring, ARB | 6–8 |
| P1 | Auth + approval-pipeline onboarding: S1–S2 [MOB-RST-01] | 6–8 |
| P2 | Orders board + buckets + StatStrip: S3 [MOB-RST-06 base] | 10–12 |
| P3 | Alarm layer + FCM killed-app + CountdownRing WS sync: S3a [MOB-RST-04/05] | 12–14 |
| P4 | Accept/reject flows + RejectReasonSheet: S4 [MOB-RST-04/06] | 8–10 |
| P5 | Menu manager + availability + price sheet: S5, S7, S8 [MOB-RST-02/03] | 10–12 |
| P6 | Money tab + invoices: S9 [MOB-RST-08] | 6–8 |
| P7 | History + CSV + reviews: S6, S10 [MOB-RST-07/09] | 5–7 |
| P8 | Store-health, More tabs (hours/staff/settings): S11–S13 [MOB-RST-10] | 5–7 |
| P9 | Tone families, coalescing, a11y (fluorescent-light screenshot pass), bn QA | 4–6 |
| | **Total** | **72–92** |

## 8. App-specific concepts to learn (beyond overview §9)

1. Full-screen intent notifications / alarm overlays on Android: exact-alarm permissions, OEM battery-killer whitelisting reality, killed-app delivery verification matrix
2. WebSocket delta reconciliation for countdown timers (server-truth clocks, drift correction, honest reconnect state)
3. Optimistic UI with idempotency-key rollback semantics
4. Debounced autosave patterns (1.5s menu edits, 500ms availability) with sync chips
5. Multipart/signed-direct-upload flows for photos (no proxy through API)
6. CSV export request handling (async job → download link)
7. Audio focus + volume-stream separation for alarm tones; vibration pattern composition
8. Dense-variant typography tokens and layout wrapping rules

## 9. Definition of done

All MOB-RST-01..10 map to shipped screens; killed-app alarm verified on device matrix (both platforms); `alarm→accept p50 ≤ 7s` instrumented and green in staging; menu-edit round trip passes on staging (M2 exit); both themes screenshot-archived under fluorescent-light emulation; TalkBack reads "Accept order 1047, three items, 620 taka, auto cancel in 4 minutes".

