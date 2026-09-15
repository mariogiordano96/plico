import 'package:isar/isar.dart';

part 'coach_message.g.dart';

/// Un messaggio della chat Coach (docs/integrazione_flutter_gemma.md, Fase 7),
/// persistito per sopravvivere a un riavvio dell'app — prima restava solo in
/// memoria della sessione corrente. Una sola conversazione continua, non una
/// per giorno/sessione: l'utente la azzera esplicitamente se vuole ripartire.
@collection
class CoachMessage {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late DateTime createdAt;

  late bool isUser;
  late String text;
  // Messaggio di rifiuto nostro (guardrail o errore Gemini), non una vera
  // risposta del modello — va escluso dalla history rimandata a Gemini e dal
  // rendering Markdown, stesso trattamento di prima quando viveva solo in
  // memoria (vedi coach_screen.dart).
  bool isError = false;
  // Sottoinsieme di isError: rifiuto locale del guardrail (non un errore
  // Gemini) — non ha mai un bottone "Riprova" in sessione, e non deve
  // riapparire ricostruito al reload da disco (vedi _fromPersisted).
  bool isGuardrail = false;
}
