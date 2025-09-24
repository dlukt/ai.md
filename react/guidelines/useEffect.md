# AGENTS.md — React Effects Playbook (Based on “You Might Not Need an Effect”)

> **Purpose**: Give humans and code agents a clear, enforceable policy for when to use (and avoid) React Effects. Effects are for **syncing with external systems**. If no external system is involved, you probably **don’t need** an Effect.

---

## 1) Golden Rule & Quick Decision Tree

**Golden Rule**: *Use an Effect only to synchronize your UI with an **external system** (DOM APIs, subscriptions, timers, network, storage, URL, non-React widgets).* Otherwise, compute during **render** or run logic in **event handlers**.

**Decision Tree**:

1. **Can the value be computed from props/state during render?** → Compute it; **don’t** store a duplicate in state.
2. **Is this work a direct response to a user action?** → Do it in the **event handler** (not an Effect).
3. **Do you need to subscribe to something external?** → Use **`useSyncExternalStore`** or an Effect + cleanup.
4. **Are you reading/writing layout or DOM after paint?** → Use **`useEffect`**; use **`useLayoutEffect`** only if you must measure/mutate **before** paint.
5. **Is this app-wide one-time init?** → Prefer **module scope** or an idempotent guard over a mount-only Effect.
6. **Fetching data tied to navigation/URL/query?** → Prefer framework data APIs. If inside a component, use an Effect with **cancellation** and **stale-response guards**.

---

## 2) Prefer Render-Time Derivation (Avoid Derived State in State)

**Anti-pattern** (duplicating derived data):

```tsx
// ❌ Avoid: copying props into state and syncing via Effect
function Price({ amount, taxRate }: { amount: number; taxRate: number }) {
  const [total, setTotal] = React.useState(0);
  React.useEffect(() => { setTotal(amount * taxRate); }, [amount, taxRate]);
  return <span>{total}</span>;
}
```

**Good** (derive during render):

```tsx
// ✅ Compute in render; memoize only if expensive
function Price({ amount, taxRate }: { amount: number; taxRate: number }) {
  const total = amount * taxRate; // or useMemo if truly expensive
  return <span>{total}</span>;
}
```

**Guidelines**

* Store **minimal** state only (inputs you can’t compute from other state/props).
* Use `useMemo` only for **expensive** computations or referential stability.
* Use `useRef` for **mutable, non-UI** values that shouldn’t trigger re-render.

---

## 3) State Resets & Transitions Without Effects

**Reset a subtree on key change**:

```tsx
// ✅ Changing `key` remounts child and resets its state
<Wizard key={userId} userId={userId} />
```

**Adjust just what changed**: Prefer expressing transitions in render instead of running a “reset” Effect.

**Prefer IDs over objects in state**: Store `selectedId` and derive `selectedItem` from the list during render.

---

## 4) Event-Driven Work Belongs in Event Handlers

**Anti-pattern** (inferring events via Effects):

```tsx
// ❌ Don’t watch state and then “guess” which event occurred
const [count, setCount] = useState(0);
useEffect(() => { if (count > 0) sendClick(); }, [count]);
```

**Good** (do it directly in the handler):

```tsx
// ✅ Keep cause and effect together
function Button() {
  const [count, setCount] = useState(0);
  const onClick = () => {
    sendClick();
    setCount(c => c + 1);
  };
  return <button onClick={onClick}>Clicked {count}</button>;
}
```

**Notify parents in the same handler**: Lift state or call callbacks; avoid child Effects that “push” data up later.

---

## 5) External Stores & Subscriptions

Prefer **`useSyncExternalStore`** for correctness with concurrent rendering:

```tsx
// ✅ Example: subscribe to a store
function useOnlineStatus() {
  return React.useSyncExternalStore(
    (onStoreChange) => { window.addEventListener('online', onStoreChange); window.addEventListener('offline', onStoreChange); return () => { window.removeEventListener('online', onStoreChange); window.removeEventListener('offline', onStoreChange); }; },
    () => navigator.onLine,
  );
}
```

If you must use an Effect for subscriptions, **return a cleanup** and ensure the subscription source is stable.

---

## 6) Data Fetching Patterns (Component-Level)

When not handled by the framework/router:

```tsx
function Products({ query }: { query: string }) {
  const [items, setItems] = useState<Product[] | null>(null);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const ac = new AbortController();
    let alive = true; // stale-response guard
    fetch(`/api/products?q=${encodeURIComponent(query)}`, { signal: ac.signal })
      .then(r => r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)))
      .then(data => { if (alive) setItems(data); })
      .catch(e => { if (alive && e.name !== 'AbortError') setError(e); });
    return () => { alive = false; ac.abort(); };
  }, [query]);

  if (error) return <ErrorView error={error} />;
  if (!items) return <Spinner />;
  return <List items={items} />;
}
```

