package demo;

import imgui.ImGui;
import imgui.Structs.ImVec2;
import imgui.Structs.ImVec4;
import imgui.Enums.ImGuiCol;
import imgui.Enums.ImGuiStyleVar;
import imgui.Enums.ImGuiColorEditFlags;
import imgui.Enums.ImGuiMouseButton;
import imgui.Enums.ImGuiKey;
import imgui.ref.BoolRef;
import imgui.ref.FloatRef;
import imgui.ref.IntRef;
import hl.Bytes;

// -----------------------------------------------------------------------------
// 1. Multi-Select & Batch Actions View
// -----------------------------------------------------------------------------
class AssetItem {
	public var id:Int;
	public var name:String;
	public var category:String;
	public var rarity:String;
	public var value:Int;
	public var selected:Bool = false;

	public function new(id:Int, name:String, category:String, rarity:String, value:Int) {
		this.id = id;
		this.name = name;
		this.category = category;
		this.rarity = rarity;
		this.value = value;
	}
}

class MultiSelectView {
	public static var items:Array<AssetItem> = [
		new AssetItem(1, "Radiant Sunblade", "Weapon", "Legendary", 8500),
		new AssetItem(2, "Corona Aegis", "Armor", "Epic", 4200),
		new AssetItem(3, "Solar Sigil of Power", "Trinket", "Rare", 1800),
		new AssetItem(4, "Voidglass Catalyst", "Material", "Epic", 3100),
		new AssetItem(5, "Starlight Infusion Vial", "Consumable", "Common", 150),
		new AssetItem(6, "Phoenix Feather Charm", "Trinket", "Legendary", 9200),
		new AssetItem(7, "Celestial Mantle", "Armor", "Rare", 2400),
		new AssetItem(8, "Supernova Core Fragment", "Material", "Legendary", 12000),
		new AssetItem(9, "Astral Essence Flask", "Consumable", "Rare", 650),
		new AssetItem(10, "Dawnbreaker Pauldrons", "Armor", "Epic", 5100)
	];

	static var filterBuffer = new Bytes(64);
	static var lastRangeIndex:Int = -1;

	public static function init():Void {
		filterBuffer.setUI8(0, 0);
	}

