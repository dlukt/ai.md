# Getting Started and Workflow

## Required setup

Install or update runtime package in a project:

```bash
go get -u graphics.gd@release
```

Install or update CLI (run outside project directory):

```bash
go install graphics.gd/cmd/gd@release
```

Use `gd` command in project root:

```bash
gd run
gd test
```

For shared-library integration without `gd`, use:

```bash
go build -o example.so -buildmode=c-shared
```

## Environment details

- Ensure `go` is installed and available.
- Ensure `$GOPATH/bin` is in `PATH` so installed tools (including `gd`) are executable.
- By default, graphics.gd manages toolchain dependencies for you.
- Set `GDTOOLCHAIN=local` to force using locally installed toolchain dependencies.
- Tooling dependencies are installed under `$GDPATH/bin` (default `$GDPATH=$HOME`).

## Default project behavior

- In Go projects, `gd` creates a `graphics/` directory at module root for Godot assets.
- Running `gd` with no arguments starts the editor.
- Scene-tree projects created with `gd` commonly load `main.tscn` by default.

## Development workflow guidance

Use this sequence:

1. Model domain/state in Go structs first.
2. Register classdb extensions intentionally.
3. Use Godot editor for assets/spatial composition.
4. Keep runtime logic in Go methods.

## Planned hot-reload/snapshot notes

Hot reload and snapshots are planned features, not guaranteed currently.
Still design for future compatibility:

- Prefer exported struct fields.
- Prefer `startup.Scene`.
- Avoid relying on globals/anonymous functions for persistent state.
- If persistent state is required, use `startup.OnSuspend` and `startup.OnRestore`.
- For class-specific state, implement `Suspend(Dictionary.Any)` / `Restore(Dictionary.Any)`.

## Practical safety checks

- Update both `graphics.gd` module and `gd` CLI together.
- Re-run `gd run` after startup flow edits.
- Re-run `gd test` after classdb registration/type conversion edits.
- Use `gd` as the default command unless there is an explicit requirement to manage all build flags manually.
