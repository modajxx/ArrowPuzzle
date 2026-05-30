import 'direction.dart';

class Arrow {
  final Direction direction;
  const Arrow(this.direction);

  @override
  bool operator ==(Object other) =>
      other is Arrow && other.direction == direction;

  @override
  int get hashCode => direction.hashCode;

  @override
  String toString() => 'Arrow(${direction.name})';
}
