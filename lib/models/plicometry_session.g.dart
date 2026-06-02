// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plicometry_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlicometrySessionCollection on Isar {
  IsarCollection<PlicometrySession> get plicometrySessions => this.collection();
}

const PlicometrySessionSchema = CollectionSchema(
  name: r'PlicometrySession',
  id: 4256065940659897639,
  properties: {
    r'altezzaCm': PropertySchema(
      id: 0,
      name: r'altezzaCm',
      type: IsarType.double,
    ),
    r'data': PropertySchema(
      id: 1,
      name: r'data',
      type: IsarType.dateTime,
    ),
    r'etaAnni': PropertySchema(
      id: 2,
      name: r'etaAnni',
      type: IsarType.long,
    ),
    r'metodo': PropertySchema(
      id: 3,
      name: r'metodo',
      type: IsarType.byte,
      enumMap: _PlicometrySessionmetodoEnumValueMap,
    ),
    r'note': PropertySchema(
      id: 4,
      name: r'note',
      type: IsarType.string,
    ),
    r'pesoKg': PropertySchema(
      id: 5,
      name: r'pesoKg',
      type: IsarType.double,
    ),
    r'pliche': PropertySchema(
      id: 6,
      name: r'pliche',
      type: IsarType.object,
      target: r'Pliche',
    ),
    r'risultati': PropertySchema(
      id: 7,
      name: r'risultati',
      type: IsarType.object,
      target: r'RisultatiPlico',
    )
  },
  estimateSize: _plicometrySessionEstimateSize,
  serialize: _plicometrySessionSerialize,
  deserialize: _plicometrySessionDeserialize,
  deserializeProp: _plicometrySessionDeserializeProp,
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
  embeddedSchemas: {
    r'Pliche': PlicheSchema,
    r'RisultatiPlico': RisultatiPlicoSchema
  },
  getId: _plicometrySessionGetId,
  getLinks: _plicometrySessionGetLinks,
  attach: _plicometrySessionAttach,
  version: '3.1.0+1',
);

int _plicometrySessionEstimateSize(
  PlicometrySession object,
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
  bytesCount += 3 +
      PlicheSchema.estimateSize(object.pliche, allOffsets[Pliche]!, allOffsets);
  bytesCount += 3 +
      RisultatiPlicoSchema.estimateSize(
          object.risultati, allOffsets[RisultatiPlico]!, allOffsets);
  return bytesCount;
}

void _plicometrySessionSerialize(
  PlicometrySession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.altezzaCm);
  writer.writeDateTime(offsets[1], object.data);
  writer.writeLong(offsets[2], object.etaAnni);
  writer.writeByte(offsets[3], object.metodo.index);
  writer.writeString(offsets[4], object.note);
  writer.writeDouble(offsets[5], object.pesoKg);
  writer.writeObject<Pliche>(
    offsets[6],
    allOffsets,
    PlicheSchema.serialize,
    object.pliche,
  );
  writer.writeObject<RisultatiPlico>(
    offsets[7],
    allOffsets,
    RisultatiPlicoSchema.serialize,
    object.risultati,
  );
}

PlicometrySession _plicometrySessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlicometrySession();
  object.altezzaCm = reader.readDouble(offsets[0]);
  object.data = reader.readDateTime(offsets[1]);
  object.etaAnni = reader.readLong(offsets[2]);
  object.id = id;
  object.metodo =
      _PlicometrySessionmetodoValueEnumMap[reader.readByteOrNull(offsets[3])] ??
          MetodoPlicometria.durninWomersley;
  object.note = reader.readStringOrNull(offsets[4]);
  object.pesoKg = reader.readDouble(offsets[5]);
  object.pliche = reader.readObjectOrNull<Pliche>(
        offsets[6],
        PlicheSchema.deserialize,
        allOffsets,
      ) ??
      Pliche();
  object.risultati = reader.readObjectOrNull<RisultatiPlico>(
        offsets[7],
        RisultatiPlicoSchema.deserialize,
        allOffsets,
      ) ??
      RisultatiPlico();
  return object;
}

