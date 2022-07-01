/// @description enemy dies

if (!states.data.is_alive || !other.states.data.is_alive) exit;

ROOMCONTROLLER.gain_score(1);
other.states.set_state("die");

