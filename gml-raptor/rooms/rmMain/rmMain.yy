{
  "$GMRoom":"",
  "%Name":"rmMain",
  "creationCodeFile":"",
  "inheritCode":false,
  "inheritCreationOrder":false,
  "inheritLayers":false,
  "instanceCreationOrder":[
    {"name":"raptorTemplateRoomController","path":"rooms/rmMain/rmMain.yy",},
    {"name":"playMouseCursor_2_1_2_2","path":"rooms/rmMain/rmMain.yy",},
    {"name":"inst_216BCA47","path":"rooms/rmMain/rmMain.yy",},
  ],
  "isDnd":false,
  "layers":[
    {"$GMRInstanceLayer":"","%Name":"Controllers","depth":0,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
        {"$GMRInstance":"","%Name":"raptorTemplateRoomController","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"raptorTemplateRoomController","objectId":{"name":"MainRoomController","path":"objects/MainRoomController/MainRoomController.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":0.0,"y":-32.0,},
        {"$GMRInstance":"","%Name":"playMouseCursor_2_1_2_2","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"playMouseCursor_2_1_2_2","objectId":{"name":"RaptorMouseCursor","path":"objects/RaptorMouseCursor/RaptorMouseCursor.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":32.0,"y":32.0,},
      ],"layers":[],"name":"Controllers","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
    {"$GMRInstanceLayer":"","%Name":"MessageBox","depth":100,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[],"layers":[],"name":"MessageBox","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
    {"$GMRLayer":"","%Name":"popups","depth":200,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[
        {"$GMRInstanceLayer":"","%Name":"popup_instances","depth":300,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[],"layers":[],"name":"popup_instances","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
        {"$GMREffectLayer":"","%Name":"popup_effects","depth":400,"effectEnabled":true,"effectType":"_filter_vignette","gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"popup_effects","properties":[
            {"name":"g_VignetteEdges","type":0,"value":"0.2",},
            {"name":"g_VignetteEdges","type":0,"value":"1.2",},
            {"name":"g_VignetteSharpness","type":0,"value":"1",},
            {"name":"g_VignetteTexture","type":2,"value":"_filter_vignette_texture",},
          ],"resourceType":"GMREffectLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
        {"$GMREffectLayer":"","%Name":"popup_greyscale","depth":500,"effectEnabled":true,"effectType":"_filter_colourise","gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"popup_greyscale","properties":[
            {"name":"g_Intensity","type":0,"value":"1",},
            {"name":"g_TintCol","type":1,"value":"#FFFFFFFF",},
          ],"resourceType":"GMREffectLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
      ],"name":"popups","properties":[],"resourceType":"GMRLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
    {"$GMRLayer":"","%Name":"ui","depth":600,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[
        {"$GMRInstanceLayer":"","%Name":"ui_instances","depth":700,"effectEnabled":true,"effectType":null,"gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
            {"$GMRInstance":"","%Name":"inst_216BCA47","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_216BCA47","objectId":{"name":"AnimatedFlag","path":"objects/AnimatedFlag/AnimatedFlag.yy",},"properties":[
                {"$GMOverriddenProperty":"","%Name":"","name":"","objectId":{"name":"AnimatedFlag","path":"objects/AnimatedFlag/AnimatedFlag.yy",},"propertyId":{"name":"wave_speed","path":"objects/AnimatedFlag/AnimatedFlag.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"3",},
              ],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":3.1419713,"scaleY":3.1419716,"x":544.0,"y":352.0,},
          ],"layers":[],"name":"ui_instances","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
        {"$GMRAssetLayer":"","%Name":"ui_sprites","assets":[],"depth":800,"effectEnabled":true,"effectType":null,"gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"ui_sprites","properties":[],"resourceType":"GMRAssetLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
      ],"name":"ui","properties":[],"resourceType":"GMRLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
    {"$GMRBackgroundLayer":"","%Name":"Background","animationFPS":15.0,"animationSpeedType":0,"colour":4278190080,"depth":900,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"hspeed":0.0,"htiled":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"Background","properties":[],"resourceType":"GMRBackgroundLayer","resourceVersion":"2.0","spriteId":null,"stretch":false,"userdefinedAnimFPS":false,"userdefinedDepth":false,"visible":true,"vspeed":0.0,"vtiled":false,"x":0,"y":0,},
  ],
  "name":"rmMain",
  "parent":{
    "name":"main",
    "path":"folders/Rooms/main.yy",
  },
  "parentRoom":null,
  "physicsSettings":{
    "inheritPhysicsSettings":false,
    "PhysicsWorld":false,
    "PhysicsWorldGravityX":0.0,
    "PhysicsWorldGravityY":10.0,
    "PhysicsWorldPixToMetres":0.1,
  },
  "resourceType":"GMRoom",
  "resourceVersion":"2.0",
  "roomSettings":{
    "Height":1080,
    "inheritRoomSettings":false,
    "persistent":false,
    "Width":1920,
  },
  "sequenceId":null,
  "views":[
    {"hborder":32,"hport":1080,"hspeed":-1,"hview":1080,"inherit":false,"objectId":null,"vborder":32,"visible":true,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
  ],
  "viewSettings":{
    "clearDisplayBuffer":true,
    "clearViewBackground":true,
    "enableViews":true,
    "inheritViewSettings":false,
  },
  "volume":1.0,
}