P _plicometrySessionDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (_PlicometrySessionmetodoValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MetodoPlicometria.durninWomersley) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readObjectOrNull<Pliche>(
            offset,
            PlicheSchema.deserialize,
            allOffsets,
          ) ??
          Pliche()) as P;
    case 7:
      return (reader.readObjectOrNull<RisultatiPlico>(
            offset,
            RisultatiPlicoSchema.deserialize,
            allOffsets,
          ) ??
          RisultatiPlico()) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PlicometrySessionmetodoEnumValueMap = {
  'durninWomersley': 0,
  'jacksonPollock3': 1,
  'jacksonPollock7': 2,
  'faulkner': 3,
  'usNavy': 4,
};
const _PlicometrySessionmetodoValueEnumMap = {
  0: MetodoPlicometria.durninWomersley,
  1: MetodoPlicometria.jacksonPollock3,
  2: MetodoPlicometria.jacksonPollock7,
  3: MetodoPlicometria.faulkner,
  4: MetodoPlicometria.usNavy,
};

Id _plicometrySessionGetId(PlicometrySession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _plicometrySessionGetLinks(
    PlicometrySession object) {
  return [];
}

void _plicometrySessionAttach(
    IsarCollection<dynamic> col, Id id, PlicometrySession object) {
  object.id = id;
}

extension PlicometrySessionQueryWhereSort
    on QueryBuilder<PlicometrySession, PlicometrySession, QWhere> {
  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhere> anyData() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'data'),
      );
    });
  }
}

extension PlicometrySessionQueryWhere
    on QueryBuilder<PlicometrySession, PlicometrySession, QWhereClause> {
  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
      dataEqualTo(DateTime data) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'data',
        value: [data],
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterWhereClause>
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

extension PlicometrySessionQueryFilter
    on QueryBuilder<PlicometrySession, PlicometrySession, QFilterCondition> {
  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      altezzaCmEqualTo(
    double value, {
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      altezzaCmGreaterThan(
    double value, {
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      altezzaCmLessThan(
    double value, {
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      altezzaCmBetween(
    double lower,
    double upper, {
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      dataEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      etaAnniEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'etaAnni',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      etaAnniGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'etaAnni',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      etaAnniLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'etaAnni',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      etaAnniBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'etaAnni',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      metodoEqualTo(MetodoPlicometria value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      metodoGreaterThan(
    MetodoPlicometria value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      metodoLessThan(
    MetodoPlicometria value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      metodoBetween(
    MetodoPlicometria lower,
    MetodoPlicometria upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteEqualTo(
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteLessThan(
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteBetween(
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteEndsWith(
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      pesoKgEqualTo(
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
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

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      pesoKgBetween(
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

extension PlicometrySessionQueryObject
    on QueryBuilder<PlicometrySession, PlicometrySession, QFilterCondition> {
  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      pliche(FilterQuery<Pliche> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'pliche');
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterFilterCondition>
      risultati(FilterQuery<RisultatiPlico> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'risultati');
    });
  }
}

extension PlicometrySessionQueryLinks
    on QueryBuilder<PlicometrySession, PlicometrySession, QFilterCondition> {}

extension PlicometrySessionQuerySortBy
    on QueryBuilder<PlicometrySession, PlicometrySession, QSortBy> {
  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByAltezzaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByAltezzaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByEtaAnni() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etaAnni', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByEtaAnniDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etaAnni', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByMetodo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByMetodoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByPesoKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      sortByPesoKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.desc);
    });
  }
}

extension PlicometrySessionQuerySortThenBy
    on QueryBuilder<PlicometrySession, PlicometrySession, QSortThenBy> {
  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByAltezzaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByAltezzaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'altezzaCm', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByEtaAnni() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etaAnni', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByEtaAnniDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etaAnni', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByMetodo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByMetodoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByPesoKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.asc);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QAfterSortBy>
      thenByPesoKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoKg', Sort.desc);
    });
  }
}

extension PlicometrySessionQueryWhereDistinct
    on QueryBuilder<PlicometrySession, PlicometrySession, QDistinct> {
  QueryBuilder<PlicometrySession, PlicometrySession, QDistinct>
      distinctByAltezzaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'altezzaCm');
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QDistinct>
      distinctByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data');
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QDistinct>
      distinctByEtaAnni() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'etaAnni');
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QDistinct>
      distinctByMetodo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodo');
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlicometrySession, PlicometrySession, QDistinct>
      distinctByPesoKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pesoKg');
    });
  }
}

extension PlicometrySessionQueryProperty
    on QueryBuilder<PlicometrySession, PlicometrySession, QQueryProperty> {
  QueryBuilder<PlicometrySession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlicometrySession, double, QQueryOperations>
      altezzaCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'altezzaCm');
    });
  }

  QueryBuilder<PlicometrySession, DateTime, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<PlicometrySession, int, QQueryOperations> etaAnniProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'etaAnni');
    });
  }

  QueryBuilder<PlicometrySession, MetodoPlicometria, QQueryOperations>
      metodoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodo');
    });
  }

  QueryBuilder<PlicometrySession, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<PlicometrySession, double, QQueryOperations> pesoKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pesoKg');
    });
  }

  QueryBuilder<PlicometrySession, Pliche, QQueryOperations> plicheProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pliche');
    });
  }

  QueryBuilder<PlicometrySession, RisultatiPlico, QQueryOperations>
      risultatiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'risultati');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlicheSchema = Schema(
  name: r'Pliche',
  id: 831341692108750642,
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
    r'cosciaMm': PropertySchema(
      id: 3,
      name: r'cosciaMm',
      type: IsarType.double,
    ),
    r'pettoralleMm': PropertySchema(
      id: 4,
      name: r'pettoralleMm',
      type: IsarType.double,
    ),
    r'polpaccioMm': PropertySchema(
      id: 5,
      name: r'polpaccioMm',
      type: IsarType.double,
    ),
    r'somma': PropertySchema(
      id: 6,
      name: r'somma',
      type: IsarType.double,
    ),
    r'sottoscapolareMm': PropertySchema(
      id: 7,
      name: r'sottoscapolareMm',
      type: IsarType.double,
    ),
    r'sovrailiachMm': PropertySchema(
      id: 8,
      name: r'sovrailiachMm',
      type: IsarType.double,
    ),
    r'tricipiteMm': PropertySchema(
      id: 9,
      name: r'tricipiteMm',
      type: IsarType.double,
    )
  },
  estimateSize: _plicheEstimateSize,
  serialize: _plicheSerialize,
  deserialize: _plicheDeserialize,
  deserializeProp: _plicheDeserializeProp,
);

