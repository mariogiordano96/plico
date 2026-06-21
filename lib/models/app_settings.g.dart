// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsCollection on Isar {
  IsarCollection<AppSettings> get appSettings => this.collection();
}

const AppSettingsSchema = CollectionSchema(
  name: r'AppSettings',
  id: -5633561779022347008,
  properties: {
    r'creaSeeded': PropertySchema(
      id: 0,
      name: r'creaSeeded',
      type: IsarType.bool,
    ),
    r'exercisesSeeded': PropertySchema(
      id: 1,
      name: r'exercisesSeeded',
      type: IsarType.bool,
    ),
    r'goalSetDate': PropertySchema(
      id: 2,
      name: r'goalSetDate',
      type: IsarType.dateTime,
    ),
    r'isDarkMode': PropertySchema(
      id: 3,
      name: r'isDarkMode',
      type: IsarType.bool,
    ),
    r'livelloAttivita': PropertySchema(
      id: 4,
      name: r'livelloAttivita',
      type: IsarType.long,
    ),
    r'metodoTdee': PropertySchema(
      id: 5,
      name: r'metodoTdee',
      type: IsarType.long,
    ),
    r'notCenaAttiva': PropertySchema(
      id: 6,
      name: r'notCenaAttiva',
      type: IsarType.bool,
    ),
    r'notCenaMin': PropertySchema(
      id: 7,
      name: r'notCenaMin',
      type: IsarType.long,
    ),
    r'notColAttiva': PropertySchema(
      id: 8,
      name: r'notColAttiva',
      type: IsarType.bool,
    ),
    r'notColMin': PropertySchema(
      id: 9,
      name: r'notColMin',
      type: IsarType.long,
    ),
    r'notPostWoAttiva': PropertySchema(
      id: 10,
      name: r'notPostWoAttiva',
      type: IsarType.bool,
    ),
    r'notPostWoMin': PropertySchema(
      id: 11,
      name: r'notPostWoMin',
      type: IsarType.long,
    ),
    r'notPranzoAttiva': PropertySchema(
      id: 12,
      name: r'notPranzoAttiva',
      type: IsarType.bool,
    ),
    r'notPranzoMin': PropertySchema(
      id: 13,
      name: r'notPranzoMin',
      type: IsarType.long,
    ),
    r'notSorAttiva': PropertySchema(
      id: 14,
      name: r'notSorAttiva',
      type: IsarType.bool,
    ),
    r'notSorMin': PropertySchema(
      id: 15,
      name: r'notSorMin',
      type: IsarType.long,
    ),
    r'notSpuntinoAttiva': PropertySchema(
      id: 16,
      name: r'notSpuntinoAttiva',
      type: IsarType.bool,
    ),
    r'notSpuntinoMin': PropertySchema(
      id: 17,
      name: r'notSpuntinoMin',
      type: IsarType.long,
    ),
    r'notificheAttive': PropertySchema(
      id: 18,
      name: r'notificheAttive',
      type: IsarType.bool,
    ),
    r'obiettivo': PropertySchema(
      id: 19,
      name: r'obiettivo',
      type: IsarType.long,
    ),
    r'pesoObiettivo': PropertySchema(
      id: 20,
      name: r'pesoObiettivo',
      type: IsarType.double,
    ),
    r'tourCompleted': PropertySchema(
      id: 21,
      name: r'tourCompleted',
      type: IsarType.bool,
    ),
    r'workoutPresetsSeeded': PropertySchema(
      id: 22,
      name: r'workoutPresetsSeeded',
      type: IsarType.bool,
    )
  },
  estimateSize: _appSettingsEstimateSize,
  serialize: _appSettingsSerialize,
  deserialize: _appSettingsDeserialize,
  deserializeProp: _appSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsGetId,
  getLinks: _appSettingsGetLinks,
  attach: _appSettingsAttach,
  version: '3.1.0+1',
);

