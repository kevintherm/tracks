// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercises.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutExercisesCollection on Isar {
  IsarCollection<WorkoutExercises> get workoutExercises => this.collection();
}

const WorkoutExercisesSchema = CollectionSchema(
  name: r'WorkoutExercises',
  id: -7796266674169859638,
  properties: {
    r'reps': PropertySchema(
      id: 0,
      name: r'reps',
      type: IsarType.long,
    ),
    r'sets': PropertySchema(
      id: 1,
      name: r'sets',
      type: IsarType.long,
    )
  },
  estimateSize: _workoutExercisesEstimateSize,
  serialize: _workoutExercisesSerialize,
  deserialize: _workoutExercisesDeserialize,
  deserializeProp: _workoutExercisesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'workout': LinkSchema(
      id: -3627932101672971724,
      name: r'workout',
      target: r'Workout',
      single: true,
    ),
    r'exercise': LinkSchema(
      id: 8651637271309021624,
      name: r'exercise',
      target: r'Exercise',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _workoutExercisesGetId,
  getLinks: _workoutExercisesGetLinks,
  attach: _workoutExercisesAttach,
  version: '3.1.0+1',
);

int _workoutExercisesEstimateSize(
  WorkoutExercises object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _workoutExercisesSerialize(
  WorkoutExercises object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.reps);
  writer.writeLong(offsets[1], object.sets);
}

WorkoutExercises _workoutExercisesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutExercises(
    reps: reader.readLongOrNull(offsets[0]) ?? 6,
    sets: reader.readLongOrNull(offsets[1]) ?? 3,
  );
  object.id = id;
  return object;
}

P _workoutExercisesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 6) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 3) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutExercisesGetId(WorkoutExercises object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutExercisesGetLinks(WorkoutExercises object) {
  return [object.workout, object.exercise];
}

void _workoutExercisesAttach(
    IsarCollection<dynamic> col, Id id, WorkoutExercises object) {
  object.id = id;
  object.workout.attach(col, col.isar.collection<Workout>(), r'workout', id);
  object.exercise.attach(col, col.isar.collection<Exercise>(), r'exercise', id);
}

extension WorkoutExercisesQueryWhereSort
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QWhere> {
  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorkoutExercisesQueryWhere
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QWhereClause> {
  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutExercisesQueryFilter
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QFilterCondition> {
  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      repsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      repsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      repsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      repsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      setsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sets',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      setsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sets',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      setsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sets',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      setsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sets',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutExercisesQueryObject
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QFilterCondition> {}

extension WorkoutExercisesQueryLinks
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QFilterCondition> {
  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      workout(FilterQuery<Workout> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'workout');
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      workoutIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'workout', 0, true, 0, true);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      exercise(FilterQuery<Exercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'exercise');
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterFilterCondition>
      exerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercise', 0, true, 0, true);
    });
  }
}

extension WorkoutExercisesQuerySortBy
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QSortBy> {
  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy> sortByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy>
      sortByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy> sortBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy>
      sortBySetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.desc);
    });
  }
}

extension WorkoutExercisesQuerySortThenBy
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QSortThenBy> {
  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy> thenByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy>
      thenByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy> thenBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QAfterSortBy>
      thenBySetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.desc);
    });
  }
}

extension WorkoutExercisesQueryWhereDistinct
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QDistinct> {
  QueryBuilder<WorkoutExercises, WorkoutExercises, QDistinct> distinctByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reps');
    });
  }

  QueryBuilder<WorkoutExercises, WorkoutExercises, QDistinct> distinctBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sets');
    });
  }
}

extension WorkoutExercisesQueryProperty
    on QueryBuilder<WorkoutExercises, WorkoutExercises, QQueryProperty> {
  QueryBuilder<WorkoutExercises, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutExercises, int, QQueryOperations> repsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reps');
    });
  }

  QueryBuilder<WorkoutExercises, int, QQueryOperations> setsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sets');
    });
  }
}
