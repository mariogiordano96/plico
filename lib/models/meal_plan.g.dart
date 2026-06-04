// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealPlanCollection on Isar {
  IsarCollection<MealPlan> get mealPlans => this.collection();
}

const MealPlanSchema = CollectionSchema(
  name: r'MealPlan',
  id: 6858060180785015955,
  properties: {
    r'carbsTotali': PropertySchema(
      id: 0,
      name: r'carbsTotali',
      type: IsarType.double,
    ),
    r'dataCreazione': PropertySchema(
      id: 1,
      name: r'dataCreazione',
      type: IsarType.dateTime,
    ),
    r'grassiTotali': PropertySchema(
      id: 2,
      name: r'grassiTotali',
      type: IsarType.double,
    ),
    r'kcalTotali': PropertySchema(
      id: 3,
      name: r'kcalTotali',
      type: IsarType.double,
    ),
    r'livelloAtGenerazione': PropertySchema(
      id: 4,
      name: r'livelloAtGenerazione',
      type: IsarType.long,
    ),
    r'obiettivoAtGenerazione': PropertySchema(
      id: 5,
      name: r'obiettivoAtGenerazione',
      type: IsarType.long,
    ),
    r'obsoleto': PropertySchema(
      id: 6,
      name: r'obsoleto',
      type: IsarType.bool,
    ),
    r'pasti': PropertySchema(
      id: 7,
      name: r'pasti',
      type: IsarType.objectList,
      target: r'PlanMeal',
    ),
    r'proteineTotali': PropertySchema(
      id: 8,
      name: r'proteineTotali',
      type: IsarType.double,
    )
  },
  estimateSize: _mealPlanEstimateSize,
  serialize: _mealPlanSerialize,
  deserialize: _mealPlanDeserialize,
  deserializeProp: _mealPlanDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'PlanMeal': PlanMealSchema,
    r'PlanSlot': PlanSlotSchema,
    r'PlanFood': PlanFoodSchema
  },
  getId: _mealPlanGetId,
  getLinks: _mealPlanGetLinks,
  attach: _mealPlanAttach,
  version: '3.1.0+1',
);