	public static function draw():Void {
		ImGui.text("Interactive Multi-Select Item Browser (Click / Shift+Click / Ctrl+Click)");
		ImGui.separator();

		// Search Filter & Selection Toolbar
		ImGui.inputTextWithHint("##item_filter", "🔍 Filter assets by name or category...", filterBuffer, 64);
		var filterText = readBuffer(filterBuffer, 64).toLowerCase();

		ImGui.sameLine();
		if (ImGui.button("Select All")) {
			for (item in items) item.selected = true;
			ToastSystem.info("Selection", 'Selected all ${items.length} items');
		}
		ImGui.sameLine();
		if (ImGui.button("Clear")) {
			for (item in items) item.selected = false;
		}
		ImGui.sameLine();
		if (ImGui.button("Invert")) {
			for (item in items) item.selected = !item.selected;
		}

		// Count selected items
		var selectedCount = 0;
		var totalValue = 0;
		for (item in items) {
			if (item.selected) {
				selectedCount++;
				totalValue += item.value;
			}
		}

		ImGui.text('Selected: $selectedCount / ${items.length} items | Total Appraisal: $totalValue Gold');

		// Bulk Action Buttons
		if (selectedCount > 0) {
			ImGui.pushStyleColor(ImGuiCol.Button, ImGui.vec4(0.20, 0.45, 0.28, 0.85));
			if (ImGui.button('✨ Batch Upgrade ($selectedCount)')) {
				ToastSystem.success("Batch Upgrade", 'Upgraded $selectedCount selected items!');
			}
			ImGui.popStyleColor();

			ImGui.sameLine();
			ImGui.pushStyleColor(ImGuiCol.Button, ImGui.vec4(0.50, 0.20, 0.20, 0.85));
			if (ImGui.button('🗑 Delete Selected ($selectedCount)')) {
				var remaining:Array<AssetItem> = [];
				for (item in items) if (!item.selected) remaining.push(item);
				var deletedCount = items.length - remaining.length;
				items = remaining;
				ToastSystem.warning("Batch Deletion", 'Deleted $deletedCount items from inventory');
			}
			ImGui.popStyleColor();
		}

		ImGui.separator();

		// Item List with Range & Toggle selection
		for (i in 0...items.length) {
			var item = items[i];
			if (filterText.length > 0 && item.name.toLowerCase().indexOf(filterText) < 0 && item.category.toLowerCase().indexOf(filterText) < 0) {
				continue;
			}

			var rarityCol = switch (item.rarity) {
				case "Legendary": ImGui.vec4(1.0, 0.70, 0.20, 1.0);
				case "Epic": ImGui.vec4(0.75, 0.35, 0.95, 1.0);
				case "Rare": ImGui.vec4(0.30, 0.65, 1.0, 1.0);
				default: ImGui.vec4(0.85, 0.85, 0.85, 1.0);
			};

			var label = '[${item.category}] ${item.name} - ${item.value}g';
			ImGui.pushID_Int(item.id);

			var isShift = ImGui.isKeyDown(ImGuiKey.LeftShift) || ImGui.isKeyDown(ImGuiKey.RightShift);
			var isCtrl = ImGui.isKeyDown(ImGuiKey.LeftCtrl) || ImGui.isKeyDown(ImGuiKey.RightCtrl);

			if (ImGui.selectable(label, item.selected, 0, ImGui.vec2(0, 24))) {
				if (isShift && lastRangeIndex >= 0) {
					// Range selection
					var start = lastRangeIndex < i ? lastRangeIndex : i;
					var end = lastRangeIndex > i ? lastRangeIndex : i;
					for (k in start...end + 1) {
						items[k].selected = true;
					}
				} else if (isCtrl) {
					// Toggle individual
					item.selected = !item.selected;
					lastRangeIndex = i;
				} else {
					// Single select
					for (other in items) other.selected = false;
					item.selected = true;
					lastRangeIndex = i;
				}
			}

			// Context Menu for Item
			if (ImGui.isItemClicked(ImGuiMouseButton.Right)) {
				ImGui.openPopup("item_context_menu");
			}

			if (ImGui.beginPopup("item_context_menu")) {
				ImGui.textColored(rarityCol, '✦ ${item.name} (${item.rarity})');
				ImGui.separator();
				if (ImGui.menuItem("Inspect Details", "Ctrl+I")) {
					ToastSystem.info("Inspection", '${item.name}: Category ${item.category}, Value ${item.value}g');
				}
				if (ImGui.menuItem("Favorite / Lock", "Ctrl+L")) {
					ToastSystem.success("Favorite", 'Marked ${item.name} as favorite');
				}
				ImGui.separator();
				if (ImGui.menuItem("Remove Item", "Del")) {
					items.remove(item);
					ToastSystem.warning("Removed", 'Removed ${item.name}');
				}
				ImGui.endPopup();
			}

			ImGui.popID();
		}
	}

	static function readBuffer(buf:Bytes, max:Int):String {
		var len = 0;
		while (len < max && buf.getUI8(len) != 0) len++;
		if (len == 0) return "";
		return buf.toBytes(len).getString(0, len);
	}
}

// -----------------------------------------------------------------------------
// 2. Real-Time Telemetry & Plots View
// -----------------------------------------------------------------------------
class TelemetryPlotsView {
	static inline var SAMPLE_COUNT = 60;
	static var fpsBuffer = new Bytes(SAMPLE_COUNT * 4);
	static var dpsBuffer = new Bytes(SAMPLE_COUNT * 4);
	static var histogramBuffer = new Bytes(12 * 4);