int _appSettingsEstimateSize(
  AppSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _appSettingsSerialize(
  AppSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.creaSeeded);
  writer.writeBool(offsets[1], object.exercisesSeeded);
  writer.writeDateTime(offsets[2], object.goalSetDate);
  writer.writeBool(offsets[3], object.isDarkMode);
  writer.writeLong(offsets[4], object.livelloAttivita);
  writer.writeLong(offsets[5], object.metodoTdee);
  writer.writeBool(offsets[6], object.notCenaAttiva);
  writer.writeLong(offsets[7], object.notCenaMin);
  writer.writeBool(offsets[8], object.notColAttiva);
  writer.writeLong(offsets[9], object.notColMin);
  writer.writeBool(offsets[10], object.notPostWoAttiva);
  writer.writeLong(offsets[11], object.notPostWoMin);
  writer.writeBool(offsets[12], object.notPranzoAttiva);
  writer.writeLong(offsets[13], object.notPranzoMin);
  writer.writeBool(offsets[14], object.notSorAttiva);
  writer.writeLong(offsets[15], object.notSorMin);
  writer.writeBool(offsets[16], object.notSpuntinoAttiva);
  writer.writeLong(offsets[17], object.notSpuntinoMin);
  writer.writeBool(offsets[18], object.notificheAttive);
  writer.writeLong(offsets[19], object.obiettivo);
  writer.writeDouble(offsets[20], object.pesoObiettivo);
  writer.writeBool(offsets[21], object.tourCompleted);
  writer.writeBool(offsets[22], object.workoutPresetsSeeded);
}

AppSettings _appSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettings();
  object.creaSeeded = reader.readBool(offsets[0]);
  object.exercisesSeeded = reader.readBool(offsets[1]);
  object.goalSetDate = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.isDarkMode = reader.readBool(offsets[3]);
  object.livelloAttivita = reader.readLong(offsets[4]);
  object.metodoTdee = reader.readLong(offsets[5]);
  object.notCenaAttiva = reader.readBool(offsets[6]);
  object.notCenaMin = reader.readLong(offsets[7]);
  object.notColAttiva = reader.readBool(offsets[8]);
  object.notColMin = reader.readLong(offsets[9]);
  object.notPostWoAttiva = reader.readBool(offsets[10]);
  object.notPostWoMin = reader.readLong(offsets[11]);
  object.notPranzoAttiva = reader.readBool(offsets[12]);
  object.notPranzoMin = reader.readLong(offsets[13]);
  object.notSorAttiva = reader.readBool(offsets[14]);
  object.notSorMin = reader.readLong(offsets[15]);
  object.notSpuntinoAttiva = reader.readBool(offsets[16]);
  object.notSpuntinoMin = reader.readLong(offsets[17]);
  object.notificheAttive = reader.readBool(offsets[18]);
  object.obiettivo = reader.readLong(offsets[19]);
  object.pesoObiettivo = reader.readDoubleOrNull(offsets[20]);
  object.tourCompleted = reader.readBool(offsets[21]);
  object.workoutPresetsSeeded = reader.readBool(offsets[22]);
  return object;
}

