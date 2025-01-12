// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TimerState {
  TimerType get timerType => throw _privateConstructorUsedError;
  int get remainingSeconds => throw _privateConstructorUsedError;
  bool get isRunning => throw _privateConstructorUsedError;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
          TimerState value, $Res Function(TimerState) then) =
      _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call({TimerType timerType, int remainingSeconds, bool isRunning});
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timerType = null,
    Object? remainingSeconds = null,
    Object? isRunning = null,
  }) {
    return _then(_value.copyWith(
      timerType: null == timerType
          ? _value.timerType
          : timerType // ignore: cast_nullable_to_non_nullable
              as TimerType,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
          _$TimerStateImpl value, $Res Function(_$TimerStateImpl) then) =
      __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TimerType timerType, int remainingSeconds, bool isRunning});
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
      _$TimerStateImpl _value, $Res Function(_$TimerStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timerType = null,
    Object? remainingSeconds = null,
    Object? isRunning = null,
  }) {
    return _then(_$TimerStateImpl(
      timerType: null == timerType
          ? _value.timerType
          : timerType // ignore: cast_nullable_to_non_nullable
              as TimerType,
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TimerStateImpl implements _TimerState {
  const _$TimerStateImpl(
      {required this.timerType,
      required this.remainingSeconds,
      required this.isRunning});

  @override
  final TimerType timerType;
  @override
  final int remainingSeconds;
  @override
  final bool isRunning;

  @override
  String toString() {
    return 'TimerState(timerType: $timerType, remainingSeconds: $remainingSeconds, isRunning: $isRunning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.timerType, timerType) ||
                other.timerType == timerType) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, timerType, remainingSeconds, isRunning);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState implements TimerState {
  const factory _TimerState(
      {required final TimerType timerType,
      required final int remainingSeconds,
      required final bool isRunning}) = _$TimerStateImpl;

  @override
  TimerType get timerType;
  @override
  int get remainingSeconds;
  @override
  bool get isRunning;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