int _plicheEstimateSize(
  Pliche object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _plicheSerialize(
  Pliche object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.addomineMm);
  writer.writeDouble(offsets[1], object.ascelllareMm);
  writer.writeDouble(offsets[2], object.bicipiteMm);
  writer.writeDouble(offsets[3], object.cosciaMm);
  writer.writeDouble(offsets[4], object.pettoralleMm);
  writer.writeDouble(offsets[5], object.polpaccioMm);
  writer.writeDouble(offsets[6], object.somma);
  writer.writeDouble(offsets[7], object.sottoscapolareMm);
  writer.writeDouble(offsets[8], object.sovrailiachMm);
  writer.writeDouble(offsets[9], object.tricipiteMm);
}

Pliche _plicheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Pliche();
  object.addomineMm = reader.readDoubleOrNull(offsets[0]);
  object.ascelllareMm = reader.readDoubleOrNull(offsets[1]);
  object.bicipiteMm = reader.readDoubleOrNull(offsets[2]);
  object.cosciaMm = reader.readDoubleOrNull(offsets[3]);
  object.pettoralleMm = reader.readDoubleOrNull(offsets[4]);
  object.polpaccioMm = reader.readDoubleOrNull(offsets[5]);
  object.sottoscapolareMm = reader.readDoubleOrNull(offsets[7]);
  object.sovrailiachMm = reader.readDoubleOrNull(offsets[8]);
  object.tricipiteMm = reader.readDoubleOrNull(offsets[9]);
  return object;
}

