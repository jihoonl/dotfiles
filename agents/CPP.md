# C++ Development Guide

## Required Baseline
- Use ISO C++17; do not use compiler extensions or newer language or library features.
- Read the project's build, test, formatting, and contribution instructions.
- Match existing naming, layout, and error-handling style where it does not conflict with this guide.
- Search for an existing helper or pattern before adding one.

## MISRA C++:2023
- MISRA C++:2023 is the coding standard; run the project's MISRA static analysis on changed code.
- Document and review every deviation with its scope, rationale, and safety impact.
- Make all conversions explicit with named casts; no C-style casts, no implicit narrowing or sign changes.
- Initialize every object at its declaration; never read an uninitialized value.
- Handle every enum value in a `switch`; no implicit fallthrough, and give non-exhaustive switches a `default`.

## Safety-Oriented Interface Separation
- Put safety-critical operations behind their own minimal interface, separate from convenience, tuning, and monitoring APIs.
- Give each interface one role; callers depend only on the interface for their role.
- Validate inputs at the interface boundary and fail detectably; never proceed on invalid state.
- Encode units, ranges, and states in types (strong types, scoped enums) so an invalid call fails to compile.
- Mark control-loop and safety-path functions `noexcept` and keep them allocation-free by contract.

## Deterministic Memory and Timing
- Use RAII for memory, files, locks, and other resources.
- Prefer value semantics and smart pointers; avoid owning raw pointers and manual `new`/`delete`.
- Allocate required dynamic memory during initialization, not during steady-state or control-loop execution.
- Watch for hidden allocations on control paths: `std::string`, `std::function`, capturing lambdas, and container growth all touch the heap.
- Give every buffer and container an explicit maximum capacity; do not allow unbounded growth.
- Keep stack usage bounded and avoid recursion unless its maximum depth is proven.
- Never block unboundedly in a control loop; any lock taken there needs a proven short hold time and priority inheritance.
- Pass data between RT and non-RT threads through preallocated lock-free or bounded-wait structures, never shared locks held across slow work.

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
