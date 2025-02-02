// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TimerSession {
  /// Type of session (work or rest)
  TimerType get sessionType => throw _privateConstructorUsedError;

  /// When the session started
  DateTime get startedAt => throw _privateConstructorUsedError;

  /// When the session ended (completed or stopped)
  DateTime? get endedAt => throw _privateConstructorUsedError;

  /// List of all pauses during this session
  List<PauseRecord> get pauses => throw _privateConstructorUsedError;

  /// Total intended duration of the session
  Duration get totalDuration => throw _privateConstructorUsedError;

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionCopyWith<TimerSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionCopyWith<$Res> {
  factory $TimerSessionCopyWith(
          TimerSession value, $Res Function(TimerSession) then) =
      _$TimerSessionCopyWithImpl<$Res, TimerSession>;
  @useResult
  $Res call(
      {TimerType sessionType,
      DateTime startedAt,
      DateTime? endedAt,
      List<PauseRecord> pauses,
      Duration totalDuration});
}

/// @nodoc
class _$TimerSessionCopyWithImpl<$Res, $Val extends TimerSession>
    implements $TimerSessionCopyWith<$Res> {
  _$TimerSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionType = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? pauses = null,
    Object? totalDuration = null,
  }) {
    return _then(_value.copyWith(
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as TimerType,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pauses: null == pauses
          ? _value.pauses
          : pauses // ignore: cast_nullable_to_non_nullable
              as List<PauseRecord>,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimerSessionImplCopyWith<$Res>
    implements $TimerSessionCopyWith<$Res> {
  factory _$$TimerSessionImplCopyWith(
          _$TimerSessionImpl value, $Res Function(_$TimerSessionImpl) then) =
      __$$TimerSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TimerType sessionType,
      DateTime startedAt,
      DateTime? endedAt,
      List<PauseRecord> pauses,
      Duration totalDuration});
}

/// @nodoc
class __$$TimerSessionImplCopyWithImpl<$Res>
    extends _$TimerSessionCopyWithImpl<$Res, _$TimerSessionImpl>
    implements _$$TimerSessionImplCopyWith<$Res> {
  __$$TimerSessionImplCopyWithImpl(
      _$TimerSessionImpl _value, $Res Function(_$TimerSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionType = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? pauses = null,
    Object? totalDuration = null,
  }) {
    return _then(_$TimerSessionImpl(
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as TimerType,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pauses: null == pauses
          ? _value._pauses
          : pauses // ignore: cast_nullable_to_non_nullable
              as List<PauseRecord>,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$TimerSessionImpl extends _TimerSession {
  const _$TimerSessionImpl(
      {required this.sessionType,
      required this.startedAt,
      required this.endedAt,
      required final List<PauseRecord> pauses,
      required this.totalDuration})
      : _pauses = pauses,
        super._();

  /// Type of session (work or rest)
  @override
  final TimerType sessionType;

  /// When the session started
  @override
  final DateTime startedAt;

  /// When the session ended (completed or stopped)
  @override
  final DateTime? endedAt;

  /// List of all pauses during this session
  final List<PauseRecord> _pauses;

  /// List of all pauses during this session
  @override
  List<PauseRecord> get pauses {
    if (_pauses is EqualUnmodifiableListView) return _pauses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pauses);
  }

  /// Total intended duration of the session
  @override
  final Duration totalDuration;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionImpl &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            const DeepCollectionEquality().equals(other._pauses, _pauses) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionType, startedAt, endedAt,
      const DeepCollectionEquality().hash(_pauses), totalDuration);

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionImplCopyWith<_$TimerSessionImpl> get copyWith =>
      __$$TimerSessionImplCopyWithImpl<_$TimerSessionImpl>(this, _$identity);
}

abstract class _TimerSession extends TimerSession {
  const factory _TimerSession(
      {required final TimerType sessionType,
      required final DateTime startedAt,
      required final DateTime? endedAt,
      required final List<PauseRecord> pauses,
      required final Duration totalDuration}) = _$TimerSessionImpl;
  const _TimerSession._() : super._();

  /// Type of session (work or rest)
  @override
  TimerType get sessionType;

  /// When the session started
  @override
  DateTime get startedAt;

  /// When the session ended (completed or stopped)
  @override
  DateTime? get endedAt;

  /// List of all pauses during this session
  @override
  List<PauseRecord> get pauses;

  /// Total intended duration of the session
  @override
  Duration get totalDuration;

  /// Create a copy of TimerSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionImplCopyWith<_$TimerSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
