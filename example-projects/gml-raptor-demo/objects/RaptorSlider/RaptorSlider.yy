{
  "$GMObject":"",
  "%Name":"RaptorSlider",
  "eventList":[
    {"$GMEvent":"","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":0,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":3,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"","%Name":"","collisionObjectId":null,"eventNum":56,"eventType":6,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"","%Name":"","collisionObjectId":null,"eventNum":53,"eventType":6,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
  ],
  "managed":true,
  "name":"RaptorSlider",
  "overriddenProperties":[
    {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"autosize","path":"objects/_baseControl/_baseControl.yy",},"resource":null,"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"False",},
  ],
  "parent":{
    "name":"controls",
    "path":"folders/_gml_raptor_/UI/controls.yy",
  },
  "parentObjectId":{
    "name":"_baseControlWithTooltip",
    "path":"objects/_baseControlWithTooltip/_baseControlWithTooltip.yy",
  },
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":1,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":1,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "properties":[
    {"$GMObjectProperty":"v1","%Name":"value","filters":[],"listItems":[],"multiselect":false,"name":"value","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"min_value","filters":[],"listItems":[],"multiselect":false,"name":"min_value","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"max_value","filters":[],"listItems":[],"multiselect":false,"name":"max_value","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"100","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"on_value_changed","filters":[],"listItems":[],"multiselect":false,"name":"on_value_changed","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"undefined","varType":4,},
    {"$GMObjectProperty":"v1","%Name":"on_mouse_enter_knob","filters":[],"listItems":[],"multiselect":false,"name":"on_mouse_enter_knob","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"undefined","varType":4,},
    {"$GMObjectProperty":"v1","%Name":"on_mouse_leave_knob","filters":[],"listItems":[],"multiselect":false,"name":"on_mouse_leave_knob","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"undefined","varType":4,},
    {"$GMObjectProperty":"v1","%Name":"rail_sprite_horizontal","filters":[
        "GMSprite",
      ],"listItems":[],"multiselect":false,"name":"rail_sprite_horizontal","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"sprDefaultSliderRailH","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"rail_sprite_vertical","filters":[
        "GMSprite",
      ],"listItems":[],"multiselect":false,"name":"rail_sprite_vertical","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"sprDefaultSliderRailV","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"knob_sprite","filters":[
        "GMSprite",
      ],"listItems":[],"multiselect":false,"name":"knob_sprite","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"sprDefaultSliderKnob","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"knob_color_mouse_over","filters":[],"listItems":[],"multiselect":false,"name":"knob_color_mouse_over","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"THEME_MAIN","varType":7,},
    {"$GMObjectProperty":"v1","%Name":"knob_autoscale","filters":[],"listItems":[],"multiselect":false,"name":"knob_autoscale","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"True","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"knob_xscale","filters":[],"listItems":[],"multiselect":false,"name":"knob_xscale","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"1","varType":0,},
    {"$GMObjectProperty":"v1","%Name":"knob_yscale","filters":[],"listItems":[],"multiselect":false,"name":"knob_yscale","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"1","varType":0,},
    {"$GMObjectProperty":"v1","%Name":"auto_text","filters":[],"listItems":[
        "slider_autotext.none",
        "slider_autotext.text_is_value",
        "slider_autotext.text_is_percent",
      ],"multiselect":false,"name":"auto_text","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"slider_autotext.text_is_value","varType":6,},
    {"$GMObjectProperty":"v1","%Name":"auto_text_position","filters":[],"listItems":[
        "slider_text.h_above",
        "slider_text.h_below",
        "slider_text.v_left",
        "slider_text.v_right",
      ],"multiselect":false,"name":"auto_text_position","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"slider_text.h_above","varType":6,},
    {"$GMObjectProperty":"v1","%Name":"orientation_horizontal","filters":[],"listItems":[],"multiselect":false,"name":"orientation_horizontal","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resource":null,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"True","varType":3,},
  ],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":{
    "name":"sprDefaultSliderRailH",
    "path":"sprites/sprDefaultSliderRailH/sprDefaultSliderRailH.yy",
  },
  "spriteMaskId":null,
  "visible":true,
}