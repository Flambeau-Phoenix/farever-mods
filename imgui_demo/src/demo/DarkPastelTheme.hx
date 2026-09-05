package demo;

import imgui.Enums.ImGuiCol;
import imgui.Enums.ImGuiStyleVar;
import imgui.Structs.ImVec2;
import imgui.Structs.ImVec4;
import imgui.ImGui;
import hl.Bytes;

class ThemeColorSet {
	public var winBg:ImVec4;
	public var childBg:ImVec4;
	public var popupBg:ImVec4;
	public var border:ImVec4;
	public var accent:ImVec4;
	public var accentHover:ImVec4;
	public var btn:ImVec4;
	public var btnHover:ImVec4;
	public var header:ImVec4;
	public var text:ImVec4;
	public var titleBg:ImVec4;
	public var titleBgActive:ImVec4;
	public var tab:ImVec4;
	public var tabSelected:ImVec4;

	public function new(
		winBg:ImVec4, childBg:ImVec4, popupBg:ImVec4, border:ImVec4,
		accent:ImVec4, accentHover:ImVec4, btn:ImVec4, btnHover:ImVec4,
		header:ImVec4, text:ImVec4, titleBg:ImVec4, titleBgActive:ImVec4,
		tab:ImVec4, tabSelected:ImVec4
	) {
		this.winBg = winBg;
		this.childBg = childBg;
		this.popupBg = popupBg;
		this.border = border;
		this.accent = accent;
		this.accentHover = accentHover;
		this.btn = btn;
		this.btnHover = btnHover;
		this.header = header;
		this.text = text;
		this.titleBg = titleBg;
		this.titleBgActive = titleBgActive;
		this.tab = tab;
		this.tabSelected = tabSelected;
	}
}

/**
 * Modern theme engine for the ImGui showcase with multiple presets and dynamic customization.
 */
class DarkPastelTheme {
	public static var currentPreset:String = "Dark Pastel";
	public static var windowAlpha:Float = 0.95;

	// Persistent buffers for live custom theme editing
	public static var customWindowBg = makeColorBytes(0.11, 0.12, 0.15, 0.95);
	public static var customChildBg = makeColorBytes(0.13, 0.14, 0.18, 0.95);
	public static var customAccent = makeColorBytes(0.38, 0.58, 0.92, 1.00);
	public static var customButton = makeColorBytes(0.24, 0.30, 0.42, 0.80);
	public static var customHeader = makeColorBytes(0.30, 0.38, 0.52, 0.70);
	public static var customBorder = makeColorBytes(0.28, 0.34, 0.46, 0.50);
	public static var customText = makeColorBytes(0.92, 0.94, 0.98, 1.00);

	static inline var PUSHED_COLOR_COUNT = 25;
	static inline var PUSHED_VAR_COUNT = 14;

	static function makeColorBytes(r:Float, g:Float, b:Float, a:Float):Bytes {
		var bytes = new Bytes(16);
		bytes.setF32(0, r);
		bytes.setF32(4, g);
		bytes.setF32(8, b);
		bytes.setF32(12, a);
		return bytes;
	}

