// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pause_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PauseRecord {
  /// When the timer was paused
  DateTime get pausedAt => throw _privateConstructorUsedError;

  /// When the timer was resumed
  DateTime get resumedAt => throw _privateConstructorUsedError;

  /// Create a copy of PauseRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PauseRecordCopyWith<PauseRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PauseRecordCopyWith<$Res> {
  factory $PauseRecordCopyWith(
          PauseRecord value, $Res Function(PauseRecord) then) =
      _$PauseRecordCopyWithImpl<$Res, PauseRecord>;
  @useResult
  $Res call({DateTime pausedAt, DateTime resumedAt});
}

/// @nodoc
class _$PauseRecordCopyWithImpl<$Res, $Val extends PauseRecord>
    implements $PauseRecordCopyWith<$Res> {
  _$PauseRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PauseRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pausedAt = null,
    Object? resumedAt = null,
  }) {
    return _then(_value.copyWith(
      pausedAt: null == pausedAt
          ? _value.pausedAt
          : pausedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resumedAt: null == resumedAt
          ? _value.resumedAt
          : resumedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PauseRecordImplCopyWith<$Res>
    implements $PauseRecordCopyWith<$Res> {
  factory _$$PauseRecordImplCopyWith(
          _$PauseRecordImpl value, $Res Function(_$PauseRecordImpl) then) =
      __$$PauseRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime pausedAt, DateTime resumedAt});
}

/// @nodoc
class __$$PauseRecordImplCopyWithImpl<$Res>
    extends _$PauseRecordCopyWithImpl<$Res, _$PauseRecordImpl>
    implements _$$PauseRecordImplCopyWith<$Res> {
  __$$PauseRecordImplCopyWithImpl(
      _$PauseRecordImpl _value, $Res Function(_$PauseRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of PauseRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pausedAt = null,
    Object? resumedAt = null,
  }) {
    return _then(_$PauseRecordImpl(
      pausedAt: null == pausedAt
          ? _value.pausedAt
          : pausedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resumedAt: null == resumedAt
          ? _value.resumedAt
          : resumedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$PauseRecordImpl extends _PauseRecord {
  const _$PauseRecordImpl({required this.pausedAt, required this.resumedAt})
      : super._();

  /// When the timer was paused
  @override
  final DateTime pausedAt;

  /// When the timer was resumed
  @override
  final DateTime resumedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PauseRecordImpl &&
            (identical(other.pausedAt, pausedAt) ||
                other.pausedAt == pausedAt) &&
            (identical(other.resumedAt, resumedAt) ||
                other.resumedAt == resumedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pausedAt, resumedAt);

  /// Create a copy of PauseRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PauseRecordImplCopyWith<_$PauseRecordImpl> get copyWith =>
      __$$PauseRecordImplCopyWithImpl<_$PauseRecordImpl>(this, _$identity);
}

abstract class _PauseRecord extends PauseRecord {
  const factory _PauseRecord(
      {required final DateTime pausedAt,
      required final DateTime resumedAt}) = _$PauseRecordImpl;
  const _PauseRecord._() : super._();

  /// When the timer was paused
  @override
  DateTime get pausedAt;

  /// When the timer was resumed
  @override
  DateTime get resumedAt;

  /// Create a copy of PauseRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PauseRecordImplCopyWith<_$PauseRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
