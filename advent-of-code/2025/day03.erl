#!/usr/bin/env escript
-mode(compile).

main(_) ->
    Lines = read_lines_string(),
    MaxJoltage = sum_max_banks(Lines, 2),
    io:format("Part 1: ~p~n", [MaxJoltage]),

    MaxJoltage2 = sum_max_banks_greedy(Lines, 12),
    io:format("Part 2: ~p~n", [MaxJoltage2]),
    done.


% Part 2 code
sum_max_banks_greedy(Lines, NumDigits) -> sum_max_banks_greedy(Lines, NumDigits, 0).
sum_max_banks_greedy([], _, Acc) -> Acc;
sum_max_banks_greedy([H|T], NumDigits, Acc) ->
    MaxBankValue = get_max_bank_value_greedy(H, NumDigits),
    sum_max_banks_greedy(T, NumDigits, Acc + MaxBankValue).


get_max_bank_value_greedy(Bank, NumDigits) ->
    Digits = [ D - $0 || D <- Bank ],
    SelectedDigits = max_k_digits(Digits, NumDigits),
    Value = join_int_list(SelectedDigits, 0),
    Value.


max_k_digits(Digits, DigitsNeeded) ->
    Drops = length(Digits) - DigitsNeeded,
    Stack = max_k_digits(Digits, Drops, []),
    lists:sublist(lists:reverse(Stack), DigitsNeeded).

max_k_digits([], _, Acc) -> Acc;
max_k_digits([Digit|Rest], Drops, Acc) ->
    % Pop from stack if Digit produces a larger value
    case Acc of
        [Head|Tail] when Drops > 0, Head < Digit ->
            max_k_digits([Digit|Rest], Drops - 1, Tail);
        _ ->
            max_k_digits(Rest, Drops, [Digit|Acc])
    end.

join_int_list([], Acc) -> Acc;
join_int_list([H|T], Acc) -> join_int_list(T, 10*Acc + H).

% Part 1 code
sum_max_banks(Lines, NumDigits) -> sum_max_banks(Lines, NumDigits, 0).
sum_max_banks([], _, Acc) -> Acc;
sum_max_banks([H|T], NumDigits, Acc) ->
    MaxBankValue = get_max_bank_value(H, NumDigits),
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
