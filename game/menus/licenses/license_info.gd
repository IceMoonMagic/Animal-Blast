extends PanelContainer

const Component := preload("res://addons/licenses/component.gd")

@export var dividing_line_width: int = 10
var component: Component:
	set(val):
		component = val
		name_label.text = component.name
		version_label.text = component.version
		version_label.visible = version_label.text != ""
		description_text.text = component.description
		copyright_text.text = "\n".join(component.copyright)
		web_text.text = component.web
		web_text.uri = component.web
		web_text.visible = web_text.text != ""
		web_label.visible = web_text.visible
		licenses_names.text = "\n".join(
			component.licenses.map(
				func(license: Component.License) -> String: return license.name
			)
		)
		for child: Node in (
			licenses_text_template.get_parent().get_children().slice(1)
		):
			child.queue_free()
		for license: Component.License in component.licenses:
			var text_box := licenses_text_template.duplicate()
			text_box.text = license.get_license_text()
			text_box.visible = true
			licenses_text_template.get_parent().add_child(text_box)
@onready var name_label: Label = %NameLabel
@onready var version_label: Label = %VersionLabel
@onready var description_text: RichTextLabel = %DescriptionText
@onready var copyright_text: RichTextLabel = %CopyrightText
@onready var web_label: Label = %WebLabel
@onready var web_text: LinkButton = %WebText
@onready var licenses_names: RichTextLabel = %LicensesNames
@onready var licenses_text_template: RichTextLabel = %LicensesTextTemplate
