// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_exercise.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionExerciseCollection on Isar {
  IsarCollection<SessionExercise> get sessionExercises => this.collection();
}

const SessionExerciseSchema = CollectionSchema(
  name: r'SessionExercise',
  id: -3699433427391073826,
  properties: {
    r'exerciseName': PropertySchema(
      id: 0,
      name: r'exerciseName',
      type: IsarType.string,
    ),
    r'needSync': PropertySchema(id: 1, name: r'needSync', type: IsarType.bool),
    r'order': PropertySchema(id: 2, name: r'order', type: IsarType.long),
    r'pocketbaseId': PropertySchema(
      id: 3,
      name: r'pocketbaseId',
      type: IsarType.string,
    ),
  },
  estimateSize: _sessionExerciseEstimateSize,
  serialize: _sessionExerciseSerialize,
  deserialize: _sessionExerciseDeserialize,
  deserializeProp: _sessionExerciseDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'session': LinkSchema(
      id: 1549308457042710275,
      name: r'session',
      target: r'Session',
      single: true,
    ),
    r'exercise': LinkSchema(
      id: 3024238133688270337,
      name: r'exercise',
      target: r'Exercise',
      single: true,
    ),
  },
  embeddedSchemas: {},
  getId: _sessionExerciseGetId,
  getLinks: _sessionExerciseGetLinks,
  attach: _sessionExerciseAttach,
  version: '3.1.0+1',
);

int _sessionExerciseEstimateSize(
  SessionExercise object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseName.length * 3;
  {
    final value = object.pocketbaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sessionExerciseSerialize(
  SessionExercise object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.exerciseName);
  writer.writeBool(offsets[1], object.needSync);
  writer.writeLong(offsets[2], object.order);
  writer.writeString(offsets[3], object.pocketbaseId);
}

SessionExercise _sessionExerciseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionExercise(
    exerciseName: reader.readString(offsets[0]),
    needSync: reader.readBoolOrNull(offsets[1]) ?? true,
    order: reader.readLong(offsets[2]),
  );
  object.id = id;
  object.pocketbaseId = reader.readStringOrNull(offsets[3]);
  return object;
}

P _sessionExerciseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionExerciseGetId(SessionExercise object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessionExerciseGetLinks(SessionExercise object) {
  return [object.session, object.exercise];
}

void _sessionExerciseAttach(
  IsarCollection<dynamic> col,
  Id id,
  SessionExercise object,
) {
  object.id = id;
  object.session.attach(col, col.isar.collection<Session>(), r'session', id);
  object.exercise.attach(col, col.isar.collection<Exercise>(), r'exercise', id);
}

extension SessionExerciseQueryWhereSort
    on QueryBuilder<SessionExercise, SessionExercise, QWhere> {
  QueryBuilder<SessionExercise, SessionExercise, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SessionExerciseQueryWhere
    on QueryBuilder<SessionExercise, SessionExercise, QWhereClause> {
  QueryBuilder<SessionExercise, SessionExercise, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterWhereClause>
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

  QueryBuilder<SessionExercise, SessionExercise, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SessionExerciseQueryFilter
    on QueryBuilder<SessionExercise, SessionExercise, QFilterCondition> {
  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'exerciseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'exerciseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'exerciseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'exerciseName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'exerciseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'exerciseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'exerciseName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'exerciseName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exerciseName', value: ''),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'exerciseName', value: ''),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  needSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'needSync', value: value),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'order', value: value),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  orderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  orderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'order',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'order',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pocketbaseId'),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pocketbaseId'),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pocketbaseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pocketbaseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pocketbaseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pocketbaseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'pocketbaseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'pocketbaseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'pocketbaseId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'pocketbaseId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pocketbaseId', value: ''),
      );
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  pocketbaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pocketbaseId', value: ''),
      );
    });
  }
}

extension SessionExerciseQueryObject
    on QueryBuilder<SessionExercise, SessionExercise, QFilterCondition> {}

extension SessionExerciseQueryLinks
    on QueryBuilder<SessionExercise, SessionExercise, QFilterCondition> {
  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition> session(
    FilterQuery<Session> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'session');
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  sessionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'session', 0, true, 0, true);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exercise(FilterQuery<Exercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'exercise');
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterFilterCondition>
  exerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercise', 0, true, 0, true);
    });
  }
}

extension SessionExerciseQuerySortBy
    on QueryBuilder<SessionExercise, SessionExercise, QSortBy> {
  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  sortByExerciseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  sortByExerciseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.desc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  sortByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  sortByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  sortByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  sortByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }
}

extension SessionExerciseQuerySortThenBy
    on QueryBuilder<SessionExercise, SessionExercise, QSortThenBy> {
  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  thenByExerciseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  thenByExerciseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.desc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  thenByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  thenByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  thenByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QAfterSortBy>
  thenByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }
}

extension SessionExerciseQueryWhereDistinct
    on QueryBuilder<SessionExercise, SessionExercise, QDistinct> {
  QueryBuilder<SessionExercise, SessionExercise, QDistinct>
  distinctByExerciseName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QDistinct>
  distinctByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needSync');
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<SessionExercise, SessionExercise, QDistinct>
  distinctByPocketbaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pocketbaseId', caseSensitive: caseSensitive);
    });
  }
}

extension SessionExerciseQueryProperty
    on QueryBuilder<SessionExercise, SessionExercise, QQueryProperty> {
  QueryBuilder<SessionExercise, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionExercise, String, QQueryOperations>
  exerciseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseName');
    });
  }

  QueryBuilder<SessionExercise, bool, QQueryOperations> needSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needSync');
    });
  }

  QueryBuilder<SessionExercise, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<SessionExercise, String?, QQueryOperations>
  pocketbaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pocketbaseId');
    });
  }
}