int _mealPlanEstimateSize(
  MealPlan object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.pasti.length * 3;
  {
    final offsets = allOffsets[PlanMeal]!;
    for (var i = 0; i < object.pasti.length; i++) {
      final value = object.pasti[i];
      bytesCount += PlanMealSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _mealPlanSerialize(
  MealPlan object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.carbsTotali);
  writer.writeDateTime(offsets[1], object.dataCreazione);
  writer.writeDouble(offsets[2], object.grassiTotali);
  writer.writeDouble(offsets[3], object.kcalTotali);
  writer.writeLong(offsets[4], object.livelloAtGenerazione);
  writer.writeLong(offsets[5], object.obiettivoAtGenerazione);
  writer.writeBool(offsets[6], object.obsoleto);
  writer.writeObjectList<PlanMeal>(
    offsets[7],
    allOffsets,
    PlanMealSchema.serialize,
    object.pasti,
  );
  writer.writeDouble(offsets[8], object.proteineTotali);
}

MealPlan _mealPlanDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealPlan();
  object.carbsTotali = reader.readDouble(offsets[0]);
  object.dataCreazione = reader.readDateTime(offsets[1]);
  object.grassiTotali = reader.readDouble(offsets[2]);
  object.id = id;
  object.kcalTotali = reader.readDouble(offsets[3]);
  object.livelloAtGenerazione = reader.readLong(offsets[4]);
  object.obiettivoAtGenerazione = reader.readLong(offsets[5]);
  object.obsoleto = reader.readBool(offsets[6]);
  object.pasti = reader.readObjectList<PlanMeal>(
        offsets[7],
        PlanMealSchema.deserialize,
        allOffsets,
        PlanMeal(),
      ) ??
      [];
  object.proteineTotali = reader.readDouble(offsets[8]);
  return object;
}

P _mealPlanDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readObjectList<PlanMeal>(
            offset,
            PlanMealSchema.deserialize,
            allOffsets,
            PlanMeal(),
          ) ??
          []) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mealPlanGetId(MealPlan object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealPlanGetLinks(MealPlan object) {
  return [];
}

void _mealPlanAttach(IsarCollection<dynamic> col, Id id, MealPlan object) {
  object.id = id;
}

extension MealPlanQueryWhereSort on QueryBuilder<MealPlan, MealPlan, QWhere> {
  QueryBuilder<MealPlan, MealPlan, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MealPlanQueryWhere on QueryBuilder<MealPlan, MealPlan, QWhereClause> {
  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterWhereClause> idBetween(
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

extension MealPlanQueryFilter
    on QueryBuilder<MealPlan, MealPlan, QFilterCondition> {
  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> carbsTotaliEqualTo(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> carbsTotaliLessThan(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> carbsTotaliBetween(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dataCreazioneEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataCreazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      dataCreazioneGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataCreazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dataCreazioneLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataCreazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> dataCreazioneBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataCreazione',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> grassiTotaliEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grassiTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      grassiTotaliGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grassiTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> grassiTotaliLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grassiTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> grassiTotaliBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grassiTotali',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> kcalTotaliEqualTo(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> kcalTotaliGreaterThan(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> kcalTotaliLessThan(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> kcalTotaliBetween(
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

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      livelloAtGenerazioneEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'livelloAtGenerazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      livelloAtGenerazioneGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'livelloAtGenerazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      livelloAtGenerazioneLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'livelloAtGenerazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      livelloAtGenerazioneBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'livelloAtGenerazione',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      obiettivoAtGenerazioneEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'obiettivoAtGenerazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      obiettivoAtGenerazioneGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'obiettivoAtGenerazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      obiettivoAtGenerazioneLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'obiettivoAtGenerazione',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      obiettivoAtGenerazioneBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'obiettivoAtGenerazione',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> obsoletoEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'obsoleto',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> pastiLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pasti',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> pastiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pasti',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> pastiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pasti',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> pastiLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pasti',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      pastiLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pasti',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> pastiLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pasti',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> proteineTotaliEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteineTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      proteineTotaliGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteineTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition>
      proteineTotaliLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteineTotali',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> proteineTotaliBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteineTotali',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MealPlanQueryObject
    on QueryBuilder<MealPlan, MealPlan, QFilterCondition> {
  QueryBuilder<MealPlan, MealPlan, QAfterFilterCondition> pastiElement(
      FilterQuery<PlanMeal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'pasti');
    });
  }
}

extension MealPlanQueryLinks
    on QueryBuilder<MealPlan, MealPlan, QFilterCondition> {}

extension MealPlanQuerySortBy on QueryBuilder<MealPlan, MealPlan, QSortBy> {
  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByCarbsTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByCarbsTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByDataCreazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCreazione', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByDataCreazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCreazione', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByGrassiTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grassiTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByGrassiTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grassiTotali', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByKcalTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByKcalTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByLivelloAtGenerazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAtGenerazione', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      sortByLivelloAtGenerazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAtGenerazione', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      sortByObiettivoAtGenerazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivoAtGenerazione', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      sortByObiettivoAtGenerazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivoAtGenerazione', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByObsoleto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obsoleto', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByObsoletoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obsoleto', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByProteineTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteineTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> sortByProteineTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteineTotali', Sort.desc);
    });
  }
}

extension MealPlanQuerySortThenBy
    on QueryBuilder<MealPlan, MealPlan, QSortThenBy> {
  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByCarbsTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByCarbsTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsTotali', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByDataCreazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCreazione', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByDataCreazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCreazione', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByGrassiTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grassiTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByGrassiTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grassiTotali', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByKcalTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByKcalTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalTotali', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByLivelloAtGenerazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAtGenerazione', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      thenByLivelloAtGenerazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAtGenerazione', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      thenByObiettivoAtGenerazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivoAtGenerazione', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy>
      thenByObiettivoAtGenerazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivoAtGenerazione', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByObsoleto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obsoleto', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByObsoletoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obsoleto', Sort.desc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByProteineTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteineTotali', Sort.asc);
    });
  }

  QueryBuilder<MealPlan, MealPlan, QAfterSortBy> thenByProteineTotaliDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteineTotali', Sort.desc);
    });
  }
}

extension MealPlanQueryWhereDistinct
    on QueryBuilder<MealPlan, MealPlan, QDistinct> {
  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByCarbsTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsTotali');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByDataCreazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataCreazione');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByGrassiTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grassiTotali');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByKcalTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalTotali');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByLivelloAtGenerazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'livelloAtGenerazione');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct>
      distinctByObiettivoAtGenerazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'obiettivoAtGenerazione');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByObsoleto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'obsoleto');
    });
  }

  QueryBuilder<MealPlan, MealPlan, QDistinct> distinctByProteineTotali() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteineTotali');
    });
  }
}

