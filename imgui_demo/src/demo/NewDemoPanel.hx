package demo;

import imgui.ImGui;
import imgui.ImGui.ImGuiPayload;
import imgui.Structs.ImVec2;
import imgui.Structs.ImVec4;
import imgui.Enums.ImGuiCol;
import imgui.Enums.ImGuiStyleVar;
import imgui.Enums.ImGuiTableFlags;
import imgui.Enums.ImGuiTableColumnFlags;
import imgui.Enums.ImGuiSortDirection;
import imgui.Enums.ImGuiDockNodeFlags;
import imgui.Enums.ImGuiCond;
import imgui.Enums.ImGuiWindowFlags;
import imgui.Enums.ImGuiMouseButton;
import imgui.Enums.ImGuiKey;
import imgui.ref.BoolRef;
import imgui.ref.FloatRef;
import imgui.ref.IntRef;
import demo.DemoViews;
import hl.Bytes;

/**
 * Modern HL-ImGui Showcase Master Panel
 * Demonstrates: Docking, Drag & Drop, Sortable Tables, Multi-Select,
 * Telemetry Plots, Vector Canvas, Theme Studio, Tooltips, Context Menus, and Toasts.
 */
class NewDemoPanel {
	// Window open toggles
	var showMainHub = new BoolRef(true);
	var showSpellDeck = new BoolRef(true);
	var showTelemetryTable = new BoolRef(true);
	var showMultiSelect = new BoolRef(true);
	var showTelemetryPlots = new BoolRef(true);
	var showScriptEditor = new BoolRef(true);
	var showThemeStudio = new BoolRef(true);
	var showTooltipsToasts = new BoolRef(true);
	var showVectorCanvas = new BoolRef(true);

	// Onboarding tour & Help modal
	var showTourModal = false;
	var tourStep:Int = 0;
	var showHelpModal = false;
	var showAboutModal = false;

	// Docking state
	var dockSpaceId:Int = 0;
	var dockInitialized = false;

	// Drag & Drop State
	static inline var PAYLOAD_SPELL = "DEMO_SPELL_CARD";
	var spellDeck = [
		{id: 101, name: "Solar Beam", type: "Radiant", power: 95, cost: 40, icon: "☀️"},
		{id: 102, name: "Supernova Flare", type: "Fire", power: 140, cost: 75, icon: "🔥"},
		{id: 103, name: "Corona Shield", type: "Barrier", power: 60, cost: 30, icon: "🛡️"},
		{id: 104, name: "Eclipse Void", type: "Dark", power: 110, cost: 55, icon: "🌑"},
		{id: 105, name: "Starlight Mend", type: "Holy", power: 80, cost: 35, icon: "✨"},
		{id: 106, name: "Plasma Lance", type: "Energy", power: 125, cost: 60, icon: "⚡"}
	];
	var activeSlots:Array<Null<Int>> = [101, 103, null, 102];

	// Sortable Table State
	var telemetryRows = [
		{id: 1, target: "Infernal Drake", dps: 18420.5, hps: 120.0, status: "Vulnerable", threat: 85},
		{id: 2, target: "Astral Warden", dps: 9450.0, hps: 840.5, status: "Shielded", threat: 42},
		{id: 3, target: "Void Weaver", dps: 24100.2, hps: 0.0, status: "Casting", threat: 98},
		{id: 4, target: "Solar Construct", dps: 13200.8, hps: 450.0, status: "Overheating", threat: 64},
		{id: 5, target: "Nebula Core", dps: 5120.0, hps: 1520.0, status: "Protected", threat: 18},
		{id: 6, target: "Chaos Behemoth", dps: 28900.0, hps: 310.0, status: "Enraged", threat: 100}
	];
	var tableSortCol:Int = 1; // Default sort by DPS
	var tableSortDir:Int = ImGuiSortDirection.Descending;
	var tableSearchBuf = new Bytes(64);

	// Resource Sliders State
	var healthValue = new FloatRef(82.0);
	var manaValue = new FloatRef(64.0);

	// Script editor / completion state
	var scriptBuffer = new Bytes(512);
	var completionCandidates = ["target.healthPercent", "player.mana", "combo.count", "cooldown.ready", "aura.active", "castSpell"];

