/// @description game over

if (GUI_POPUP_VISIBLE || !states.data.is_alive || !other.owner.states.data.is_alive) exit;

STATEMACHINES.process_all("set_state", "ev:key_press_vk_escape");
states.set_state("die");

