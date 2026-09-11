// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutExerciseCollection on Isar {
  IsarCollection<WorkoutExercise> get workoutExercises => this.collection();
}

const WorkoutExerciseSchema = CollectionSchema(
  name: r'WorkoutExercise',
  id: 9115529306380274138,
  properties: {
    r'avgHeartRate': PropertySchema(
      id: 0,
      name: r'avgHeartRate',
      type: IsarType.double,
    ),
    r'cardioConfirmed': PropertySchema(
      id: 1,
      name: r'cardioConfirmed',
      type: IsarType.bool,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'durationSeconds': PropertySchema(
      id: 3,
      name: r'durationSeconds',
      type: IsarType.long,
    ),
    r'estimatedKcal': PropertySchema(
      id: 4,
      name: r'estimatedKcal',
      type: IsarType.long,
    ),
    r'exerciseId': PropertySchema(
      id: 5,
      name: r'exerciseId',
      type: IsarType.string,
    ),
    r'exerciseName': PropertySchema(
      id: 6,
      name: r'exerciseName',
      type: IsarType.string,
    ),
    r'importedIsStrength': PropertySchema(
      id: 7,
      name: r'importedIsStrength',
      type: IsarType.bool,
    ),
    r'isCardio': PropertySchema(
      id: 8,
      name: r'isCardio',
      type: IsarType.bool,
    ),
    r'met': PropertySchema(
      id: 9,
      name: r'met',
      type: IsarType.long,
    ),
    r'restSeconds': PropertySchema(
      id: 10,
      name: r'restSeconds',
      type: IsarType.long,
    ),
    r'sets': PropertySchema(
      id: 11,
      name: r'sets',
      type: IsarType.objectList,
      target: r'WorkoutSet',
    ),
    r'source': PropertySchema(
      id: 12,
      name: r'source',
      type: IsarType.string,
    ),
    r'sourceEndTime': PropertySchema(
      id: 13,
      name: r'sourceEndTime',
      type: IsarType.dateTime,
    ),
    r'sourceProgramId': PropertySchema(
      id: 14,
      name: r'sourceProgramId',
      type: IsarType.long,
    ),
    r'sourceProgramName': PropertySchema(
      id: 15,
      name: r'sourceProgramName',
      type: IsarType.string,
    ),
    r'sourceStartTime': PropertySchema(
      id: 16,
      name: r'sourceStartTime',
      type: IsarType.dateTime,
    ),
    r'sourceTemplateId': PropertySchema(
      id: 17,
      name: r'sourceTemplateId',
      type: IsarType.long,
    ),
    r'sourceTemplateName': PropertySchema(
      id: 18,
      name: r'sourceTemplateName',
      type: IsarType.string,
    ),
    r'supersetGroupId': PropertySchema(
      id: 19,
      name: r'supersetGroupId',
      type: IsarType.long,
    ),
    r'supersetRole': PropertySchema(
      id: 20,
      name: r'supersetRole',
      type: IsarType.string,
    )
  },
  estimateSize: _workoutExerciseEstimateSize,
  serialize: _workoutExerciseSerialize,
  deserialize: _workoutExerciseDeserialize,
  deserializeProp: _workoutExerciseDeserializeProp,
  idName: r'id',
  indexes: {
    r'exerciseId': IndexSchema(
      id: -5431545612219001672,
      name: r'exerciseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'exerciseId',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'WorkoutSet': WorkoutSetSchema,
    r'DropStage': DropStageSchema
  },
  getId: _workoutExerciseGetId,
  getLinks: _workoutExerciseGetLinks,
  attach: _workoutExerciseAttach,
  version: '3.1.0+1',
);

int _workoutExerciseEstimateSize(
  WorkoutExercise object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseId.length * 3;
  bytesCount += 3 + object.exerciseName.length * 3;
  bytesCount += 3 + object.sets.length * 3;
  {
    final offsets = allOffsets[WorkoutSet]!;
    for (var i = 0; i < object.sets.length; i++) {
      final value = object.sets[i];
      bytesCount += WorkoutSetSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.source;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceProgramName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceTemplateName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.supersetRole;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _workoutExerciseSerialize(
  WorkoutExercise object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.avgHeartRate);
  writer.writeBool(offsets[1], object.cardioConfirmed);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeLong(offsets[3], object.durationSeconds);
  writer.writeLong(offsets[4], object.estimatedKcal);
  writer.writeString(offsets[5], object.exerciseId);
  writer.writeString(offsets[6], object.exerciseName);
  writer.writeBool(offsets[7], object.importedIsStrength);
  writer.writeBool(offsets[8], object.isCardio);
  writer.writeLong(offsets[9], object.met);
  writer.writeLong(offsets[10], object.restSeconds);
  writer.writeObjectList<WorkoutSet>(
    offsets[11],
    allOffsets,
    WorkoutSetSchema.serialize,
    object.sets,
  );
  writer.writeString(offsets[12], object.source);
  writer.writeDateTime(offsets[13], object.sourceEndTime);
  writer.writeLong(offsets[14], object.sourceProgramId);
  writer.writeString(offsets[15], object.sourceProgramName);
  writer.writeDateTime(offsets[16], object.sourceStartTime);
  writer.writeLong(offsets[17], object.sourceTemplateId);
  writer.writeString(offsets[18], object.sourceTemplateName);
  writer.writeLong(offsets[19], object.supersetGroupId);
  writer.writeString(offsets[20], object.supersetRole);
}

WorkoutExercise _workoutExerciseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutExercise();
  object.avgHeartRate = reader.readDoubleOrNull(offsets[0]);
  object.cardioConfirmed = reader.readBool(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.durationSeconds = reader.readLongOrNull(offsets[3]);
  object.estimatedKcal = reader.readLongOrNull(offsets[4]);
  object.exerciseId = reader.readString(offsets[5]);
  object.exerciseName = reader.readString(offsets[6]);
  object.id = id;
  object.importedIsStrength = reader.readBool(offsets[7]);
  object.met = reader.readLongOrNull(offsets[9]);
  object.restSeconds = reader.readLongOrNull(offsets[10]);
  object.sets = reader.readObjectList<WorkoutSet>(
        offsets[11],
        WorkoutSetSchema.deserialize,
        allOffsets,
        WorkoutSet(),
      ) ??
      [];
  object.source = reader.readStringOrNull(offsets[12]);
  object.sourceEndTime = reader.readDateTimeOrNull(offsets[13]);
  object.sourceProgramId = reader.readLongOrNull(offsets[14]);
  object.sourceProgramName = reader.readStringOrNull(offsets[15]);
  object.sourceStartTime = reader.readDateTimeOrNull(offsets[16]);
  object.sourceTemplateId = reader.readLongOrNull(offsets[17]);
  object.sourceTemplateName = reader.readStringOrNull(offsets[18]);
  object.supersetGroupId = reader.readLongOrNull(offsets[19]);
  object.supersetRole = reader.readStringOrNull(offsets[20]);
  return object;
}

P _workoutExerciseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readObjectList<WorkoutSet>(
            offset,
            WorkoutSetSchema.deserialize,
            allOffsets,
            WorkoutSet(),
          ) ??
          []) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readLongOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutExerciseGetId(WorkoutExercise object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutExerciseGetLinks(WorkoutExercise object) {
  return [];
}

void _workoutExerciseAttach(
    IsarCollection<dynamic> col, Id id, WorkoutExercise object) {
  object.id = id;
}

extension WorkoutExerciseQueryWhereSort
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QWhere> {
  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhere> anyExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'exerciseId'),
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension WorkoutExerciseQueryWhere
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QWhereClause> {
  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
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

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause> idBetween(
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

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdEqualTo(String exerciseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'exerciseId',
        value: [exerciseId],
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdNotEqualTo(String exerciseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [],
              upper: [exerciseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [exerciseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [exerciseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'exerciseId',
              lower: [],
              upper: [exerciseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdGreaterThan(
    String exerciseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exerciseId',
        lower: [exerciseId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdLessThan(
    String exerciseId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exerciseId',
        lower: [],
        upper: [exerciseId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdBetween(
    String lowerExerciseId,
    String upperExerciseId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exerciseId',
        lower: [lowerExerciseId],
        includeLower: includeLower,
        upper: [upperExerciseId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdStartsWith(String ExerciseIdPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'exerciseId',
        lower: [ExerciseIdPrefix],
        upper: ['$ExerciseIdPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'exerciseId',
        value: [''],
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'exerciseId',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'exerciseId',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'exerciseId',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'exerciseId',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutExerciseQueryFilter
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QFilterCondition> {
  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      avgHeartRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avgHeartRate',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      avgHeartRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avgHeartRate',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      avgHeartRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      avgHeartRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      avgHeartRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      avgHeartRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgHeartRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      cardioConfirmedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cardioConfirmed',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      durationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      durationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      durationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      durationSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      durationSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      durationSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      estimatedKcalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'estimatedKcal',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      estimatedKcalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'estimatedKcal',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      estimatedKcalEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedKcal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      estimatedKcalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedKcal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      estimatedKcalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedKcal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      estimatedKcalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedKcal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exerciseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exerciseName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      exerciseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
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

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
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

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
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

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      importedIsStrengthEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importedIsStrength',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      isCardioEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCardio',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      metIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'met',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      metIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'met',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      metEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'met',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      metGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'met',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      metLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'met',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      metBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'met',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      restSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'restSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      restSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'restSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      restSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'restSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      restSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'restSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      restSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'restSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      restSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'restSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      setsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sets',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      setsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sets',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      setsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sets',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      setsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sets',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      setsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sets',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      setsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'source',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEndTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceEndTime',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEndTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceEndTime',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEndTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceEndTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEndTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceEndTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEndTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceEndTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceEndTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceEndTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceProgramId',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceProgramId',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceProgramId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceProgramId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceProgramId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceProgramId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceProgramName',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceProgramName',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceProgramName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceProgramName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceProgramName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceProgramName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceProgramName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceProgramName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceProgramName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceProgramName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceProgramName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceProgramNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceProgramName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceStartTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceStartTime',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceStartTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceStartTime',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceStartTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceStartTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceStartTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceStartTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceStartTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceStartTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceTemplateId',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceTemplateId',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTemplateId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceTemplateId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceTemplateId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceTemplateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceTemplateName',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceTemplateName',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTemplateName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceTemplateName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceTemplateName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceTemplateName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceTemplateName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceTemplateName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceTemplateName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceTemplateName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTemplateName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      sourceTemplateNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceTemplateName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetGroupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supersetGroupId',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetGroupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supersetGroupId',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetGroupIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supersetGroupId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetGroupIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supersetGroupId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetGroupIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supersetGroupId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetGroupIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supersetGroupId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supersetRole',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supersetRole',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supersetRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supersetRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supersetRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supersetRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supersetRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supersetRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supersetRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supersetRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supersetRole',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      supersetRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supersetRole',
        value: '',
      ));
    });
  }
}

extension WorkoutExerciseQueryObject
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QFilterCondition> {
  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterFilterCondition>
      setsElement(FilterQuery<WorkoutSet> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sets');
    });
  }
}

extension WorkoutExerciseQueryLinks
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QFilterCondition> {}

extension WorkoutExerciseQuerySortBy
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QSortBy> {
  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByAvgHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByAvgHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByCardioConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardioConfirmed', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByCardioConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardioConfirmed', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByEstimatedKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedKcal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByEstimatedKcalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedKcal', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByExerciseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByExerciseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByImportedIsStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedIsStrength', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByImportedIsStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedIsStrength', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByIsCardio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCardio', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByIsCardioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCardio', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> sortByMet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'met', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> sortByMetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'met', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByRestSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortByRestSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restSeconds', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEndTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEndTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceProgramName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceProgramNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceStartTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceStartTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceTemplateName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySourceTemplateNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySupersetGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetGroupId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySupersetGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetGroupId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySupersetRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetRole', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      sortBySupersetRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetRole', Sort.desc);
    });
  }
}

extension WorkoutExerciseQuerySortThenBy
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QSortThenBy> {
  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByAvgHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByAvgHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByCardioConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardioConfirmed', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByCardioConfirmedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardioConfirmed', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationSeconds', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByEstimatedKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedKcal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByEstimatedKcalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedKcal', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByExerciseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByExerciseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByImportedIsStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedIsStrength', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByImportedIsStrengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedIsStrength', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByIsCardio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCardio', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByIsCardioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCardio', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> thenByMet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'met', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> thenByMetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'met', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByRestSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenByRestSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restSeconds', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEndTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEndTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceProgramName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceProgramNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceProgramName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceStartTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceStartTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceTemplateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceTemplateName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateName', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySourceTemplateNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTemplateName', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySupersetGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetGroupId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySupersetGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetGroupId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySupersetRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetRole', Sort.asc);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QAfterSortBy>
      thenBySupersetRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supersetRole', Sort.desc);
    });
  }
}

extension WorkoutExerciseQueryWhereDistinct
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct> {
  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByAvgHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgHeartRate');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByCardioConfirmed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardioConfirmed');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationSeconds');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByEstimatedKcal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedKcal');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByExerciseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByExerciseName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByImportedIsStrength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importedIsStrength');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByIsCardio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCardio');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct> distinctByMet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'met');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctByRestSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restSeconds');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySourceEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceEndTime');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySourceProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceProgramId');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySourceProgramName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceProgramName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySourceStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceStartTime');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySourceTemplateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceTemplateId');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySourceTemplateName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceTemplateName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySupersetGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supersetGroupId');
    });
  }

  QueryBuilder<WorkoutExercise, WorkoutExercise, QDistinct>
      distinctBySupersetRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supersetRole', caseSensitive: caseSensitive);
    });
  }
}

