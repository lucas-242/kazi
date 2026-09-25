# Bottom navigation

Four destinations around a central slot, with `KaziNavBarFab` docked on the
bar's top edge. `KaziNavBar` is stateless — `selectedIndex` always comes from
the caller, which is what keeps the highlight honest on deep links, `pop` and
programmatic navigation.

| | |
|---|---|
| Destination ink | icon `navBarIcon` (21) + 3 + one label line (10 × 1.1) = **35** |
| Breathing room | `KaziInsets.xs` above and below the ink |
| Bar height | the two added: **51**, plus the safe area |
| Floor | `KaziSizings.navBarMinHeight` (48) — one touch target |
| Destination target | the full slot, ~79 × 51 on a 390pt phone |
| Central slot | `navBarCenterSlot` (74) for a `navBarFabSize` (54) button |

## The height is derived, and the inset is not ours to add

`KaziNavBar._heightFor` sizes the bar to a destination's own ink plus its
breathing room, reading the label's line through `MediaQuery.textScalerOf`.
Fixed at 48 the bar clipped its labels above 200% text scale; the bar is the
one strip of the app a user cannot scroll to finish reading, so it grows
instead. `navBarMinHeight` is only the floor, taken when the derived number
would fall under a touch target.

**The safe area is added by `BottomAppBar` itself** — it wraps whatever it is
given in a `SafeArea` of its own, around a child sized to `height`. Adding
`MediaQuery.paddingOf(context).bottom` to `height` therefore counts the inset
twice, which is what once made the bar 116pt tall on a phone with a 34pt home
indicator instead of 82. `kazi_nav_bar_test.dart` holds the line.

## The notch's margin is a hole, not a painted gap

The bar is notched around the button, with `notchMargin` at `KaziInsets.xs`.
`CircularNotchedRectangle` cuts the guest circle out of the bar, and
`BottomAppBar` hands it the button **inflated by that margin**
(`_BottomAppBarClipper` in
[`bottom_app_bar.dart`](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/bottom_app_bar.dart)).
So the gap is not ink the bar paints: it is an 8pt hole reaching 35pt below the
bar's top edge while the 54pt button ends at 27, and it shows whatever sits
behind the bar — with an ordinary `Scaffold`, the scaffold's background colour.

That is deliberate, and it is the reason the gap cannot simply be recoloured.
Changing what shows there means changing what is behind the bar (the shell's
`Scaffold` extending its body under it) or closing the margin to 0, which
removes the gap along with the colour. Neither is what this bar wants.

## A destination does not ink on touch

`splashFactory: NoSplash.splashFactory` and a transparent `highlightColor`. The
destination the tap opens is the feedback; focus and hover keep their own
overlays, which a touch never raises.

Three attempts got there. `InkResponse.radius` is a radius, not a diameter, so
the original `minTouchTarget` meant a **96pt** circle inside a slot 79 wide and
51 tall — sliced on all four sides, every tap. Shrinking it to the icon's size
only moved the problem, because the circle grows from wherever the finger
landed: any radius generous enough in the middle of the slot overruns it on a
tap near the edge. Containing it (`InkWell`) fixed the clipping and read as a
rectangle lighting up under a small round icon. A strip this short has no ripple
that reads as deliberate, so it has none.

## Accessibility

Each destination is one semantics node: the label, `button`, `selected`, and a
tap action. The numbers above clear WCAG 2.5.8 (AA, 24×24) and 2.5.5 (AAA,
44×44), and the derived height is what keeps 1.4.4 (resize text to 200%) true.
Contrast comes from `context.colors` — `text` on `card` for the active
destination, `textMuted` for the rest; both pass AA in either brightness, and
only the muted label in the light theme falls short of AAA (5.65:1).
