// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMeasurementSnapshotCollection on Isar {
  IsarCollection<MeasurementSnapshot> get measurementSnapshots =>
      this.collection();
}

const MeasurementSnapshotSchema = CollectionSchema(
  name: r'MeasurementSnapshot',
  id: -2659336406045931769,
  properties: {
    r'addomineMm': PropertySchema(
      id: 0,
      name: r'addomineMm',
      type: IsarType.double,
    ),
    r'ascelllareMm': PropertySchema(
      id: 1,
      name: r'ascelllareMm',
      type: IsarType.double,
    ),
    r'bicipiteMm': PropertySchema(
      id: 2,
      name: r'bicipiteMm',
      type: IsarType.double,
    ),
    r'braccioCm': PropertySchema(
      id: 3,
      name: r'braccioCm',
      type: IsarType.double,
    ),
    r'colloCm': PropertySchema(
      id: 4,
      name: r'colloCm',
      type: IsarType.double,
    ),
    r'contCirconferenze': PropertySchema(
      id: 5,
      name: r'contCirconferenze',
      type: IsarType.long,
    ),
    r'contPliche': PropertySchema(
      id: 6,
      name: r'contPliche',
      type: IsarType.long,
    ),
    r'cosciaCm': PropertySchema(
      id: 7,
      name: r'cosciaCm',
      type: IsarType.double,
    ),
    r'cosciaMm': PropertySchema(
      id: 8,
      name: r'cosciaMm',
      type: IsarType.double,
    ),
    r'data': PropertySchema(
      id: 9,
      name: r'data',
      type: IsarType.dateTime,
    ),
    r'fianchiCm': PropertySchema(
      id: 10,
      name: r'fianchiCm',
      type: IsarType.double,
    ),
    r'fonti': PropertySchema(
      id: 11,
      name: r'fonti',
      type: IsarType.stringList,
    ),
    r'pettoraleMm': PropertySchema(
      id: 12,
      name: r'pettoraleMm',
      type: IsarType.double,
    ),
    r'polpaccioCm': PropertySchema(
      id: 13,
      name: r'polpaccioCm',
      type: IsarType.double,
    ),
    r'polpaccioMm': PropertySchema(
      id: 14,
      name: r'polpaccioMm',
      type: IsarType.double,
    ),
    r'sottoscapolareMm': PropertySchema(
      id: 15,
      name: r'sottoscapolareMm',
      type: IsarType.double,
    ),
    r'sovrailiachMm': PropertySchema(
      id: 16,
      name: r'sovrailiachMm',
      type: IsarType.double,
    ),
    r'spalleCm': PropertySchema(
      id: 17,
      name: r'spalleCm',
      type: IsarType.double,
    ),
    r'toraceCm': PropertySchema(
      id: 18,
      name: r'toraceCm',
      type: IsarType.double,
    ),
    r'tricipiteMm': PropertySchema(
      id: 19,
      name: r'tricipiteMm',
      type: IsarType.double,
    ),
    r'vitaCm': PropertySchema(
      id: 20,
      name: r'vitaCm',
      type: IsarType.double,
    )
  },
  estimateSize: _measurementSnapshotEstimateSize,
  serialize: _measurementSnapshotSerialize,
  deserialize: _measurementSnapshotDeserialize,
  deserializeProp: _measurementSnapshotDeserializeProp,
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
  getId: _measurementSnapshotGetId,
  getLinks: _measurementSnapshotGetLinks,
  attach: _measurementSnapshotAttach,
  version: '3.1.0+1',
);

