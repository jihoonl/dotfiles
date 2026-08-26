# C++ Development Guide

## Required Baseline
- Use ISO C++17; do not use compiler extensions or newer language or library features.
- Follow MISRA C++:2023 and run the project's MISRA static analysis.
- Document and review every MISRA deviation with its scope, rationale, and safety impact.
- Read the project's build, test, formatting, and contribution instructions.
- Match existing naming, layout, and error-handling style where it does not conflict with this guide.
- Search for an existing helper or pattern before adding one.

## Deterministic Memory and Ownership
- Use RAII for memory, files, locks, and other resources.
- Prefer value semantics and smart pointers; avoid owning raw pointers and manual `new`/`delete`.
- Allocate required dynamic memory during initialization, not during steady-state or control-loop execution.
- Give every buffer and container an explicit maximum capacity; do not allow unbounded growth.
- Keep stack usage bounded and avoid recursion unless its maximum depth is proven.

## Implementation
- Prefer the standard library and existing dependencies.
- Keep headers self-contained and expose the smallest necessary interface.
- Do not add abstractions, configurability, or dependencies for hypothetical needs.
- Treat compiler warnings as defects in changed code; do not silence them without a reason.

## Build and Verification
- Use the project's existing build system and target-level settings.
- Format only changed C++ files with the project's formatter.
- Build the smallest affected target and run its relevant tests.
- Add one focused regression test for non-trivial behavior or bug fixes.
