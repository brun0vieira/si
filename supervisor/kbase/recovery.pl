
recover_failure:-
    % dummy recovery, use if it suits you
    write('recovering a failure'),
    retract(failures_to_json(_)),
    !.


% other recovery failures here...
/*recover_failure:-
    not(failure(x10_failure, _TimeStamp, _Description, _States, _Goals)),
    member(recover_seq(ID,x10_failure,Sequence)),
    assert(sequence(ID, recovery_x_10, Sequence)),
    assert(plan_to_json(Sequence)),
    retract(failures_to_json(_)).
*/
recover_failure. % this should be the last one
