import 'package:uuid/uuid.dart';

final uuid = Uuid();

abstract class ValueObject {
  @override
  bool operator ==(Object other);
  @override
  int get hashCode;
}

abstract class Entity<ID> {
  final ID id;

  Entity(this.id);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entity<ID> &&
        runtimeType == other.runtimeType &&
        id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

abstract class AggregateRoot<ID> extends Entity<ID> {
  AggregateRoot(super.id);
}

abstract class Repository<T extends AggregateRoot<ID>, ID> {
  Future<T?> getById(ID id);
}

abstract class DomainFactory {}

abstract class DomainService {}

abstract class EntityId<V> extends ValueObject {
  final V _value;

  EntityId(this._value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntityId &&
        other._value == _value &&
        other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => _value.hashCode;
}

abstract class EntityUniqueId extends EntityId<UuidValue> {
  EntityUniqueId.generate() : super(uuid.v4obj());

  EntityUniqueId.fromString(String id) : super(UuidValue.fromString(id));
}
