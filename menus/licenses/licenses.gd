extends Control

const Component := preload("res://addons/licenses/component.gd")
const Licenses := preload("res://addons/licenses/licenses.gd")

@onready var license_tree: Tree = %LicenseTree
@onready var license_info: PanelContainer = %LicenseInfo


func _ready() -> void:
	load_licenses()


func load_licenses() -> void:
	var res: Licenses.LoadResult = Licenses.load(
		Licenses.get_license_data_filepath()
	)
	if res.err_msg != "":
		return
	var components: Array[Component] = res.components
	components.append_array(Licenses.get_required_engine_components())
	components.sort_custom(Licenses.new().compare_components_ascending)

	var categories: Dictionary[String, TreeItem] = {}
	var root: TreeItem = license_tree.create_item()
	root.set_text(0, "Back")
	root.set_selectable(0, true)
	root.disable_folding = true
	categories[""] = root

	for component: Component in components:
		if component.category not in categories:
			var category: TreeItem = license_tree.create_item()
			category.set_text(0, component.category)
			category.set_selectable(0, false)
			categories[component.category] = category
		_apply_project_to_main(component)

		var item: TreeItem = license_tree.create_item(
			categories[component.category]
		)
		item.set_text(0, component.name)
		item.set_meta("component", component)
		if component.id == "main":
			license_tree.set_selected(item, 0)


func _apply_project_to_main(component: Component) -> void:
	if component.id != "main":
		return

	component.name = ProjectSettings.get_setting("application/config/name")
	component.description = ProjectSettings.get_setting(
		"application/config/description"
	)
	component.version = ProjectSettings.get_setting(
		"application/config/version"
	)


func _on_tree_item_selected() -> void:
	if not license_tree.get_selected().has_meta("component"):
		await get_tree().process_frame  # Avoids get_viewport error
		get_tree().change_scene_to_file("res://menus/title_screen.tscn")
		return

	license_info.component = license_tree.get_selected().get_meta("component")