	static var fpsValues:Array<Float> = [];
	static var dpsValues:Array<Float> = [];
	static var dpsHistory:Float = 14500.0;
	static var simTimer:Float = 0.0;

	public static function update(dt:Float):Void {
		simTimer += dt;

		// Simulated live FPS fluctuation around 60 FPS
		var fps = 60.0 + Math.sin(simTimer * 2.5) * 4.0 + (Math.random() - 0.5) * 2.0;
		fpsValues.push(fps);
		if (fpsValues.length > SAMPLE_COUNT) fpsValues.shift();

		// Simulated live combat DPS fluctuation
		var dpsNoise = (Math.random() - 0.48) * 1200.0;
		dpsHistory += dpsNoise;
		if (dpsHistory < 8000) dpsHistory = 8000;
		if (dpsHistory > 28000) dpsHistory = 28000;
		dpsValues.push(dpsHistory);
		if (dpsValues.length > SAMPLE_COUNT) dpsValues.shift();

		// Fill byte buffers for ImGui plot calls
		for (i in 0...fpsValues.length) {
			fpsBuffer.setF32(i * 4, fpsValues[i]);
		}
		for (i in 0...dpsValues.length) {
			dpsBuffer.setF32(i * 4, dpsValues[i]);
		}

		// Fill 12-bucket histogram for damage skill distribution
		var bins = [12, 28, 45, 82, 110, 95, 70, 52, 38, 24, 15, 8];
		for (i in 0...12) {
			var variation = bins[i] + Math.sin(simTimer * 3.0 + i) * 6.0;
			histogramBuffer.setF32(i * 4, variation > 0 ? variation : 1.0);
		}
	}

	public static function draw():Void {
		ImGui.text("Real-Time Telemetry Plots & Damage Distribution");
		ImGui.separator();

		// 1. Framerate Line Plot
		var currentFps = fpsValues.length > 0 ? fpsValues[fpsValues.length - 1] : 60.0;
		ImGui.text('Engine Framerate: ${Math.round(currentFps * 10) / 10} FPS (Target: 60 FPS)');
		ImGui.pushStyleColor(ImGuiCol.PlotLines, ImGui.vec4(0.35, 0.85, 0.45, 1.0));
		ImGui.pushStyleColor(ImGuiCol.PlotLinesHovered, ImGui.vec4(0.60, 1.00, 0.60, 1.0));
		ImGui.plotLines("##fps_plot", fpsBuffer, fpsValues.length, 0, '${Math.round(currentFps)} FPS', 30.0, 75.0, ImGui.vec2(-1, 70));
		ImGui.popStyleColor(2);

		ImGui.newLine();

		// 2. Combat DPS Line Plot
		var currentDps = dpsValues.length > 0 ? dpsValues[dpsValues.length - 1] : 14000.0;
		ImGui.text('Combat DPS: ${Std.int(currentDps)} DMG/s');
		ImGui.pushStyleColor(ImGuiCol.PlotLines, ImGui.vec4(0.95, 0.45, 0.25, 1.0));
		ImGui.pushStyleColor(ImGuiCol.PlotLinesHovered, ImGui.vec4(1.0, 0.65, 0.40, 1.0));
		ImGui.plotLines("##dps_plot", dpsBuffer, dpsValues.length, 0, '${Std.int(currentDps)} DPS', 5000.0, 30000.0, ImGui.vec2(-1, 70));
		ImGui.popStyleColor(2);

		ImGui.newLine();

		// 3. Damage Distribution Histogram
		ImGui.text("Damage Distribution Spectrum (12 Ability Tiers):");
		ImGui.pushStyleColor(ImGuiCol.PlotHistogram, ImGui.vec4(0.40, 0.65, 1.00, 0.85));
		ImGui.pushStyleColor(ImGuiCol.PlotHistogramHovered, ImGui.vec4(0.60, 0.85, 1.00, 1.0));
		ImGui.plotHistogram("##dmg_hist", histogramBuffer, 12, 0, "Hits / Tier", 0.0, 125.0, ImGui.vec2(-1, 75));
		ImGui.popStyleColor(2);
	}
}

