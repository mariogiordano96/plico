// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template_exercise.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const WorkoutTemplateExerciseSchema = Schema(
  name: r'WorkoutTemplateExercise',
  id: 254898386855562952,
  properties: {
    r'exerciseId': PropertySchema(
      id: 0,
      name: r'exerciseId',
      type: IsarType.string,
    ),
    r'exerciseName': PropertySchema(
      id: 1,
      name: r'exerciseName',
      type: IsarType.string,
    ),
    r'isCardio': PropertySchema(
      id: 2,
      name: r'isCardio',
      type: IsarType.bool,
    ),
    r'plannedSets': PropertySchema(
      id: 3,
      name: r'plannedSets',
      type: IsarType.objectList,
      target: r'WorkoutTemplateSet',
    ),
    r'restSeconds': PropertySchema(
      id: 4,
      name: r'restSeconds',
      type: IsarType.long,
    ),
    r'supersetGroupId': PropertySchema(
      id: 5,
      name: r'supersetGroupId',
      type: IsarType.long,
    ),
    r'supersetRole': PropertySchema(
      id: 6,
      name: r'supersetRole',
      type: IsarType.string,
    ),
    r'targetDurationSeconds': PropertySchema(
      id: 7,
      name: r'targetDurationSeconds',
      type: IsarType.long,
    ),
    r'targetReps': PropertySchema(
      id: 8,
      name: r'targetReps',
      type: IsarType.long,
    ),
    r'targetSets': PropertySchema(
      id: 9,
      name: r'targetSets',
      type: IsarType.long,
    ),
    r'targetWeightKg': PropertySchema(
      id: 10,
      name: r'targetWeightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _workoutTemplateExerciseEstimateSize,
  serialize: _workoutTemplateExerciseSerialize,
  deserialize: _workoutTemplateExerciseDeserialize,
  deserializeProp: _workoutTemplateExerciseDeserializeProp,
);

int _workoutTemplateExerciseEstimateSize(
  WorkoutTemplateExercise object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseId.length * 3;
  bytesCount += 3 + object.exerciseName.length * 3;
  {
    final list = object.plannedSets;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[WorkoutTemplateSet]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              WorkoutTemplateSetSchema.estimateSize(value, offsets, allOffsets);
        }
      }
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

void _workoutTemplateExerciseSerialize(
  WorkoutTemplateExercise object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.exerciseId);
  writer.writeString(offsets[1], object.exerciseName);
  writer.writeBool(offsets[2], object.isCardio);
  writer.writeObjectList<WorkoutTemplateSet>(
    offsets[3],
    allOffsets,
    WorkoutTemplateSetSchema.serialize,
    object.plannedSets,
  );
  writer.writeLong(offsets[4], object.restSeconds);
  writer.writeLong(offsets[5], object.supersetGroupId);
  writer.writeString(offsets[6], object.supersetRole);
  writer.writeLong(offsets[7], object.targetDurationSeconds);
  writer.writeLong(offsets[8], object.targetReps);
  writer.writeLong(offsets[9], object.targetSets);
  writer.writeDouble(offsets[10], object.targetWeightKg);
}

WorkoutTemplateExercise _workoutTemplateExerciseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutTemplateExercise();
  object.exerciseId = reader.readString(offsets[0]);
  object.exerciseName = reader.readString(offsets[1]);
  object.plannedSets = reader.readObjectList<WorkoutTemplateSet>(
    offsets[3],
    WorkoutTemplateSetSchema.deserialize,
    allOffsets,
    WorkoutTemplateSet(),
  );
  object.restSeconds = reader.readLongOrNull(offsets[4]);
  object.supersetGroupId = reader.readLongOrNull(offsets[5]);
  object.supersetRole = reader.readStringOrNull(offsets[6]);
  object.targetDurationSeconds = reader.readLongOrNull(offsets[7]);
  object.targetReps = reader.readLongOrNull(offsets[8]);
  object.targetSets = reader.readLongOrNull(offsets[9]);
  object.targetWeightKg = reader.readDoubleOrNull(offsets[10]);
  return object;
}

