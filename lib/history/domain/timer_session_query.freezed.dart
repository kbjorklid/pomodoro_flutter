// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_session_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TimerSessionQuery {
  /// Start of the time range
  DateTime get start => throw _privateConstructorUsedError;

  /// End of the time range
  DateTime get end => throw _privateConstructorUsedError;

  /// Filter by completion status
  CompletionStatus get completionStatus => throw _privateConstructorUsedError;

  /// Filter by session type
  TimerType get sessionType => throw _privateConstructorUsedError;

  /// Create a copy of TimerSessionQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerSessionQueryCopyWith<TimerSessionQuery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerSessionQueryCopyWith<$Res> {
  factory $TimerSessionQueryCopyWith(
          TimerSessionQuery value, $Res Function(TimerSessionQuery) then) =
      _$TimerSessionQueryCopyWithImpl<$Res, TimerSessionQuery>;
  @useResult
  $Res call(
      {DateTime start,
      DateTime end,
      CompletionStatus completionStatus,
      TimerType sessionType});
}

/// @nodoc
class _$TimerSessionQueryCopyWithImpl<$Res, $Val extends TimerSessionQuery>
    implements $TimerSessionQueryCopyWith<$Res> {
  _$TimerSessionQueryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerSessionQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? completionStatus = null,
    Object? sessionType = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionStatus: null == completionStatus
          ? _value.completionStatus
          : completionStatus // ignore: cast_nullable_to_non_nullable
              as CompletionStatus,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as TimerType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimerSessionQueryImplCopyWith<$Res>
    implements $TimerSessionQueryCopyWith<$Res> {
  factory _$$TimerSessionQueryImplCopyWith(_$TimerSessionQueryImpl value,
          $Res Function(_$TimerSessionQueryImpl) then) =
      __$$TimerSessionQueryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime start,
      DateTime end,
      CompletionStatus completionStatus,
      TimerType sessionType});
}

/// @nodoc
class __$$TimerSessionQueryImplCopyWithImpl<$Res>
    extends _$TimerSessionQueryCopyWithImpl<$Res, _$TimerSessionQueryImpl>
    implements _$$TimerSessionQueryImplCopyWith<$Res> {
  __$$TimerSessionQueryImplCopyWithImpl(_$TimerSessionQueryImpl _value,
      $Res Function(_$TimerSessionQueryImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimerSessionQuery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? completionStatus = null,
    Object? sessionType = null,
  }) {
    return _then(_$TimerSessionQueryImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionStatus: null == completionStatus
          ? _value.completionStatus
          : completionStatus // ignore: cast_nullable_to_non_nullable
              as CompletionStatus,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as TimerType,
    ));
  }
}

/// @nodoc

class _$TimerSessionQueryImpl implements _TimerSessionQuery {
  const _$TimerSessionQueryImpl(
      {required this.start,
      required this.end,
      this.completionStatus = CompletionStatus.any,
      this.sessionType = TimerType.any});

  /// Start of the time range
  @override
  final DateTime start;

  /// End of the time range
  @override
  final DateTime end;

  /// Filter by completion status
  @override
  @JsonKey()
  final CompletionStatus completionStatus;

  /// Filter by session type
  @override
  @JsonKey()
  final TimerType sessionType;

  @override
  String toString() {
    return 'TimerSessionQuery(start: $start, end: $end, completionStatus: $completionStatus, sessionType: $sessionType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerSessionQueryImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.completionStatus, completionStatus) ||
                other.completionStatus == completionStatus) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, start, end, completionStatus, sessionType);

  /// Create a copy of TimerSessionQuery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerSessionQueryImplCopyWith<_$TimerSessionQueryImpl> get copyWith =>
      __$$TimerSessionQueryImplCopyWithImpl<_$TimerSessionQueryImpl>(
          this, _$identity);
}

abstract class _TimerSessionQuery implements TimerSessionQuery {
  const factory _TimerSessionQuery(
      {required final DateTime start,
      required final DateTime end,
      final CompletionStatus completionStatus,
      final TimerType sessionType}) = _$TimerSessionQueryImpl;

  /// Start of the time range
  @override
  DateTime get start;

  /// End of the time range
  @override
  DateTime get end;

  /// Filter by completion status
  @override
  CompletionStatus get completionStatus;

  /// Filter by session type
  @override
  TimerType get sessionType;

  /// Create a copy of TimerSessionQuery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerSessionQueryImplCopyWith<_$TimerSessionQueryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