**Rules**

* Abort on unmount/param change.
* Guard against stale responses.
* Tie dependencies to the **source of truth** (e.g., `query`).
* Prefer framework loaders/server components when available.

---

## 7) DOM & Layout Side-Effects

* **`useEffect`**: post-paint work (adding classes, `document.title`, non-critical DOM writes).
* **`useLayoutEffect`**: measure/mutate **before** paint (rare; can block rendering). Keep minimal and fast.

**Examples**

```tsx
// ✅ Document title
useEffect(() => { document.title = `Profile – ${user.name}`; }, [user.name]);

// ✅ Measure after mount (prefer ResizeObserver when possible)
useLayoutEffect(() => {
  const rect = ref.current?.getBoundingClientRect();
  // ... use rect to set layout-critical state
}, []);
```

---

## 8) One-Time App Initialization

* Prefer **module-level** initialization (executed once when the module loads).
* If you must run once per app session inside a component, use an **idempotent guard**:

```tsx
let didInit = false;
export function AppInit() {
  if (!didInit) {
    didInit = true; initAnalytics();
  }
  return null;
}
```

---

## 9) Common Recipes

* **Controlled inputs**: State holds the value; no Effects needed.
* **Debounced search**: Keep raw input in state; use a custom `useDebouncedValue` hook or a debounced handler. If using an Effect, clean up the timer.
* **Analytics “on show”**: Effect on mount; make it idempotent (guard against Strict Mode double-invocations in dev).
* **Sync with URL**: Prefer router APIs (search params, loaders). If using Effects, keep a single source of truth.
* **3rd‑party widgets**: Initialize in an Effect; return cleanup to destroy/unsubscribe.

---

## 10) What to **Never** Do with Effects

* ❌ Copy props to state “just in case”, then sync via Effect.
* ❌ Trigger a network request **because some state changed** when it should have happened in the user’s event handler.
* ❌ Chain multiple Effects that ping-pong state between each other.
* ❌ Read, then set state inside an Effect every render causing loops.
* ❌ Omit cleanups for subscriptions/timers.

---

## 11) PR Review & Agent Checklist (Copy/Paste)

**When an Effect appears, require answers:**

* Which **external system** are we syncing with?
* Why can’t this be computed during **render** or done in an **event handler**?
* Is there a **cleanup**? Are dependencies **minimal & correct**?
* Have we addressed **cancellation** and **stale responses** for async work?
* Is state **minimal** (no duplication of derived data)?
* Did we consider **`useSyncExternalStore`** for subscriptions?
* Is `useLayoutEffect` strictly necessary (blocking paint)?

**Static checks** (enable in tooling):

* `eslint-plugin-react-hooks` (`rules-of-hooks`, `exhaustive-deps`).
* (Optional) Custom lint pattern to flag `useEffect(() => setX(Y), [Y])`.

---

## 12) Quick Reference Table

| Goal                  | Prefer                        | Avoid                               |
| --------------------- | ----------------------------- | ----------------------------------- |
| Compute display value | Render (maybe `useMemo`)      | State + Effect sync                 |
| React to click/input  | Event handler                 | Effect that “watches” state         |
| Subscribe to store    | `useSyncExternalStore`        | Ad-hoc subscription without cleanup |
| DOM after paint       | `useEffect`                   | Unnecessary `useLayoutEffect`       |
| DOM before paint      | `useLayoutEffect` (minimal)   | Doing layout work in render         |
| Data tied to URL      | Router/framework APIs         | Fire-and-forget Effects             |
| Reset state on prop   | `key` remount or render logic | Resetting via Effect                |
| One-time app init     | Module scope/guard            | Mount-only Effect by default        |

---

## 13) Agent Prompts (for Codegen Tools)

* “Before adding `useEffect`, identify the external system involved. If none, choose render-time or event-handler solutions.”
* “Do not add state that can be derived from existing state/props.”
* “If subscribing, prefer `useSyncExternalStore` and include cleanups.”
* “For async Effects, include `AbortController` and stale-response guards.”
* “Avoid `useLayoutEffect` unless measuring/mutating before paint is required.”

---

## 14) Appendix: Minimal Examples

**Selecting by ID (no Effect):**

```tsx
const selected = items.find(i => i.id === selectedId);
```

**Debounce (with cleanup):**

```tsx
function useDebouncedValue<T>(value: T, delay = 300) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(t);
  }, [value, delay]);
  return debounced;
}
```

**3rd‑party widget lifecycle:**

```tsx
useEffect(() => {
  const w = mountWidget(container.current);
  return () => w.unmount();
}, []);
```

---

**One‑liner**: *If it can be computed during render or triggered by a specific user event, you probably don’t need an Effect.*
