# Motion configuration review

Reviewed against review-animations, adapting web rules to Flutter. Preserving
the existing full-motion timings and geometry is an explicit requirement.

| Before | After | Why |
| --- | --- | --- |
| Controllers implicitly share enter/reposition/exit settings | Independent phase config in lib/src/motion.dart, selected at lib/src/toast.dart:680 | Applications can tune motion by intent while defaults retain trajectories |
| Missing system reduced-motion handling | Policy resolution at lib/src/toast.dart:535 and snap/fade handling at :683 | Reduced motion removes automatic travel/scale and retains a 150 ms ease-out fade |
| Fixed 250 ms removal timer | Completion in lib/src/lifecycle.dart:46 and lib/src/utils.dart:127 | Long custom exits finish and multiple viewers wait for each participant |

## Performance

Paint translation and independent controllers are retained. Content remains
outside tick/drag callbacks (lib/src/toast.dart:719). Builder counts increase
during structural exit removal in the fixture. Same-device timings are
mixed; this API addition does not establish a uniform performance improvement.
See RESULTS.md for timing references and thermal limits.

## Interruptibility and timing

Retargeting preserves controller update order and spring velocity
(lib/src/utils.dart:104). Direct drag remains immediate
(lib/src/toast.dart:748); custom return motion is separate. Tests cover phase
selection, interruptions, long/shared exits, disposal and index changes.
Completion removal deliberately permits the final toast to finish its exit;
this is a lifecycle behavior change from the former cutoff.

## Accessibility and cohesion

Full-motion defaults pass all 83 original golden frames without regeneration.
Reduced/none policies cover runtime changes and missing MediaQuery. Existing
top swipe velocity threshold remains asymmetric (lib/src/toast.dart:652); its
fix is deferred to preserve current interaction behavior. TalkBack remains
without dedicated regression coverage.

**Approve** within the agreed scope. 45 tests, analyzer, formatting and diff
checks pass. Profile benchmark and screen-awake repeat pass on Pixel 7a.
Debug hot restarts succeed on macOS and Android. The normal Android example
has existing RenderFlex overflows, limiting the manual feel check. Reduced
motion and drag cancellation are verified in widget tests; a full recorded,
frame-scrubbed device review of every custom phase was not performed.
