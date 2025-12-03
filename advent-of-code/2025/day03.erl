#!/usr/bin/env escript
-mode(compile).

main(_) ->
    Lines = read_lines_string(),
    MaxJoltage = sum_max_banks(Lines, 2),
    io:format("Part 1: ~p~n", [MaxJoltage]),

    MaxJoltage2 = sum_max_banks_greedy(Lines, 12),
    io:format("Part 2: ~p~n", [MaxJoltage2]),
    done.


% Part 2 code - 98417339375687 too low
sum_max_banks_greedy(Lines, NumDigits) -> sum_max_banks_greedy(Lines, NumDigits, 0).
sum_max_banks_greedy([], _, Acc) -> Acc;
sum_max_banks_greedy([H|T], NumDigits, Acc) ->
    MaxBankValue = get_max_bank_value_greedy(H, NumDigits),
    % io:format("Max bank value for ~p is ~p~n", [H, MaxBankValue]),
    sum_max_banks_greedy(T, NumDigits, Acc + MaxBankValue).

get_max_bank_value_greedy([H|T], NumDigits) ->
    % Always assume well-formed input; we will always start with the first value
    {HNum, _} = string:to_integer([H]),
    get_max_bank_value_greedy(T, NumDigits, HNum, HNum).
get_max_bank_value_greedy([], _, _, Acc) -> Acc;
get_max_bank_value_greedy([H|T], NumDigits, LastDigit, Acc) ->
    AccStr = integer_to_list(Acc),
    AccLength = string:length(AccStr),


    DigitsNeeded = NumDigits - AccLength,
    DigitsRemaining = string:length(T),

    {HNum, _} = string:to_integer([H]),
    ReplaceLastDigit = HNum > LastDigit andalso DigitsRemaining >= DigitsNeeded,
    CanTakeDigit = DigitsNeeded > 0,

    case ReplaceLastDigit of
        true ->
            get_max_bank_value_greedy(T, NumDigits, HNum, Acc div 10 * 10 + HNum);
        false ->
            case CanTakeDigit of
                true ->
                    get_max_bank_value_greedy(T, NumDigits, HNum, Acc * 10 + HNum);
                false ->
                    get_max_bank_value_greedy(T, NumDigits, LastDigit, Acc)
            end
    end.


% Part 1 code
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
