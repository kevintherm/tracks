// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_set.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionSetCollection on Isar {
  IsarCollection<SessionSet> get sessionSets => this.collection();
}

const SessionSetSchema = CollectionSchema(
  name: r'SessionSet',
  id: 7378379328497303479,
  properties: {
    r'duration': PropertySchema(id: 0, name: r'duration', type: IsarType.long),
    r'effortRate': PropertySchema(
      id: 1,
      name: r'effortRate',
      type: IsarType.long,
    ),
    r'failOnRep': PropertySchema(
      id: 2,
      name: r'failOnRep',
      type: IsarType.long,
    ),
    r'needSync': PropertySchema(id: 3, name: r'needSync', type: IsarType.bool),
    r'note': PropertySchema(id: 4, name: r'note', type: IsarType.string),
    r'pocketbaseId': PropertySchema(
      id: 5,
      name: r'pocketbaseId',
      type: IsarType.string,
    ),
    r'reps': PropertySchema(id: 6, name: r'reps', type: IsarType.long),
    r'restDuration': PropertySchema(
      id: 7,
      name: r'restDuration',
      type: IsarType.long,
    ),
    r'weight': PropertySchema(id: 8, name: r'weight', type: IsarType.double),
  },
  estimateSize: _sessionSetEstimateSize,
  serialize: _sessionSetSerialize,
  deserialize: _sessionSetDeserialize,
  deserializeProp: _sessionSetDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'sessionExercise': LinkSchema(
      id: 8209102497419006420,
      name: r'sessionExercise',
      target: r'SessionExercise',
      single: true,
    ),
  },
  embeddedSchemas: {},
  getId: _sessionSetGetId,
  getLinks: _sessionSetGetLinks,
  attach: _sessionSetAttach,
  version: '3.1.0+1',
);

int _sessionSetEstimateSize(
  SessionSet object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pocketbaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sessionSetSerialize(
  SessionSet object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.duration);
  writer.writeLong(offsets[1], object.effortRate);
  writer.writeLong(offsets[2], object.failOnRep);
  writer.writeBool(offsets[3], object.needSync);
  writer.writeString(offsets[4], object.note);
  writer.writeString(offsets[5], object.pocketbaseId);
  writer.writeLong(offsets[6], object.reps);
  writer.writeLong(offsets[7], object.restDuration);
  writer.writeDouble(offsets[8], object.weight);
}

SessionSet _sessionSetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionSet(
    duration: reader.readLong(offsets[0]),
    effortRate: reader.readLong(offsets[1]),
    failOnRep: reader.readLongOrNull(offsets[2]),
    needSync: reader.readBoolOrNull(offsets[3]) ?? true,
    note: reader.readStringOrNull(offsets[4]),
    reps: reader.readLong(offsets[6]),
    restDuration: reader.readLongOrNull(offsets[7]) ?? 0,
    weight: reader.readDouble(offsets[8]),
  );
  object.id = id;
  object.pocketbaseId = reader.readStringOrNull(offsets[5]);
  return object;
}

P _sessionSetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionSetGetId(SessionSet object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessionSetGetLinks(SessionSet object) {
  return [object.sessionExercise];
}

void _sessionSetAttach(IsarCollection<dynamic> col, Id id, SessionSet object) {
  object.id = id;
  object.sessionExercise.attach(
    col,
    col.isar.collection<SessionExercise>(),
    r'sessionExercise',
    id,
  );
}

extension SessionSetQueryWhereSort
    on QueryBuilder<SessionSet, SessionSet, QWhere> {
  QueryBuilder<SessionSet, SessionSet, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SessionSetQueryWhere
    on QueryBuilder<SessionSet, SessionSet, QWhereClause> {
  QueryBuilder<SessionSet, SessionSet, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SessionSet, SessionSet, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterWhereClause> idBetween(
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

extension SessionSetQueryFilter
    on QueryBuilder<SessionSet, SessionSet, QFilterCondition> {
  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> durationEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duration', value: value),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  durationGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> durationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> durationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> effortRateEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'effortRate', value: value),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  effortRateGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'effortRate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  effortRateLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'effortRate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> effortRateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'effortRate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  failOnRepIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'failOnRep'),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  failOnRepIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'failOnRep'),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> failOnRepEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'failOnRep', value: value),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  failOnRepGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'failOnRep',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> failOnRepLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'failOnRep',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> failOnRepBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'failOnRep',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> needSyncEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'needSync', value: value),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  pocketbaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pocketbaseId'),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  pocketbaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pocketbaseId'),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
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

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  pocketbaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pocketbaseId', value: ''),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  pocketbaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pocketbaseId', value: ''),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> repsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reps', value: value),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> repsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> repsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> repsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  restDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'restDuration', value: value),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  restDurationGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'restDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  restDurationLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'restDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  restDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'restDuration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> weightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'weight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> weightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> weightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weight',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> weightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension SessionSetQueryObject
    on QueryBuilder<SessionSet, SessionSet, QFilterCondition> {}

extension SessionSetQueryLinks
    on QueryBuilder<SessionSet, SessionSet, QFilterCondition> {
  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition> sessionExercise(
    FilterQuery<SessionExercise> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'sessionExercise');
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterFilterCondition>
  sessionExerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'sessionExercise', 0, true, 0, true);
    });
  }
}

extension SessionSetQuerySortBy
    on QueryBuilder<SessionSet, SessionSet, QSortBy> {
  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByEffortRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortRate', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByEffortRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortRate', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByFailOnRep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failOnRep', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByFailOnRepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failOnRep', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByRestDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension SessionSetQuerySortThenBy
    on QueryBuilder<SessionSet, SessionSet, QSortThenBy> {
  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByEffortRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortRate', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByEffortRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effortRate', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByFailOnRep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failOnRep', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByFailOnRepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failOnRep', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByRestDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.desc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension SessionSetQueryWhereDistinct
    on QueryBuilder<SessionSet, SessionSet, QDistinct> {
  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByEffortRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effortRate');
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByFailOnRep() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failOnRep');
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needSync');
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByPocketbaseId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pocketbaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reps');
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restDuration');
    });
  }

  QueryBuilder<SessionSet, SessionSet, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension SessionSetQueryProperty
    on QueryBuilder<SessionSet, SessionSet, QQueryProperty> {
  QueryBuilder<SessionSet, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionSet, int, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<SessionSet, int, QQueryOperations> effortRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effortRate');
    });
  }

  QueryBuilder<SessionSet, int?, QQueryOperations> failOnRepProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failOnRep');
    });
  }

  QueryBuilder<SessionSet, bool, QQueryOperations> needSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needSync');
    });
  }

  QueryBuilder<SessionSet, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<SessionSet, String?, QQueryOperations> pocketbaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pocketbaseId');
    });
  }

  QueryBuilder<SessionSet, int, QQueryOperations> repsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reps');
    });
  }

  QueryBuilder<SessionSet, int, QQueryOperations> restDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restDuration');
    });
  }

  QueryBuilder<SessionSet, double, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}
