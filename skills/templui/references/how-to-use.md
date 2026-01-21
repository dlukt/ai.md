# templui how-to-use (condensed)

## Requirements
- Go (check with `go version`)
- templ CLI: `go install github.com/a-h/templ/cmd/templ@latest`
- Tailwind CSS v4.1+ (standalone CLI recommended; npx fallback with `npx tailwindcss@latest`)

## Install templui CLI
```
go install github.com/templui/templui/cmd/templui@latest
templui -v
```

## New project (fastest setup)
```
templui new my-app
cd my-app
go mod tidy
task dev
```
Options:
```
templui new my-app --module github.com/foo/bar
templui new@<version> my-app
```

## Initialize existing project
```
templui init
```
Prompts for:
- componentsDir (default: components)
- utilsDir (default: utils)
- moduleName (use `go.mod` module)
- jsDir (default: assets/js)
- jsPublicPath (optional)

This writes `.templui.json`:
```
{
  "componentsDir": "components",
  "utilsDir": "utils",
  "moduleName": "your-app/module",
  "jsDir": "assets/js",
  "jsPublicPath": "/assets/js"
}
```
If `jsPublicPath` is omitted, it defaults to "/" + jsDir.

## Add and update components
```
# Add specific components
templui add button card

# Add all components
templui add "*"

# From a specific version
templui add@<version> button
```
Update (overwrites local changes):
```
templui add carousel
templui -f add carousel
```
Tip: Components with JavaScript include a `Script()` template function. Add it to your base layout to load required JS.

## List and upgrade
```
templui list
templui list@<version>

templui upgrade
templui upgrade@<version>
```

## Copy/paste workflow (manual)
If you copy components from docs or GitHub, handle dependencies, update import paths, and include required JS assets yourself.

## JS asset routing
Serve `jsDir` at `jsPublicPath`.
Example with net/http mux:
```
mux.Handle("/assets/js/", http.StripPrefix("/assets/js/",
    http.FileServer(http.Dir("./assets/js"))))
```
If the app is mounted under `/app/`, set `jsPublicPath` to `/app/assets/js` and adjust routing.

## Dev workflow (optional)
Use Taskfile to run templ and Tailwind watchers in parallel. Example commands:
```
templ generate --watch --proxy="http://localhost:8090" --cmd="go run ./main.go" --open-browser=false
```
```
tailwindcss -i ./assets/css/input.css -o ./assets/css/output.css --watch
```
`task dev` runs both. templ dev server runs at `http://localhost:7331`. Adjust the proxy port if your app uses a different port.

## Base styles and themes
For a fresh Tailwind setup, copy `assets/css/input.css` from a `templui new` project or the official docs. For color palettes and theme variables, see `https://templui.io/docs/themes`.