	// Animation time tracking
	var lastFrameTime:Float = 0.0;

	public function new() {
		tableSearchBuf.setUI8(0, 0);
		scriptBuffer.setUI8(0, 0);
		MultiSelectView.init();
		ShortcutsAndInputsView.init();
		ToastSystem.success("ImGui Showcase", "Modern ImGui Docking Branch showcase loaded!");
	}

	public function draw():Void {
		var now = Date.now().getTime() / 1000.0;
		var dt = (lastFrameTime > 0.0) ? (now - lastFrameTime) : 0.016;
		lastFrameTime = now;
		if (dt > 0.1) dt = 0.1;

		// Update subview simulations
		TelemetryPlotsView.update(dt);
		VectorCanvasView.update(dt);

		if (!dockInitialized) {
			dockSpaceId = ImGui.getID_Str("NewDemoMasterDockSpace");
			dockInitialized = true;
		}

		// 1. Submit Main Viewport Dockspace
		ImGui.dockSpaceOverViewport(null, ImGuiDockNodeFlags.PassthruCentralNode);

		// 2. Main Menu Bar
		drawMainMenuBar();

		// 3. Dockable Feature Panels
		if (showMainHub.get()) drawMainControlHub();
		if (showSpellDeck.get()) drawSpellDeckWindow();
		if (showTelemetryTable.get()) drawSortableTableWindow();
		if (showMultiSelect.get()) drawMultiSelectWindow();
		if (showTelemetryPlots.get()) drawTelemetryPlotsWindow();
		if (showScriptEditor.get()) drawScriptEditorWindow();
		if (showThemeStudio.get()) drawThemeStudioWindow();
		if (showTooltipsToasts.get()) drawTooltipsAndToastsWindow();
		if (showVectorCanvas.get()) drawVectorCanvasWindow();

		// 4. Modals & Dialogs
		if (showTourModal) drawOnboardingTour();
		if (showHelpModal) drawHelpDialog();
		if (showAboutModal) drawAboutDialog();

		// 5. Floating Toast Notification Layer
		ToastSystem.draw();
	}

