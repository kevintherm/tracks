// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_muscles.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExerciseMusclesCollection on Isar {
  IsarCollection<ExerciseMuscles> get exerciseMuscles => this.collection();
}

const ExerciseMusclesSchema = CollectionSchema(
  name: r'ExerciseMuscles',
  id: -1994292471239953824,
  properties: {
    r'activation': PropertySchema(
      id: 0,
      name: r'activation',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'needSync': PropertySchema(
      id: 2,
      name: r'needSync',
      type: IsarType.bool,
    ),
    r'pocketbaseId': PropertySchema(
      id: 3,
      name: r'pocketbaseId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _exerciseMusclesEstimateSize,
  serialize: _exerciseMusclesSerialize,
  deserialize: _exerciseMusclesDeserialize,
  deserializeProp: _exerciseMusclesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'exercise': LinkSchema(
      id: 1444584876733261992,
      name: r'exercise',
      target: r'Exercise',
      single: true,
    ),
    r'muscle': LinkSchema(
      id: -7134929170778678034,
      name: r'muscle',
      target: r'Muscle',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _exerciseMusclesGetId,
  getLinks: _exerciseMusclesGetLinks,
  attach: _exerciseMusclesAttach,
  version: '3.1.0+1',
);

int _exerciseMusclesEstimateSize(
  ExerciseMuscles object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.pocketbaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _exerciseMusclesSerialize(
  ExerciseMuscles object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activation);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.needSync);
  writer.writeString(offsets[3], object.pocketbaseId);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

ExerciseMuscles _exerciseMusclesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExerciseMuscles(
    activation: reader.readLongOrNull(offsets[0]) ?? 50,
    needSync: reader.readBoolOrNull(offsets[2]) ?? true,
    pocketbaseId: reader.readStringOrNull(offsets[3]),
  );
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[4]);
  return object;
}

P _exerciseMusclesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 50) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exerciseMusclesGetId(ExerciseMuscles object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exerciseMusclesGetLinks(ExerciseMuscles object) {
  return [object.exercise, object.muscle];
}

void _exerciseMusclesAttach(
    IsarCollection<dynamic> col, Id id, ExerciseMuscles object) {
  object.id = id;
  object.exercise.attach(col, col.isar.collection<Exercise>(), r'exercise', id);
  object.muscle.attach(col, col.isar.collection<Muscle>(), r'muscle', id);
}

extension ExerciseMusclesQueryWhereSort
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QWhere> {
  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExerciseMusclesQueryWhere
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QWhereClause> {
  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterWhereClause>
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

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterWhereClause> idBetween(
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

extension ExerciseMusclesQueryFilter
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QFilterCondition> {
  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      activationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activation',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      activationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activation',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      activationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activation',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      activationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
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

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
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

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
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

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      needSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needSync',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pocketbaseId',
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pocketbaseId',
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pocketbaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pocketbaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pocketbaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pocketbaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pocketbaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pocketbaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pocketbaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pocketbaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pocketbaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      pocketbaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pocketbaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ExerciseMusclesQueryObject
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QFilterCondition> {}

extension ExerciseMusclesQueryLinks
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QFilterCondition> {
  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      exercise(FilterQuery<Exercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'exercise');
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      exerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercise', 0, true, 0, true);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition> muscle(
      FilterQuery<Muscle> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'muscle');
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterFilterCondition>
      muscleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'muscle', 0, true, 0, true);
    });
  }
}

extension ExerciseMusclesQuerySortBy
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QSortBy> {
  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByActivation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activation', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByActivationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activation', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExerciseMusclesQuerySortThenBy
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QSortThenBy> {
  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByActivation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activation', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByActivationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activation', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ExerciseMusclesQueryWhereDistinct
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QDistinct> {
  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QDistinct>
      distinctByActivation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activation');
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QDistinct>
      distinctByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needSync');
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QDistinct>
      distinctByPocketbaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pocketbaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExerciseMuscles, ExerciseMuscles, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ExerciseMusclesQueryProperty
    on QueryBuilder<ExerciseMuscles, ExerciseMuscles, QQueryProperty> {
  QueryBuilder<ExerciseMuscles, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExerciseMuscles, int, QQueryOperations> activationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activation');
    });
  }

  QueryBuilder<ExerciseMuscles, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExerciseMuscles, bool, QQueryOperations> needSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needSync');
    });
  }

  QueryBuilder<ExerciseMuscles, String?, QQueryOperations>
      pocketbaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pocketbaseId');
    });
  }

  QueryBuilder<ExerciseMuscles, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