	public static function getActiveColors():ThemeColorSet {
		return switch (currentPreset) {
			case "Obsidian Ember":
				new ThemeColorSet(
					ImGui.vec4(0.07, 0.08, 0.10, windowAlpha),
					ImGui.vec4(0.10, 0.11, 0.14, windowAlpha),
					ImGui.vec4(0.08, 0.09, 0.12, 0.98),
					ImGui.vec4(0.26, 0.28, 0.34, 0.60),
					ImGui.vec4(0.95, 0.52, 0.22, 1.00),
					ImGui.vec4(1.00, 0.62, 0.32, 1.00),
					ImGui.vec4(0.22, 0.24, 0.29, 0.85),
					ImGui.vec4(0.95, 0.52, 0.22, 0.85),
					ImGui.vec4(0.24, 0.27, 0.33, 0.75),
					ImGui.vec4(0.92, 0.92, 0.94, 1.00),
					ImGui.vec4(0.12, 0.13, 0.17, 1.00),
					ImGui.vec4(0.18, 0.20, 0.25, 1.00),
					ImGui.vec4(0.16, 0.18, 0.22, 0.85),
					ImGui.vec4(0.26, 0.29, 0.36, 1.00)
				);
			case "Voidsteel Blue":
				new ThemeColorSet(
					ImGui.vec4(0.06, 0.08, 0.12, windowAlpha),
					ImGui.vec4(0.09, 0.12, 0.18, windowAlpha),
					ImGui.vec4(0.07, 0.09, 0.14, 0.98),
					ImGui.vec4(0.22, 0.28, 0.40, 0.55),
					ImGui.vec4(0.32, 0.72, 0.96, 1.00),
					ImGui.vec4(0.45, 0.82, 1.00, 1.00),
					ImGui.vec4(0.16, 0.24, 0.36, 0.85),
					ImGui.vec4(0.24, 0.34, 0.50, 0.95),
					ImGui.vec4(0.20, 0.28, 0.42, 0.75),
					ImGui.vec4(0.90, 0.93, 0.98, 1.00),
					ImGui.vec4(0.10, 0.14, 0.22, 1.00),
					ImGui.vec4(0.15, 0.21, 0.32, 1.00),
					ImGui.vec4(0.12, 0.18, 0.28, 0.85),
					ImGui.vec4(0.22, 0.32, 0.48, 1.00)
				);
			case "Solarflare Crimson":
				new ThemeColorSet(
					ImGui.vec4(0.10, 0.06, 0.08, windowAlpha),
					ImGui.vec4(0.14, 0.08, 0.11, windowAlpha),
					ImGui.vec4(0.10, 0.06, 0.08, 0.98),
					ImGui.vec4(0.38, 0.20, 0.26, 0.60),
					ImGui.vec4(0.95, 0.32, 0.42, 1.00),
					ImGui.vec4(1.00, 0.45, 0.55, 1.00),
					ImGui.vec4(0.28, 0.14, 0.18, 0.85),
					ImGui.vec4(0.38, 0.20, 0.26, 0.95),
					ImGui.vec4(0.32, 0.16, 0.22, 0.75),
					ImGui.vec4(0.96, 0.90, 0.92, 1.00),
					ImGui.vec4(0.16, 0.09, 0.12, 1.00),
					ImGui.vec4(0.24, 0.13, 0.18, 1.00),
					ImGui.vec4(0.20, 0.11, 0.15, 0.85),
					ImGui.vec4(0.34, 0.18, 0.25, 1.00)
				);
			case "Custom":
				var wb = bytesToVec4(customWindowBg);
				wb.w = windowAlpha;
				var cb = bytesToVec4(customChildBg);
				cb.w = windowAlpha;
				var acc = bytesToVec4(customAccent);
				var btn = bytesToVec4(customButton);
				var hdr = bytesToVec4(customHeader);
				var bdr = bytesToVec4(customBorder);
				var txt = bytesToVec4(customText);
				new ThemeColorSet(
					wb,
					cb,
					ImGui.vec4(wb.x * 0.9, wb.y * 0.9, wb.z * 0.9, 0.98),
					bdr,
					acc,
					ImGui.vec4(acc.x * 1.15, acc.y * 1.15, acc.z * 1.15, 1.0),
					btn,
					ImGui.vec4(btn.x * 1.25, btn.y * 1.25, btn.z * 1.25, 0.95),
					hdr,
					txt,
					ImGui.vec4(wb.x * 1.4, wb.y * 1.4, wb.z * 1.4, 1.0),
					ImGui.vec4(wb.x * 1.8, wb.y * 1.8, wb.z * 1.8, 1.0),
					ImGui.vec4(wb.x * 1.3, wb.y * 1.3, wb.z * 1.3, 0.85),
					ImGui.vec4(hdr.x, hdr.y, hdr.z, 1.0)
				);
			default: // "Dark Pastel"
				new ThemeColorSet(
					ImGui.vec4(0.11, 0.12, 0.15, windowAlpha),
					ImGui.vec4(0.13, 0.14, 0.18, windowAlpha),
					ImGui.vec4(0.09, 0.10, 0.13, 0.98),
					ImGui.vec4(0.28, 0.32, 0.42, 0.45),
					ImGui.vec4(0.38, 0.58, 0.92, 1.00),
					ImGui.vec4(0.48, 0.68, 1.00, 1.00),
					ImGui.vec4(0.25, 0.32, 0.46, 0.75),
					ImGui.vec4(0.35, 0.44, 0.62, 0.90),
					ImGui.vec4(0.32, 0.38, 0.52, 0.65),
					ImGui.vec4(0.92, 0.94, 0.97, 1.00),
					ImGui.vec4(0.16, 0.19, 0.26, 1.00),
					ImGui.vec4(0.22, 0.27, 0.38, 1.00),
					ImGui.vec4(0.22, 0.26, 0.36, 0.80),
					ImGui.vec4(0.38, 0.46, 0.64, 1.00)
				);
		};
	}

	static function bytesToVec4(b:Bytes):ImVec4 {
		return ImGui.vec4(b.getF32(0), b.getF32(4), b.getF32(8), b.getF32(12));
	}

