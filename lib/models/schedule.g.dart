// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScheduleCollection on Isar {
  IsarCollection<Schedule> get schedules => this.collection();
}

const ScheduleSchema = CollectionSchema(
  name: r'Schedule',
  id: 6369058706800408146,
  properties: {
    r'activeSelectedDates': PropertySchema(
      id: 0,
      name: r'activeSelectedDates',
      type: IsarType.dateTimeList,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyWeekday': PropertySchema(
      id: 2,
      name: r'dailyWeekday',
      type: IsarType.byteList,
      enumMap: _ScheduledailyWeekdayEnumValueMap,
    ),
    r'durationAlert': PropertySchema(
      id: 3,
      name: r'durationAlert',
      type: IsarType.bool,
    ),
    r'needSync': PropertySchema(id: 4, name: r'needSync', type: IsarType.bool),
    r'plannedDuration': PropertySchema(
      id: 5,
      name: r'plannedDuration',
      type: IsarType.long,
    ),
    r'pocketbaseId': PropertySchema(
      id: 6,
      name: r'pocketbaseId',
      type: IsarType.string,
    ),
    r'recurrenceType': PropertySchema(
      id: 7,
      name: r'recurrenceType',
      type: IsarType.byte,
      enumMap: _SchedulerecurrenceTypeEnumValueMap,
    ),
    r'selectedDates': PropertySchema(
      id: 8,
      name: r'selectedDates',
      type: IsarType.dateTimeList,
    ),
    r'startTime': PropertySchema(
      id: 9,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _scheduleEstimateSize,
  serialize: _scheduleSerialize,
  deserialize: _scheduleDeserialize,
  deserializeProp: _scheduleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'workout': LinkSchema(
      id: -5058931440356630441,
      name: r'workout',
      target: r'Workout',
      single: true,
    ),
  },
  embeddedSchemas: {},
  getId: _scheduleGetId,
  getLinks: _scheduleGetLinks,
  attach: _scheduleAttach,
  version: '3.1.0+1',
);

int _scheduleEstimateSize(
  Schedule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeSelectedDates.length * 8;
  bytesCount += 3 + object.dailyWeekday.length;
  {
    final value = object.pocketbaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.selectedDates.length * 8;
  return bytesCount;
}

void _scheduleSerialize(
  Schedule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTimeList(offsets[0], object.activeSelectedDates);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeByteList(
    offsets[2],
    object.dailyWeekday.map((e) => e.index).toList(),
  );
  writer.writeBool(offsets[3], object.durationAlert);
  writer.writeBool(offsets[4], object.needSync);
  writer.writeLong(offsets[5], object.plannedDuration);
  writer.writeString(offsets[6], object.pocketbaseId);
  writer.writeByte(offsets[7], object.recurrenceType.index);
  writer.writeDateTimeList(offsets[8], object.selectedDates);
  writer.writeDateTime(offsets[9], object.startTime);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

Schedule _scheduleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Schedule(
    durationAlert: reader.readBoolOrNull(offsets[3]) ?? false,
    needSync: reader.readBoolOrNull(offsets[4]) ?? true,
    plannedDuration: reader.readLongOrNull(offsets[5]) ?? 30,
    recurrenceType:
        _SchedulerecurrenceTypeValueEnumMap[reader.readByteOrNull(
          offsets[7],
        )] ??
        RecurrenceType.once,
    startTime: reader.readDateTime(offsets[9]),
  );
  object.createdAt = reader.readDateTime(offsets[1]);
  object.dailyWeekday =
      reader
          .readByteList(offsets[2])
          ?.map((e) => _ScheduledailyWeekdayValueEnumMap[e] ?? Weekday.monday)
          .toList() ??
      [];
  object.id = id;
  object.pocketbaseId = reader.readStringOrNull(offsets[6]);
  object.selectedDates = reader.readDateTimeList(offsets[8]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _scheduleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader
                  .readByteList(offset)
                  ?.map(
                    (e) =>
                        _ScheduledailyWeekdayValueEnumMap[e] ?? Weekday.monday,
                  )
                  .toList() ??
              [])
          as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 30) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (_SchedulerecurrenceTypeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              RecurrenceType.once)
          as P;
    case 8:
      return (reader.readDateTimeList(offset) ?? []) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ScheduledailyWeekdayEnumValueMap = {
  'monday': 0,
  'tuesday': 1,
  'wednesday': 2,
  'thursday': 3,
  'friday': 4,
  'saturday': 5,
  'sunday': 6,
};
const _ScheduledailyWeekdayValueEnumMap = {
  0: Weekday.monday,
  1: Weekday.tuesday,
  2: Weekday.wednesday,
  3: Weekday.thursday,
  4: Weekday.friday,
  5: Weekday.saturday,
  6: Weekday.sunday,
};
const _SchedulerecurrenceTypeEnumValueMap = {
  'once': 0,
  'daily': 1,
  'monthly': 2,
};
const _SchedulerecurrenceTypeValueEnumMap = {
  0: RecurrenceType.once,
  1: RecurrenceType.daily,
  2: RecurrenceType.monthly,
};

Id _scheduleGetId(Schedule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scheduleGetLinks(Schedule object) {
  return [object.workout];
}

void _scheduleAttach(IsarCollection<dynamic> col, Id id, Schedule object) {
  object.id = id;
  object.workout.attach(col, col.isar.collection<Workout>(), r'workout', id);
}

extension ScheduleQueryWhereSort on QueryBuilder<Schedule, Schedule, QWhere> {
  QueryBuilder<Schedule, Schedule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScheduleQueryWhere on QueryBuilder<Schedule, Schedule, QWhereClause> {
  QueryBuilder<Schedule, Schedule, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Schedule, Schedule, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterWhereClause> idBetween(
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

extension ScheduleQueryFilter
    on QueryBuilder<Schedule, Schedule, QFilterCondition> {
  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'activeSelectedDates', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesElementGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'activeSelectedDates',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesElementLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'activeSelectedDates',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'activeSelectedDates',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeSelectedDates',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'activeSelectedDates', 0, true, 0, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'activeSelectedDates', 0, false, 999999, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'activeSelectedDates', 0, true, length, include);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeSelectedDates',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  activeSelectedDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activeSelectedDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayElementEqualTo(Weekday value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dailyWeekday', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayElementGreaterThan(Weekday value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dailyWeekday',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayElementLessThan(Weekday value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dailyWeekday',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayElementBetween(
    Weekday lower,
    Weekday upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dailyWeekday',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dailyWeekday', length, true, length, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dailyWeekday', 0, true, 0, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dailyWeekday', 0, false, 999999, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dailyWeekday', 0, true, length, include);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'dailyWeekday', length, include, 999999, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  dailyWeekdayLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dailyWeekday',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> durationAlertEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'durationAlert', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> needSyncEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'needSync', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  plannedDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'plannedDuration', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  plannedDurationGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'plannedDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  plannedDurationLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'plannedDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  plannedDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'plannedDuration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pocketbaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pocketbaseId'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  pocketbaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pocketbaseId'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pocketbaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pocketbaseIdLessThan(
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pocketbaseIdBetween(
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pocketbaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pocketbaseIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pocketbaseIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  pocketbaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pocketbaseId', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  pocketbaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'pocketbaseId', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> recurrenceTypeEqualTo(
    RecurrenceType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recurrenceType', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  recurrenceTypeGreaterThan(RecurrenceType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recurrenceType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  recurrenceTypeLessThan(RecurrenceType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recurrenceType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> recurrenceTypeBetween(
    RecurrenceType lower,
    RecurrenceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recurrenceType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesElementEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'selectedDates', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesElementGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'selectedDates',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesElementLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'selectedDates',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesElementBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'selectedDates',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedDates', length, true, length, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedDates', 0, true, 0, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedDates', 0, false, 999999, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedDates', 0, true, length, include);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'selectedDates', length, include, 999999, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  selectedDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'selectedDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startTimeEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startTime', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startTime',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startTime',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ScheduleQueryObject
    on QueryBuilder<Schedule, Schedule, QFilterCondition> {}

extension ScheduleQueryLinks
    on QueryBuilder<Schedule, Schedule, QFilterCondition> {
  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> workout(
    FilterQuery<Workout> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'workout');
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> workoutIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'workout', 0, true, 0, true);
    });
  }
}

extension ScheduleQuerySortBy on QueryBuilder<Schedule, Schedule, QSortBy> {
  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByDurationAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationAlert', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByDurationAlertDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationAlert', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByPlannedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDuration', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByPlannedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDuration', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByRecurrenceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByRecurrenceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ScheduleQuerySortThenBy
    on QueryBuilder<Schedule, Schedule, QSortThenBy> {
  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByDurationAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationAlert', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByDurationAlertDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationAlert', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByNeedSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needSync', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByPlannedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDuration', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByPlannedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'plannedDuration', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByPocketbaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByPocketbaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pocketbaseId', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByRecurrenceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByRecurrenceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recurrenceType', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ScheduleQueryWhereDistinct
    on QueryBuilder<Schedule, Schedule, QDistinct> {
  QueryBuilder<Schedule, Schedule, QDistinct> distinctByActiveSelectedDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeSelectedDates');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByDailyWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyWeekday');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByDurationAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationAlert');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByNeedSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needSync');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByPlannedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'plannedDuration');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByPocketbaseId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pocketbaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByRecurrenceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recurrenceType');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctBySelectedDates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'selectedDates');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<Schedule, Schedule, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ScheduleQueryProperty
    on QueryBuilder<Schedule, Schedule, QQueryProperty> {
  QueryBuilder<Schedule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Schedule, List<DateTime>, QQueryOperations>
  activeSelectedDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeSelectedDates');
    });
  }

  QueryBuilder<Schedule, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Schedule, List<Weekday>, QQueryOperations>
  dailyWeekdayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyWeekday');
    });
  }

  QueryBuilder<Schedule, bool, QQueryOperations> durationAlertProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationAlert');
    });
  }

  QueryBuilder<Schedule, bool, QQueryOperations> needSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needSync');
    });
  }

  QueryBuilder<Schedule, int, QQueryOperations> plannedDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'plannedDuration');
    });
  }

  QueryBuilder<Schedule, String?, QQueryOperations> pocketbaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pocketbaseId');
    });
  }

  QueryBuilder<Schedule, RecurrenceType, QQueryOperations>
  recurrenceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recurrenceType');
    });
  }

  QueryBuilder<Schedule, List<DateTime>, QQueryOperations>
  selectedDatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'selectedDates');
    });
  }

  QueryBuilder<Schedule, DateTime, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<Schedule, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
