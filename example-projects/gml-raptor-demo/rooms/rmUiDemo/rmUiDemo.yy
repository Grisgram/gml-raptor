{
  "resourceType": "GMRoom",
  "resourceVersion": "1.0",
  "name": "rmUiDemo",
  "creationCodeFile": "",
  "inheritCode": false,
  "inheritCreationOrder": false,
  "inheritLayers": false,
  "instanceCreationOrder": [
    {"name":"uiDemoRoomController","path":"rooms/rmUiDemo/rmUiDemo.yy",},
    {"name":"uiDemoMouseCursor","path":"rooms/rmUiDemo/rmUiDemo.yy",},
    {"name":"inst_6780F786","path":"rooms/rmUiDemo/rmUiDemo.yy",},
    {"name":"inst_41F202B3","path":"rooms/rmUiDemo/rmUiDemo.yy",},
    {"name":"inst_7A529505","path":"rooms/rmUiDemo/rmUiDemo.yy",},
    {"name":"inst_42B159E","path":"rooms/rmUiDemo/rmUiDemo.yy",},
  ],
  "isDnd": false,
  "layers": [
    {"resourceType":"GMRInstanceLayer","resourceVersion":"1.0","name":"Controllers","depth":0,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
        {"resourceType":"GMRInstance","resourceVersion":"1.0","name":"uiDemoRoomController","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"objectId":{"name":"UiDemoRoomController","path":"objects/UiDemoRoomController/UiDemoRoomController.yy",},"properties":[],"rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":0.0,"y":-32.0,},
        {"resourceType":"GMRInstance","resourceVersion":"1.0","name":"uiDemoMouseCursor","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"objectId":{"name":"MouseCursor","path":"objects/MouseCursor/MouseCursor.yy",},"properties":[],"rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":32.0,"y":32.0,},
      ],"layers":[],"properties":[],"userdefinedDepth":false,"visible":true,},
    {"resourceType":"GMRInstanceLayer","resourceVersion":"1.0","name":"MessageBox","depth":100,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[],"layers":[],"properties":[],"userdefinedDepth":false,"visible":true,},
    {"resourceType":"GMRLayer","resourceVersion":"1.0","name":"popups","depth":200,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[
        {"resourceType":"GMRInstanceLayer","resourceVersion":"1.0","name":"popup_instances","depth":300,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[],"layers":[],"properties":[],"userdefinedDepth":false,"visible":false,},
        {"resourceType":"GMREffectLayer","resourceVersion":"1.0","name":"popup_effects","depth":400,"effectEnabled":true,"effectType":"_filter_vignette","gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"properties":[
            {"name":"g_VignetteEdges","type":0,"value":"0.2",},
            {"name":"g_VignetteEdges","type":0,"value":"1.2",},
            {"name":"g_VignetteSharpness","type":0,"value":"1",},
            {"name":"g_VignetteTexture","type":2,"value":"_filter_vignette_texture",},
          ],"userdefinedDepth":false,"visible":false,},
        {"resourceType":"GMREffectLayer","resourceVersion":"1.0","name":"popup_greyscale","depth":500,"effectEnabled":true,"effectType":"_filter_colourise","gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"properties":[
            {"name":"g_Intensity","type":0,"value":"1",},
            {"name":"g_TintCol","type":1,"value":"#FFFFFFFF",},
          ],"userdefinedDepth":false,"visible":false,},
      ],"properties":[],"userdefinedDepth":false,"visible":false,},
    {"resourceType":"GMRLayer","resourceVersion":"1.0","name":"ui","depth":600,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[
        {"resourceType":"GMRInstanceLayer","resourceVersion":"1.0","name":"ui_instances","depth":700,"effectEnabled":true,"effectType":null,"gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
            {"resourceType":"GMRInstance","resourceVersion":"1.0","name":"inst_6780F786","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"objectId":{"name":"TextButton","path":"objects/TextButton/TextButton.yy",},"properties":[
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"LGTextObject","path":"objects/LGTextObject/LGTextObject.yy",},"propertyId":{"name":"text","path":"objects/LGTextObject/LGTextObject.yy",},"value":"=main_menu/show_message",},
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"_baseClickableControl","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"propertyId":{"name":"on_left_click","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"value":"messageboxButton_click",},
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"_baseControlWithTooltip","path":"objects/_baseControlWithTooltip/_baseControlWithTooltip.yy",},"propertyId":{"name":"tooltip_text","path":"objects/_baseControlWithTooltip/_baseControlWithTooltip.yy",},"value":"=main_menu/tooltips/game_button",},
              ],"rotation":0.0,"scaleX":10.0,"scaleY":2.0,"x":80.0,"y":112.0,},
            {"resourceType":"GMRInstance","resourceVersion":"1.0","name":"inst_41F202B3","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"objectId":{"name":"TextButton","path":"objects/TextButton/TextButton.yy",},"properties":[
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"LGTextObject","path":"objects/LGTextObject/LGTextObject.yy",},"propertyId":{"name":"text","path":"objects/LGTextObject/LGTextObject.yy",},"value":"=play/ui/race_exit_button",},
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"_baseClickableControl","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"propertyId":{"name":"on_left_click","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"value":"ui_demo_exit_click",},
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"draw_on_gui","path":"objects/_baseControl/_baseControl.yy",},"value":"False",},
              ],"rotation":0.0,"scaleX":10.0,"scaleY":2.0,"x":80.0,"y":416.0,},
            {"resourceType":"GMRInstance","resourceVersion":"1.0","name":"inst_7A529505","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"objectId":{"name":"TextButton","path":"objects/TextButton/TextButton.yy",},"properties":[
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"LGTextObject","path":"objects/LGTextObject/LGTextObject.yy",},"propertyId":{"name":"text","path":"objects/LGTextObject/LGTextObject.yy",},"value":"=ui_demo/show_sizeable",},
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"_baseClickableControl","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"propertyId":{"name":"on_left_click","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"value":"ui_demo_sizable_window_click",},
              ],"rotation":0.0,"scaleX":10.0,"scaleY":2.0,"x":80.0,"y":192.0,},
            {"resourceType":"GMRInstance","resourceVersion":"1.0","name":"inst_42B159E","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"objectId":{"name":"TextButton","path":"objects/TextButton/TextButton.yy",},"properties":[
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"LGTextObject","path":"objects/LGTextObject/LGTextObject.yy",},"propertyId":{"name":"text","path":"objects/LGTextObject/LGTextObject.yy",},"value":"=ui_demo/control_tree",},
                {"resourceType":"GMOverriddenProperty","resourceVersion":"1.0","name":"","objectId":{"name":"_baseClickableControl","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"propertyId":{"name":"on_left_click","path":"objects/_baseClickableControl/_baseClickableControl.yy",},"value":"ui_demo_control_tree_click",},
              ],"rotation":0.0,"scaleX":10.0,"scaleY":2.0,"x":80.0,"y":272.0,},
          ],"layers":[],"properties":[],"userdefinedDepth":false,"visible":true,},
        {"resourceType":"GMRAssetLayer","resourceVersion":"1.0","name":"ui_sprites","assets":[],"depth":800,"effectEnabled":true,"effectType":null,"gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"properties":[],"userdefinedDepth":false,"visible":true,},
      ],"properties":[],"userdefinedDepth":false,"visible":true,},
    {"resourceType":"GMRBackgroundLayer","resourceVersion":"1.0","name":"Background","animationFPS":15.0,"animationSpeedType":0,"colour":4278190080,"depth":900,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"hspeed":0.0,"htiled":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"properties":[],"spriteId":null,"stretch":false,"userdefinedAnimFPS":false,"userdefinedDepth":false,"visible":true,"vspeed":0.0,"vtiled":false,"x":0,"y":0,},
  ],
  "parent": {
    "name": "ui-demo",
    "path": "folders/Rooms/ui-demo.yy",
  },
  "parentRoom": null,
  "physicsSettings": {
    "inheritPhysicsSettings": false,
    "PhysicsWorld": false,
    "PhysicsWorldGravityX": 0.0,
    "PhysicsWorldGravityY": 10.0,
    "PhysicsWorldPixToMetres": 0.1,
  },
  "roomSettings": {
    "Height": 1080,
    "inheritRoomSettings": false,
    "persistent": false,
    "Width": 1920,
  },
  "sequenceId": null,
  "views": [
    {"hborder":32,"hport":1080,"hspeed":-1,"hview":1080,"inherit":false,"objectId":null,"vborder":32,"visible":true,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
  ],
  "viewSettings": {
    "clearDisplayBuffer": true,
    "clearViewBackground": true,
    "enableViews": true,
    "inheritViewSettings": false,
  },
  "volume": 1.0,
}