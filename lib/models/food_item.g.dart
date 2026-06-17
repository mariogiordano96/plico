// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFoodItemCollection on Isar {
  IsarCollection<FoodItem> get foodItems => this.collection();
}

const FoodItemSchema = CollectionSchema(
  name: r'FoodItem',
  id: 8311037358550475404,
  properties: {
    r'brand': PropertySchema(
      id: 0,
      name: r'brand',
      type: IsarType.string,
    ),
    r'carbsPer100g': PropertySchema(
      id: 1,
      name: r'carbsPer100g',
      type: IsarType.double,
    ),
    r'categoria': PropertySchema(
      id: 2,
      name: r'categoria',
      type: IsarType.string,
    ),
    r'creaCode': PropertySchema(
      id: 3,
      name: r'creaCode',
      type: IsarType.string,
    ),
    r'fatPer100g': PropertySchema(
      id: 4,
      name: r'fatPer100g',
      type: IsarType.double,
    ),
    r'imageUrl': PropertySchema(
      id: 5,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'isCustom': PropertySchema(
      id: 6,
      name: r'isCustom',
      type: IsarType.bool,
    ),
    r'isFavorite': PropertySchema(
      id: 7,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'kcalPer100g': PropertySchema(
      id: 8,
      name: r'kcalPer100g',
      type: IsarType.double,
    ),
    r'lastUsedAt': PropertySchema(
      id: 9,
      name: r'lastUsedAt',
      type: IsarType.dateTime,
    ),
    r'nome': PropertySchema(
      id: 10,
      name: r'nome',
      type: IsarType.string,
    ),
    r'nomeInglese': PropertySchema(
      id: 11,
      name: r'nomeInglese',
      type: IsarType.string,
    ),
    r'nutrizione': PropertySchema(
      id: 12,
      name: r'nutrizione',
      type: IsarType.object,
      target: r'NutrizioneCompleta',
    ),
    r'offCode': PropertySchema(
      id: 13,
      name: r'offCode',
      type: IsarType.string,
    ),
    r'parteCommestibile': PropertySchema(
      id: 14,
      name: r'parteCommestibile',
      type: IsarType.double,
    ),
    r'porzione': PropertySchema(
      id: 15,
      name: r'porzione',
      type: IsarType.double,
    ),
    r'proteinPer100g': PropertySchema(
      id: 16,
      name: r'proteinPer100g',
      type: IsarType.double,
    )
  },
  estimateSize: _foodItemEstimateSize,
  serialize: _foodItemSerialize,
  deserialize: _foodItemDeserialize,
  deserializeProp: _foodItemDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'NutrizioneCompleta': NutrizioneCompletaSchema},
  getId: _foodItemGetId,
  getLinks: _foodItemGetLinks,
  attach: _foodItemAttach,
  version: '3.1.0+1',
);

int _foodItemEstimateSize(
  FoodItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.brand;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.categoria;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.creaCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nome.length * 3;
  {
    final value = object.nomeInglese;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nutrizione;
    if (value != null) {
      bytesCount += 3 +
          NutrizioneCompletaSchema.estimateSize(
              value, allOffsets[NutrizioneCompleta]!, allOffsets);
    }
  }
  {
    final value = object.offCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _foodItemSerialize(
  FoodItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.brand);
  writer.writeDouble(offsets[1], object.carbsPer100g);
  writer.writeString(offsets[2], object.categoria);
  writer.writeString(offsets[3], object.creaCode);
  writer.writeDouble(offsets[4], object.fatPer100g);
  writer.writeString(offsets[5], object.imageUrl);
  writer.writeBool(offsets[6], object.isCustom);
  writer.writeBool(offsets[7], object.isFavorite);
  writer.writeDouble(offsets[8], object.kcalPer100g);
  writer.writeDateTime(offsets[9], object.lastUsedAt);
  writer.writeString(offsets[10], object.nome);
  writer.writeString(offsets[11], object.nomeInglese);
  writer.writeObject<NutrizioneCompleta>(
    offsets[12],
    allOffsets,
    NutrizioneCompletaSchema.serialize,
    object.nutrizione,
  );
  writer.writeString(offsets[13], object.offCode);
  writer.writeDouble(offsets[14], object.parteCommestibile);
  writer.writeDouble(offsets[15], object.porzione);
  writer.writeDouble(offsets[16], object.proteinPer100g);
}

FoodItem _foodItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FoodItem();
  object.brand = reader.readStringOrNull(offsets[0]);
  object.carbsPer100g = reader.readDouble(offsets[1]);
  object.categoria = reader.readStringOrNull(offsets[2]);
  object.creaCode = reader.readStringOrNull(offsets[3]);
  object.fatPer100g = reader.readDouble(offsets[4]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[5]);
  object.isCustom = reader.readBool(offsets[6]);
  object.isFavorite = reader.readBool(offsets[7]);
  object.kcalPer100g = reader.readDouble(offsets[8]);
  object.lastUsedAt = reader.readDateTimeOrNull(offsets[9]);
  object.nome = reader.readString(offsets[10]);
  object.nomeInglese = reader.readStringOrNull(offsets[11]);
  object.nutrizione = reader.readObjectOrNull<NutrizioneCompleta>(
    offsets[12],
    NutrizioneCompletaSchema.deserialize,
    allOffsets,
  );
  object.offCode = reader.readStringOrNull(offsets[13]);
  object.parteCommestibile = reader.readDoubleOrNull(offsets[14]);
  object.porzione = reader.readDoubleOrNull(offsets[15]);
  object.proteinPer100g = reader.readDouble(offsets[16]);
  return object;
}

P _foodItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readObjectOrNull<NutrizioneCompleta>(
        offset,
        NutrizioneCompletaSchema.deserialize,
        allOffsets,
      )) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readDoubleOrNull(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _foodItemGetId(FoodItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _foodItemGetLinks(FoodItem object) {
  return [];
}

void _foodItemAttach(IsarCollection<dynamic> col, Id id, FoodItem object) {
  object.id = id;
}

extension FoodItemQueryWhereSort on QueryBuilder<FoodItem, FoodItem, QWhere> {
  QueryBuilder<FoodItem, FoodItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FoodItemQueryWhere on QueryBuilder<FoodItem, FoodItem, QWhereClause> {
  QueryBuilder<FoodItem, FoodItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<FoodItem, FoodItem, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterWhereClause> idBetween(
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

extension FoodItemQueryFilter
    on QueryBuilder<FoodItem, FoodItem, QFilterCondition> {
  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'brand',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'brand',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'brand',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'brand',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'brand',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> brandIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'brand',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> carbsPer100gEqualTo(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> carbsPer100gLessThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> carbsPer100gBetween(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoria',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoria',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoria',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoria',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> categoriaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoria',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      categoriaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoria',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'creaCode',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'creaCode',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creaCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creaCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creaCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creaCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'creaCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'creaCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'creaCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'creaCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creaCode',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> creaCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'creaCode',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> fatPer100gEqualTo(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> fatPer100gGreaterThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> fatPer100gLessThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> fatPer100gBetween(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> isCustomEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCustom',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> isFavoriteEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> kcalPer100gEqualTo(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> kcalPer100gLessThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> kcalPer100gBetween(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> lastUsedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUsedAt',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      lastUsedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUsedAt',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> lastUsedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> lastUsedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> lastUsedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> lastUsedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeEqualTo(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeGreaterThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeLessThan(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeBetween(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeStartsWith(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeEndsWith(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeContains(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeMatches(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nome',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nomeInglese',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      nomeIngleseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nomeInglese',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeInglese',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      nomeIngleseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomeInglese',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomeInglese',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomeInglese',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomeInglese',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomeInglese',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomeInglese',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomeInglese',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nomeIngleseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeInglese',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      nomeIngleseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomeInglese',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nutrizioneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nutrizione',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      nutrizioneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nutrizione',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'offCode',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'offCode',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'offCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'offCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'offCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'offCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'offCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'offCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'offCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offCode',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> offCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'offCode',
        value: '',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      parteCommestibileIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parteCommestibile',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      parteCommestibileIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parteCommestibile',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      parteCommestibileEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parteCommestibile',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      parteCommestibileGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parteCommestibile',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      parteCommestibileLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parteCommestibile',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
      parteCommestibileBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parteCommestibile',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> porzioneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'porzione',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> porzioneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'porzione',
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> porzioneEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'porzione',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> porzioneGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'porzione',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> porzioneLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'porzione',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> porzioneBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'porzione',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> proteinPer100gEqualTo(
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition>
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

  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> proteinPer100gBetween(
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
}

extension FoodItemQueryObject
    on QueryBuilder<FoodItem, FoodItem, QFilterCondition> {
  QueryBuilder<FoodItem, FoodItem, QAfterFilterCondition> nutrizione(
      FilterQuery<NutrizioneCompleta> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'nutrizione');
    });
  }
}

extension FoodItemQueryLinks
    on QueryBuilder<FoodItem, FoodItem, QFilterCondition> {}

extension FoodItemQuerySortBy on QueryBuilder<FoodItem, FoodItem, QSortBy> {
  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByCarbsPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByCarbsPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPer100g', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByCategoria() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByCategoriaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByCreaCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaCode', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByCreaCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaCode', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByFatPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByFatPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPer100g', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByIsCustom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByIsCustomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByKcalPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByKcalPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPer100g', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByNomeInglese() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeInglese', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByNomeIngleseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeInglese', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByOffCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offCode', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByOffCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offCode', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByParteCommestibile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parteCommestibile', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByParteCommestibileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parteCommestibile', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByPorzione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'porzione', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByPorzioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'porzione', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByProteinPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> sortByProteinPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPer100g', Sort.desc);
    });
  }
}

extension FoodItemQuerySortThenBy
    on QueryBuilder<FoodItem, FoodItem, QSortThenBy> {
  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByBrand() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByBrandDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'brand', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByCarbsPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByCarbsPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPer100g', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByCategoria() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByCategoriaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoria', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByCreaCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaCode', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByCreaCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaCode', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByFatPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByFatPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPer100g', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByIsCustom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByIsCustomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustom', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByKcalPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByKcalPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kcalPer100g', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nome', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByNomeInglese() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeInglese', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByNomeIngleseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeInglese', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByOffCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offCode', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByOffCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'offCode', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByParteCommestibile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parteCommestibile', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByParteCommestibileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parteCommestibile', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByPorzione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'porzione', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByPorzioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'porzione', Sort.desc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByProteinPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPer100g', Sort.asc);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QAfterSortBy> thenByProteinPer100gDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPer100g', Sort.desc);
    });
  }
}

extension FoodItemQueryWhereDistinct
    on QueryBuilder<FoodItem, FoodItem, QDistinct> {
  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByBrand(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'brand', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByCarbsPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsPer100g');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByCategoria(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoria', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByCreaCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creaCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByFatPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatPer100g');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByIsCustom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCustom');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByKcalPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kcalPer100g');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsedAt');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByNome(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByNomeInglese(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomeInglese', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByOffCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'offCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByParteCommestibile() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parteCommestibile');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByPorzione() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'porzione');
    });
  }

  QueryBuilder<FoodItem, FoodItem, QDistinct> distinctByProteinPer100g() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinPer100g');
    });
  }
}

extension FoodItemQueryProperty
    on QueryBuilder<FoodItem, FoodItem, QQueryProperty> {
  QueryBuilder<FoodItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FoodItem, String?, QQueryOperations> brandProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'brand');
    });
  }

  QueryBuilder<FoodItem, double, QQueryOperations> carbsPer100gProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsPer100g');
    });
  }

  QueryBuilder<FoodItem, String?, QQueryOperations> categoriaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoria');
    });
  }

  QueryBuilder<FoodItem, String?, QQueryOperations> creaCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creaCode');
    });
  }

  QueryBuilder<FoodItem, double, QQueryOperations> fatPer100gProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatPer100g');
    });
  }

  QueryBuilder<FoodItem, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<FoodItem, bool, QQueryOperations> isCustomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCustom');
    });
  }

  QueryBuilder<FoodItem, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<FoodItem, double, QQueryOperations> kcalPer100gProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kcalPer100g');
    });
  }

  QueryBuilder<FoodItem, DateTime?, QQueryOperations> lastUsedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsedAt');
    });
  }

  QueryBuilder<FoodItem, String, QQueryOperations> nomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nome');
    });
  }

  QueryBuilder<FoodItem, String?, QQueryOperations> nomeIngleseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomeInglese');
    });
  }

  QueryBuilder<FoodItem, NutrizioneCompleta?, QQueryOperations>
      nutrizioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nutrizione');
    });
  }

  QueryBuilder<FoodItem, String?, QQueryOperations> offCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'offCode');
    });
  }

  QueryBuilder<FoodItem, double?, QQueryOperations>
      parteCommestibileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parteCommestibile');
    });
  }

  QueryBuilder<FoodItem, double?, QQueryOperations> porzioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'porzione');
    });
  }

  QueryBuilder<FoodItem, double, QQueryOperations> proteinPer100gProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinPer100g');
    });
  }
}
