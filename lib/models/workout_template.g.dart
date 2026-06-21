// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutTemplateCollection on Isar {
  IsarCollection<WorkoutTemplate> get workoutTemplates => this.collection();
}

const WorkoutTemplateSchema = CollectionSchema(
  name: r'WorkoutTemplate',
  id: 9152743543952114156,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'exercises': PropertySchema(
      id: 1,
      name: r'exercises',
      type: IsarType.objectList,
      target: r'WorkoutTemplateExercise',
    ),
    r'isPreset': PropertySchema(
      id: 2,
      name: r'isPreset',
      type: IsarType.bool,
    ),
    r'lastUsedAt': PropertySchema(
      id: 3,
      name: r'lastUsedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'order': PropertySchema(
      id: 5,
      name: r'order',
      type: IsarType.long,
    ),
    r'programId': PropertySchema(
      id: 6,
      name: r'programId',
      type: IsarType.long,
    )
  },
  estimateSize: _workoutTemplateEstimateSize,
  serialize: _workoutTemplateSerialize,
  deserialize: _workoutTemplateDeserialize,
  deserializeProp: _workoutTemplateDeserializeProp,
  idName: r'id',
  indexes: {
    r'programId': IndexSchema(
      id: 8658639611369428834,
      name: r'programId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'programId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'WorkoutTemplateExercise': WorkoutTemplateExerciseSchema},
  getId: _workoutTemplateGetId,
  getLinks: _workoutTemplateGetLinks,
  attach: _workoutTemplateAttach,
  version: '3.1.0+1',
);

int _workoutTemplateEstimateSize(
  WorkoutTemplate object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exercises.length * 3;
  {
    final offsets = allOffsets[WorkoutTemplateExercise]!;
    for (var i = 0; i < object.exercises.length; i++) {
      final value = object.exercises[i];
      bytesCount += WorkoutTemplateExerciseSchema.estimateSize(
          value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _workoutTemplateSerialize(
  WorkoutTemplate object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeObjectList<WorkoutTemplateExercise>(
    offsets[1],
    allOffsets,
    WorkoutTemplateExerciseSchema.serialize,
    object.exercises,
  );
  writer.writeBool(offsets[2], object.isPreset);
  writer.writeDateTime(offsets[3], object.lastUsedAt);
  writer.writeString(offsets[4], object.name);
  writer.writeLong(offsets[5], object.order);
  writer.writeLong(offsets[6], object.programId);
}

WorkoutTemplate _workoutTemplateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutTemplate();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.exercises = reader.readObjectList<WorkoutTemplateExercise>(
        offsets[1],
        WorkoutTemplateExerciseSchema.deserialize,
        allOffsets,
        WorkoutTemplateExercise(),
      ) ??
      [];
  object.id = id;
  object.isPreset = reader.readBool(offsets[2]);
  object.lastUsedAt = reader.readDateTimeOrNull(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.order = reader.readLong(offsets[5]);
  object.programId = reader.readLongOrNull(offsets[6]);
  return object;
}

P _workoutTemplateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readObjectList<WorkoutTemplateExercise>(
            offset,
            WorkoutTemplateExerciseSchema.deserialize,
            allOffsets,
            WorkoutTemplateExercise(),
          ) ??
          []) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutTemplateGetId(WorkoutTemplate object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutTemplateGetLinks(WorkoutTemplate object) {
  return [];
}

void _workoutTemplateAttach(
    IsarCollection<dynamic> col, Id id, WorkoutTemplate object) {
  object.id = id;
}

extension WorkoutTemplateQueryWhereSort
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QWhere> {
  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhere> anyProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'programId'),
      );
    });
  }
}

extension WorkoutTemplateQueryWhere
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QWhereClause> {
  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause> idBetween(
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      programIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'programId',
        value: [null],
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      programIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'programId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      programIdEqualTo(int? programId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'programId',
        value: [programId],
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      programIdNotEqualTo(int? programId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'programId',
              lower: [],
              upper: [programId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'programId',
              lower: [programId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'programId',
              lower: [programId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'programId',
              lower: [],
              upper: [programId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      programIdGreaterThan(
    int? programId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'programId',
        lower: [programId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      programIdLessThan(
    int? programId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'programId',
        lower: [],
        upper: [programId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterWhereClause>
      programIdBetween(
    int? lowerProgramId,
    int? upperProgramId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'programId',
        lower: [lowerProgramId],
        includeLower: includeLower,
        upper: [upperProgramId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutTemplateQueryFilter
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QFilterCondition> {
  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      exercisesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exercises',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      exercisesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exercises',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      exercisesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exercises',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      exercisesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exercises',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      exercisesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exercises',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      exercisesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'exercises',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      isPresetEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPreset',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      lastUsedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUsedAt',
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      lastUsedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUsedAt',
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      lastUsedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      lastUsedAtGreaterThan(
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      lastUsedAtLessThan(
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      lastUsedAtBetween(
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

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      orderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      orderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      orderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      orderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      programIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'programId',
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      programIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'programId',
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      programIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'programId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      programIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'programId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      programIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'programId',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      programIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'programId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutTemplateQueryObject
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QFilterCondition> {
  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterFilterCondition>
      exercisesElement(FilterQuery<WorkoutTemplateExercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'exercises');
    });
  }
}

extension WorkoutTemplateQueryLinks
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QFilterCondition> {}

extension WorkoutTemplateQuerySortBy
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QSortBy> {
  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByIsPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPreset', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByIsPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPreset', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      sortByProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.desc);
    });
  }
}

extension WorkoutTemplateQuerySortThenBy
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QSortThenBy> {
  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByIsPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPreset', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByIsPresetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPreset', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByLastUsedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QAfterSortBy>
      thenByProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.desc);
    });
  }
}

extension WorkoutTemplateQueryWhereDistinct
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QDistinct> {
  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QDistinct>
      distinctByIsPreset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPreset');
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QDistinct>
      distinctByLastUsedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsedAt');
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<WorkoutTemplate, WorkoutTemplate, QDistinct>
      distinctByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'programId');
    });
  }
}

extension WorkoutTemplateQueryProperty
    on QueryBuilder<WorkoutTemplate, WorkoutTemplate, QQueryProperty> {
  QueryBuilder<WorkoutTemplate, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutTemplate, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WorkoutTemplate, List<WorkoutTemplateExercise>, QQueryOperations>
      exercisesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exercises');
    });
  }

  QueryBuilder<WorkoutTemplate, bool, QQueryOperations> isPresetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPreset');
    });
  }

  QueryBuilder<WorkoutTemplate, DateTime?, QQueryOperations>
      lastUsedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsedAt');
    });
  }

  QueryBuilder<WorkoutTemplate, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<WorkoutTemplate, int, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<WorkoutTemplate, int?, QQueryOperations> programIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'programId');
    });
  }
}
