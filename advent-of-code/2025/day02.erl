#!/usr/bin/env escript
-mode(compile).


main(_) ->
    Lines = read_lines_string(),
    SumInvalid = sum_invalid(Lines),
    io:format("Part 1: ~p~n", [SumInvalid]),

    % Part 2:
    % - start with first digit; copy it as many times to get it into range. Add to SumInvalid
    % - once you can no longer add digits, take the first two digits slice; copy it as many times to get it into range
    % - repeat until you've gone past half the digits. Keep a running list of invalids you added so you don't double count
    SumAllInvalid = sum_invalid2(Lines, 1),
    io:format("Part 2: ~p~n", [SumAllInvalid]),
    done.


% Part 2 Code
sum_invalid2(Lines, MinLength) -> sum_invalid2(Lines, MinLength, 0).
sum_invalid2([], _, Acc) -> Acc;
sum_invalid2([H|T], MinLength, Acc) ->
    [Start|[End|_]] = string:split(H, "-", all),
    io:format("Handling ~p to ~p~n", [Start, End]),

    RangeSum = sum_all_repeating(Start, End, 1),
    sum_invalid2(T, MinLength, Acc + RangeSum).


sum_all_repeating(Start, End, RepeatLength) ->
    sum_all_repeating(Start, End, RepeatLength, [], 0).
sum_all_repeating(Start, End, RepeatLength, Seen, Acc) ->
    NumLength = string:length(End),

    case NumLength of
        % NumLength < Repeatlength, exit.
        NL when NL < RepeatLength ->
            Acc;

        _ ->
            Curr = lists:sublist(Start, RepeatLength),
            {RLSum, NewSeen} = sum_all_repeating_length(Start, End, Curr, RepeatLength, Seen, 0),
            sum_all_repeating(Start, End, RepeatLength + 1, NewSeen, Acc + RLSum)
    end.

sum_all_repeating_length(Start, End, Curr, RepeatLength, Seen, Acc) ->
    NumLength = string:length(Start),
    NumRepeat = NumLength div RepeatLength,

    {CurrNum, _} = string:to_integer(Curr),

    Candidate = string:copies(Curr, NumRepeat),
    {CandNum, _} = string:to_integer(Candidate),

    IsSeen = lists:member(CandNum, Seen),
    case IsSeen of
        true ->
            CandNum2 = 0;
        false ->
            CandNum2 = CandNum
    end,

    {StartNum, _} = string:to_integer(Start),
    {EndNum, _} = string:to_integer(End),
    CurrLength = string:length(Curr),

    case CandNum2 of
        CN when CN < StartNum ->
            sum_all_repeating_length(
                Start,
                End,
                integer_to_list(CurrNum + 1),
                RepeatLength,
                Seen,
                Acc
            );
        CN when CN > EndNum orelse CurrLength =/= RepeatLength ->
            {Acc, Seen};
        _ ->
            io:format("Taking invalid ~p~n", [CandNum2]),
            sum_all_repeating_length(
                Start,
                End,
                integer_to_list(CurrNum + 1),
                RepeatLength,
                Seen ++ [CandNum2],
                Acc + CandNum2
            )
    end.


% Part 1 Code
sum_invalid(Lines) -> sum_invalid(Lines, 0).
sum_invalid([], Acc) -> Acc;
sum_invalid([H|T], Acc) ->
    [Start|[End|_]] = string:split(H, "-", all),

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