// -----------------------------------------------------------------------------
// 3. Theme & Color Studio View
// -----------------------------------------------------------------------------
class ThemeStudioView {
	static var sampleColor3 = makeColorBytes(0.95, 0.55, 0.20, 1.0);
	static var sampleColor4 = makeColorBytes(0.35, 0.75, 1.00, 0.85);

	static function makeColorBytes(r:Float, g:Float, b:Float, a:Float):Bytes {
		var bytes = new Bytes(16);
		bytes.setF32(0, r);
		bytes.setF32(4, g);
		bytes.setF32(8, b);
		bytes.setF32(12, a);
		return bytes;
	}

	public static function draw():Void {
		ImGui.text("Live Color Pickers & Theme Style Customizer");
		ImGui.separator();

		// Theme Presets Selector
		ImGui.text("Active UI Theme Preset:");
		var presets = ["Dark Pastel", "Obsidian Ember", "Voidsteel Blue", "Solarflare Crimson", "Custom"];
		for (p in presets) {
			if (ImGui.radioButton(p, DarkPastelTheme.currentPreset == p)) {
				DarkPastelTheme.currentPreset = p;
				ToastSystem.info("Theme Changed", 'Switched to $p preset');
			}
			ImGui.sameLine();
		}
		ImGui.newLine();

		// Window Opacity Slider
		var opacityRef = new FloatRef(DarkPastelTheme.windowAlpha);
		if (ImGui.sliderFloat("Window Opacity", opacityRef, 0.3, 1.0, "%.2f")) {
			DarkPastelTheme.windowAlpha = opacityRef.get();
		}

		ImGui.separatorText("Color Picker Types & Flags");

		// RGB Color Picker (colorEdit3)
		ImGui.text("1. RGB Color Editor (colorEdit3):");
		ImGui.colorEdit3("Particle Tint##p_tint", sampleColor3);

		// RGBA Color Picker with Wheel and Alpha Bar (colorEdit4)
		ImGui.text("2. RGBA Color Editor with Hue Wheel & Alpha Bar (colorEdit4):");
		var colorFlags = ImGuiColorEditFlags.AlphaBar | ImGuiColorEditFlags.PickerHueWheel | ImGuiColorEditFlags.DisplayRGB | ImGuiColorEditFlags.DisplayHSV | ImGuiColorEditFlags.DisplayHex;
		ImGui.colorEdit4("Aura Glow##a_glow", sampleColor4, colorFlags);

		ImGui.separatorText("Palette Quick Swatches (colorButton)");
		var swatches = [
			{name: "Solar Gold", r: 1.0, g: 0.78, b: 0.22},
			{name: "Corona Crimson", r: 0.95, g: 0.25, b: 0.32},
			{name: "Void Violet", r: 0.65, g: 0.28, b: 0.95},
			{name: "Astral Cyan", r: 0.25, g: 0.82, b: 1.00},
			{name: "Emerald Heal", r: 0.28, g: 0.92, b: 0.45}
		];

		for (s in swatches) {
			var vec = ImGui.vec4(s.r, s.g, s.b, 1.0);
			if (ImGui.colorButton('##swatch_${s.name}', vec, 0, ImGui.vec2(36, 28))) {
				sampleColor4.setF32(0, s.r);
				sampleColor4.setF32(4, s.g);
				sampleColor4.setF32(8, s.b);
				ToastSystem.info("Swatch Picked", 'Applied ${s.name}');
			}
			if (ImGui.isItemHovered()) {
				ImGui.setTooltip(s.name);
			}
			ImGui.sameLine();
		}
		ImGui.newLine();

		// Custom Theme Live Color Tweakers
		if (DarkPastelTheme.currentPreset == "Custom") {
			ImGui.separatorText("Custom Color Channel Tuning");
			ImGui.colorEdit4("Window BG##cust_wb", DarkPastelTheme.customWindowBg);
			ImGui.colorEdit4("Accent Color##cust_acc", DarkPastelTheme.customAccent);
			ImGui.colorEdit4("Button BG##cust_btn", DarkPastelTheme.customButton);
			ImGui.colorEdit4("Header BG##cust_hdr", DarkPastelTheme.customHeader);
			ImGui.colorEdit4("Border Color##cust_bdr", DarkPastelTheme.customBorder);
		}
	}
}

