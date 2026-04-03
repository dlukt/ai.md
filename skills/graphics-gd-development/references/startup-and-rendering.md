# Startup and Rendering

## Integration patterns

### Pattern A: Go frame loop (`startup.Rendering`)

Use for code-centric projects and rendering-server-driven loops.

```go
frames := startup.Rendering()
for dt := range frames {
  _ = dt
  // frame logic
}
```

### Pattern B: Custom `MainLoop` (`startup.MainLoop`)

Use when replacing SceneTree as the main loop:

```go
type MyMainLoop struct {
  MainLoop.Implementation
}

func (m *MyMainLoop) Initialize() {}
func (m *MyMainLoop) Process(delta Float.X) {}
func (m *MyMainLoop) Finalize() {}

func main() {
  startup.MainLoop(new(MyMainLoop))
}
```

### Pattern C: Scene-tree (`startup.Scene`)

Use for editor/ecosystem interoperability:

```go
startup.LoadingScene()     // optional pre-setup wait
SceneTree.Add(Node.New())  // optional setup
startup.Scene()            // blocks until shutdown
```

### Pattern D: Redistributable extension (`startup.AsExtension`)

Use for extension libraries:

```go
func main() {
  startup.AsExtension()
}
```

Constraint: only one Go runtime per OS process; build all Go extensions together.

## Rendering layer choices

### Canvas

Use immediate-mode 2D rendering by implementing `Draw()` on `Node2D.Extension[T]`.
Good for loop-oriented architectures similar to Love2D/Ebiten.

### Scenes

Use for authored levels/environments and editor-heavy workflows.
Prefer this when artists/designers need scene-tree tools.

### RenderingServer

Use lower-level retained rendering API for advanced rendering systems.

### RenderingDevice

Use very low-level Vulkan/OpenGL-like control.

## Startup order checklist

1. Register custom classes first.
2. Wait for readiness (`LoadingScene`/`Rendering`) before engine-dependent actions.
3. Add initial nodes/resources before `startup.Scene` when required.
4. Avoid global object usage before startup readiness.

## Common startup mistakes

- Import `graphics.gd/startup` outside `main` package.
- Mix multiple integration patterns without clear ownership.
- Create globals that are accessed before startup completion.
- Register classes after startup function has already been called.
