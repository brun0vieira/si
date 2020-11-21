:-ensure_loaded('RTXengine/RTXengine.pl').
:-ensure_loaded('RTXengine/RTXutil.pl').

defrule gotox_right
	if goto_x(Xf) and x_is_at(Xi) and (Xi<Xf) and x_moving(0) and y_is_at(2) and y_moving(0)
	then [
		assert_once(action(move_x_right))
	].

defrule gotox_left
	if goto_x(Xf) and x_is_at(Xi) and (Xi>Xf) and x_moving(0) and y_is_at(2) and y_moving(0)
	then [
		assert_once(action(move_x_left))
	].

defrule gotox_finish
	if goto_x(Xf) and x_is_at(Xf)
	then [
		assert_once(action(stop_x)),
		retract(goto_x(Xf))
	].

defrule store_pallete
       if put_in_cell(X,Z,Block)
       then [
           new_id(ID),
           Seq = [
               (   true, assert(goto_xz(X,Z))),
               (   (x_is_at(X), z_is_at(Z), z_moving(0), x_moving(0)), assert(action(move_z_up))),
               (   is_at_z_up, assert(action(stop_z))),
               (   (is_at_z_up, z_moving(0)), assert(action(move_y_inside))),
               (   y_is_at(3), assert(action(stop_y))),
               (   (y_is_at(3), y_moving(0)), assert(action(move_z_down))),
               (   is_at_z_down, assert(action(stop_z))),
               (   (is_at_z_down, z_moving(0)), assert(action(move_y_outside))),
               (   y_is_at(2), assert(action(stop_y)))
           ],
           assert(sequence(ID,store_pallet_seq,Seq)),
           retract(store_pallete(X,Z,Block))
       ].


defrule gotoz_up
        if goto_z(Zf) and z_is_at(Zi) and (Zi<Zf) and z_moving(0)
        then [
            new_id(ID),
            Seq = [
                (    true, assert(action(move_z_up)),
                (    z_is_at(Zf), assert(action(stop_z)), retract_safe(goto_z(Zf))))
            ],
            assert(sequence(ID, gotoz_up_seq, Seq))
        ].

