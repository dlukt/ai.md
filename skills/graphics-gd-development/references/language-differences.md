# Go vs GDScript Differences (graphics.gd context)

## Identifier/export behavior

- In Go, exported identifiers are `PascalCase`.
- In graphics.gd, exported Go fields/methods map into script/editor-facing symbols (typically snake_case on script side).
- Lowercase/private Go fields and methods are not exported to scripts.

## Paradigm differences

- Go: package-oriented, static typing, procedural + methods on types.
- GDScript: per-file class model, dynamic typing, object-oriented scripting.

When mixing Go + GDScript, keep cross-language contracts explicit:

1. Export only stable public fields/methods.
2. Keep internal implementation details private in Go.
3. Avoid renaming exported API casually once scripts depend on it.

## Math APIs

- Use Go `math` package for scalar `float64` operations.
- Use `graphics.gd/variant/*` math helpers for variant/vector operations.

## Resource loading

- Go supports typed resource loading via `Resource.Load[...]`, including global preloads where appropriate.
- GDScript uses `load("res://...")`.

Prefer typed load paths in Go where possible to catch type mistakes early.

## Signals

- In Go, define signals as struct fields using `graphics.gd/variant/Signal` types.
- Emitting signals is safe from goroutines (handlers are queued), but still keep broader threading rules in mind.
- In GDScript, signals are declared via the `signal` keyword.

## Porting checklist

1. Convert script-facing names intentionally.
2. Convert dynamic dictionaries/arrays to typed Go data where feasible.
3. Keep script<->Go boundaries narrow and stable.
4. Verify exported methods remain compatible with existing scenes/scripts.