extension WorkoutExerciseQueryProperty
    on QueryBuilder<WorkoutExercise, WorkoutExercise, QQueryProperty> {
  QueryBuilder<WorkoutExercise, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutExercise, double?, QQueryOperations>
      avgHeartRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgHeartRate');
    });
  }

  QueryBuilder<WorkoutExercise, bool, QQueryOperations>
      cardioConfirmedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardioConfirmed');
    });
  }

  QueryBuilder<WorkoutExercise, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<WorkoutExercise, int?, QQueryOperations>
      durationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationSeconds');
    });
  }

  QueryBuilder<WorkoutExercise, int?, QQueryOperations>
      estimatedKcalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedKcal');
    });
  }

  QueryBuilder<WorkoutExercise, String, QQueryOperations> exerciseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseId');
    });
  }

  QueryBuilder<WorkoutExercise, String, QQueryOperations>
      exerciseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseName');
    });
  }

  QueryBuilder<WorkoutExercise, bool, QQueryOperations>
      importedIsStrengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importedIsStrength');
    });
  }

  QueryBuilder<WorkoutExercise, bool, QQueryOperations> isCardioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCardio');
    });
  }

  QueryBuilder<WorkoutExercise, int?, QQueryOperations> metProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'met');
    });
  }

  QueryBuilder<WorkoutExercise, int?, QQueryOperations> restSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restSeconds');
    });
  }

  QueryBuilder<WorkoutExercise, List<WorkoutSet>, QQueryOperations>
      setsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sets');
    });
  }

  QueryBuilder<WorkoutExercise, String?, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<WorkoutExercise, DateTime?, QQueryOperations>
      sourceEndTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceEndTime');
    });
  }

  QueryBuilder<WorkoutExercise, int?, QQueryOperations>
      sourceProgramIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceProgramId');
    });
  }

  QueryBuilder<WorkoutExercise, String?, QQueryOperations>
      sourceProgramNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceProgramName');
    });
  }

  QueryBuilder<WorkoutExercise, DateTime?, QQueryOperations>
      sourceStartTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceStartTime');
    });
  }

  QueryBuilder<WorkoutExercise, int?, QQueryOperations>
      sourceTemplateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceTemplateId');
    });
  }

  QueryBuilder<WorkoutExercise, String?, QQueryOperations>
      sourceTemplateNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceTemplateName');
    });
  }

  QueryBuilder<WorkoutExercise, int?, QQueryOperations>
      supersetGroupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supersetGroupId');
    });
  }

  QueryBuilder<WorkoutExercise, String?, QQueryOperations>
      supersetRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supersetRole');
    });
  }
}