P _workoutTemplateExerciseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readObjectList<WorkoutTemplateSet>(
        offset,
        WorkoutTemplateSetSchema.deserialize,
        allOffsets,
        WorkoutTemplateSet(),
      )) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension WorkoutTemplateExerciseQueryFilter on QueryBuilder<
    WorkoutTemplateExercise, WorkoutTemplateExercise, QFilterCondition> {
  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdEqualTo(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdGreaterThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdLessThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdBetween(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdStartsWith(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdEndsWith(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
          QAfterFilterCondition>
      exerciseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
          QAfterFilterCondition>
      exerciseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameEqualTo(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameGreaterThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameLessThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameBetween(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameStartsWith(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameEndsWith(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
          QAfterFilterCondition>
      exerciseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
          QAfterFilterCondition>
      exerciseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> exerciseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseName',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> isCardioEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCardio',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'plannedSets',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'plannedSets',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'plannedSets',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'plannedSets',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'plannedSets',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'plannedSets',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'plannedSets',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> plannedSetsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'plannedSets',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> restSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'restSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> restSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'restSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> restSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'restSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> restSecondsGreaterThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> restSecondsLessThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> restSecondsBetween(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetGroupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supersetGroupId',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetGroupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supersetGroupId',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetGroupIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supersetGroupId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetGroupIdGreaterThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetGroupIdLessThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetGroupIdBetween(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supersetRole',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supersetRole',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleEqualTo(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleGreaterThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleLessThan(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleBetween(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleStartsWith(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleEndsWith(
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

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
          QAfterFilterCondition>
      supersetRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supersetRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
          QAfterFilterCondition>
      supersetRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supersetRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supersetRole',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> supersetRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supersetRole',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetDurationSecondsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetDurationSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetDurationSecondsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetDurationSeconds',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetDurationSecondsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetDurationSecondsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetDurationSecondsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetDurationSecondsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetRepsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetReps',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetRepsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetReps',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetRepsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetReps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetRepsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetReps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetRepsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetReps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetRepsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetReps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetSetsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetSets',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetSetsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetSets',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetSetsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetSets',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetSetsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetSets',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetSetsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetSets',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetSetsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetSets',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetWeightKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetWeightKg',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetWeightKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetWeightKg',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetWeightKgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetWeightKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetWeightKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
      QAfterFilterCondition> targetWeightKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension WorkoutTemplateExerciseQueryObject on QueryBuilder<
    WorkoutTemplateExercise, WorkoutTemplateExercise, QFilterCondition> {
  QueryBuilder<WorkoutTemplateExercise, WorkoutTemplateExercise,
          QAfterFilterCondition>
      plannedSetsElement(FilterQuery<WorkoutTemplateSet> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'plannedSets');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const WorkoutTemplateSetSchema = Schema(
  name: r'WorkoutTemplateSet',
  id: -3479987951029928712,
  properties: {
    r'dropStages': PropertySchema(
      id: 0,
      name: r'dropStages',
      type: IsarType.objectList,
      target: r'DropStage',
    ),
    r'forcedReps': PropertySchema(
      id: 1,
      name: r'forcedReps',
      type: IsarType.long,
    ),
    r'isSuperSlow': PropertySchema(
      id: 2,
      name: r'isSuperSlow',
      type: IsarType.bool,
    ),
    r'reps': PropertySchema(
      id: 3,
      name: r'reps',
      type: IsarType.long,
    ),
    r'restPauseClusters': PropertySchema(
      id: 4,
      name: r'restPauseClusters',
      type: IsarType.longList,
    ),
    r'weightKg': PropertySchema(
      id: 5,
      name: r'weightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _workoutTemplateSetEstimateSize,
  serialize: _workoutTemplateSetSerialize,
  deserialize: _workoutTemplateSetDeserialize,
  deserializeProp: _workoutTemplateSetDeserializeProp,
);

int _workoutTemplateSetEstimateSize(
  WorkoutTemplateSet object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.dropStages;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[DropStage]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              DropStageSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.restPauseClusters;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  return bytesCount;
}

void _workoutTemplateSetSerialize(
  WorkoutTemplateSet object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<DropStage>(
    offsets[0],
    allOffsets,
    DropStageSchema.serialize,
    object.dropStages,
  );
  writer.writeLong(offsets[1], object.forcedReps);
  writer.writeBool(offsets[2], object.isSuperSlow);
  writer.writeLong(offsets[3], object.reps);
  writer.writeLongList(offsets[4], object.restPauseClusters);
  writer.writeDouble(offsets[5], object.weightKg);
}

WorkoutTemplateSet _workoutTemplateSetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutTemplateSet();
  object.dropStages = reader.readObjectList<DropStage>(
    offsets[0],
    DropStageSchema.deserialize,
    allOffsets,
    DropStage(),
  );
  object.forcedReps = reader.readLongOrNull(offsets[1]);
  object.isSuperSlow = reader.readBool(offsets[2]);
  object.reps = reader.readLongOrNull(offsets[3]);
  object.restPauseClusters = reader.readLongList(offsets[4]);
  object.weightKg = reader.readDoubleOrNull(offsets[5]);
  return object;
}

P _workoutTemplateSetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<DropStage>(
        offset,
        DropStageSchema.deserialize,
        allOffsets,
        DropStage(),
      )) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongList(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension WorkoutTemplateSetQueryFilter
    on QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QFilterCondition> {
  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dropStages',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dropStages',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dropStages',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dropStages',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dropStages',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dropStages',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dropStages',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dropStages',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      forcedRepsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'forcedReps',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      forcedRepsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'forcedReps',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      forcedRepsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forcedReps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      forcedRepsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'forcedReps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      forcedRepsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'forcedReps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      forcedRepsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'forcedReps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      isSuperSlowEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSuperSlow',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      repsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reps',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      repsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reps',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      repsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      repsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      repsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reps',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      repsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'restPauseClusters',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'restPauseClusters',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'restPauseClusters',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'restPauseClusters',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'restPauseClusters',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'restPauseClusters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restPauseClusters',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restPauseClusters',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restPauseClusters',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restPauseClusters',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restPauseClusters',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      restPauseClustersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'restPauseClusters',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      weightKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weightKg',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      weightKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weightKg',
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      weightKgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      weightKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      weightKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      weightKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension WorkoutTemplateSetQueryObject
    on QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QFilterCondition> {
  QueryBuilder<WorkoutTemplateSet, WorkoutTemplateSet, QAfterFilterCondition>
      dropStagesElement(FilterQuery<DropStage> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'dropStages');
    });
  }
}
