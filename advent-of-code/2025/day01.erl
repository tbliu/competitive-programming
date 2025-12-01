#!/usr/bin/env escript
-mode(compile).

main(_) ->
    Lines = read_lines_string(),
    Counts = count_land_on_zeros(Lines, 50),
    io:format("Part 1: ~p~n", [Counts]),

    Clicks = count_all_zeros(Lines, 50),
    io:format("Part 2: ~p~n", [Clicks]),
    done.

count_land_on_zeros(List, Pos) -> count_land_on_zeros(List, Pos, 0).
count_land_on_zeros([], _, Acc) -> Acc;
count_land_on_zeros([H|T], Pos, Acc) ->
    [Direction|Rest] = H,
    {Rotations,_} = string:to_integer(Rest),
    [NewPos|_] = rotate(Pos, Direction, Rotations),
    case NewPos of
        NP when NP =:= 0 ->
            count_land_on_zeros(T, NP, Acc + 1);
        NP ->
            count_land_on_zeros(T, NP, Acc)
    end.


count_all_zeros(List, Pos) -> count_all_zeros(List, Pos, 0).
count_all_zeros([], _, Acc) -> Acc;
count_all_zeros([H|T], Pos, Acc) ->
    [Direction|Rest] = H,
    {Rotations,_} = string:to_integer(Rest),
    [NewPos|Clicks] = rotate(Pos, Direction, Rotations),

    count_all_zeros(T, NewPos, Acc + hd(Clicks)).

rotate(Pos, Direction, Count) ->
    case Direction of
        $L ->
            NewPos = Pos - Count;
        $R ->
            NewPos = Pos + Count
    end,

    % Get how far away the first zero is
    FirstZero =
        case Direction of
            $L ->
                case Pos of
                    0 -> 100;
                    _ -> Pos
                end;
            $R ->
                case Pos of
                    0 -> 100;
                    _ -> 100 - Pos
                end
        end,

    NumZeros =
        case Count < FirstZero of
            true -> 0;
            false -> 1 + (Count - FirstZero) div 100
        end,

    % We can rotate more than 99 clicks.
    % Since it's [0, 99] inclusive, we divide by 100
    Rem = NewPos rem 100,

    % Erlang doesn't have a proper modulo function
    % so we need to increment by 100 to get back to acceptable bounds
    case Rem of
        R when R > 99 ->
            % We cycle back one more time so increment Cycles for part 2
            [R - 100, NumZeros];
        R when R < 0 ->
            [R + 100, NumZeros];
        R ->
            [R, NumZeros]
    end.


read_lines_string() ->
    {ok, Data} = file:read_file("input.txt"),
    Lines = string:split(binary_to_list(Data), "\n", all),
    [L || L <- Lines, L =/= "" ].