extension MealPlanQueryProperty
    on QueryBuilder<MealPlan, MealPlan, QQueryProperty> {
  QueryBuilder<MealPlan, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> carbsTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsTotali');
    });
  }

  QueryBuilder<MealPlan, DateTime, QQueryOperations> dataCreazioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataCreazione');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> grassiTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grassiTotali');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> kcalTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalTotali');
    });
  }

  QueryBuilder<MealPlan, int, QQueryOperations> livelloAtGenerazioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'livelloAtGenerazione');
    });
  }

  QueryBuilder<MealPlan, int, QQueryOperations>
      obiettivoAtGenerazioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'obiettivoAtGenerazione');
    });
  }

  QueryBuilder<MealPlan, bool, QQueryOperations> obsoletoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'obsoleto');
    });
  }

  QueryBuilder<MealPlan, List<PlanMeal>, QQueryOperations> pastiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pasti');
    });
  }

  QueryBuilder<MealPlan, double, QQueryOperations> proteineTotaliProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteineTotali');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlanFoodSchema = Schema(
  name: r'PlanFood',
  id: 7145332733269608018,
  properties: {
    r'carboidrati': PropertySchema(
      id: 0,
      name: r'carboidrati',
      type: IsarType.double,
    ),
    r'foodItemId': PropertySchema(
      id: 1,
      name: r'foodItemId',
      type: IsarType.long,
    ),
    r'grassi': PropertySchema(
      id: 2,
      name: r'grassi',
      type: IsarType.double,
    ),
    r'kcal': PropertySchema(
      id: 3,
      name: r'kcal',
      type: IsarType.double,
    ),
    r'nome': PropertySchema(
      id: 4,
      name: r'nome',
      type: IsarType.string,
    ),
    r'proteine': PropertySchema(
      id: 5,
      name: r'proteine',
      type: IsarType.double,
    ),
    r'quantitaG': PropertySchema(
      id: 6,
      name: r'quantitaG',
      type: IsarType.double,
    )
  },
  estimateSize: _planFoodEstimateSize,
  serialize: _planFoodSerialize,
  deserialize: _planFoodDeserialize,
  deserializeProp: _planFoodDeserializeProp,
);

int _planFoodEstimateSize(
  PlanFood object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nome.length * 3;
  return bytesCount;
}

void _planFoodSerialize(
  PlanFood object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.carboidrati);
  writer.writeLong(offsets[1], object.foodItemId);
  writer.writeDouble(offsets[2], object.grassi);
  writer.writeDouble(offsets[3], object.kcal);
  writer.writeString(offsets[4], object.nome);
  writer.writeDouble(offsets[5], object.proteine);
  writer.writeDouble(offsets[6], object.quantitaG);
}

PlanFood _planFoodDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanFood();
  object.carboidrati = reader.readDouble(offsets[0]);
  object.foodItemId = reader.readLong(offsets[1]);
  object.grassi = reader.readDouble(offsets[2]);
  object.kcal = reader.readDouble(offsets[3]);
  object.nome = reader.readString(offsets[4]);
  object.proteine = reader.readDouble(offsets[5]);
  object.quantitaG = reader.readDouble(offsets[6]);
  return object;
}

