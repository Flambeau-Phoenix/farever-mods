package demo;

import imgui.ImGui;
import imgui.Enums.ImGuiCol;
import imgui.Enums.ImGuiWindowFlags;
import imgui.Enums.ImGuiCond;
import imgui.Structs.ImVec2;
import imgui.Structs.ImVec4;

class DemoToast {
	public var message:String;
	public var title:String;
	public var type:String; // "info", "success", "warning", "error"
	public var timer:Float;
	public var maxTimer:Float;

	public function new(title:String, message:String, type:String, duration:Float) {
		this.title = title;
		this.message = message;
		this.type = type;
		this.timer = duration;
		this.maxTimer = duration > 0 ? duration : 3.0;
	}
}

/**
 * High-performance, non-intrusive floating toast notification system for ImGui.
 * Features auto-dismiss countdowns, alpha fading, colored accent bars, and non-blocking overlays.
 */
class ToastSystem {
	static var toasts:Array<DemoToast> = [];
	static inline var MAX_CONCURRENT_TOASTS:Int = 6;
	static var lastTimestamp:Float = 0.0;

	public static function notify(title:String, message:String, type:String = "info", duration:Float = 3.5):Void {
		toasts.push(new DemoToast(title, message, type, duration));
		if (toasts.length > MAX_CONCURRENT_TOASTS) {
			toasts.shift();
		}
	}

	public static function info(title:String, message:String, duration:Float = 3.0):Void {
		notify(title, message, "info", duration);
	}

	public static function success(title:String, message:String, duration:Float = 3.0):Void {
		notify(title, message, "success", duration);
	}

	public static function warning(title:String, message:String, duration:Float = 4.0):Void {
		notify(title, message, "warning", duration);
	}

	public static function error(title:String, message:String, duration:Float = 5.0):Void {
		notify(title, message, "error", duration);
	}

	public static function clear():Void {
		toasts = [];
	}

	public static function draw():Void {
		if (toasts.length == 0) return;

		var now = Date.now().getTime() / 1000.0;
		var dt:Single = (lastTimestamp > 0.0) ? (now - lastTimestamp) : 0.016;
		lastTimestamp = now;
		if (dt > 0.1) dt = 0.1;

		var screenW:Single = 1920.0;
		var screenH:Single = 1080.0;
		try {
			var vp = ImGui.getMainViewport();
			if (vp != null) {
				var c = ImGui.ImGuiViewport_GetCenter(vp);
				if (c != null && c.x > 100) {
					screenW = c.x * 2;
					screenH = c.y * 2;
				}
			}
		} catch (_:Dynamic) {}

		var yOffset:Single = 40.0;
		var toastWidth:Single = 320.0;
		var toastMarginRight:Single = 24.0;
		var remaining:Array<DemoToast> = [];

		for (i in 0...toasts.length) {
			var toast = toasts[i];
			toast.timer -= dt;
			if (toast.timer <= 0) continue;
			remaining.push(toast);

			var alpha:Single = 1.0;
			if (toast.timer < 0.6) {
				alpha = (toast.timer / 0.6);
			} else if ((toast.maxTimer - toast.timer) < 0.25) {
				alpha = ((toast.maxTimer - toast.timer) / 0.25);
			}
			if (alpha > 1.0) alpha = 1.0;
			if (alpha < 0.0) alpha = 0.0;

			var bgCol:ImVec4 = switch (toast.type) {
				case "success": ImGui.vec4(0.08, 0.22, 0.12, 0.92 * alpha);
				case "error": ImGui.vec4(0.26, 0.08, 0.08, 0.92 * alpha);
				case "warning": ImGui.vec4(0.28, 0.20, 0.06, 0.92 * alpha);
				default: ImGui.vec4(0.09, 0.14, 0.24, 0.92 * alpha);
			};

			var borderCol:ImVec4 = switch (toast.type) {
				case "success": ImGui.vec4(0.28, 0.85, 0.45, 0.95 * alpha);
				case "error": ImGui.vec4(0.95, 0.28, 0.28, 0.95 * alpha);
				case "warning": ImGui.vec4(0.95, 0.72, 0.18, 0.95 * alpha);
				default: ImGui.vec4(0.35, 0.65, 0.98, 0.95 * alpha);
			};

			var iconStr = switch (toast.type) {
				case "success": "✓ ";
				case "error": "✗ ";
				case "warning": "⚠ ";
				default: "ℹ ";
			};

			ImGui.setNextWindowPos(ImGui.vec2(screenW - toastWidth - toastMarginRight, yOffset), ImGuiCond.Always);
			ImGui.setNextWindowSize(ImGui.vec2(toastWidth, 0), ImGuiCond.Always);

			var flags = ImGuiWindowFlags.NoTitleBar |
				ImGuiWindowFlags.NoResize |
				ImGuiWindowFlags.NoMove |
				ImGuiWindowFlags.NoDocking |
				ImGuiWindowFlags.NoScrollbar |
				ImGuiWindowFlags.NoSavedSettings |
				ImGuiWindowFlags.NoFocusOnAppearing |
				ImGuiWindowFlags.NoNav;

			ImGui.pushStyleColor(ImGuiCol.WindowBg, bgCol);
			ImGui.pushStyleColor(ImGuiCol.Border, borderCol);

			if (ImGui.begin('##demo_toast_${i}', null, flags)) {
				ImGui.textColored(borderCol, iconStr + toast.title);
				ImGui.separator();
				ImGui.textWrapped(toast.message);

				// Countdown progress line
				var progressFrac = toast.timer / toast.maxTimer;
				ImGui.pushStyleColor(ImGuiCol.PlotHistogram, borderCol);
				ImGui.progressBar(progressFrac, ImGui.vec2(-1, 2), "");
				ImGui.popStyleColor();
			}
			ImGui.end();
			ImGui.popStyleColor(2);

			yOffset += 78.0;
		}

		toasts = remaining;
	}
}