	function drawMainMenuBar():Void {
		if (ImGui.beginMainMenuBar()) {
			if (ImGui.beginMenu("File")) {
				if (ImGui.menuItem("Save Layout", "Ctrl+S")) {
					ToastSystem.success("Layout Saved", "Saved window positions to imgui.ini");
				}
				if (ImGui.menuItem("Export Telemetry JSON", "Ctrl+E")) {
					ToastSystem.info("Export", "Telemetry data copied to clipboard");
				}
				ImGui.separator();
				if (ImGui.menuItem("Clear All Toasts")) {
					ToastSystem.clear();
				}
				ImGui.endMenu();
			}

			if (ImGui.beginMenu("View")) {
				ImGui.menuItem("⚡ Feature Hub", null, showMainHub.get(), true);
				if (ImGui.isItemClicked()) showMainHub.set(!showMainHub.get());

				ImGui.menuItem("🃏 Spell Deck & Drag-Drop", null, showSpellDeck.get(), true);
				if (ImGui.isItemClicked()) showSpellDeck.set(!showSpellDeck.get());

				ImGui.menuItem("📊 Sortable Telemetry Table", null, showTelemetryTable.get(), true);
				if (ImGui.isItemClicked()) showTelemetryTable.set(!showTelemetryTable.get());

				ImGui.menuItem("📦 Multi-Select Asset Browser", null, showMultiSelect.get(), true);
				if (ImGui.isItemClicked()) showMultiSelect.set(!showMultiSelect.get());

				ImGui.menuItem("📈 Live Telemetry Plots", null, showTelemetryPlots.get(), true);
				if (ImGui.isItemClicked()) showTelemetryPlots.set(!showTelemetryPlots.get());

				ImGui.menuItem("📝 Script Editor & Inputs", null, showScriptEditor.get(), true);
				if (ImGui.isItemClicked()) showScriptEditor.set(!showScriptEditor.get());

				ImGui.menuItem("🎨 Theme & Color Studio", null, showThemeStudio.get(), true);
				if (ImGui.isItemClicked()) showThemeStudio.set(!showThemeStudio.get());

				ImGui.menuItem("💬 Tooltips & Toasts Center", null, showTooltipsToasts.get(), true);
				if (ImGui.isItemClicked()) showTooltipsToasts.set(!showTooltipsToasts.get());

				ImGui.menuItem("✏️ Vector Canvas Playground", null, showVectorCanvas.get(), true);
				if (ImGui.isItemClicked()) showVectorCanvas.set(!showVectorCanvas.get());

				ImGui.separator();
				if (ImGui.menuItem("Show All Windows")) {
					setAllWindowsVisible(true);
					ToastSystem.info("View", "All showcase windows enabled");
				}
				if (ImGui.menuItem("Hide All Secondary Windows")) {
					setAllWindowsVisible(false);
					showMainHub.set(true);
				}
				ImGui.endMenu();
			}

			if (ImGui.beginMenu("Layouts")) {
				if (ImGui.menuItem("Combat Arena Layout")) {
					showSpellDeck.set(true);
					showTelemetryTable.set(true);
					showTelemetryPlots.set(true);
					showVectorCanvas.set(false);
					showMultiSelect.set(false);
					ToastSystem.info("Layout Preset", "Applied Combat Arena HUD Layout");
				}
				if (ImGui.menuItem("Telemetry & Analytics Layout")) {
					showTelemetryTable.set(true);
					showTelemetryPlots.set(true);
					showMultiSelect.set(true);
					showScriptEditor.set(true);
					showSpellDeck.set(false);
					ToastSystem.info("Layout Preset", "Applied Telemetry Studio Layout");
				}
				if (ImGui.menuItem("Full Developer Showcase")) {
					setAllWindowsVisible(true);
					ToastSystem.info("Layout Preset", "Applied Developer Showcase Layout");
				}
				ImGui.endMenu();
			}

			if (ImGui.beginMenu("Theme")) {
				var presets = ["Dark Pastel", "Obsidian Ember", "Voidsteel Blue", "Solarflare Crimson", "Custom"];
				for (p in presets) {
					if (ImGui.menuItem(p, null, DarkPastelTheme.currentPreset == p)) {
						DarkPastelTheme.currentPreset = p;
						ToastSystem.info("Theme", 'Active theme set to $p');
					}
				}
				ImGui.endMenu();
			}

			if (ImGui.beginMenu("Help")) {
				if (ImGui.menuItem("Interactive Onboarding Tour...")) {
					showTourModal = true;
					tourStep = 0;
				}
				if (ImGui.menuItem("Feature Reference Guide...")) {
					showHelpModal = true;
				}
				ImGui.separator();
				if (ImGui.menuItem("About HL-ImGui Showcase...")) {
					showAboutModal = true;
				}
				ImGui.endMenu();
			}

			ImGui.endMainMenuBar();
		}
	}

	function setAllWindowsVisible(visible:Bool):Void {
		showMainHub.set(visible);
		showSpellDeck.set(visible);
		showTelemetryTable.set(visible);
		showMultiSelect.set(visible);
		showTelemetryPlots.set(visible);
		showScriptEditor.set(visible);
		showThemeStudio.set(visible);
		showTooltipsToasts.set(visible);
		showVectorCanvas.set(visible);
	}

