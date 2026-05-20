// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 0;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      codeSnippet: fields[2] as String,
      geminiProbability: fields[3] as double,
      groqProbability: fields[4] as double,
      ensembleProbability: fields[5] as double,
      verdict: fields[6] as String,
      confidence: fields[7] as String,
      geminiExplanation: fields[8] as String?,
      groqExplanation: fields[9] as String?,
      geminiSuccess: fields[10] as bool,
      groqSuccess: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.codeSnippet)
      ..writeByte(3)
      ..write(obj.geminiProbability)
      ..writeByte(4)
      ..write(obj.groqProbability)
      ..writeByte(5)
      ..write(obj.ensembleProbability)
      ..writeByte(6)
      ..write(obj.verdict)
      ..writeByte(7)
      ..write(obj.confidence)
      ..writeByte(8)
      ..write(obj.geminiExplanation)
      ..writeByte(9)
      ..write(obj.groqExplanation)
      ..writeByte(10)
      ..write(obj.geminiSuccess)
      ..writeByte(11)
      ..write(obj.groqSuccess);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
