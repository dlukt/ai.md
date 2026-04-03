---
name: graphics-gd-development
description: Implement, debug, and refactor Go + Godot projects built with graphics.gd. Use when requests mention graphics.gd, `gd` command workflows, `graphics.gd/startup`, `graphics.gd/classdb`, class registration, extension structs, variant types, reference invalidation/memory safety, or rendering choices (Canvas, Scenes, RenderingServer, RenderingDevice).
---

# Graphics Gd Development

## Goal

Execute graphics.gd tasks with a repeatable flow that minimizes startup mistakes, classdb registration bugs, and reference invalidation panics.
Use explicit checklists and references so weaker models can make safe, verifiable edits.

## Workflow

1. Scan the project before making changes.
2. Choose the correct engine integration pattern.
3. Apply classdb/instance patterns that match graphics.gd semantics.
4. Apply reference invalidation and threading safety rules.
5. Choose rendering level (Canvas, Scenes, RenderingServer, RenderingDevice) based on task needs.
6. Verify with targeted checks and run commands.

## Step 1: Scan Project

Run the bundled scanner first:

```bash
bash scripts/scan_graphics_gd_project.sh <project-root>
```

If scanning the `graphics.gd` framework repository itself, rerun with:

```bash
INCLUDE_GENERATED=1 bash scripts/scan_graphics_gd_project.sh <project-root>
```

Use scan output to identify:
- Startup mode (`startup.Rendering`, `startup.MainLoop`, `startup.Scene`, `startup.AsExtension`)
- Registered classes (`classdb.Register[...]`)
- Extension/singleton usage (`*.Extension[T]`, `*.Singleton[T]`)
- Methods that affect behavior (`Ready`, `Process`, `Draw`, `PhysicsProcess`)

## Step 2: Pick Integration Pattern

Pick one mode and keep code consistent with it:

- `startup.Rendering`: Use for code-centric frame loops and direct rendering server usage.
- `startup.MainLoop`: Use when replacing `SceneTree` with a custom `MainLoop.Interface`.
- `startup.Scene` (+ optional `startup.LoadingScene`): Use for scene-tree/editor-centered projects.
- `startup.AsExtension`: Use for redistributable GDExtensions. Build all Go extensions into one shared library per process.

Import `graphics.gd/startup` only from the `main` package.

See [startup-and-rendering.md](references/startup-and-rendering.md).

## Step 3: Apply ClassDB Patterns

When adding or changing custom classes:

1. Embed the correct base (`Node.Extension[T]`, `Node2D.Extension[T]`, etc.).
2. Register every custom class with `classdb.Register[...]()` before handing control to startup.
3. Keep editor/script exports intentional:
- Uppercase fields become properties.
- Uppercase methods become script-callable methods.
- Use struct tags for `gd`, `range`, and `group`.
4. Use singletons intentionally with `*.Singleton[T]`; avoid implicit global state unless required.

When handling instances:

- Create engine classes with `Type.New()` to get `Type.Instance`.
- Convert to lower-level APIs with `Type.Advanced(instance)` (and `MoreArgs` where needed).
- Convert safely across object types with `Object.As`, `Object.Is`, `Object.To`.

See [classdb-and-instances.md](references/classdb-and-instances.md).

## Step 4: Enforce Memory and Thread Safety

Treat reference invalidation as a primary failure mode.

1. Keep long-lived engine references reachable from `Extension[T]`, or explicitly keep alive with `Object.Use`.
2. Avoid stale references across frames for high-performance types (`Array.Any`, `Dictionary.Any`, `Signal.Any`, `Callable.Function`, `String.Name`, `Path.ToNode`, packed arrays).
3. Use object IDs only when needed; they are safer for infrequent storage but slower than direct instance use.
4. Access globals only after engine startup (`LoadingScene`, `Rendering`, `Scene`, or engine callback context).
5. Use only thread-safe APIs from goroutines; prefer channels/signals over shared mutable state.
6. Use manual leak/free (`Object.Leak`, `Object.Free`) only when profiling proves lifecycle tracking overhead is a bottleneck.

See [variants-memory-performance.md](references/variants-memory-performance.md).

## Step 5: Choose Rendering Layer

Match rendering strategy to project constraints:

- Canvas (`Draw` on `Node2D.Extension`): Use for immediate-mode 2D and game-loop-like architecture.
- Scenes: Use for editor-centric composition, authored levels, and node ecosystem interoperability.
- RenderingServer: Use for lower-level retained rendering (often 3D-heavy systems).
- RenderingDevice: Use for the lowest-level Vulkan/OpenGL-style API needs.

See [startup-and-rendering.md](references/startup-and-rendering.md).

## Step 6: Validate

Run the smallest useful verification set:

```bash
gd run
gd test
go test ./...
```

If the task is startup-sensitive, verify startup order explicitly:

1. Registration happens before startup call.
2. `LoadingScene`/scene setup happens before `startup.Scene`.
3. No invalid global access before engine readiness.

## Fast Recipes

### Add a new custom node class

1. Define struct with `Base.Extension[T]`.
2. Add exported fields/methods intentionally.
3. Register with `classdb.Register[T]()`.
4. Attach to scene tree (`SceneTree.Add(...)`) or instantiate from scripts.
5. Run `gd run` and verify `Ready`/`Process` behavior.

### Fix reference invalidation panic

1. Identify where stale reference is held past two unused frames.
2. Move reference into an `Extension[T]` field, or call `Object.Use` each frame.
3. Replace long-lived references with ID-based lookup where applicable.
4. Re-test with the same runtime path that previously panicked.

### Port a pure Go loop to graphics.gd

1. Start from `startup.Rendering` frame iteration.
2. Keep rendering logic independent from scene tree until needed.
3. Introduce classdb extensions only when editor/script interop is required.

## References

- [getting-started-and-workflow.md](references/getting-started-and-workflow.md)
- [startup-and-rendering.md](references/startup-and-rendering.md)
- [classdb-and-instances.md](references/classdb-and-instances.md)
- [variants-memory-performance.md](references/variants-memory-performance.md)
- [language-differences.md](references/language-differences.md)
- [source-links.md](references/source-links.md)
