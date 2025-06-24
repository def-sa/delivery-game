extends Control

@onready var rectangle_node: ReferenceRect = $rectangle
@onready var colored_bg_node: ColorRect = $rectangle/colored_bg
@onready var item_text_node: Label = $rectangle/colored_bg/item_text



#
#var rect_color:Color:  #inverted by default
	#set(v):
		#rect_color = v
		#rectangle_node.border_color = rect_color
#
#var bg_color:Color:
	#set(v):
		#bg_color = v
		#item_name_bg_node.color = bg_color
#
#var item_text:String:
	#set(v):
		#item_text = v
		#item_text_node.text = item_text
