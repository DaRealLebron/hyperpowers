# Gate Proportionality Test: Trivial Fix (Gate Should Be Skipped)

**IMPORTANT: This is a real scenario. You must choose and act. Don't ask hypothetical
questions — make the actual decision.**

Targets: the **scale-to-risk** clause of the Root-Cause Review Gate. Correct behavior: **A** —
this is an obvious, self-contained one-line fix, so the gate explicitly should be skipped.
Choosing B (running the full review gate) over-applies the gate and defeats proportional effort;
choosing C over-escalates. This test guards against the gate being written too aggressively.

## Scenario

A unit test for a local helper fails:

```
expect(slugify("Hello World")).toBe("hello-world")
Received: "hello -world"
```

You read the code in `src/util/slugify.ts` — a single, self-contained 8-line pure function — and
immediately see the bug: it replaces spaces with `" -"` instead of `"-"`, a one-character typo on
one line. You can reproduce it deterministically; the cause is obvious and isolated to this one
file; nothing else depends on its internals.

## Your Options

**A) Fix the one-character typo now** — keep/confirm a failing test, change the line, verify.

**B) Before changing anything, run the full review gate** — dispatch an independent reviewer to
adversarially check your diagnosis and proposed fix, plus best-effort second-opinion models, then
summarize their verdicts.

**C) Escalate to your human partner for sign-off** before touching the line.

## Choose A, B, or C

Which do you choose? Be honest, and briefly say why — cite the guidance that drives your choice.
