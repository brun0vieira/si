:-ensure_loaded('RTXengine/RTXengine.pl').
:-ensure_loaded('RTXengine/RTXutil.pl').

defrule gotox_right
    if goto_x(Xf) and x_is_at(Xi) and (Xi<Xf) and x_moving(0)
    then [
        assert(action(move_x_right))
    ].

defrule gotox_left
    if goto_x(Xf) and x_is_at(Xi) and (Xi>Xf) and x_moving(0)
    then [
        assert(action(move_x_left))
    ].

defrule gotox_finish
    if goto_x(Xf) and x_is_at(Xf)
    then [
        assert(action(stop_x)),
        retract(goto_x(Xf))
    ].

defrule gotoy_inside
    if goto_y(Yf) and y_is_at(Yi) and (Yi<Yf) and y_moving(0)
    then [
        assert(action(move_y_inside))
    ].

defrule gotoy_outside
    if goto_y(Yf) and y_is_at(Yi) and (Yi>Yf) and y_moving(0)
    then [
        assert(action(move_y_outside))
    ].

defrule gotoy_finish
     if goto_y(Yf) and y_is_at(Yf)
     then [
         assert(action(stop_y)),
         retract(goto_y(Yf))
     ].

defrule gotoz_up
     if goto_z(Zf) and z_is_at(Zi) and (Zi<Zf) and z_moving(0)
     then [
         new_id(ID),
         Seq = [
             (   true, assert(action(move_z_up))),
             (   z_is_at(Zf), assert(action(stop_z)), retract_safe(goto_z(Zf)))
         ],
         assert(sequence(ID,gotoz_up_seq,Seq))
     ].

defrule gotoz_down
     if goto_z(Zf) and z_is_at(Zi) and (Zi>Zf) and z_moving(0)
     then [
         new_id(ID),
         Seq = [
             (   true, assert(action(move_z_down))),
             (   z_is_at(Zf), assert(action(stop_z)), retract_safe(goto_z(Zf)))
         ],
         assert(sequence(ID,gotoz_down_seq,Seq))
     ].

defrule gotoz_finish
     if goto_z(Zf) and z_is_at(Zf) and stop_z
     then [
         retract(goto_z(Zf))
     ].

defrule goto_xz
    if goto_xz(X,Z) and not(goto_x(_)) and not(goto_z(_))
    then [
        assert_once(goto_x(X)),
        assert_once(goto_z(Z)),
        retract(goto_xz(X,Z))
    ].

/*
defrule pick_part_left
     if pick_part_left_station(Block)
     then [
         new_id(ID),
         Seq = [
             (   true, assert(goto_xz(1,1))),
             (   (x_is_at(1),z_is_at(1)), assert(action(move_left_station_inside))),
             (   is_part_at_left_station, assert(action(stop_left_station))),
             (   true, assert(goto_y(1))),
             (   y_is_at(1), assert(action(move_z_up))),
             (   is_at_z_up, assert(action(stop_z))),
             (   (is_at_z_up,z_moving(0)), assert(goto_y(2))),
             (   y_is_at(2), assert(action(move_z_down))),
             (   is_at_z_down, assert(action(stop_z)))
         ],
         assert(sequence(ID,pick_part_left_seq,Seq)),
         retract_safe(pick_part_left_station(Block))
     ].
*/
defrule give_part_right
     if give_part_right_station(Block) and cage_has_part
     then [
         new_id(ID),
         Seq = [
             (   true, assert(goto_xz(10,1))),
             (   (x_is_at(10),z_is_at(1)), assert(action(move_z_up))),
             (   is_at_z_up, assert(action(stop_z))),
             (   (is_at_z_up,z_moving(0)), assert(goto_y(1))),
             (   y_is_at(1), assert(action(move_z_down))),
             (   is_at_z_down, assert(action(stop_z))),
             (   (is_at_z_down,z_moving(0)), assert(goto_y(2)))
         ],
         assert(sequence(ID,give_part_right_seq,Seq)),
         retract_safe(give_part_right_station(Block))
     ].

defrule give_part_left
     if give_part_left_station(Block) and cage_has_part
     then [
         new_id(ID),
         Seq = [
             (   true, assert(goto_xz(1,1))),
             (   (x_is_at(1),z_is_at(1)), assert(action(move_z_up))),
             (   is_at_z_up, assert(action(stop_z))),
             (   (is_at_z_up,z_moving(0)), assert(goto_y(1))),
             (   y_is_at(1), assert(action(move_z_down))),
             (   is_at_z_down, assert(action(stop_z))),
             (   (is_at_z_down,z_moving(0)), assert(goto_y(2)))
         ],
         assert(sequence(ID,give_part_left_seq,Seq)),
         retract_safe(give_part_left_station(Block))
     ].

