// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_food_preferences.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserFoodPreferencesCollection on Isar {
  IsarCollection<UserFoodPreferences> get userFoodPreferences =>
      this.collection();
}

const UserFoodPreferencesSchema = CollectionSchema(
  name: r'UserFoodPreferences',
  id: 1610409720860535883,
  properties: {
    r'foodLikedIds': PropertySchema(
      id: 0,
      name: r'foodLikedIds',
      type: IsarType.longList,
    ),
    r'haSpuntinoPostWo': PropertySchema(
      id: 1,
      name: r'haSpuntinoPostWo',
      type: IsarType.bool,
    ),
    r'numPasti': PropertySchema(
      id: 2,
      name: r'numPasti',
      type: IsarType.long,
    ),
    r'questionarioCompletato': PropertySchema(
      id: 3,
      name: r'questionarioCompletato',
      type: IsarType.bool,
    ),
    r'restrizioni': PropertySchema(
      id: 4,
      name: r'restrizioni',
      type: IsarType.stringList,
    )
  },
  estimateSize: _userFoodPreferencesEstimateSize,
  serialize: _userFoodPreferencesSerialize,
  deserialize: _userFoodPreferencesDeserialize,
  deserializeProp: _userFoodPreferencesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userFoodPreferencesGetId,
  getLinks: _userFoodPreferencesGetLinks,
  attach: _userFoodPreferencesAttach,
  version: '3.1.0+1',
);

int _userFoodPreferencesEstimateSize(
  UserFoodPreferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.foodLikedIds.length * 8;
  bytesCount += 3 + object.restrizioni.length * 3;
  {
    for (var i = 0; i < object.restrizioni.length; i++) {
      final value = object.restrizioni[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _userFoodPreferencesSerialize(
  UserFoodPreferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.foodLikedIds);
  writer.writeBool(offsets[1], object.haSpuntinoPostWo);
  writer.writeLong(offsets[2], object.numPasti);
  writer.writeBool(offsets[3], object.questionarioCompletato);
  writer.writeStringList(offsets[4], object.restrizioni);
}

UserFoodPreferences _userFoodPreferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserFoodPreferences();
  object.foodLikedIds = reader.readLongList(offsets[0]) ?? [];
  object.haSpuntinoPostWo = reader.readBool(offsets[1]);
  object.id = id;
  object.numPasti = reader.readLong(offsets[2]);
  object.questionarioCompletato = reader.readBool(offsets[3]);
  object.restrizioni = reader.readStringList(offsets[4]) ?? [];
  return object;
}

P _userFoodPreferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset) ?? []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userFoodPreferencesGetId(UserFoodPreferences object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userFoodPreferencesGetLinks(
    UserFoodPreferences object) {
  return [];
}

void _userFoodPreferencesAttach(
    IsarCollection<dynamic> col, Id id, UserFoodPreferences object) {
  object.id = id;
}

extension UserFoodPreferencesQueryWhereSort
    on QueryBuilder<UserFoodPreferences, UserFoodPreferences, QWhere> {
  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserFoodPreferencesQueryWhere
    on QueryBuilder<UserFoodPreferences, UserFoodPreferences, QWhereClause> {
  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterWhereClause>
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

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterWhereClause>
      idBetween(
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

extension UserFoodPreferencesQueryFilter on QueryBuilder<UserFoodPreferences,
    UserFoodPreferences, QFilterCondition> {
  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodLikedIds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodLikedIds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodLikedIds',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodLikedIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodLikedIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodLikedIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodLikedIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodLikedIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodLikedIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      foodLikedIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodLikedIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      haSpuntinoPostWoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'haSpuntinoPostWo',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
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

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
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

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
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

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      numPastiEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numPasti',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      numPastiGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numPasti',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      numPastiLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numPasti',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      numPastiBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numPasti',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      questionarioCompletatoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionarioCompletato',
        value: value,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'restrizioni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'restrizioni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'restrizioni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'restrizioni',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'restrizioni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'restrizioni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'restrizioni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'restrizioni',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'restrizioni',
        value: '',
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'restrizioni',
        value: '',
      ));
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restrizioni',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restrizioni',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restrizioni',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restrizioni',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restrizioni',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterFilterCondition>
      restrizioniLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restrizioni',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension UserFoodPreferencesQueryObject on QueryBuilder<UserFoodPreferences,
    UserFoodPreferences, QFilterCondition> {}

extension UserFoodPreferencesQueryLinks on QueryBuilder<UserFoodPreferences,
    UserFoodPreferences, QFilterCondition> {}

extension UserFoodPreferencesQuerySortBy
    on QueryBuilder<UserFoodPreferences, UserFoodPreferences, QSortBy> {
  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      sortByHaSpuntinoPostWo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'haSpuntinoPostWo', Sort.asc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      sortByHaSpuntinoPostWoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'haSpuntinoPostWo', Sort.desc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      sortByNumPasti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numPasti', Sort.asc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      sortByNumPastiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numPasti', Sort.desc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      sortByQuestionarioCompletato() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionarioCompletato', Sort.asc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      sortByQuestionarioCompletatoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionarioCompletato', Sort.desc);
    });
  }
}

extension UserFoodPreferencesQuerySortThenBy
    on QueryBuilder<UserFoodPreferences, UserFoodPreferences, QSortThenBy> {
  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenByHaSpuntinoPostWo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'haSpuntinoPostWo', Sort.asc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenByHaSpuntinoPostWoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'haSpuntinoPostWo', Sort.desc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenByNumPasti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numPasti', Sort.asc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenByNumPastiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numPasti', Sort.desc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenByQuestionarioCompletato() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionarioCompletato', Sort.asc);
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QAfterSortBy>
      thenByQuestionarioCompletatoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionarioCompletato', Sort.desc);
    });
  }
}

extension UserFoodPreferencesQueryWhereDistinct
    on QueryBuilder<UserFoodPreferences, UserFoodPreferences, QDistinct> {
  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QDistinct>
      distinctByFoodLikedIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodLikedIds');
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QDistinct>
      distinctByHaSpuntinoPostWo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'haSpuntinoPostWo');
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QDistinct>
      distinctByNumPasti() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numPasti');
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QDistinct>
      distinctByQuestionarioCompletato() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionarioCompletato');
    });
  }

  QueryBuilder<UserFoodPreferences, UserFoodPreferences, QDistinct>
      distinctByRestrizioni() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restrizioni');
    });
  }
}

extension UserFoodPreferencesQueryProperty
    on QueryBuilder<UserFoodPreferences, UserFoodPreferences, QQueryProperty> {
  QueryBuilder<UserFoodPreferences, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserFoodPreferences, List<int>, QQueryOperations>
      foodLikedIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodLikedIds');
    });
  }

  QueryBuilder<UserFoodPreferences, bool, QQueryOperations>
      haSpuntinoPostWoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'haSpuntinoPostWo');
    });
  }

  QueryBuilder<UserFoodPreferences, int, QQueryOperations> numPastiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numPasti');
    });
  }

  QueryBuilder<UserFoodPreferences, bool, QQueryOperations>
      questionarioCompletatoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionarioCompletato');
    });
  }

  QueryBuilder<UserFoodPreferences, List<String>, QQueryOperations>
      restrizioniProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restrizioni');
    });
  }
}
