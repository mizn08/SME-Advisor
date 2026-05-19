class ChatTurn {
  ChatTurn({required this.role, required this.text, this.sources = const []});

  final String role;
  final String text;
  final List<ChatSource> sources;
}

class ChatSource {
  ChatSource({this.type, required this.snippet});

  final String? type;
  final String snippet;

  factory ChatSource.fromJson(Map<String, dynamic> j) => ChatSource(
        type: j['type'] as String?,
        snippet: j['snippet'] as String? ?? '',
      );
}

class ChatResponse {
  ChatResponse({
    required this.answer,
    required this.mode,
    this.sources = const [],
  });

  final String answer;
  final String mode;
  final List<ChatSource> sources;

  factory ChatResponse.fromJson(Map<String, dynamic> j) => ChatResponse(
        answer: j['answer'] as String? ?? '',
        mode: j['mode'] as String? ?? 'unknown',
        sources: (j['sources'] as List<dynamic>? ?? [])
            .map((e) => ChatSource.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AgentAdvice {
  AgentAdvice({
    required this.leadAgent,
    required this.summary,
    required this.agents,
    this.recommendation,
    this.ragSnippet,
  });

  final String leadAgent;
  final String summary;
  final List<AgentInsight> agents;
  final Map<String, dynamic>? recommendation;
  final String? ragSnippet;

  factory AgentAdvice.fromJson(Map<String, dynamic> j) => AgentAdvice(
        leadAgent: j['lead_agent'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        agents: (j['agents'] as List<dynamic>? ?? [])
            .map((e) => AgentInsight.fromJson(e as Map<String, dynamic>))
            .toList(),
        recommendation: j['recommendation'] as Map<String, dynamic>?,
        ragSnippet: j['rag_snippet'] as String?,
      );
}

class AgentInsight {
  AgentInsight({required this.name, required this.insight});

  final String name;
  final String insight;

  factory AgentInsight.fromJson(Map<String, dynamic> j) => AgentInsight(
        name: j['name'] as String? ?? '',
        insight: j['insight'] as String? ?? '',
      );
}