P _appSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readDoubleOrNull(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsGetId(AppSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsGetLinks(AppSettings object) {
  return [];
}

void _appSettingsAttach(
    IsarCollection<dynamic> col, Id id, AppSettings object) {
  object.id = id;
}

extension AppSettingsQueryWhereSort
    on QueryBuilder<AppSettings, AppSettings, QWhere> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsQueryWhere
    on QueryBuilder<AppSettings, AppSettings, QWhereClause> {
  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterWhereClause> idBetween(
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

extension AppSettingsQueryFilter
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {
  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      creaSeededEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creaSeeded',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      exercisesSeededEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exercisesSeeded',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      goalSetDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalSetDate',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      goalSetDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalSetDate',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      goalSetDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalSetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      goalSetDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalSetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      goalSetDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalSetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      goalSetDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalSetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      isDarkModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDarkMode',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      livelloAttivitaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'livelloAttivita',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      livelloAttivitaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'livelloAttivita',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      livelloAttivitaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'livelloAttivita',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      livelloAttivitaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'livelloAttivita',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      metodoTdeeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoTdee',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      metodoTdeeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodoTdee',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      metodoTdeeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodoTdee',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      metodoTdeeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodoTdee',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notCenaAttivaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notCenaAttiva',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notCenaMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notCenaMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notCenaMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notCenaMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notCenaMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notCenaMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notCenaMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notCenaMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notColAttivaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notColAttiva',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notColMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notColMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notColMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notColMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notColMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notColMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notColMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notColMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPostWoAttivaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notPostWoAttiva',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPostWoMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notPostWoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPostWoMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notPostWoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPostWoMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notPostWoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPostWoMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notPostWoMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPranzoAttivaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notPranzoAttiva',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPranzoMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notPranzoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPranzoMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notPranzoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPranzoMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notPranzoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notPranzoMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notPranzoMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSorAttivaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notSorAttiva',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSorMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notSorMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSorMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notSorMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSorMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notSorMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSorMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notSorMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSpuntinoAttivaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notSpuntinoAttiva',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSpuntinoMinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notSpuntinoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSpuntinoMinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notSpuntinoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSpuntinoMinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notSpuntinoMin',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notSpuntinoMinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notSpuntinoMin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      notificheAttiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificheAttive',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      obiettivoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'obiettivo',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      obiettivoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'obiettivo',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      obiettivoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'obiettivo',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      obiettivoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'obiettivo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      pesoObiettivoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pesoObiettivo',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      pesoObiettivoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pesoObiettivo',
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      pesoObiettivoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pesoObiettivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      pesoObiettivoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pesoObiettivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      pesoObiettivoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pesoObiettivo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      pesoObiettivoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pesoObiettivo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      tourCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tourCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterFilterCondition>
      workoutPresetsSeededEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'workoutPresetsSeeded',
        value: value,
      ));
    });
  }
}

extension AppSettingsQueryObject
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQueryLinks
    on QueryBuilder<AppSettings, AppSettings, QFilterCondition> {}

extension AppSettingsQuerySortBy
    on QueryBuilder<AppSettings, AppSettings, QSortBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByCreaSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByCreaSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaSeeded', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByExercisesSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercisesSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByExercisesSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercisesSeeded', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByGoalSetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSetDate', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByGoalSetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSetDate', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByLivelloAttivita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAttivita', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByLivelloAttivitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAttivita', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByMetodoTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoTdee', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByMetodoTdeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoTdee', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotCenaAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotCenaAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotCenaMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotCenaMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotColAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotColAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotColMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotColMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotPostWoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotPostWoAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotPostWoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotPostWoMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotPranzoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotPranzoAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotPranzoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotPranzoMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotSorAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotSorAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotSorMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotSorMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotSpuntinoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotSpuntinoAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotSpuntinoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotSpuntinoMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByNotificheAttive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificheAttive', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByNotificheAttiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificheAttive', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByObiettivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivo', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByObiettivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivo', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByPesoObiettivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoObiettivo', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByPesoObiettivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoObiettivo', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> sortByTourCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tourCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByTourCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tourCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByWorkoutPresetsSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutPresetsSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      sortByWorkoutPresetsSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutPresetsSeeded', Sort.desc);
    });
  }
}