// -----------------------------------------------------------------------------
// 4. Shortcuts & Rich Inputs View
// -----------------------------------------------------------------------------
class ShortcutsAndInputsView {
	static var searchBuf = new Bytes(128);
	static var multilineBuf = new Bytes(1024);
	static var numericInt = new IntRef(42);
	static var numericFloat = new FloatRef(3.1415);
	static var lastKeyTriggered:String = "None";

	public static function init():Void {
		searchBuf.setUI8(0, 0);
		var initialScript = "// Write custom combat automation script\nif (target.hp < 0.25) {\n    castSpell(\"Supernova Flare\");\n}\n";
		var b = haxe.io.Bytes.ofString(initialScript);
		for (i in 0...b.length) multilineBuf.setUI8(i, b.get(i));
		multilineBuf.setUI8(b.length, 0);
	}

	public static function draw():Void {
		ImGui.text("Input Fields, Multiline Scripting & Key Chords");
		ImGui.separator();

		// Keyboard Chord Detection
		var ctrlDown = ImGui.isKeyDown(ImGuiKey.LeftCtrl) || ImGui.isKeyDown(ImGuiKey.RightCtrl);
		if (ctrlDown && ImGui.isKeyPressed(ImGuiKey.S, false)) {
			lastKeyTriggered = "Ctrl + S (Save Preset)";
			ToastSystem.success("Shortcut Triggered", "Executed Ctrl+S action");
		}
		if (ctrlDown && ImGui.isKeyPressed(ImGuiKey.Z, false)) {
			lastKeyTriggered = "Ctrl + Z (Undo Action)";
			ToastSystem.info("Shortcut Triggered", "Executed Ctrl+Z action");
		}
		if (ImGui.isKeyPressed(ImGuiKey.F5, false)) {
			lastKeyTriggered = "F5 (Quick Refresh)";
			ToastSystem.info("Shortcut Triggered", "Refreshed Telemetry");
		}

		ImGui.text('Last Detected Shortcut: $lastKeyTriggered');
		ImGui.separatorText("Standard & Hinted Inputs");

		ImGui.inputTextWithHint("Search##hint_in", "Type to search skills or macros...", searchBuf, 128);

		ImGui.inputInt("Integer Stepper##int_step", numericInt, 1, 10);
		ImGui.inputFloat("Float Stepper##flt_step", numericFloat, 0.1, 1.0, "%.3f");

		ImGui.separatorText("Multiline Scripting Sandbox (inputTextMultiline)");
		ImGui.inputTextMultiline("##multiline_code", multilineBuf, 1024, ImGui.vec2(-1, 130), 0);

		if (ImGui.button("Execute Script (Ctrl+Enter)")) {
			ToastSystem.success("Script Engine", "Compiled and executed script snippet successfully!");
		}
		ImGui.sameLine();
		if (ImGui.button("Reset Script")) {
			init();
		}
	}
}

// -----------------------------------------------------------------------------
// 5. Vector Canvas & Primitives View
// -----------------------------------------------------------------------------
class VectorCanvasView {
	static var radarAngle:Float = 0.0;
	static var spinnerSegments = new IntRef(28);

	public static function update(dt:Float):Void {
		radarAngle += dt * 2.5;
		if (radarAngle > Math.PI * 2) radarAngle -= Math.PI * 2;
	}

