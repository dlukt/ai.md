# ClassDB and Instances

## Registration baseline

Register custom classes by embedding an extension base and calling `classdb.Register`.

```go
type MyClass struct {
  Node.Extension[MyClass]
  MyProperty string
}

func (m *MyClass) Ready() {}

func main() {
  classdb.Register[MyClass]()
  startup.Scene()
}
```

Rules:

- Exported fields become properties in editor/scripts.
- Exported methods become script-callable methods.
- Prefer explicit registration in `main` or package `init`.

## Struct tags

- ``gd:"rename"``: rename property in engine.
- ``range:"min,max,step,flags"``: configure editor slider range.
- ``group:"name"``: group property in editor inspector.
- ``gd:"-"``: hide field from engine exports.

## Tool mode (run in editor)

Embed `classdb.Tool` in the extension struct to run callbacks in editor.
Use `Engine.IsEditorHint` to branch editor/runtime behavior.

## Constructors, static functions, renaming

- Register constructor function: `classdb.Register[MyClass](NewMyClass)`.
- Register static/extra functions by passing functions into `Register`.
- Rename methods/functions by passing `map[string]any` to `Register`.

## Constants and enums

- Register constants with `map[string]int`.
- Prefer `graphics.gd/variant/Enum` for enum definitions; enum types used in methods register cleanly.

## Singletons

Embed `*.Singleton[T]` to create one startup instance exposed globally to scripts.
Singleton pointers can be auto-filled into other extension structs.

## Inheritance patterns

Prefer struct embedding for shared behavior.
Use `classdb.ExtensionInherits[Parent, Child]` only when explicit engine hierarchy is required.

## Instances and conversions

- Instantiate engine classes with `Type.New()` -> `Type.Instance`.
- Convert to lower-level APIs with `Type.Advanced(instance)`.
- Use `MoreArgs()` when optional arguments are required.
- Use `Object.As[T]` and `Object.Is[T]` for safe checks.
- Use `Object.To[T]` only when type is known correct (panics on mismatch).

## Declarative children

For `Node`-derived extensions, exported `Node`-derived fields auto-bind to matching children (or auto-create when absent).
Support names/paths/unique names via `gd` tags, for example:

- ``gd:"Label"``
- ``gd:"Path/To/Node"``
- ``gd:"%UniqueNode"``

Use declarative children to keep scene dependencies explicit in type definitions.
