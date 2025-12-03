#!/usr/bin/env escript
-mode(compile).

main(_) ->
    Lines = read_lines_string(),
    MaxJoltage = sum_max_banks(Lines, 2),
    io:format("Part 1: ~p~n", [MaxJoltage]),

    % Part 2 - short circuit by tracking max joltage so far
    done.


sum_max_banks(Lines, NumDigits) -> sum_max_banks(Lines, NumDigits, 0).
sum_max_banks([], _, Acc) -> Acc;
sum_max_banks([H|T], NumDigits, Acc) ->
    MaxBankValue = get_max_bank_value(H, NumDigits),
    % io:format("Max bank value for ~p is ~p~n", [H, MaxBankValue]),
    sum_max_banks(T, NumDigits, Acc + MaxBankValue).


get_max_bank_value(Bank, NumDigits) -> get_max_bank_value(Bank, NumDigits, 0).
get_max_bank_value([], NumDigits, Acc) ->
    Length = string:length(integer_to_list(Acc)),
    case Length of
        L when L =:= NumDigits ->
            Acc;
        _ ->  % invalid
            -1
    end;
get_max_bank_value([H|T], NumDigits, Acc) ->
    Length = string:length(integer_to_list(Acc)),
    {HNum, _} = string:to_integer([H]),
    case Length of
        L when L < NumDigits ->
            Take = get_max_bank_value(T, NumDigits, Acc * 10 + HNum),
            DontTake = get_max_bank_value(T, NumDigits, Acc),

            Value = max(Take, DontTake),
            Value;
        L when L =:= NumDigits ->
            Acc;
        L when L > NumDigits ->
            -1
    end.



read_lines_string() ->
    {ok, Data} = file:read_file("input.txt"),
    Lines = string:split(binary_to_list(Data), "\n", all),
    [string:trim(L) || L <- Lines, L =/= "" ].
