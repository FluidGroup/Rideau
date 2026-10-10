# Self-sizing layout reentry

The reported iPhone Duo failure shows `RideauHostingView.resolve` measuring the
body while `RideauContentContainerView.layoutSubviews` reports changed body
bounds. The host's callback synchronously calls `layoutIfNeeded` again. The
repeating stack and UIKit observation feedback warnings are consistent with
reentrant layout exhausting the stack.

The host now owns the complete layout transaction, including horizontal
constraints, UIKit layout, and fitting. Body-bounds observations invalidate the
next pass. Explicit requests normally update synchronously or through their
supplied animator; requests received during a pass are drained on the next main
queue turn. A pending animated request retains the previous vertical geometry
until its animator can commit the new height. Mixed animated and unanimated
requests share that commit, and every supplied animator is started.

Body layout before fitting is retained to propagate safe areas. Fitting does not
write the container height constraint. Invalidations received during fitting
remain pending, and unchanged constraint constants are not assigned again.

## Verification

The new regressions detect synchronous host layout and nested fitting on 2.5.0.
The patched package passes all 19 tests on iPhone 18 Pro / iOS 27.0 and iPhone Duo
/ iOS 27.1, both from 2.5.0 and current main. Coverage includes both resizing
options, mixed sizing requests, intermediate animation positions and completions,
hosted SwiftUI text and safe areas, adaptive widths, snap points, and dragging.

A dedicated iPhone Duo / iOS 27.1 lab linked to the 2.5.0 backport also exercised
visible-area and fixed-body sizing, Auto/70% snaps, content grow/shrink, folding,
and rotation. In fixed-body mode, the software keyboard appeared, accepted an
on-screen key, and dismissed with the sheet restored. Input persisted across
Open/Closed transitions. The captured process logs contain no observation
feedback loop, `EXC_BAD_ACCESS`, or unsatisfiable-constraint messages during this
pass. This verifies the isolated host, rather than the consuming app's screens.

```sh
xcodebuild -workspace .swiftpm/xcode/package.xcworkspace -scheme Rideau \
  -destination 'platform=iOS Simulator,name=iPhone Duo' test
```

The 2.5.0 backport is on `muukii/prevent-self-sizing-layout-reentry`. Main uses
the newer drag implementation and intrinsic-size observation, which are retained
by the forward port. Integration in the consuming app requires a separate
dependency update; these package tests do not verify that app's full screens.