extension AppSettingsQuerySortThenBy
    on QueryBuilder<AppSettings, AppSettings, QSortThenBy> {
  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByCreaSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByCreaSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creaSeeded', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByExercisesSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercisesSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByExercisesSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exercisesSeeded', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByGoalSetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSetDate', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByGoalSetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalSetDate', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByLivelloAttivita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAttivita', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByLivelloAttivitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'livelloAttivita', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByMetodoTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoTdee', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByMetodoTdeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoTdee', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotCenaAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotCenaAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotCenaMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotCenaMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notCenaMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotColAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotColAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotColMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotColMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notColMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotPostWoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotPostWoAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotPostWoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotPostWoMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPostWoMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotPranzoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotPranzoAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotPranzoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotPranzoMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notPranzoMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotSorAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotSorAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotSorMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotSorMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSorMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotSpuntinoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoAttiva', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotSpuntinoAttivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoAttiva', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotSpuntinoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoMin', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotSpuntinoMinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notSpuntinoMin', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByNotificheAttive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificheAttive', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByNotificheAttiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificheAttive', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByObiettivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivo', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByObiettivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'obiettivo', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByPesoObiettivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoObiettivo', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByPesoObiettivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pesoObiettivo', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy> thenByTourCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tourCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByTourCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tourCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByWorkoutPresetsSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutPresetsSeeded', Sort.asc);
    });
  }

  QueryBuilder<AppSettings, AppSettings, QAfterSortBy>
      thenByWorkoutPresetsSeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'workoutPresetsSeeded', Sort.desc);
    });
  }
}

extension AppSettingsQueryWhereDistinct
    on QueryBuilder<AppSettings, AppSettings, QDistinct> {
  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByCreaSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creaSeeded');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByExercisesSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exercisesSeeded');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByGoalSetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalSetDate');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDarkMode');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByLivelloAttivita() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'livelloAttivita');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByMetodoTdee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodoTdee');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotCenaAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notCenaAttiva');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotCenaMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notCenaMin');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotColAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notColAttiva');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotColMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notColMin');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByNotPostWoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notPostWoAttiva');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotPostWoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notPostWoMin');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByNotPranzoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notPranzoAttiva');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotPranzoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notPranzoMin');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotSorAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notSorAttiva');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotSorMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notSorMin');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByNotSpuntinoAttiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notSpuntinoAttiva');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByNotSpuntinoMin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notSpuntinoMin');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByNotificheAttive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificheAttive');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByObiettivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'obiettivo');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByPesoObiettivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pesoObiettivo');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct> distinctByTourCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tourCompleted');
    });
  }

  QueryBuilder<AppSettings, AppSettings, QDistinct>
      distinctByWorkoutPresetsSeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'workoutPresetsSeeded');
    });
  }
}

extension AppSettingsQueryProperty
    on QueryBuilder<AppSettings, AppSettings, QQueryProperty> {
  QueryBuilder<AppSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> creaSeededProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creaSeeded');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> exercisesSeededProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exercisesSeeded');
    });
  }

  QueryBuilder<AppSettings, DateTime?, QQueryOperations> goalSetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalSetDate');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> isDarkModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDarkMode');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> livelloAttivitaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'livelloAttivita');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> metodoTdeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodoTdee');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> notCenaAttivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notCenaAttiva');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> notCenaMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notCenaMin');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> notColAttivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notColAttiva');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> notColMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notColMin');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> notPostWoAttivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notPostWoAttiva');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> notPostWoMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notPostWoMin');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> notPranzoAttivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notPranzoAttiva');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> notPranzoMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notPranzoMin');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> notSorAttivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notSorAttiva');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> notSorMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notSorMin');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      notSpuntinoAttivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notSpuntinoAttiva');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> notSpuntinoMinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notSpuntinoMin');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> notificheAttiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificheAttive');
    });
  }

  QueryBuilder<AppSettings, int, QQueryOperations> obiettivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'obiettivo');
    });
  }

  QueryBuilder<AppSettings, double?, QQueryOperations> pesoObiettivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pesoObiettivo');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations> tourCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tourCompleted');
    });
  }

  QueryBuilder<AppSettings, bool, QQueryOperations>
      workoutPresetsSeededProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'workoutPresetsSeeded');
    });
  }
}
