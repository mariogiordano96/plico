// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyLogCollection on Isar {
  IsarCollection<DailyLog> get dailyLogs => this.collection();
}

const DailyLogSchema = CollectionSchema(
  name: r'DailyLog',
  id: -3995615497450705259,
  properties: {
    r'carbsTotali': PropertySchema(
      id: 0,
      name: r'carbsTotali',
      type: IsarType.double,
    ),
    r'data': PropertySchema(
      id: 1,
      name: r'data',
      type: IsarType.dateTime,
    ),
    r'entries': PropertySchema(
      id: 2,
      name: r'entries',
      type: IsarType.objectList,
      target: r'MealEntry',
    ),
    r'fatTotali': PropertySchema(
      id: 3,
      name: r'fatTotali',
      type: IsarType.double,
    ),
    r'kcalTotali': PropertySchema(
      id: 4,
      name: r'kcalTotali',
      type: IsarType.double,
    ),
    r'proteinTotali': PropertySchema(
      id: 5,
      name: r'proteinTotali',
      type: IsarType.double,
    )
  },
  estimateSize: _dailyLogEstimateSize,
  serialize: _dailyLogSerialize,
  deserialize: _dailyLogDeserialize,
  deserializeProp: _dailyLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'data': IndexSchema(
      id: -1965939710438318818,
      name: r'data',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'data',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'MealEntry': MealEntrySchema},
  getId: _dailyLogGetId,
  getLinks: _dailyLogGetLinks,
  attach: _dailyLogAttach,
  version: '3.1.0+1',
);

int _dailyLogEstimateSize(
  DailyLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entries.length * 3;
  {
    final offsets = allOffsets[MealEntry]!;
    for (var i = 0; i < object.entries.length; i++) {
      final value = object.entries[i];
      bytesCount += MealEntrySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _dailyLogSerialize(
  DailyLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.carbsTotali);
  writer.writeDateTime(offsets[1], object.data);
  writer.writeObjectList<MealEntry>(
    offsets[2],
    allOffsets,
    MealEntrySchema.serialize,
    object.entries,
  );
  writer.writeDouble(offsets[3], object.fatTotali);
  writer.writeDouble(offsets[4], object.kcalTotali);
  writer.writeDouble(offsets[5], object.proteinTotali);
}

DailyLog _dailyLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyLog();
  object.data = reader.readDateTime(offsets[1]);
  object.entries = reader.readObjectList<MealEntry>(
        offsets[2],
        MealEntrySchema.deserialize,
        allOffsets,
        MealEntry(),
      ) ??
      [];
  object.id = id;
  return object;
}

P _dailyLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readObjectList<MealEntry>(
            offset,
            MealEntrySchema.deserialize,
            allOffsets,
            MealEntry(),
          ) ??
          []) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyLogGetId(DailyLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyLogGetLinks(DailyLog object) {
  return [];
}

void _dailyLogAttach(IsarCollection<dynamic> col, Id id, DailyLog object) {
  object.id = id;
}

extension DailyLogQueryWhereSort on QueryBuilder<DailyLog, DailyLog, QWhere> {
  QueryBuilder<DailyLog, DailyLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhere> anyData() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'data'),
      );
    });
  }
}

extension DailyLogQueryWhere on QueryBuilder<DailyLog, DailyLog, QWhereClause> {
  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dataEqualTo(
      DateTime data) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'data',
        value: [data],
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dataNotEqualTo(
      DateTime data) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'data',
              lower: [],
              upper: [data],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'data',
              lower: [data],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'data',
              lower: [data],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'data',
              lower: [],
              upper: [data],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dataGreaterThan(
    DateTime data, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'data',
        lower: [data],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dataLessThan(
    DateTime data, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'data',
        lower: [],
        upper: [data],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterWhereClause> dataBetween(
    DateTime lowerData,
    DateTime upperData, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'data',
        lower: [lowerData],
        includeLower: includeLower,
        upper: [upperData],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyLogQueryFilter
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {
  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> carbsTotaliEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
      carbsTotaliGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbsTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> carbsTotaliLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbsTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> carbsTotaliBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbsTotali',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dataEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dataGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dataLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> dataBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> entriesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> entriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> entriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> entriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
      entriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> entriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> fatTotaliEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> fatTotaliGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> fatTotaliLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> fatTotaliBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatTotali',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> kcalTotaliEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcalTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> kcalTotaliGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcalTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> kcalTotaliLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcalTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> kcalTotaliBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcalTotali',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> proteinTotaliEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition>
      proteinTotaliGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> proteinTotaliLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> proteinTotaliBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinTotali',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension DailyLogQueryObject
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {
  QueryBuilder<DailyLog, DailyLog, QAfterFilterCondition> entriesElement(
      FilterQuery<MealEntry> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'entries');
    });
  }
}

extension DailyLogQueryLinks
    on QueryBuilder<DailyLog, DailyLog, QFilterCondition> {}

extension DailyLogQuerySortBy on QueryBuilder<DailyLog, DailyLog, QSortBy> {
  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByCarbsTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByCarbsTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByFatTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByFatTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTotali', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByKcalTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByKcalTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByProteinTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> sortByProteinTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTotali', Sort.desc);
    });
  }
}

extension DailyLogQuerySortThenBy
    on QueryBuilder<DailyLog, DailyLog, QSortThenBy> {
  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByCarbsTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByCarbsTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByFatTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByFatTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatTotali', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByKcalTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByKcalTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.desc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByProteinTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTotali', Sort.asc);
    });
  }

  QueryBuilder<DailyLog, DailyLog, QAfterSortBy> thenByProteinTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinTotali', Sort.desc);
    });
  }
}

extension DailyLogQueryWhereDistinct
    on QueryBuilder<DailyLog, DailyLog, QDistinct> {
  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByCarbsTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsTotali');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByFatTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatTotali');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByKcalTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalTotali');
    });
  }

  QueryBuilder<DailyLog, DailyLog, QDistinct> distinctByProteinTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinTotali');
    });
  }
}

extension DailyLogQueryProperty
    on QueryBuilder<DailyLog, DailyLog, QQueryProperty> {
  QueryBuilder<DailyLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyLog, double, QQueryOperations> carbsTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsTotali');
    });
  }

  QueryBuilder<DailyLog, DateTime, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<DailyLog, List<MealEntry>, QQueryOperations> entriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entries');
    });
  }

  QueryBuilder<DailyLog, double, QQueryOperations> fatTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatTotali');
    });
  }

  QueryBuilder<DailyLog, double, QQueryOperations> kcalTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalTotali');
    });
  }

  QueryBuilder<DailyLog, double, QQueryOperations> proteinTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinTotali');
    });
  }
}
