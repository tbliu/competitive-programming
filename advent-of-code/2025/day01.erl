#!/usr/bin/env escript
-mode(compile).

main(_) ->
    Lines = read_lines_string(),
    Counts = count_zeros(Lines, 50),
    io:format("Part 1: ~p~n", [Counts]),

    done.

count_zeros(List, Pos) -> count_zeros(List, Pos, 0).
count_zeros([], _, Acc) -> Acc;
count_zeros([H|T], Pos, Acc) ->
    [Direction|Rest] = H,
    {Rotations,_} = string:to_integer(Rest),
    NewPos = rotate(Pos, Direction, Rotations),
    case NewPos of
        NP when NewPos =:= 0 ->
            count_zeros(T, NP, Acc + 1);
        NP ->
            count_zeros(T, NP, Acc)
    end.


rotate(Pos, Direction, Count) ->
    % L is negative; R is positive increasing
    case Direction of
        $L ->
            NewPos = Pos - Count;
        % Else is "R"
        _ ->
            NewPos = Pos + Count
    end,

    % We can rotate more than 99 clicks.
    % Since it's [0, 99] inclusive, we use 100
    % to divide
    Rem = NewPos rem 100,

    % Erlang doesn't have a proper modulo function
    % so we need to increment by 100 to get back to acceptable bounds
    case Rem of
        R when R > 99 ->
            R - 99 - 1;
        R when R < 0 ->
            R + 99 + 1;
        R ->
            R
    end.


read_lines_string() ->
    {ok, Data} = file:read_file("input.txt"),
    Lines = string:split(binary_to_list(Data), "\n", all),
    [L || L <- Lines, L =/= "" ].
