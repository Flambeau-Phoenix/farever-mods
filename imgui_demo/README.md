# Dear ImGui Docking Branch Showcase Mod (`new_imgui_demo`)

A comprehensive standalone showcase mod demonstrating the full capabilities of the **Dear ImGui Docking Branch (v1.92.9+)** integrated with **HashLink (HLX)** for Farever.

---

## 🌟 Showcased Features

1. **Docking Workspace & Layout Presets**
   - Central passthrough viewport dockspace (`dockSpaceOverViewport` + `PassthruCentralNode`).
   - Seamless docking of windows into split panes, tabbed views, or tear-off floating windows.
   - Built-in layout presets: *Combat Arena*, *Telemetry & Analytics*, and *Full Developer Showcase*.

2. **Drag & Drop System**
   - Interactive spell deck library acting as Drag Sources with payload serialization and rich preview cards.
   - Action bar slots acting as Drop Targets with type validation (`ImGuiPayload_IsDataType`) and slot reordering.

3. **Advanced Sortable & Filterable Tables**
   - Multi-column sortable telemetry table powered by `tableGetSortSpecs()`.
   - Real-time instant search filtering across target names and status states.
   - Colored status indicators and progress bar threat meters.

4. **Multi-Select Asset & Skill Browser**
   - Single-click, Shift+Click Range Selection, Ctrl+Click Toggle Selection.
   - Real-time appraisal calculations and batch actions (Batch Upgrade, Batch Delete, Select All, Invert).
   - Right-click item context menus with inspection and locking operations.

5. **Real-Time Live Telemetry Plots**
   - Ring-buffered 60 FPS rolling framerate line plot (`plotLines`).
   - Dynamic combat DPS telemetry tracker.
   - 12-bucket damage distribution histogram spectrum (`plotHistogram`).

6. **Script Editor, Rich Inputs & Keyboard Shortcuts**
   - Hinted search input (`inputTextWithHint`) and integer/float steppers.
   - Multiline script editor (`inputTextMultiline`) with macro insertion.
   - Keyboard chord listener (`Ctrl+S` save, `Ctrl+Z` undo, `F5` refresh, `Ctrl+Enter` execute).

7. **Theme & Color Studio**
   - RGB color editor (`colorEdit3`) and RGBA color editor with Hue Wheel & Alpha Bar (`colorEdit4`).
   - Swatch palette buttons (`colorButton`) with live tooltips.
   - Live multi-preset theme engine (*Dark Pastel*, *Obsidian Ember*, *Voidsteel Blue*, *Solarflare Crimson*, *Custom*).

8. **Tooltips, Context Menus & Floating Toast Notifications**
   - Delayed tooltips (`ImGuiHoveredFlags.DelayNormal`) and rich multi-line stat cards.
   - Nested right-click context menus with hierarchical actions.
   - Non-blocking DX12 floating toast notification queue with auto-dismiss countdowns and status styling.

9. **Vector Canvas Playground**
   - High-performance `ImDrawList` vector rendering.
   - Real-time animated radar sweep HUD with target blips.
   - Quadratic Bezier curves, dashed guide lines, and rounded badges.

10. **Interactive Onboarding Tour & Help Reference**
    - Step-by-step modal guide walking users through the docking ecosystem.
    - Integrated quick-help documentation modal.

---

## 🛠️ How to Build

From the `new_imgui_demo` directory:

```bash
haxe compile.hxml
```

The output binary will be compiled to `build/new_imgui_demo.hl`.

---

## 📦 How to Install into Farever

1. Copy `build/new_imgui_demo.hl` to `Farever/hlx/mods/new_imgui_demo.hl`.
2. Ensure `imgui64.hdll` is in `Farever/hlx/plugins/`.
3. Launch Farever. The showcase panel and dockspace will appear automatically.