int _measurementSnapshotEstimateSize(
  MeasurementSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fonti.length * 3;
  {
    for (var i = 0; i < object.fonti.length; i++) {
      final value = object.fonti[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _measurementSnapshotSerialize(
  MeasurementSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.addomineMm);
  writer.writeDouble(offsets[1], object.ascelllareMm);
  writer.writeDouble(offsets[2], object.bicipiteMm);
  writer.writeDouble(offsets[3], object.braccioCm);
  writer.writeDouble(offsets[4], object.colloCm);
  writer.writeLong(offsets[5], object.contCirconferenze);
  writer.writeLong(offsets[6], object.contPliche);
  writer.writeDouble(offsets[7], object.cosciaCm);
  writer.writeDouble(offsets[8], object.cosciaMm);
  writer.writeDateTime(offsets[9], object.data);
  writer.writeDouble(offsets[10], object.fianchiCm);
  writer.writeStringList(offsets[11], object.fonti);
  writer.writeDouble(offsets[12], object.pettoraleMm);
  writer.writeDouble(offsets[13], object.polpaccioCm);
  writer.writeDouble(offsets[14], object.polpaccioMm);
  writer.writeDouble(offsets[15], object.sottoscapolareMm);
  writer.writeDouble(offsets[16], object.sovrailiachMm);
  writer.writeDouble(offsets[17], object.spalleCm);
  writer.writeDouble(offsets[18], object.toraceCm);
  writer.writeDouble(offsets[19], object.tricipiteMm);
  writer.writeDouble(offsets[20], object.vitaCm);
}

MeasurementSnapshot _measurementSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MeasurementSnapshot();
  object.addomineMm = reader.readDoubleOrNull(offsets[0]);
  object.ascelllareMm = reader.readDoubleOrNull(offsets[1]);
  object.bicipiteMm = reader.readDoubleOrNull(offsets[2]);
  object.braccioCm = reader.readDoubleOrNull(offsets[3]);
  object.colloCm = reader.readDoubleOrNull(offsets[4]);
  object.cosciaCm = reader.readDoubleOrNull(offsets[7]);
  object.cosciaMm = reader.readDoubleOrNull(offsets[8]);
  object.data = reader.readDateTime(offsets[9]);
  object.fianchiCm = reader.readDoubleOrNull(offsets[10]);
  object.fonti = reader.readStringList(offsets[11]) ?? [];
  object.id = id;
  object.pettoraleMm = reader.readDoubleOrNull(offsets[12]);
  object.polpaccioCm = reader.readDoubleOrNull(offsets[13]);
  object.polpaccioMm = reader.readDoubleOrNull(offsets[14]);
  object.sottoscapolareMm = reader.readDoubleOrNull(offsets[15]);
  object.sovrailiachMm = reader.readDoubleOrNull(offsets[16]);
  object.spalleCm = reader.readDoubleOrNull(offsets[17]);
  object.toraceCm = reader.readDoubleOrNull(offsets[18]);
  object.tricipiteMm = reader.readDoubleOrNull(offsets[19]);
  object.vitaCm = reader.readDoubleOrNull(offsets[20]);
  return object;
}

P _measurementSnapshotDeserializeProp<P>(
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
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readDoubleOrNull(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _measurementSnapshotGetId(MeasurementSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _measurementSnapshotGetLinks(
    MeasurementSnapshot object) {
  return [];
}

void _measurementSnapshotAttach(
    IsarCollection<dynamic> col, Id id, MeasurementSnapshot object) {
  object.id = id;
}

extension MeasurementSnapshotQueryWhereSort
    on QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QWhere> {
  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhere>
      anyData() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'data'),
      );
    });
  }
}

