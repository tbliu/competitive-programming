#!/usr/bin/env escript
-mode(compile).


main(_) ->
    Lines = read_lines_string(),
    SumInvalid = sum_invalid(Lines),
    io:format("Part 1: ~p~n", [SumInvalid]),

    SumAllInvalid = sum_invalid2(Lines),
    io:format("Part 2: ~p~n", [SumAllInvalid]),
    done.


% Part 2 Code
sum_invalid2(Lines) -> sum_invalid2(Lines, 0).
sum_invalid2([], Acc) -> Acc;
sum_invalid2([H|T], Acc) ->
    [Start|[End|_]] = string:split(H, "-", all),
    RangeSum = sum_all_repeating(Start, End),
    sum_invalid2(T, Acc + RangeSum).


sum_all_repeating(Start, End) ->
    StartLength = string:length(Start),
    EndLength = string:length(End),
    {RangeSum, _} = sum_all_repeating(Start, End, 1, StartLength, EndLength, [], 0),
    RangeSum.


sum_all_repeating(Start, End, TakeFirstN, TargetLength, MaxLength, Seen, Acc) ->
    case TakeFirstN of
        _ when TargetLength > MaxLength ->
            {Acc, Seen};
        TFN when TFN >= TargetLength div 2 + 1 ->
            sum_all_repeating(Start, End, 1, TargetLength + 1, MaxLength, Seen, Acc);
        TFN when TargetLength rem TFN =/= 0 ->
            sum_all_repeating(Start, End, TakeFirstN + 1, TargetLength, MaxLength, Seen, Acc);
        TFN ->
            FirstNDigits = "1" ++ string:copies("0", TFN-1),
            NumRepeat = TargetLength div TFN,
            {RangeSum1, NewSeen1} = sum_all_repeating_length(Start, End, FirstNDigits, NumRepeat, Seen, 0),
            {RangeSum2, NewSeen2} = sum_all_repeating(Start, End, TFN + 1, TargetLength, MaxLength, NewSeen1, 0),
            {RangeSum3, NewSeen3} = sum_all_repeating(Start, End, 1, TargetLength + 1, MaxLength, NewSeen2, 0),

            Total = RangeSum1 + RangeSum2 + RangeSum3 + Acc,
            {Total, NewSeen3}
    end.


sum_all_repeating_length(Start, End, Curr, NumRepeat, Seen, Acc) ->
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

    case CandNum2 of
        CN when CN < StartNum ->
            sum_all_repeating_length(
                Start,
                End,
                integer_to_list(CurrNum + 1),
                NumRepeat,
                Seen,
                Acc
            );
        CN when CN > EndNum ->
            {Acc, Seen};
        _ ->
            sum_all_repeating_length(
                Start,
                End,
                integer_to_list(CurrNum + 1),
                NumRepeat,
                Seen ++ [CandNum2],
                Acc + CandNum2
            )
    end.


% Part 1 Code
sum_invalid(Lines) -> sum_invalid(Lines, 0).
sum_invalid([], Acc) -> Acc;
sum_invalid([H|T], Acc) ->
    [Start|[End|_]] = string:split(H, "-", all),
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
    [string:trim(L) || L <- Lines, L =/= "" ].