	public static function draw():Void {
		ImGui.text("Vector Primitives & High-Performance ImDrawList Graphics");
		ImGui.separator();

		var drawList = ImGui.getWindowDrawList();
		var cursor = ImGui.getCursorScreenPos();

		if (drawList != null) {
			// Canvas 1: Animated Radar HUD
			var radarCenter = ImGui.vec2(cursor.x + 80, cursor.y + 80);
			var radarRadius:Single = 65.0;

			// Background disk & rings
			ImGui.ImDrawList_AddCircleFilled(drawList, radarCenter, radarRadius, 0x33112233, 32);
			ImGui.ImDrawList_AddCircle(drawList, radarCenter, radarRadius, 0xFF3388EE, 32, 1.5);
			ImGui.ImDrawList_AddCircle(drawList, radarCenter, radarRadius * 0.65, 0x663388EE, 32, 1.0);
			ImGui.ImDrawList_AddCircle(drawList, radarCenter, radarRadius * 0.30, 0x663388EE, 32, 1.0);

			// Crosshairs
			ImGui.ImDrawList_AddLine(drawList, ImGui.vec2(radarCenter.x - radarRadius, radarCenter.y), ImGui.vec2(radarCenter.x + radarRadius, radarCenter.y), 0x443388EE, 1.0);
			ImGui.ImDrawList_AddLine(drawList, ImGui.vec2(radarCenter.x, radarCenter.y - radarRadius), ImGui.vec2(radarCenter.x, radarCenter.y + radarRadius), 0x443388EE, 1.0);

			// Rotating Sweep Line
			var sweepX = radarCenter.x + Math.cos(radarAngle) * radarRadius;
			var sweepY = radarCenter.y + Math.sin(radarAngle) * radarRadius;
			ImGui.ImDrawList_AddLine(drawList, radarCenter, ImGui.vec2(sweepX, sweepY), 0xFF88FF88, 2.0);

			// Target Blips
			var blip1 = ImGui.vec2(radarCenter.x + 25, radarCenter.y - 30);
			var blip2 = ImGui.vec2(radarCenter.x - 35, radarCenter.y + 20);
			ImGui.ImDrawList_AddCircleFilled(drawList, blip1, 4.0, 0xFFFF4444, 16);
			ImGui.ImDrawList_AddCircleFilled(drawList, blip2, 3.5, 0xFFFFAA00, 16);

			// Canvas 2: Cubic Bezier Curve & Badges
			var curveStart = ImGui.vec2(cursor.x + 190, cursor.y + 120);
			var curveCtrl1 = ImGui.vec2(cursor.x + 230, cursor.y + 20);
			var curveCtrl2 = ImGui.vec2(cursor.x + 310, cursor.y + 20);
			var curveEnd = ImGui.vec2(cursor.x + 350, cursor.y + 120);

			ImGui.ImDrawList_AddBezierCubic(drawList, curveStart, curveCtrl1, curveCtrl2, curveEnd, 0xFFFFAA33, 3.0, 32);

			// Control Point Indicator
			ImGui.ImDrawList_AddCircleFilled(drawList, curveCtrl1, 3.0, 0xFFFFFFFF, 12);
			ImGui.ImDrawList_AddCircleFilled(drawList, curveCtrl2, 3.0, 0xFFFFFFFF, 12);

			// Rounded Glow Badge
			var badgeMin = ImGui.vec2(cursor.x + 380, cursor.y + 30);
			var badgeMax = ImGui.vec2(cursor.x + 500, cursor.y + 110);
			ImGui.ImDrawList_AddRectFilled(drawList, badgeMin, badgeMax, 0x44225588, 10.0);
			ImGui.ImDrawList_AddRect(drawList, badgeMin, badgeMax, 0xFF44AAFF, 10.0, 2.0, 0);
		}

		ImGui.dummy(ImGui.vec2(520, 165));
	}
}