P _planFoodDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlanFoodQueryFilter
    on QueryBuilder<PlanFood, PlanFood, QFilterCondition> {
  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> carboidratiEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carboidrati',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition>
      carboidratiGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carboidrati',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> carboidratiLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carboidrati',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> carboidratiBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carboidrati',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> foodItemIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodItemId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> foodItemIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodItemId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> foodItemIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodItemId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> foodItemIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodItemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> grassiEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grassi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> grassiGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grassi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> grassiLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grassi',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> grassiBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grassi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> kcalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> kcalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> kcalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> kcalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> proteineEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteine',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> proteineGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteine',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> proteineLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteine',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> proteineBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteine',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> quantitaGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantitaG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> quantitaGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantitaG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> quantitaGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantitaG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlanFood, PlanFood, QAfterFilterCondition> quantitaGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantitaG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension PlanFoodQueryObject
    on QueryBuilder<PlanFood, PlanFood, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlanSlotSchema = Schema(
  name: r'PlanSlot',
  id: 4531425431995605813,
  properties: {
    r'alternative': PropertySchema(
      id: 0,
      name: r'alternative',
      type: IsarType.objectList,
      target: r'PlanFood',
    ),
    r'principale': PropertySchema(
      id: 1,
      name: r'principale',
      type: IsarType.object,
      target: r'PlanFood',
    ),
    r'tipo': PropertySchema(
      id: 2,
      name: r'tipo',
      type: IsarType.long,
    )
  },
  estimateSize: _planSlotEstimateSize,
  serialize: _planSlotSerialize,
  deserialize: _planSlotDeserialize,
  deserializeProp: _planSlotDeserializeProp,
);

int _planSlotEstimateSize(
  PlanSlot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.alternative.length * 3;
  {
    final offsets = allOffsets[PlanFood]!;
    for (var i = 0; i < object.alternative.length; i++) {
      final value = object.alternative[i];
      bytesCount += PlanFoodSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.principale;
    if (value != null) {
      bytesCount += 3 +
          PlanFoodSchema.estimateSize(value, allOffsets[PlanFood]!, allOffsets);
    }
  }
  return bytesCount;
}

void _planSlotSerialize(
  PlanSlot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<PlanFood>(
    offsets[0],
    allOffsets,
    PlanFoodSchema.serialize,
    object.alternative,
  );
  writer.writeObject<PlanFood>(
    offsets[1],
    allOffsets,
    PlanFoodSchema.serialize,
    object.principale,
  );
  writer.writeLong(offsets[2], object.tipo);
}

PlanSlot _planSlotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanSlot();
  object.alternative = reader.readObjectList<PlanFood>(
        offsets[0],
        PlanFoodSchema.deserialize,
        allOffsets,
        PlanFood(),
      ) ??
      [];
  object.principale = reader.readObjectOrNull<PlanFood>(
    offsets[1],
    PlanFoodSchema.deserialize,
    allOffsets,
  );
  object.tipo = reader.readLong(offsets[2]);
  return object;
}

P _planSlotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<PlanFood>(
            offset,
            PlanFoodSchema.deserialize,
            allOffsets,
            PlanFood(),
          ) ??
          []) as P;
    case 1:
      return (reader.readObjectOrNull<PlanFood>(
        offset,
        PlanFoodSchema.deserialize,
        allOffsets,
      )) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlanSlotQueryFilter
    on QueryBuilder<PlanSlot, PlanSlot, QFilterCondition> {
  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition>
      alternativeLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alternative',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> alternativeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alternative',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition>
      alternativeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alternative',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition>
      alternativeLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alternative',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition>
      alternativeLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alternative',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition>
      alternativeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'alternative',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> principaleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'principale',
      ));
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition>
      principaleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'principale',
      ));
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> tipoEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> tipoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> tipoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> tipoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlanSlotQueryObject
    on QueryBuilder<PlanSlot, PlanSlot, QFilterCondition> {
  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> alternativeElement(
      FilterQuery<PlanFood> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'alternative');
    });
  }

  QueryBuilder<PlanSlot, PlanSlot, QAfterFilterCondition> principale(
      FilterQuery<PlanFood> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'principale');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlanMealSchema = Schema(
  name: r'PlanMeal',
  id: 947294684589054925,
  properties: {
    r'slots': PropertySchema(
      id: 0,
      name: r'slots',
      type: IsarType.objectList,
      target: r'PlanSlot',
    ),
    r'tipo': PropertySchema(
      id: 1,
      name: r'tipo',
      type: IsarType.long,
    )
  },
  estimateSize: _planMealEstimateSize,
  serialize: _planMealSerialize,
  deserialize: _planMealDeserialize,
  deserializeProp: _planMealDeserializeProp,
);

int _planMealEstimateSize(
  PlanMeal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.slots.length * 3;
  {
    final offsets = allOffsets[PlanSlot]!;
    for (var i = 0; i < object.slots.length; i++) {
      final value = object.slots[i];
      bytesCount += PlanSlotSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _planMealSerialize(
  PlanMeal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<PlanSlot>(
    offsets[0],
    allOffsets,
    PlanSlotSchema.serialize,
    object.slots,
  );
  writer.writeLong(offsets[1], object.tipo);
}

PlanMeal _planMealDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlanMeal();
  object.slots = reader.readObjectList<PlanSlot>(
        offsets[0],
        PlanSlotSchema.deserialize,
        allOffsets,
        PlanSlot(),
      ) ??
      [];
  object.tipo = reader.readLong(offsets[1]);
  return object;
}

P _planMealDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<PlanSlot>(
            offset,
            PlanSlotSchema.deserialize,
            allOffsets,
            PlanSlot(),
          ) ??
          []) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlanMealQueryFilter
    on QueryBuilder<PlanMeal, PlanMeal, QFilterCondition> {
  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> slotsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> slotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> slotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> slotsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition>
      slotsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> slotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'slots',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> tipoEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> tipoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> tipoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipo',
        value: value,
      ));
    });
  }

  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> tipoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlanMealQueryObject
    on QueryBuilder<PlanMeal, PlanMeal, QFilterCondition> {
  QueryBuilder<PlanMeal, PlanMeal, QAfterFilterCondition> slotsElement(
      FilterQuery<PlanSlot> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'slots');
    });
  }
}
