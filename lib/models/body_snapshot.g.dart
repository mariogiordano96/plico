// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBodySnapshotCollection on Isar {
  IsarCollection<BodySnapshot> get bodySnapshots => this.collection();
}

const BodySnapshotSchema = CollectionSchema(
  name: r'BodySnapshot',
  id: 1359296007130234066,
  properties: {
    r'altezzaCm': PropertySchema(
      id: 0,
      name: r'altezzaCm',
      type: IsarType.double,
    ),
    r'bodyFatManuale': PropertySchema(
      id: 1,
      name: r'bodyFatManuale',
      type: IsarType.double,
    ),
    r'data': PropertySchema(
      id: 2,
      name: r'data',
      type: IsarType.dateTime,
    ),
    r'note': PropertySchema(
      id: 3,
      name: r'note',
      type: IsarType.string,
    ),
    r'pesoKg': PropertySchema(
      id: 4,
      name: r'pesoKg',
      type: IsarType.double,
    )
  },
  estimateSize: _bodySnapshotEstimateSize,
  serialize: _bodySnapshotSerialize,
  deserialize: _bodySnapshotDeserialize,
  deserializeProp: _bodySnapshotDeserializeProp,
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
  embeddedSchemas: {},
  getId: _bodySnapshotGetId,
  getLinks: _bodySnapshotGetLinks,
  attach: _bodySnapshotAttach,
  version: '3.1.0+1',
);

int _bodySnapshotEstimateSize(
  BodySnapshot object,
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
  return bytesCount;
}

void _bodySnapshotSerialize(
  BodySnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.altezzaCm);
  writer.writeDouble(offsets[1], object.bodyFatManuale);
  writer.writeDateTime(offsets[2], object.data);
  writer.writeString(offsets[3], object.note);
  writer.writeDouble(offsets[4], object.pesoKg);
}

BodySnapshot _bodySnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BodySnapshot();
  object.altezzaCm = reader.readDoubleOrNull(offsets[0]);
  object.bodyFatManuale = reader.readDoubleOrNull(offsets[1]);
  object.data = reader.readDateTime(offsets[2]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[3]);
  object.pesoKg = reader.readDouble(offsets[4]);
  return object;
}

P _bodySnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bodySnapshotGetId(BodySnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bodySnapshotGetLinks(BodySnapshot object) {
  return [];
}

void _bodySnapshotAttach(
    IsarCollection<dynamic> col, Id id, BodySnapshot object) {
  object.id = id;
}

extension BodySnapshotQueryWhereSort
    on QueryBuilder<BodySnapshot, BodySnapshot, QWhere> {
  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhere> anyData() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'data'),
      );
    });
  }
}

extension BodySnapshotQueryWhere
    on QueryBuilder<BodySnapshot, BodySnapshot, QWhereClause> {
  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> idBetween(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> dataEqualTo(
      DateTime data) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'data',
        value: [data],
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> dataNotEqualTo(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> dataGreaterThan(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> dataLessThan(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterWhereClause> dataBetween(
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

extension BodySnapshotQueryFilter
    on QueryBuilder<BodySnapshot, BodySnapshot, QFilterCondition> {
  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      altezzaCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'altezzaCm',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      altezzaCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'altezzaCm',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      altezzaCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'altezzaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      altezzaCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'altezzaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      altezzaCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'altezzaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      altezzaCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'altezzaCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      bodyFatManualeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bodyFatManuale',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      bodyFatManualeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bodyFatManuale',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      bodyFatManualeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyFatManuale',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      bodyFatManualeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyFatManuale',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      bodyFatManualeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyFatManuale',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      bodyFatManualeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyFatManuale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> dataEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      dataGreaterThan(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> dataLessThan(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> dataBetween(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> pesoKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pesoKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      pesoKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pesoKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition>
      pesoKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pesoKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterFilterCondition> pesoKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pesoKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension BodySnapshotQueryObject
    on QueryBuilder<BodySnapshot, BodySnapshot, QFilterCondition> {}

extension BodySnapshotQueryLinks
    on QueryBuilder<BodySnapshot, BodySnapshot, QFilterCondition> {}

extension BodySnapshotQuerySortBy
    on QueryBuilder<BodySnapshot, BodySnapshot, QSortBy> {
  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByAltezzaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByAltezzaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy>
      sortByBodyFatManuale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatManuale', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy>
      sortByBodyFatManualeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatManuale', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByPesoKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> sortByPesoKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.desc);
    });
  }
}

extension BodySnapshotQuerySortThenBy
    on QueryBuilder<BodySnapshot, BodySnapshot, QSortThenBy> {
  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByAltezzaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByAltezzaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy>
      thenByBodyFatManuale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatManuale', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy>
      thenByBodyFatManualeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatManuale', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByPesoKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.asc);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QAfterSortBy> thenByPesoKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.desc);
    });
  }
}

extension BodySnapshotQueryWhereDistinct
    on QueryBuilder<BodySnapshot, BodySnapshot, QDistinct> {
  QueryBuilder<BodySnapshot, BodySnapshot, QDistinct> distinctByAltezzaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'altezzaCm');
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QDistinct>
      distinctByBodyFatManuale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyFatManuale');
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QDistinct> distinctByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data');
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodySnapshot, BodySnapshot, QDistinct> distinctByPesoKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pesoKg');
    });
  }
}

extension BodySnapshotQueryProperty
    on QueryBuilder<BodySnapshot, BodySnapshot, QQueryProperty> {
  QueryBuilder<BodySnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BodySnapshot, double?, QQueryOperations> altezzaCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'altezzaCm');
    });
  }

  QueryBuilder<BodySnapshot, double?, QQueryOperations>
      bodyFatManualeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyFatManuale');
    });
  }

  QueryBuilder<BodySnapshot, DateTime, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<BodySnapshot, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<BodySnapshot, double, QQueryOperations> pesoKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pesoKg');
    });
  }
}
