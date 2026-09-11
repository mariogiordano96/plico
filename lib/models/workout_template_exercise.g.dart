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
    r'restSeconds': PropertySchema(
      id: 3,
      name: r'restSeconds',
      type: IsarType.long,
    ),
    r'supersetGroupId': PropertySchema(
      id: 4,
      name: r'supersetGroupId',
      type: IsarType.long,
    ),
    r'supersetRole': PropertySchema(
      id: 5,
      name: r'supersetRole',
      type: IsarType.string,
    ),
    r'targetDurationSeconds': PropertySchema(
      id: 6,
      name: r'targetDurationSeconds',
      type: IsarType.long,
    ),
    r'targetReps': PropertySchema(
      id: 7,
      name: r'targetReps',
      type: IsarType.long,
    ),
    r'targetSets': PropertySchema(
      id: 8,
      name: r'targetSets',
      type: IsarType.long,
    ),
    r'targetWeightKg': PropertySchema(
      id: 9,
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
  writer.writeLong(offsets[3], object.restSeconds);
  writer.writeLong(offsets[4], object.supersetGroupId);
  writer.writeString(offsets[5], object.supersetRole);
  writer.writeLong(offsets[6], object.targetDurationSeconds);
  writer.writeLong(offsets[7], object.targetReps);
  writer.writeLong(offsets[8], object.targetSets);
  writer.writeDouble(offsets[9], object.targetWeightKg);
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
  object.restSeconds = reader.readLongOrNull(offsets[3]);
  object.supersetGroupId = reader.readLongOrNull(offsets[4]);
  object.supersetRole = reader.readStringOrNull(offsets[5]);
  object.targetDurationSeconds = reader.readLongOrNull(offsets[6]);
  object.targetReps = reader.readLongOrNull(offsets[7]);
  object.targetSets = reader.readLongOrNull(offsets[8]);
  object.targetWeightKg = reader.readDoubleOrNull(offsets[9]);
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
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
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
    WorkoutTemplateExercise, WorkoutTemplateExercise, QFilterCondition> {}