	function drawMainControlHub():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("⚡ Feature Hub", showMainHub)) {
			ImGui.text("Dear ImGui Docking Branch & HLX Modern Toolkit");
			ImGui.textDisabled('Dock ID: ${ImGui.getWindowDockID()} | Docked: ${ImGui.isWindowDocked() ? "Yes" : "No"}');
			ImGui.separator();

			ImGui.text("Toggle Showcase Modules:");
			ImGui.checkbox("🃏 Spell Deck (Drag-Drop)", showSpellDeck);
			ImGui.sameLine();
			ImGui.checkbox("📊 Telemetry Table", showTelemetryTable);
			ImGui.sameLine();
			ImGui.checkbox("📦 Multi-Select Browser", showMultiSelect);

			ImGui.checkbox("📈 Real-Time Plots", showTelemetryPlots);
			ImGui.sameLine();
			ImGui.checkbox("📝 Script & Inputs", showScriptEditor);
			ImGui.sameLine();
			ImGui.checkbox("🎨 Theme Studio", showThemeStudio);

			ImGui.checkbox("💬 Tooltips & Toasts", showTooltipsToasts);
			ImGui.sameLine();
			ImGui.checkbox("✏️ Vector Canvas", showVectorCanvas);

			ImGui.separatorText("Quick Actions & Guided Tour");
			if (ImGui.button("🚀 Start Interactive Tour", ImGui.vec2(180, 30))) {
				showTourModal = true;
				tourStep = 0;
			}
			ImGui.sameLine();
			if (ImGui.button("🔔 Send Test Notification", ImGui.vec2(180, 30))) {
				ToastSystem.success("Test Alert", "Toast notifications are functioning perfectly!");
			}
		}
		ImGui.end();
	}

	function drawSpellDeckWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("🃏 Spell Deck & Drag-Drop", showSpellDeck)) {
			ImGui.text("Drag spells from the Deck into Action Bar Slots below (with re-ordering):");
			ImGui.separator();

			ImGui.text("Spell Library (Drag Sources):");
			for (spell in spellDeck) {
				ImGui.pushID_Int(spell.id);
				ImGui.button('${spell.icon} [${spell.type}] ${spell.name} (${spell.power} Pwr)', ImGui.vec2(240, 32));

				// Drag Source
				if (ImGui.beginDragDropSource(0)) {
					var idBytes = haxe.io.Bytes.ofString(Std.string(spell.id));
					ImGui.setDragDropPayload(PAYLOAD_SPELL, idBytes.getData(), idBytes.length + 1);

					// Rich Drag Preview Card
					ImGui.textColored(ImGui.vec4(1.0, 0.8, 0.3, 1.0), '${spell.icon} ${spell.name}');
					ImGui.text('Type: ${spell.type} | Power: ${spell.power} | Cost: ${spell.cost} MP');
					ImGui.endDragDropSource();
				}
				ImGui.popID();
			}

			ImGui.newLine();
			ImGui.separatorText("Action Bar (Drop Targets)");

			for (slotIdx in 0...activeSlots.length) {
				var slottedId = activeSlots[slotIdx];
				var spell = findSpell(slottedId);
				var label = spell != null ? '${spell.icon} ${spell.name}\n[${spell.cost} MP]' : 'Slot #${slotIdx + 1}\n[Drop Here]';

				ImGui.pushID_Int(slotIdx + 2000);
				ImGui.button(label, ImGui.vec2(140, 52));

				// Drag out of slot to reorder
				if (slottedId != null && ImGui.beginDragDropSource(0)) {
					var idBytes = haxe.io.Bytes.ofString(Std.string(slottedId));
					ImGui.setDragDropPayload(PAYLOAD_SPELL, idBytes.getData(), idBytes.length + 1);
					ImGui.text('Moving ${spell.name}');
					ImGui.endDragDropSource();
				}

				// Drop Target into slot
				if (ImGui.beginDragDropTarget()) {
					var payload = ImGui.acceptDragDropPayload(PAYLOAD_SPELL);
					if (payload != null && ImGui.ImGuiPayload_IsDataType(payload, PAYLOAD_SPELL)) {
						var data = ImGui.getPayloadData(payload);
						var size = ImGui.getPayloadDataSize(payload);
						if (data != null && size > 0) {
							var idStr = readUtf8(data, size);
							var droppedId = Std.parseInt(idStr);
							if (droppedId != null) {
								activeSlots[slotIdx] = droppedId;
								var sp = findSpell(droppedId);
								ToastSystem.success("Slotted", 'Assigned ${sp != null ? sp.name : "Spell"} to slot #${slotIdx + 1}');
							}
						}
					}
					ImGui.endDragDropTarget();
				}

				ImGui.popID();
				if (slotIdx < activeSlots.length - 1) ImGui.sameLine();
			}

			ImGui.sameLine();
			if (ImGui.button("Clear Slots", ImGui.vec2(100, 52))) {
				for (i in 0...activeSlots.length) activeSlots[i] = null;
				ToastSystem.info("Action Bar", "Cleared all action slots");
			}
		}
		ImGui.end();
	}

	function drawSortableTableWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("📊 Sortable Telemetry Table", showTelemetryTable)) {
			// Search filter
			ImGui.inputTextWithHint("##tbl_search", "🔍 Filter targets...", tableSearchBuf, 64);
			var searchStr = readUtf8(tableSearchBuf, 64).toLowerCase();

			ImGui.separator();

			var flags = ImGuiTableFlags.Borders |
				ImGuiTableFlags.RowBg |
				ImGuiTableFlags.Resizable |
				ImGuiTableFlags.Reorderable |
				ImGuiTableFlags.Sortable |
				ImGuiTableFlags.Hideable;

			if (ImGui.beginTable("TelemetrySortTable", 5, flags)) {
				ImGui.tableSetupColumn("Target Name", ImGuiTableColumnFlags.DefaultSort);
				ImGui.tableSetupColumn("DPS", ImGuiTableColumnFlags.None);
				ImGui.tableSetupColumn("HPS", ImGuiTableColumnFlags.None);
				ImGui.tableSetupColumn("Status", ImGuiTableColumnFlags.None);
				ImGui.tableSetupColumn("Threat Level", ImGuiTableColumnFlags.None);
				ImGui.tableHeadersRow();

				// Process Sorting Specs
				var specs = ImGui.tableGetSortSpecs();
				if (specs != null && ImGui.tableSortSpecsGetSpecsDirty(specs)) {
					var count = ImGui.tableSortSpecsGetSpecsCount(specs);
					if (count > 0) {
						tableSortCol = ImGui.tableSortSpecsGetColumnIndex(specs, 0);
						tableSortDir = ImGui.tableSortSpecsGetSortDirection(specs, 0);
						sortTableRows();
					}
					ImGui.tableSortSpecsSetSpecsDirty(specs, false);
				}

				// Draw Rows
				for (row in telemetryRows) {
					if (searchStr.length > 0 && row.target.toLowerCase().indexOf(searchStr) < 0 && row.status.toLowerCase().indexOf(searchStr) < 0) {
						continue;
					}

					ImGui.tableNextRow(0, 0);

					ImGui.tableNextColumn();
					ImGui.text(row.target);

					ImGui.tableNextColumn();
					ImGui.text('${row.dps}');

					ImGui.tableNextColumn();
					ImGui.text('${row.hps}');

					ImGui.tableNextColumn();
					var statusCol = switch (row.status) {
						case "Vulnerable": ImGui.vec4(0.95, 0.4, 0.4, 1.0);
						case "Shielded", "Protected": ImGui.vec4(0.4, 0.7, 1.0, 1.0);
						case "Enraged": ImGui.vec4(1.0, 0.2, 0.2, 1.0);
						default: ImGui.vec4(0.9, 0.9, 0.9, 1.0);
					};
					ImGui.textColored(statusCol, row.status);

					ImGui.tableNextColumn();
					// Threat meter bar
					var frac = row.threat / 100.0;
					var col = frac > 0.8 ? ImGui.vec4(0.95, 0.25, 0.25, 1.0) : (frac > 0.5 ? ImGui.vec4(0.95, 0.75, 0.20, 1.0) : ImGui.vec4(0.30, 0.85, 0.40, 1.0));
					ImGui.pushStyleColor(ImGuiCol.PlotHistogram, col);
					ImGui.progressBar(frac, ImGui.vec2(-1.0, 0), '${row.threat}%');
					ImGui.popStyleColor();
				}

				ImGui.endTable();
			}
		}
		ImGui.end();
	}

	function sortTableRows():Void {
		var col = tableSortCol;
		var dir = tableSortDir;

		telemetryRows.sort(function(a, b):Int {
			var result = 0;
			switch (col) {
				case 0: result = (a.target < b.target) ? -1 : (a.target > b.target ? 1 : 0);
				case 1: result = (a.dps < b.dps) ? -1 : (a.dps > b.dps ? 1 : 0);
				case 2: result = (a.hps < b.hps) ? -1 : (a.hps > b.hps ? 1 : 0);
				case 3: result = (a.status < b.status) ? -1 : (a.status > b.status ? 1 : 0);
				case 4: result = (a.threat < b.threat) ? -1 : (a.threat > b.threat ? 1 : 0);
				default: result = 0;
			}
			return dir == ImGuiSortDirection.Ascending ? result : -result;
		});
	}

	function drawMultiSelectWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("📦 Multi-Select Asset Browser", showMultiSelect)) {
			MultiSelectView.draw();
		}
		ImGui.end();
	}

	function drawTelemetryPlotsWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("📈 Live Telemetry Plots", showTelemetryPlots)) {
			TelemetryPlotsView.draw();
		}
		ImGui.end();
	}

	function drawScriptEditorWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("📝 Script Editor & Inputs", showScriptEditor)) {
			ShortcutsAndInputsView.draw();
		}
		ImGui.end();
	}

	function drawThemeStudioWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("🎨 Theme & Color Studio", showThemeStudio)) {
			ThemeStudioView.draw();
		}
		ImGui.end();
	}

	function drawTooltipsAndToastsWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("💬 Tooltips & Toasts Center", showTooltipsToasts)) {
			ImGui.separatorText("Delayed & Rich Tooltips");

			ImGui.button("Hover for Tooltip");
			if (ImGui.isItemHovered()) {
				ImGui.beginTooltip();
				ImGui.textColored(ImGui.vec4(0.35, 0.75, 1.0, 1.0), "ℹ️ Delayed Tooltip Feature");
				ImGui.text("This tooltip provides detailed context when the item is hovered.");
				ImGui.endTooltip();
			}

			ImGui.sameLine();
			ImGui.button("Hover for Rich Stat Card");
			if (ImGui.isItemHovered()) {
				ImGui.beginTooltip();
				ImGui.textColored(ImGui.vec4(1.0, 0.8, 0.2, 1.0), "⚔️ Legendary Item Card");
				ImGui.separator();
				ImGui.text("Attack Power: +450");
				ImGui.text("Critical Strike: +18.5%");
				ImGui.text("Set Bonus: [2/4] Sunfire Radiance");
				ImGui.endTooltip();
			}

			ImGui.separatorText("Interactive Toast Notification Dispatcher");
			if (ImGui.button("Send Info Toast", ImGui.vec2(140, 32))) {
				ToastSystem.info("Information", "Telemetry log updated with 4 new packets");
			}
			ImGui.sameLine();
			if (ImGui.button("Send Success Toast", ImGui.vec2(140, 32))) {
				ToastSystem.success("Operation Complete", "Database synchronizer committed 18 records");
			}
			ImGui.sameLine();
			if (ImGui.button("Send Warning Toast", ImGui.vec2(140, 32))) {
				ToastSystem.warning("Low Resources", "Memory threshold reached 85% capacity");
			}
			ImGui.sameLine();
			if (ImGui.button("Send Error Toast", ImGui.vec2(140, 32))) {
				ToastSystem.error("Connection Dropped", "Failed to connect to remote socket host");
			}

			ImGui.separatorText("Context Menu Test Area");
			ImGui.text("Right-click anywhere in this box to open a nested context popup:");
			ImGui.pushStyleColor(ImGuiCol.ChildBg, ImGui.vec4(0.15, 0.18, 0.24, 0.5));
			if (ImGui.beginChild("##context_box", ImGui.vec2(-1, 80), 0, 0)) {
				ImGui.text("Right-click here for nested menu...");
				if (ImGui.isWindowHovered() && ImGui.isMouseClicked(ImGuiMouseButton.Right)) {
					ImGui.openPopup("nested_context_menu");
				}

				if (ImGui.beginPopup("nested_context_menu")) {
					ImGui.text("Actions & Macros");
					ImGui.separator();
					if (ImGui.beginMenu("File Operations")) {
						if (ImGui.menuItem("New Script")) ToastSystem.info("File", "Created script");
						if (ImGui.menuItem("Save Preset")) ToastSystem.success("File", "Saved preset");
						ImGui.endMenu();
					}
					if (ImGui.beginMenu("Quick Presets")) {
						if (ImGui.menuItem("Enable All Buffs")) ToastSystem.success("Buffs", "All buffs applied");
						if (ImGui.menuItem("Reset Cooldowns")) ToastSystem.info("Cooldowns", "Reset to 0s");
						ImGui.endMenu();
					}
					ImGui.endPopup();
				}
			}
			ImGui.endChild();
			ImGui.popStyleColor();
		}
		ImGui.end();
	}

	function drawVectorCanvasWindow():Void {
		ImGui.setNextWindowDockID(dockSpaceId, ImGuiCond.FirstUseEver);
		if (ImGui.begin("✏️ Vector Canvas Playground", showVectorCanvas)) {
			VectorCanvasView.draw();
		}
		ImGui.end();
	}

	function drawOnboardingTour():Void {
		var tourSteps = [
			{
				title: "Welcome to Dear ImGui Docking!",
				content: "You can drag window title tabs to dock them side-by-side, in tabs, or tear them into separate floating windows."
			},
			{
				title: "Drag & Drop Loadouts",
				content: "Explore the Spell Deck window! Drag spells from the library directly into action bar slots to build custom loadouts."
			},
			{
				title: "Sortable & Filterable Tables",
				content: "Click table column headers to sort ascending or descending. Use the filter bar to dynamically isolate target telemetry."
			},
			{
				title: "Multi-Selection & Themes",
				content: "In the Multi-Select Browser, use Shift+Click for ranges and Ctrl+Click for toggling. Customize themes live in the Theme Studio!"
			}
		];

		ImGui.openPopup("onboarding_tour_modal");
		if (ImGui.beginPopupModal("onboarding_tour_modal", null, ImGuiWindowFlags.AlwaysAutoResize)) {
			var current = tourSteps[tourStep];
			ImGui.separatorText('Tour Step ${tourStep + 1} of ${tourSteps.length}: ${current.title}');
			ImGui.textWrapped(current.content);
			ImGui.newLine();
			ImGui.separator();

			if (tourStep > 0) {
				if (ImGui.button("← Previous")) tourStep--;
				ImGui.sameLine();
			}

			if (tourStep < tourSteps.length - 1) {
				if (ImGui.button("Next →")) tourStep++;
			} else {
				if (ImGui.button("Finish Tour 🎉")) {
					showTourModal = false;
					ToastSystem.success("Tour Completed", "Enjoy exploring the ImGui docking features!");
				}
			}

			ImGui.sameLine();
			if (ImGui.button("Skip Tour")) {
				showTourModal = false;
			}

			ImGui.endPopup();
		}
	}

	function drawHelpDialog():Void {
		ImGui.openPopup("help_reference_modal");
		if (ImGui.beginPopupModal("help_reference_modal", null, ImGuiWindowFlags.AlwaysAutoResize)) {
			ImGui.separatorText("HL-ImGui Docking Feature Guide");
			ImGui.text("• Docking: Drag tabs to dock nodes. Use dockSpaceOverViewport for seamless integration.");
			ImGui.text("• Drag & Drop: Use beginDragDropSource / beginDragDropTarget with type validation.");
			ImGui.text("• Tables: Powered by tableGetSortSpecs() with multi-column sorting.");
			ImGui.text("• Multi-Select: Supports Shift+Click range, Ctrl+Click toggle, and batch operations.");
			ImGui.text("• Shortcuts: Key chords (Ctrl+S, Ctrl+Z, F5) detected non-intrusively.");
			ImGui.newLine();
			if (ImGui.button("Close Help")) showHelpModal = false;
			ImGui.endPopup();
		}
	}

	function drawAboutDialog():Void {
		ImGui.openPopup("about_modal");
		if (ImGui.beginPopupModal("about_modal", null, ImGuiWindowFlags.AlwaysAutoResize)) {
			ImGui.separatorText("About Dear ImGui Docking Showcase");
			ImGui.text("HL-ImGui Docking Branch (v1.92.9+) Integration for HashLink / Farever");
			ImGui.text("Engineered by the SolarFlare Modding Team");
			ImGui.newLine();
			if (ImGui.button("Close")) showAboutModal = false;
			ImGui.endPopup();
		}
	}

	function findSpell(id:Null<Int>) {
		if (id == null) return null;
		for (s in spellDeck) if (s.id == id) return s;
		return null;
	}

	function readUtf8(buf:Bytes, maxLen:Int):String {
		if (buf == null || maxLen <= 0) return "";
		var len = 0;
		while (len < maxLen && buf.getUI8(len) != 0) len++;
		if (len == 0) return "";
		return buf.toBytes(len).getString(0, len);
	}
}
