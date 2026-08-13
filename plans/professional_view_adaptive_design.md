# Professional View Adaptive Design Plan

## Objective

Make the complete Professional view (`Work` and `Other Me`) usable from narrow
phones through large desktop windows without clipping, overflow, hidden actions,
unreadable text, or pointer-only interactions. Preserve the current Gruber Darker
visual identity and the Developer view behavior.

## Current evidence

- `PortfolioPage` applies one global `< 600` check, fixed 48 px vertical page
  padding, and a bottom-right mode toggle that can cover scrollable content.
- Most sections use fixed 24 px horizontal padding rather than a shared,
  constraint-aware gutter.
- `HeroSection` keeps the name and logo in one row, gives the mobile name a
  fixed 32 px size, and uses a long fixed resume-button label.
- `ContributionHeatmap` always renders 52 week columns. On narrow widths its
  calculated squares become too small to read or interact with.
- `ProjectsSection` uses a fixed 200 px carousel, fixed 100 x 180 thumbnails,
  and a gallery overlay whose counter, close control, and caption compete for
  limited phone height.
- `ExperienceSection` combines company and period into one subtitle; the
  ExpansionTile trailing control further reduces compact width.
- `FooterSection` uses a non-wrapping social row and a full email address inside
  a text button.
- `DevSetupSection` calculates two-column card widths from the full viewport,
  not the local max-width constraint.
- Skill details currently request a 720 px dialog body and need compact-height
  behavior as well as compact-width behavior.
- Existing tests only prove that the app and hero mount. They do not exercise
  narrow widths, large text, landscape phones, scrolling, dialogs, or overflow.

## Target viewport matrix

Every implementation slice must cover these logical sizes:

| Class | Required sizes | Purpose |
| --- | --- | --- |
| Compact narrow | 320 x 568, 360 x 640 | Small and older phones |
| Compact modern | 390 x 844, 412 x 915 | Common current phones |
| Compact landscape | 640 x 360, 844 x 390 | Short-height behavior |
| Medium | 600 x 960, 768 x 1024 | Foldables and tablets |
| Expanded | 1024 x 768, 1440 x 900 | Laptop and desktop regression |

Repeat the compact matrix at text scale 1.0 and 1.3. Exercise critical cards,
navigation, and dialogs at text scale 2.0.

## Layout contract

1. Prefer local `LayoutBuilder` constraints over repeated full-screen
   `MediaQuery.sizeOf(context)` checks.
2. Use three shared window classes: compact `< 600`, medium `600-839`, and
   expanded `>= 840`. Components may switch earlier when their own content
   requires it.
3. Use shared horizontal gutters: 16 px compact, 24 px medium, 32 px expanded.
   Keep readable content at a 1000 px maximum width.
4. Let content determine height. Fixed heights are allowed only for bounded
   media with an explicit aspect ratio and compact fallback.
5. Wrap or stack actions before reducing readable text below the theme scale.
6. Keep interactive targets at least 48 x 48 logical pixels and preserve
   keyboard focus, semantic labels, and visible focus/hover states.
7. Respect `SafeArea` and ensure floating controls never hide the last scrollable
   content.

## Implementation slices

### 1. Adaptive foundation and page shell

- Add one small source of truth for window class, gutter, section spacing, and
  content max width. Avoid scattering new numeric breakpoint checks.
- Rebuild the Professional tab shell with constraint-aware outer padding and
  compact vertical rhythm.
- Wrap the top tab header and mode toggle in safe-area handling.
- Reserve scroll padding for the floating mode toggle or move it into a
  non-overlapping adaptive control location.
- Keep tab state and scroll positions stable while resizing or rotating.

**Acceptance:** both tabs render and scroll at every target size; first and last
content remain reachable; no control overlaps the system inset or content.

### 2. Compact navigation and hero

- Make tab headers fill compact width without requiring horizontal scrolling
  when both labels fit.
- Allow the name/logo row to stack or shrink by local constraint. Keep the logo
  visible without forcing name overflow.
