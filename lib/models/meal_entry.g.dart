// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MealEntrySchema = Schema(
  name: r'MealEntry',
  id: 2136597722614945685,
  properties: {
    r'carbsG': PropertySchema(
      id: 0,
      name: r'carbsG',
      type: IsarType.double,
    ),
    r'carbsPer100g': PropertySchema(
      id: 1,
      name: r'carbsPer100g',
      type: IsarType.double,
    ),
    r'fatG': PropertySchema(
      id: 2,
      name: r'fatG',
      type: IsarType.double,
    ),
    r'fatPer100g': PropertySchema(
      id: 3,
      name: r'fatPer100g',
      type: IsarType.double,
    ),
    r'foodBrand': PropertySchema(
      id: 4,
      name: r'foodBrand',
      type: IsarType.string,
    ),
    r'foodNome': PropertySchema(
      id: 5,
      name: r'foodNome',
      type: IsarType.string,
    ),
    r'kcal': PropertySchema(
      id: 6,
      name: r'kcal',
      type: IsarType.double,
    ),
    r'kcalPer100g': PropertySchema(
      id: 7,
      name: r'kcalPer100g',
      type: IsarType.double,
    ),
    r'pastoTipo': PropertySchema(
      id: 8,
      name: r'pastoTipo',
      type: IsarType.long,
    ),
    r'proteinG': PropertySchema(
      id: 9,
      name: r'proteinG',
      type: IsarType.double,
    ),
    r'proteinPer100g': PropertySchema(
      id: 10,
      name: r'proteinPer100g',
      type: IsarType.double,
    ),
    r'quantitaG': PropertySchema(
      id: 11,
      name: r'quantitaG',
      type: IsarType.double,
    )
  },
  estimateSize: _mealEntryEstimateSize,
  serialize: _mealEntrySerialize,
  deserialize: _mealEntryDeserialize,
  deserializeProp: _mealEntryDeserializeProp,
);

int _mealEntryEstimateSize(
  MealEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.foodBrand;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.foodNome.length * 3;
  return bytesCount;
}

void _mealEntrySerialize(
  MealEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.carbsG);
  writer.writeDouble(offsets[1], object.carbsPer100g);
  writer.writeDouble(offsets[2], object.fatG);
  writer.writeDouble(offsets[3], object.fatPer100g);
  writer.writeString(offsets[4], object.foodBrand);
  writer.writeString(offsets[5], object.foodNome);
  writer.writeDouble(offsets[6], object.kcal);
  writer.writeDouble(offsets[7], object.kcalPer100g);
  writer.writeLong(offsets[8], object.pastoTipo);
  writer.writeDouble(offsets[9], object.proteinG);
  writer.writeDouble(offsets[10], object.proteinPer100g);
  writer.writeDouble(offsets[11], object.quantitaG);
}

MealEntry _mealEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealEntry();
  object.carbsPer100g = reader.readDouble(offsets[1]);
  object.fatPer100g = reader.readDouble(offsets[3]);
  object.foodBrand = reader.readStringOrNull(offsets[4]);
  object.foodNome = reader.readString(offsets[5]);
  object.kcalPer100g = reader.readDouble(offsets[7]);
  object.pastoTipo = reader.readLong(offsets[8]);
  object.proteinPer100g = reader.readDouble(offsets[10]);
  object.quantitaG = reader.readDouble(offsets[11]);
  return object;
}

P _mealEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MealEntryQueryFilter
    on QueryBuilder<MealEntry, MealEntry, QFilterCondition> {
  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> carbsGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> carbsGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbsG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> carbsGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbsG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> carbsGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbsG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> carbsPer100gEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      carbsPer100gGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbsPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      carbsPer100gLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbsPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> carbsPer100gBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbsPer100g',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> fatGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> fatGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> fatGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> fatGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> fatPer100gEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      fatPer100gGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> fatPer100gLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> fatPer100gBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatPer100g',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'foodBrand',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      foodBrandIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'foodBrand',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      foodBrandGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodBrand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodBrand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodBrand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodBrandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodBrand',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      foodBrandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodBrand',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> foodNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodNome',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      foodNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodNome',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> kcalEqualTo(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> kcalGreaterThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> kcalLessThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> kcalBetween(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> kcalPer100gEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kcalPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      kcalPer100gGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kcalPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> kcalPer100gLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kcalPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> kcalPer100gBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kcalPer100g',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> pastoTipoEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pastoTipo',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      pastoTipoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pastoTipo',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> pastoTipoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pastoTipo',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> pastoTipoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pastoTipo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> proteinGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> proteinGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> proteinGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> proteinGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      proteinPer100gEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      proteinPer100gGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      proteinPer100gLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinPer100g',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      proteinPer100gBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinPer100g',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> quantitaGEqualTo(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      quantitaGGreaterThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> quantitaGLessThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> quantitaGBetween(
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

extension MealEntryQueryObject
    on QueryBuilder<MealEntry, MealEntry, QFilterCondition> {}