	public static function pushTheme():Void {
		var c = getActiveColors();

		// Backgrounds (4)
		ImGui.pushStyleColor(ImGuiCol.WindowBg, c.winBg);
		ImGui.pushStyleColor(ImGuiCol.ChildBg, c.childBg);
		ImGui.pushStyleColor(ImGuiCol.PopupBg, c.popupBg);
		ImGui.pushStyleColor(ImGuiCol.Border, c.border);

		// Text (2)
		ImGui.pushStyleColor(ImGuiCol.Text, c.text);
		ImGui.pushStyleColor(ImGuiCol.TextDisabled, ImGui.vec4(c.text.x * 0.6, c.text.y * 0.6, c.text.z * 0.6, 1.0));

		// Headers (3)
		ImGui.pushStyleColor(ImGuiCol.Header, c.header);
		ImGui.pushStyleColor(ImGuiCol.HeaderHovered, c.accent);
		ImGui.pushStyleColor(ImGuiCol.HeaderActive, c.accentHover);

		// Buttons (3)
		ImGui.pushStyleColor(ImGuiCol.Button, c.btn);
		ImGui.pushStyleColor(ImGuiCol.ButtonHovered, c.btnHover);
		ImGui.pushStyleColor(ImGuiCol.ButtonActive, c.accent);

		// Frames (3)
		ImGui.pushStyleColor(ImGuiCol.FrameBg, c.childBg);
		ImGui.pushStyleColor(ImGuiCol.FrameBgHovered, c.header);
		ImGui.pushStyleColor(ImGuiCol.FrameBgActive, c.accent);

		// Tabs & Docking (7)
		ImGui.pushStyleColor(ImGuiCol.Tab, c.tab);
		ImGui.pushStyleColor(ImGuiCol.TabHovered, c.accent);
		ImGui.pushStyleColor(ImGuiCol.TabSelected, c.tabSelected);
		ImGui.pushStyleColor(ImGuiCol.TabDimmed, c.winBg);
		ImGui.pushStyleColor(ImGuiCol.TabDimmedSelected, c.childBg);
		ImGui.pushStyleColor(ImGuiCol.DockingPreview, c.accent);
		ImGui.pushStyleColor(ImGuiCol.DockingEmptyBg, ImGui.vec4(0.06, 0.07, 0.09, 1.0));

		// Titles (2)
		ImGui.pushStyleColor(ImGuiCol.TitleBg, c.titleBg);
		ImGui.pushStyleColor(ImGuiCol.TitleBgActive, c.titleBgActive);

		// Drag & Drop (1)
		ImGui.pushStyleColor(ImGuiCol.DragDropTarget, c.accent);

		// Total pushed = 4 + 2 + 3 + 3 + 3 + 7 + 2 + 1 = 25 colors

		// Style Variables (Metrics) - 14
		ImGui.pushStyleVar(ImGuiStyleVar.WindowRounding, 8.0);
		ImGui.pushStyleVar(ImGuiStyleVar.ChildRounding, 6.0);
		ImGui.pushStyleVar(ImGuiStyleVar.FrameRounding, 5.0);
		ImGui.pushStyleVar(ImGuiStyleVar.PopupRounding, 6.0);
		ImGui.pushStyleVar(ImGuiStyleVar.ScrollbarRounding, 5.0);
		ImGui.pushStyleVar(ImGuiStyleVar.GrabRounding, 4.0);
		ImGui.pushStyleVar(ImGuiStyleVar.TabRounding, 5.0);
		ImGui.pushStyleVar(ImGuiStyleVar.WindowBorderSize, 1.0);
		ImGui.pushStyleVar(ImGuiStyleVar.FrameBorderSize, 0.0);
		ImGui.pushStyleVar(ImGuiStyleVar.PopupBorderSize, 1.0);
		ImGui.pushStyleVar(ImGuiStyleVar.WindowPadding, ImGui.vec2(12, 12));
		ImGui.pushStyleVar(ImGuiStyleVar.FramePadding, ImGui.vec2(8, 5));
		ImGui.pushStyleVar(ImGuiStyleVar.ItemSpacing, ImGui.vec2(8, 6));
		ImGui.pushStyleVar(ImGuiStyleVar.IndentSpacing, 16.0);
	}

	public static function popTheme():Void {
		ImGui.popStyleVar(PUSHED_VAR_COUNT);
		ImGui.popStyleColor(PUSHED_COLOR_COUNT);
	}

	public static function wrap(drawFn:Void->Void):Void {
		pushTheme();
		try {
			drawFn();
		} catch (e:Dynamic) {
			popTheme();
			throw e;
		}
		popTheme();
	}
}