P _plicheDeserializeProp<P>(
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
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlicheQueryFilter on QueryBuilder<Pliche, Pliche, QFilterCondition> {
  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> addomineMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'addomineMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> addomineMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'addomineMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> addomineMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> addomineMmGreaterThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> addomineMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> addomineMmBetween(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> ascelllareMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ascelllareMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> ascelllareMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ascelllareMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> ascelllareMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> ascelllareMmGreaterThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> ascelllareMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> ascelllareMmBetween(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> bicipiteMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bicipiteMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> bicipiteMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bicipiteMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> bicipiteMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> bicipiteMmGreaterThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> bicipiteMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> bicipiteMmBetween(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> cosciaMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cosciaMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> cosciaMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cosciaMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> cosciaMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> cosciaMmGreaterThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> cosciaMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> cosciaMmBetween(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> pettoralleMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pettoralleMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> pettoralleMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pettoralleMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> pettoralleMmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pettoralleMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> pettoralleMmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pettoralleMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> pettoralleMmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pettoralleMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> pettoralleMmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pettoralleMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> polpaccioMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'polpaccioMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> polpaccioMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'polpaccioMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> polpaccioMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> polpaccioMmGreaterThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> polpaccioMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> polpaccioMmBetween(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sommaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'somma',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sommaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'somma',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sommaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'somma',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sommaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'somma',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sottoscapolareMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sottoscapolareMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition>
      sottoscapolareMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sottoscapolareMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sottoscapolareMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition>
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sottoscapolareMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sottoscapolareMmBetween(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sovrailiachMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sovrailiachMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sovrailiachMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sovrailiachMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sovrailiachMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sovrailiachMmGreaterThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sovrailiachMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> sovrailiachMmBetween(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> tricipiteMmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tricipiteMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> tricipiteMmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tricipiteMm',
      ));
    });
  }

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> tricipiteMmEqualTo(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> tricipiteMmGreaterThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> tricipiteMmLessThan(
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

  QueryBuilder<Pliche, Pliche, QAfterFilterCondition> tricipiteMmBetween(
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
}

extension PlicheQueryObject on QueryBuilder<Pliche, Pliche, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const RisultatiPlicoSchema = Schema(
  name: r'RisultatiPlico',
  id: -5159990489126628702,
  properties: {
    r'bodyFatPercent': PropertySchema(
      id: 0,
      name: r'bodyFatPercent',
      type: IsarType.double,
    ),
    r'densitaCorporea': PropertySchema(
      id: 1,
      name: r'densitaCorporea',
      type: IsarType.double,
    ),
    r'massaGrassaKg': PropertySchema(
      id: 2,
      name: r'massaGrassaKg',
      type: IsarType.double,
    ),
    r'massaMagraKg': PropertySchema(
      id: 3,
      name: r'massaMagraKg',
      type: IsarType.double,
    ),
    r'sommaPlicheMm': PropertySchema(
      id: 4,
      name: r'sommaPlicheMm',
      type: IsarType.double,
    )
  },
  estimateSize: _risultatiPlicoEstimateSize,
  serialize: _risultatiPlicoSerialize,
  deserialize: _risultatiPlicoDeserialize,
  deserializeProp: _risultatiPlicoDeserializeProp,
);

int _risultatiPlicoEstimateSize(
  RisultatiPlico object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _risultatiPlicoSerialize(
  RisultatiPlico object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bodyFatPercent);
  writer.writeDouble(offsets[1], object.densitaCorporea);
  writer.writeDouble(offsets[2], object.massaGrassaKg);
  writer.writeDouble(offsets[3], object.massaMagraKg);
  writer.writeDouble(offsets[4], object.sommaPlicheMm);
}

RisultatiPlico _risultatiPlicoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RisultatiPlico();
  object.bodyFatPercent = reader.readDouble(offsets[0]);
  object.densitaCorporea = reader.readDoubleOrNull(offsets[1]);
  object.massaGrassaKg = reader.readDouble(offsets[2]);
  object.massaMagraKg = reader.readDouble(offsets[3]);
  object.sommaPlicheMm = reader.readDouble(offsets[4]);
  return object;
}

P _risultatiPlicoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension RisultatiPlicoQueryFilter
    on QueryBuilder<RisultatiPlico, RisultatiPlico, QFilterCondition> {
  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      bodyFatPercentEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyFatPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      bodyFatPercentGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyFatPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      bodyFatPercentLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyFatPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      bodyFatPercentBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyFatPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      densitaCorporeaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'densitaCorporea',
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      densitaCorporeaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'densitaCorporea',
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      densitaCorporeaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'densitaCorporea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      densitaCorporeaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'densitaCorporea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      densitaCorporeaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'densitaCorporea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      densitaCorporeaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'densitaCorporea',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaGrassaKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'massaGrassaKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaGrassaKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'massaGrassaKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaGrassaKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'massaGrassaKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaGrassaKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'massaGrassaKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaMagraKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'massaMagraKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaMagraKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'massaMagraKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaMagraKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'massaMagraKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      massaMagraKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'massaMagraKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      sommaPlicheMmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sommaPlicheMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      sommaPlicheMmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sommaPlicheMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      sommaPlicheMmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sommaPlicheMm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<RisultatiPlico, RisultatiPlico, QAfterFilterCondition>
      sommaPlicheMmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sommaPlicheMm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension RisultatiPlicoQueryObject
    on QueryBuilder<RisultatiPlico, RisultatiPlico, QFilterCondition> {}
