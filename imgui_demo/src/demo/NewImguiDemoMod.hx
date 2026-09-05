package demo;

import imgui.ImGui;

@:build(hlx.runtime.Mod.build())
class NewImguiDemoMod {
	static function main():Void {
		var panel = new NewDemoPanel();
		ImGui.register(HlxRuntime.moduleName(), () -> DarkPastelTheme.wrap(panel.draw));
	}
}
