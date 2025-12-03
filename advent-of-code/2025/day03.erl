#!/usr/bin/env escript
-mode(compile).

main(_) ->
    Lines = read_lines_string(),
    MaxJoltage = sum_max_banks(Lines),
    io:format("Part 1: ~p~n", [MaxJoltage]),

    done.


sum_max_banks(Lines) -> sum_max_banks(Lines, 0).
sum_max_banks([], Acc) -> Acc;
sum_max_banks([H|T], Acc) ->
    MaxBankValue = get_max_bank_value(H),
    % io:format("Max bank value for ~p is ~p~n", [H, MaxBankValue]),
    sum_max_banks(T, Acc + MaxBankValue).


get_max_bank_value(Bank) -> get_max_bank_value(Bank, 0).
get_max_bank_value([], Acc) ->
    Length = string:length(integer_to_list(Acc)),
    case Length of
        2 ->
            Acc;
        _ ->  % invalid
            -1
    end;
get_max_bank_value([H|T], Acc) ->
    Length = string:length(integer_to_list(Acc)),
    {HNum, _} = string:to_integer([H]),
    case Length of
        L when L =:= 0 orelse L =:= 1 ->
            Take = get_max_bank_value(T, Acc * 10 + HNum),
            DontTake = get_max_bank_value(T, Acc),

            Value = max(Take, DontTake),
            Value;
        L when L =:= 2 ->
            Acc;
        L when L > 2 ->
            -1
    end.



read_lines_string() ->
    {ok, Data} = file:read_file("input.txt"),
    Lines = string:split(binary_to_list(Data), "\n", all),
    [string:trim(L) || L <- Lines, L =/= "" ].