- Use responsive theme typography rather than isolated fixed mobile font sizes.
- Make the resume action use a compact label or full-width button when needed.
- Give the contribution heatmap an explicit compact strategy: show fewer recent
  weeks, horizontally scroll a minimum-size grid, or aggregate cells. Do not
  render unreadable subpixel squares.

**Acceptance:** 320 px width and 200% text scale show the name, title, summary,
resume action, contribution label, grid, and legend without overflow.

### 3. Work-section cards

- Keep skill chips wrapping, but cap each chip to available width and allow long
  labels to wrap cleanly. Make the skill summary dialog use viewport-relative
  width/height and scroll its content and actions independently when necessary.
- Refactor project cards around local constraints. Use aspect-ratio media,
  compact thumbnail sizing, wrapping link actions, and a phone gallery layout
  where close/counter controls never cover the caption.
- Split experience company and period into adaptive lines on compact widths.
  Verify expanded descriptions remain readable and the expansion control keeps
  a 48 px target.
- Make education cards follow the same compact metadata pattern.

**Acceptance:** every skill opens/closes; every project link remains reachable;
project galleries support swipe and close; every experience expands at 320 px
and 200% text scale without framework overflow errors.

### 4. Other Me and footer

- Calculate Dev Setup columns from parent constraints. Use one column on compact,
  two on medium, and consider denser layouts only when card minimum width holds.
- Let hobby rows stack artwork above text when horizontal text space becomes too
  narrow.
- Keep inspiration names and link actions in constraint-driven wrap/stack
  layouts rather than a screen-width boolean.
- Wrap footer social actions. Make long email addresses selectable/readable and
  keep the mail action reachable without horizontal clipping.
- Reduce oversized compact section gaps while preserving clear grouping.

**Acceptance:** all `Other Me` content and footer actions render at the complete
viewport matrix with no clipped text or horizontal scrolling.

### 5. Accessibility, motion, and regression hardening

- Add semantic section headings and useful labels for image, gallery, tab, skill,
  and mode-switch controls.
- Verify keyboard traversal and activation for chips, expansion controls,
  gallery controls, links, and tabs. Replace bare `GestureDetector` interaction
  where it prevents focus or button semantics.
- Respect reduced-motion preferences for large transitions and hover scaling.
- Confirm contrast and focus visibility against the Gruber palette.
- Test missing and failed remote images with stable fallbacks.

**Acceptance:** keyboard-only navigation reaches all actions in logical order;
screen-reader labels identify controls; reduced motion remains usable; failed
images do not change layout or throw.

## Test and verification strategy

1. Add a viewport test helper that sets logical size, device pixel ratio, and
   text scale, then restores them in teardown.
2. Add shell-level widget tests for every target width. Fail on any
   `FlutterError`, especially yellow/black RenderFlex overflow messages.
3. Add focused compact tests for hero, heatmap, skill dialog, project gallery,
   experience cards, Dev Setup, hobbies, inspirations, and footer.
4. Make contribution data injectable or provide a deterministic fake so
   responsive tests never depend on GitHub/GitLab availability.
5. Add a small golden set for 320 x 568, 390 x 844, 768 x 1024, and 1440 x 900
   after structural behavior is stable. Keep behavior assertions primary.
6. Manually inspect the built web app with device emulation, keyboard-only
   navigation, landscape rotation, text zoom, and slow/failed image requests.

Run after each slice:

```bash
fvm dart format lib/ test/
fvm flutter analyze
fvm flutter test
fvm flutter build web --release --wasm --base-href "/thgportfolio/"
```

## Definition of done

- All target viewports and text scales pass without overflow or hidden content.
- Both Professional tabs remain fully functional with touch, mouse, and keyboard.
- Remote image failure has a deterministic fallback.
- Generated `docs/` matches the validated release build.
- Developer view behavior is unchanged.
- Tests document each adaptive layout decision so later fixed-size regressions
  fail automatically.

## Out of scope

- Redesigning the Developer view.
- Replacing the Gruber Darker visual system.
- Rewriting portfolio content or changing project ordering.
- Adding a general-purpose design-system package before repeated needs justify it.
