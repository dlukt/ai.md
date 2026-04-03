# Variants, Memory, and Performance

## Variant model

graphics.gd provides:

- Convenience types: easier API ergonomics.
- High-performance types: lower allocation overhead in hot paths.

Examples:

- `String` convenience `string` vs high-performance `String.Unicode`
- `NodePath` convenience `string` vs high-performance `Path.ToNode`
- `Dictionary` convenience `struct/map` vs high-performance `Dictionary.Any`
- `Array` convenience `[]T` vs high-performance `Array.Any`

Use high-performance variants in hot loops and frequently-called paths.

## Reference invalidation model

graphics.gd tracks references per frame.
When a reference is not reachable from an `Extension[T]` and remains unused for two or more frames, it can be invalidated.
Using invalidated references can panic.

Keep long-lived references alive by:

1. Storing them on `Extension[T]` fields.
2. Touching/using them each frame when appropriate.
3. Calling `Object.Use` when explicit keep-alive is required.

## Globals and startup safety

Global objects are only valid after:

- `startup.LoadingScene`, or
- `startup.Rendering`, or
- `startup.Scene`, or
- inside an engine callback.

Avoid accessing globals before startup readiness.

## Goroutines

Memory safety protections are primarily single-thread oriented.
When using goroutines:

- Use only thread-safe APIs.
- Prefer channels/signals for communication.
- Avoid shared mutable engine state without synchronization.

## Manual memory management

Use advanced manual lifecycle only when profiling proves needed:

- `Object.Leak(...)` to bypass automatic invalidation/lifecycle tracking.
- `Object.Free(...)` when done.

`Object.Free` is safe to call multiple times.
Primary risk is memory leak from forgotten frees.

## Performance checklist

1. Prefer engine calls that do not return values in tight loops.
2. Reuse constant strings to avoid repeated engine copies.
3. Pre-initialize and reuse advanced variant values.
4. Prefer main-thread engine calls for speed and safety.
5. Add trampolines for very hot script-exposed methods that otherwise rely on reflection exports.

## Trampoline guidance

Use `classdb.MakeTrampoline` for hot paths where script->Go method dispatch allocates too much.
Only add trampolines after identifying high-frequency call sites.
Do not add them for standard virtual callbacks (`Ready`, `Process`) unless profiling demonstrates need.
