@tool
extends EditorPlugin
## Bayland Toolkit: shared modules for Bayland Blue's Godot games. Each module is opt-in: switch
## it on in Project Settings (bayland_toolkit/<module>/enabled). A module that's off adds nothing
## to an export, so a game carries only the native libraries it uses.
##
## Modules:
## - review: the store's in-app rating sheet (BaylandStoreReview, review/README.md). Android adds
##   review/bin/BaylandReview-*.aar and Google Play's review library.

const REVIEW_SETTING := "bayland_toolkit/review/enabled"

var _export: BaylandToolkitExport

func _enter_tree() -> void:
	for setting: Array in [[REVIEW_SETTING, false, TYPE_BOOL]]:
		if not ProjectSettings.has_setting(setting[0]):
			ProjectSettings.set_setting(setting[0], setting[1])
		ProjectSettings.set_initial_value(setting[0], setting[1])
		ProjectSettings.add_property_info({"name": setting[0], "type": setting[2]})
	_export = BaylandToolkitExport.new()
	# This addon's folder relative to res://addons/ (e.g. "bayland_toolkit/godot"), wherever the
	# submodule is mounted.
	_export.dir = (get_script() as Script).resource_path.get_base_dir().trim_prefix("res://addons/")
	add_export_plugin(_export)

func _exit_tree() -> void:
	remove_export_plugin(_export)
	_export = null

class BaylandToolkitExport extends EditorExportPlugin:
	## Keep in step with review/android_src/build.gradle.
	const PLAY_REVIEW := "com.google.android.play:review:2.0.2"

	var dir := "bayland_toolkit/godot"

	func _get_name() -> String:
		return "BaylandToolkit"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var libs := PackedStringArray()
		if _on(REVIEW_SETTING):
			libs.append("%s/review/bin/BaylandReview-%s.aar" % [dir, "debug" if debug else "release"])
		return libs

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		var deps := PackedStringArray()
		if _on(REVIEW_SETTING):
			deps.append(PLAY_REVIEW)
		return deps

	func _on(setting: String) -> bool:
		return bool(ProjectSettings.get_setting(setting, false))
