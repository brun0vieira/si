:-ensure_loaded('RTXengine/RTXstrips_planner').
:-ensure_loaded('RTXengine/RTXutil').

act goto_x(Xf)
     pre [x_is_at(Xi), (Xi\==Xf)]
     add [x_is_at(Xf)]
     del [x_is_at(Xi)]
     endcond [x_is_at(Xf)].

act goto_y(Yf)
     pre [y_is_at(Yi), (Yi\==Yf)]
     add [y_is_at(Yf)]
     del [y_is_at(Yi)]
     endcond [y_is_at(Yf)].

act goto_z(Zf)
     pre [z_is_at(Zi), (Zi\==Zf)]
     add [z_is_at(Zf)]
     del [z_is_at(Zi)]
     endcond [z_is_at(Zf)].

act goto_xz(Xf, Zf)
       pre [x_is_at(Xi), z_is_at(Zi), (Xi\==Xf, Zi\==Zf)]
       add [x_is_at(Xf), z_is_at(Zf)]
       del [x_is_at(Xi), z_is_at(Zi)]
       endcond [x_is_at(Xf),z_is_at(Zf)].

act give_part_right_station(Block)
      pre [x_is_at(10),z_is_at(1),cage(Block),not(is_part_at_right_station)]
      add [give_right_station(Block)]
      del [cage(Block)]
      endcond [not(cage_has_part),y_is_at(2),is_at_z_down].

act give_part_left_station(Block)
      pre [x_is_at(1),z_is_at(1),cage(Block), not(is_part_at_left_station)]
      add [give_left_station(Block)]
      del [cage(Block)]
      endcond [not(cage_has_part),y_is_at(2),is_at_z_down].

act pick_closest_part(Block)
      pre [not(cell(_,_,Block)),not(cage(_))]
      add [cage(Block)]
      del []
      endcond [not(cage_has_part),y_is_at(2),is_at_z_down].

act put_in_cell(X,Z,Block)
      pre [not(cell(X,Z,_)),cage(Block),not(cell(_,_,Block)),x_is_at(X),z_is_at(Z)]
      add [cell(X,Z,Block)]
      del [cage(Block)]
      endcond [not(cage_has_part),y_is_at(2),is_at_z_down].


act take_from_cell(X,Z,Block)
      pre [cell(X,Z,Block),not(cage(_)),x_is_at(X),z_is_at(Z)]
      add [cage(Block)]
      del [cell(X,Z,Block)]
      endcond [cage_has_part,y_is_at(2),is_at_z_down].

% Blocks world

act stack(X,Y)
      pre [clear(Y),holding(X)]
      add [on(X,Y),clear(X),handempty]
      del [clear(Y),holding(X)]
      endcond [do_next].

act unstack(X,Y)
      pre [on(X,Y),clear(X),handempty]
      add [clear(Y),holding(X)]
      del [on(X,Y),clear(X),handempty]
      endcond [do_next].

act pickup(X)
      pre [ontable(X), clear(X), handempty]
      add [holding(X)]
      del [ontable(X), clear(X), handempty]
      endcond [do_next].

act putdown(X)
      pre [holding(X)]
      add [ontable(X), clear(X), handempty]
      del [holding(X)]
      endcond [do_next].
