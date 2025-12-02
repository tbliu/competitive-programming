#!/usr/bin/env escript
-mode(compile).


main(_) ->
    Lines = read_lines_string(),
    SumInvalid = sum_invalid(Lines),
    io:format("Part 1: ~p~n", [SumInvalid]),
    done.


sum_invalid(Lines) -> sum_invalid(Lines, 0).
sum_invalid([], Acc) -> Acc;
sum_invalid([H|T], Acc) ->
    [Start|[End|_]] = string:split(H, "-", all),
    io:format("Handling ~p to ~p~n", [Start, End]),

    % We can skip any number with an odd number of digits
    % Get first and last invalid numbers based on the range boundaries
    % sum over invalid for first_invalid -> last_invalid, iterating over first half
    RangeSum = sum_invalid_in_range(Start, End),
    sum_invalid(T, Acc + RangeSum).


get_next_invalid(NumStr, End) ->
    StrLen = string:length(NumStr),
    HasEvenDigits = StrLen rem 2 =:= 0,

    case HasEvenDigits of
        true ->
            NewNumStr = NumStr;
        false ->
            NewNumStr = "1" ++ string:copies("0", StrLen)
    end,

    NewStrLen = string:length(NewNumStr),
    FirstHalf = lists:sublist(NewNumStr, NewStrLen div 2),

    Candidate = FirstHalf ++ FirstHalf,
    % io:format("Candidate ~p ~p~n", [Candidate, NumStr]),

    {CandNum, _} = string:to_integer(Candidate),
    {Num, _} = string:to_integer(NumStr),

    ShouldIncr = CandNum < Num,
    OutOfRange = CandNum > End,

    case OutOfRange of
        true ->
            "-1";
        false ->
            case ShouldIncr of
                true ->
                    {Fh, _} = string:to_integer(FirstHalf),
                    NextFh = integer_to_list(Fh + 1),
                    NextCandidate = NextFh ++ NextFh,
                    get_next_invalid(NextCandidate, End);
                false ->
                    Candidate
            end
    end.


sum_invalid_in_range(Start, End) -> sum_invalid_in_range(Start, End, 0).
sum_invalid_in_range(Curr, End, Acc) ->
    {CNum, _} = string:to_integer(Curr),
    {ENum, _} = string:to_integer(End),
    Exit = CNum > ENum,

    case Exit of
        true ->
            Acc;
        false ->
            ClosestInvalid = get_next_invalid(Curr, ENum),
            {Invalid, _} = string:to_integer(ClosestInvalid),

            io:format("Invalid to add ~p~n", [Invalid]),

            case Invalid of
                I when I =:= -1 ->
                    sum_invalid_in_range(ENum + 1, End, Acc);
                I when I =< End ->
                    NextNum = integer_to_list(Invalid + 1),  % Convert back to string
                    sum_invalid_in_range(NextNum, End, Acc + Invalid)
            end
    end.


read_lines_string() ->
    {ok, Data} = file:read_file("input.txt"),
    Lines = string:split(binary_to_list(Data), ",", all),
    [L || L <- Lines, L =/= "" ].
