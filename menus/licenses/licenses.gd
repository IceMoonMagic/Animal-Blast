extends Control

const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")

var components: Array[Component] = []
var _component_memo: Dictionary[String, Component] = {}

@onready var license_tree: Tree = %LicenseTree
@onready var license_info: PanelContainer = %LicenseInfo


func _init() -> void:
	load_licenses()


func _ready() -> void:
	list_licenses()


func load_licenses() -> void:
	# Engine Licenses
	var engine_components: Array[Component] = Licenses.get_engine_components()
	_move_to_front(engine_components, "Godot Engine logo")
	_move_to_front(engine_components, "Godot Engine")

	# Local Licenses
	var res: Licenses.LoadResult = Licenses.load(
		Licenses.get_license_data_filepath()
	)
	if res.err_msg != "":
		components = engine_components
	else:
		components = res.components + engine_components

	_apply_project_to_main()

	_rename_component(
		"Wayland protocols that add functionality not available in the core protocol",
		"Wayland extra protocols"
	)


func list_licenses() -> void:
	var categories: Dictionary[String, TreeItem] = {}
	var root: TreeItem = license_tree.create_item()
	root.set_text(0, "Back")
	root.set_selectable(0, true)
	root.disable_folding = true
	categories[""] = root

	for component: Component in components:
		_component_memo.set(component.name, component)
		if component.category not in categories:
			var category: TreeItem = license_tree.create_item()
			if component.category == "Engine Components":
				category.set_text(0, "Godot Engine")
			else:
				category.set_text(0, component.category)
			category.set_text(
				0,
				(
					component.category
					if component.category != "Engine Components"
					else "Godot Engine & Third-Parties"
				)
			)
			category.set_selectable(0, false)
			categories[component.category] = category

		var item: TreeItem = license_tree.create_item(
			categories[component.category]
		)
		item.set_text(0, component.name)
		if component.id == "main":
			license_tree.set_selected(item, 0)


func _get_component(component_name: String) -> Component:
	if not _component_memo.has(component_name):
		var index: int = components.find_custom(
			func(c: Component) -> bool: return c.name == component_name,
		)
		if index == -1:
			return null
		_component_memo.set(component_name, components[index])

	var component: Component = _component_memo[component_name]
	return component


func _move_to_front(array: Array[Component], comp_name: String) -> void:
	var index: int = array.find_custom(
		func(c: Component) -> bool: return c.name == comp_name,
	)
	if index == -1:
		return
	var component: Component = array.pop_at(index)
	array.push_front(component)


func _rename_component(orig_name: String, new_name: String) -> void:
	var component: Component = _get_component(orig_name)
	component.name = new_name


func _apply_project_to_main() -> void:
	var component: Component = _get_component("Game")

	component.name = ProjectSettings.get_setting("application/config/name")
	component.description = ProjectSettings.get_setting(
		"application/config/description"
	)
	component.version = ProjectSettings.get_setting(
		"application/config/version"
	)


func _on_tree_item_selected() -> void:
	var text: String = license_tree.get_selected().get_text(0)
	var component: Component = _get_component(text)
	if component == null:
		await get_tree().process_frame  # Avoids get_viewport error
		get_tree().change_scene_to_file("res://menus/title_screen.tscn")
		return

	license_info.component = component