extension MeasurementSnapshotQueryWhere
    on QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QWhereClause> {
  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      dataEqualTo(DateTime data) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'data',
        value: [data],
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      dataNotEqualTo(DateTime data) {
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      dataGreaterThan(
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      dataLessThan(
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterWhereClause>
      dataBetween(
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

extension MeasurementSnapshotQueryFilter on QueryBuilder<MeasurementSnapshot,
    MeasurementSnapshot, QFilterCondition> {
  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      addomineMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addomineMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      addomineMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addomineMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      addomineMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addomineMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      addomineMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addomineMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      addomineMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addomineMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      addomineMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addomineMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      ascelllareMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ascelllareMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      ascelllareMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ascelllareMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      ascelllareMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ascelllareMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      ascelllareMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ascelllareMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      ascelllareMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ascelllareMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      ascelllareMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ascelllareMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      bicipiteMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bicipiteMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      bicipiteMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bicipiteMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      bicipiteMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bicipiteMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      bicipiteMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bicipiteMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      bicipiteMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bicipiteMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      bicipiteMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bicipiteMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      braccioCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'braccioCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      braccioCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'braccioCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      braccioCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'braccioCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      braccioCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'braccioCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      braccioCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'braccioCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      braccioCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'braccioCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      colloCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'colloCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      colloCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'colloCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      colloCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colloCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      colloCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colloCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      colloCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colloCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      colloCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colloCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contCirconferenzeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contCirconferenze',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contCirconferenzeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contCirconferenze',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contCirconferenzeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contCirconferenze',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contCirconferenzeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contCirconferenze',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contPlicheEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contPliche',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contPlicheGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contPliche',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contPlicheLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contPliche',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      contPlicheBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contPliche',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cosciaCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cosciaCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cosciaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cosciaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cosciaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cosciaCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cosciaMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cosciaMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cosciaMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cosciaMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cosciaMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      cosciaMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cosciaMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      dataEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      dataLessThan(
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      dataBetween(
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fianchiCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fianchiCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fianchiCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fianchiCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fianchiCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fianchiCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fianchiCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fianchiCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fianchiCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fianchiCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fianchiCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fianchiCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fonti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fonti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fonti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fonti',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fonti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fonti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fonti',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fonti',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fonti',
        value: '',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fonti',
        value: '',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fonti',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fonti',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fonti',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fonti',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fonti',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      fontiLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fonti',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
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

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      pettoraleMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pettoraleMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      pettoraleMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pettoraleMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      pettoraleMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pettoraleMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      pettoraleMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pettoraleMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      pettoraleMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pettoraleMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      pettoraleMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pettoraleMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'polpaccioCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'polpaccioCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'polpaccioCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'polpaccioCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'polpaccioCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'polpaccioCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'polpaccioMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'polpaccioMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'polpaccioMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'polpaccioMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'polpaccioMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      polpaccioMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'polpaccioMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sottoscapolareMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sottoscapolareMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sottoscapolareMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sottoscapolareMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sottoscapolareMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sottoscapolareMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sottoscapolareMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sottoscapolareMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sottoscapolareMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sottoscapolareMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sottoscapolareMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sottoscapolareMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sovrailiachMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sovrailiachMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sovrailiachMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sovrailiachMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sovrailiachMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sovrailiachMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sovrailiachMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sovrailiachMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sovrailiachMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sovrailiachMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      sovrailiachMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sovrailiachMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      spalleCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'spalleCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      spalleCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'spalleCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      spalleCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spalleCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      spalleCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spalleCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      spalleCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spalleCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      spalleCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spalleCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      toraceCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'toraceCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      toraceCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'toraceCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      toraceCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toraceCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      toraceCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toraceCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      toraceCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toraceCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      toraceCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toraceCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      tricipiteMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tricipiteMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      tricipiteMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tricipiteMm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      tricipiteMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tricipiteMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      tricipiteMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tricipiteMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      tricipiteMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tricipiteMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      tricipiteMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tricipiteMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      vitaCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vitaCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      vitaCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vitaCm',
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      vitaCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vitaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      vitaCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vitaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      vitaCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vitaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterFilterCondition>
      vitaCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vitaCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MeasurementSnapshotQueryObject on QueryBuilder<MeasurementSnapshot,
    MeasurementSnapshot, QFilterCondition> {}

extension MeasurementSnapshotQueryLinks on QueryBuilder<MeasurementSnapshot,
    MeasurementSnapshot, QFilterCondition> {}

extension MeasurementSnapshotQuerySortBy
    on QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QSortBy> {
  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByAddomineMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addomineMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByAddomineMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addomineMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByAscelllareMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascelllareMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByAscelllareMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascelllareMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByBicipiteMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicipiteMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByBicipiteMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicipiteMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByBraccioCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'braccioCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByBraccioCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'braccioCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByColloCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colloCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByColloCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colloCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByContCirconferenze() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contCirconferenze', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByContCirconferenzeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contCirconferenze', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByContPliche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contPliche', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByContPlicheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contPliche', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByCosciaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByCosciaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByCosciaMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByCosciaMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByFianchiCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fianchiCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByFianchiCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fianchiCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByPettoraleMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pettoraleMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByPettoraleMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pettoraleMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByPolpaccioCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByPolpaccioCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByPolpaccioMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByPolpaccioMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortBySottoscapolareMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sottoscapolareMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortBySottoscapolareMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sottoscapolareMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortBySovrailiachMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sovrailiachMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortBySovrailiachMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sovrailiachMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortBySpalleCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spalleCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortBySpalleCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spalleCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByToraceCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toraceCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByToraceCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toraceCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByTricipiteMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tricipiteMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByTricipiteMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tricipiteMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByVitaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      sortByVitaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaCm', Sort.desc);
    });
  }
}

extension MeasurementSnapshotQuerySortThenBy
    on QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QSortThenBy> {
  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByAddomineMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addomineMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByAddomineMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addomineMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByAscelllareMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascelllareMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByAscelllareMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ascelllareMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByBicipiteMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicipiteMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByBicipiteMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicipiteMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByBraccioCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'braccioCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByBraccioCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'braccioCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByColloCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colloCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByColloCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colloCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByContCirconferenze() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contCirconferenze', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByContCirconferenzeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contCirconferenze', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByContPliche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contPliche', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByContPlicheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contPliche', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByCosciaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByCosciaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByCosciaMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByCosciaMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cosciaMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByFianchiCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fianchiCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByFianchiCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fianchiCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByPettoraleMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pettoraleMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByPettoraleMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pettoraleMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByPolpaccioCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByPolpaccioCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByPolpaccioMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByPolpaccioMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'polpaccioMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenBySottoscapolareMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sottoscapolareMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenBySottoscapolareMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sottoscapolareMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenBySovrailiachMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sovrailiachMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenBySovrailiachMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sovrailiachMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenBySpalleCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spalleCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenBySpalleCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spalleCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByToraceCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toraceCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByToraceCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toraceCm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByTricipiteMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tricipiteMm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByTricipiteMmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tricipiteMm', Sort.desc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByVitaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaCm', Sort.asc);
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QAfterSortBy>
      thenByVitaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaCm', Sort.desc);
    });
  }
}

extension MeasurementSnapshotQueryWhereDistinct
    on QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct> {
  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByAddomineMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addomineMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByAscelllareMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ascelllareMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByBicipiteMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bicipiteMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByBraccioCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'braccioCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByColloCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colloCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByContCirconferenze() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contCirconferenze');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByContPliche() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contPliche');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByCosciaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cosciaCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByCosciaMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cosciaMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByFianchiCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fianchiCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByFonti() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fonti');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByPettoraleMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pettoraleMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByPolpaccioCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'polpaccioCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByPolpaccioMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'polpaccioMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctBySottoscapolareMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sottoscapolareMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctBySovrailiachMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sovrailiachMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctBySpalleCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spalleCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByToraceCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toraceCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByTricipiteMm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tricipiteMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QDistinct>
      distinctByVitaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vitaCm');
    });
  }
}

extension MeasurementSnapshotQueryProperty
    on QueryBuilder<MeasurementSnapshot, MeasurementSnapshot, QQueryProperty> {
  QueryBuilder<MeasurementSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      addomineMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addomineMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      ascelllareMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ascelllareMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      bicipiteMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bicipiteMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      braccioCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'braccioCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      colloCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colloCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, int, QQueryOperations>
      contCirconferenzeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contCirconferenze');
    });
  }

  QueryBuilder<MeasurementSnapshot, int, QQueryOperations>
      contPlicheProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contPliche');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      cosciaCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cosciaCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      cosciaMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cosciaMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, DateTime, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      fianchiCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fianchiCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, List<String>, QQueryOperations>
      fontiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fonti');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      pettoraleMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pettoraleMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      polpaccioCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'polpaccioCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      polpaccioMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'polpaccioMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      sottoscapolareMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sottoscapolareMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      sovrailiachMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sovrailiachMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      spalleCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spalleCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      toraceCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toraceCm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      tricipiteMmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tricipiteMm');
    });
  }

  QueryBuilder<MeasurementSnapshot, double?, QQueryOperations>
      vitaCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vitaCm');
    });
  }
}
