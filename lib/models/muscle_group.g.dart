// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_group.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMuscleGroupCollection on Isar {
  IsarCollection<MuscleGroup> get muscleGroups => this.collection();
}

const MuscleGroupSchema = CollectionSchema(
  name: r'MuscleGroup',
  id: -4041869078048828678,
  properties: {
    r'name': PropertySchema(
      id: 0,
      name: r'name',
      type: IsarType.string,
    ),
    r'thumbnailCloud': PropertySchema(
      id: 1,
      name: r'thumbnailCloud',
      type: IsarType.string,
    ),
    r'thumbnailLocal': PropertySchema(
      id: 2,
      name: r'thumbnailLocal',
      type: IsarType.string,
    )
  },
  estimateSize: _muscleGroupEstimateSize,
  serialize: _muscleGroupSerialize,
  deserialize: _muscleGroupDeserialize,
  deserializeProp: _muscleGroupDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _muscleGroupGetId,
  getLinks: _muscleGroupGetLinks,
  attach: _muscleGroupAttach,
  version: '3.1.0+1',
);

int _muscleGroupEstimateSize(
  MuscleGroup object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.thumbnailCloud;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnailLocal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _muscleGroupSerialize(
  MuscleGroup object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.name);
  writer.writeString(offsets[1], object.thumbnailCloud);
  writer.writeString(offsets[2], object.thumbnailLocal);
}

MuscleGroup _muscleGroupDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MuscleGroup(
    name: reader.readString(offsets[0]),
    thumbnailCloud: reader.readStringOrNull(offsets[1]),
    thumbnailLocal: reader.readStringOrNull(offsets[2]),
  );
  object.id = id;
  return object;
}

P _muscleGroupDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _muscleGroupGetId(MuscleGroup object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _muscleGroupGetLinks(MuscleGroup object) {
  return [];
}

void _muscleGroupAttach(
    IsarCollection<dynamic> col, Id id, MuscleGroup object) {
  object.id = id;
}

extension MuscleGroupQueryWhereSort
    on QueryBuilder<MuscleGroup, MuscleGroup, QWhere> {
  QueryBuilder<MuscleGroup, MuscleGroup, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MuscleGroupQueryWhere
    on QueryBuilder<MuscleGroup, MuscleGroup, QWhereClause> {
  QueryBuilder<MuscleGroup, MuscleGroup, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterWhereClause> idBetween(
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

extension MuscleGroupQueryFilter
    on QueryBuilder<MuscleGroup, MuscleGroup, QFilterCondition> {
  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailCloud',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailCloud',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailCloud',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailCloud',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailCloud',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailCloud',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailCloud',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailCloud',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailCloud',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailCloud',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailCloud',
        value: '',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailCloudIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailCloud',
        value: '',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailLocal',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailLocal',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailLocal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailLocal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailLocal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailLocal',
        value: '',
      ));
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterFilterCondition>
      thumbnailLocalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailLocal',
        value: '',
      ));
    });
  }
}

extension MuscleGroupQueryObject
    on QueryBuilder<MuscleGroup, MuscleGroup, QFilterCondition> {}

extension MuscleGroupQueryLinks
    on QueryBuilder<MuscleGroup, MuscleGroup, QFilterCondition> {}

extension MuscleGroupQuerySortBy
    on QueryBuilder<MuscleGroup, MuscleGroup, QSortBy> {
  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> sortByThumbnailCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailCloud', Sort.asc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy>
      sortByThumbnailCloudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailCloud', Sort.desc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> sortByThumbnailLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailLocal', Sort.asc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy>
      sortByThumbnailLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailLocal', Sort.desc);
    });
  }
}

extension MuscleGroupQuerySortThenBy
    on QueryBuilder<MuscleGroup, MuscleGroup, QSortThenBy> {
  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> thenByThumbnailCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailCloud', Sort.asc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy>
      thenByThumbnailCloudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailCloud', Sort.desc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy> thenByThumbnailLocal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailLocal', Sort.asc);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QAfterSortBy>
      thenByThumbnailLocalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailLocal', Sort.desc);
    });
  }
}

extension MuscleGroupQueryWhereDistinct
    on QueryBuilder<MuscleGroup, MuscleGroup, QDistinct> {
  QueryBuilder<MuscleGroup, MuscleGroup, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QDistinct> distinctByThumbnailCloud(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailCloud',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MuscleGroup, MuscleGroup, QDistinct> distinctByThumbnailLocal(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailLocal',
          caseSensitive: caseSensitive);
    });
  }
}

extension MuscleGroupQueryProperty
    on QueryBuilder<MuscleGroup, MuscleGroup, QQueryProperty> {
  QueryBuilder<MuscleGroup, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MuscleGroup, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MuscleGroup, String?, QQueryOperations>
      thumbnailCloudProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailCloud');
    });
  }

  QueryBuilder<MuscleGroup, String?, QQueryOperations>
      thumbnailLocalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailLocal');
    });
  }
}