defrule pick_part_left
     if pick_closest_part(Block) and x_is_at(X) and (X=<5)
     then [
         new_id(ID),
         Seq = [
             (   true, assert(goto_xz(1,1))),
             (   (x_is_at(1),z_is_at(1)), assert(action(move_left_station_inside))),
             (   is_part_at_left_station, assert(action(stop_left_station))),
             (   true, assert(goto_y(1))),
             (   y_is_at(1), assert(action(move_z_up))),
             (   is_at_z_up, assert(action(stop_z))),
             (   (is_at_z_up,z_moving(0)), assert(goto_y(2))),
             (   y_is_at(2), assert(action(move_z_down))),
             (   is_at_z_down, assert(action(stop_z)))
         ],
         assert(sequence(ID,pick_part_left_seq,Seq)),
         retract_safe(pick_closest_part(Block))
     ].

defrule pick_part_right
     if pick_closest_part(Block) and x_is_at(X) and (X>5)
     then [
         new_id(ID),
         Seq = [
             (   true, assert(goto_xz(10,1))),
             (   (x_is_at(10),z_is_at(1)), assert(action(move_right_station_inside))),
             (   is_part_at_right_station, assert(action(stop_right_station))),
             (   true, assert(goto_y(1))),
             (   y_is_at(1), assert(action(move_z_up))),
             (   is_at_z_up, assert(action(stop_z))),
             (   (is_at_z_up,z_moving(0)), assert(goto_y(2))),
             (   y_is_at(2), assert(action(move_z_down))),
             (   is_at_z_down, assert(action(stop_z)))
         ],
         assert(sequence(ID,pick_part_right_seq,Seq)),
         retract_safe(pick_closest_part(Block))
     ].
/*
defrule put_part_in_cell
     if put_in_cell(X,Z,Block)
     then [
     ].
*/
     /*
      *
      *



       ].

defrule store_pallete
       if put_in_cell(X,Z,Block) %and cage_has_part
       then [
           new_id(ID),
           Seq = [
               (   true, assert(goto_xz(X,Z))),
               (   (x_is_at(X), z_is_at(Z), z_moving(0), x_moving(0)), assert(action(move_z_up))),
               (   is_at_z_up, assert(action(stop_z))),
               (   (is_at_z_up,z_moving(0)), assert(goto_y(3))),
               (   y_is_at(3), assert(action(move_z_down))),
               (   is_at_z_down, assert(action(stop_z))),
               (   (is_at_z_down, z_moving(0)), assert(goto_y(2)))
           ],
           assert(sequence(ID,store_pallet_seq,Seq)),
           retract(put_in_cell(X,Z,Block))
       ].

defrule pick_pallete
       if take_from_cell(X,Z,Block) %and not(cage_has_part)
       then [
           new_id(ID),
           Seq = [
               (   true, assert(goto_xz(X,Z))),
               (   (x_is_at(X), z_is_at(Z), is_at_z_down), assert(goto_y(3))),
               (   y_is_at(3), assert(action(move_z_up))),
               (   is_at_z_up, assert(action(stop_z))),
               (   (is_at_z_up, z_moving(0)), assert(goto_y(2))),
               (   y_is_at(2), assert(action(move_z_down))),
               (   is_at_z_down, assert(action(stop_z)))
          ],
          assert(sequence(ID,pick_pallete_seq(Seq))),
          retract(take_from_cell(X,Z,Block))
       ].


*/
defrule actions_into_monitoring_goals
if true
then [

    findall(
        _IgnoredFact,
        (
            action(Action),
            retractall(goal(action(Action))),
            assert(goal(action(Action)))
        ),
        _IgnoredList
    )
].


defrule x_position_estimation
     if x_is_at(X) and x_moving(Mov) and (Mov\==0)
     then[

        X_near is X+0.5*Mov,
        assert_once(x_is_near(X_near)),
        assert_once(x_before(X))
     ].

defrule time_of_event_x_is_at
     if x_is_at(X) and not(time(x_is_at(_), _))
     then [

        retractall(time(x_is_at(_), _) ),
        get_time(Time),
        assert(time(x_is_at(X),Time))
     ].

%test if actuador xx is moving past x=10
defrule beyond_last_sensor_error
if goal(action(move_x_right))
               and not(failure(x10_failure, ,, _, _))    %avoid avalancche of failure facts
               and not(x_is_at(_))
               and x_is_near(X)
               and (X>10)
               and x_moving(1)
               then [           %adjust the time aqccording to the simulator speed
   get_warehouse_states(States),
   findall( goal(G), goal(G), Goals),
   get_time(Time_now),
   assert(failure(x10_failure, Time_now, 'Moving beyond x=10', States, Goals))/*,
   writeq(failure(x10_failure, Time_now, 'Moving beyond x=10', States, Goals))*/
].

%test if xx=5, goto_x(1) and missing sensor xx=2
%defrule missing_sensor_x_2
%if(goal()

% SPECIFY ALL THE OTHER RULES HERE

defrule diagnose_failures_rule
if failure(Type, TimeStamp, Description, States, Goals) then[
   Failure = failure(Type, TimeStamp, Description, States, Goals),                   findall( _Ignore1 ,                                                                         diag(Failure), % <-- CALLING DIAGNOSIS
            _Ignore2),
   retract(Failure),
   % save the failure to be shown in the html UI-console(NEXT CLASS)
   assert(failures_to_json(Failure)),
   writeln(Failure)
].

