// lib/models.dart
class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;
  final List<Stall> stalls;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.stalls,
  });
}

class Stall {
  final String id;
  final String title;
  final String description;
  final String activityType;
  final List<QuizQuestion> quizQuestions;
  final String pollQuestion;
  final List<String> pollOptions;
  final CodingChallenge? coding;
  final String about;
  final String aim;
  final String scope;
  final String lesson;
  final List<StreamInfo> streams;
  final List<String> careers;
  final List<ResourceLink> resources;
  final List<ResourceLink> videos;
  final bool miniGameEnabled;

  Stall({
    required this.id,
    required this.title,
    required this.description,
    required this.activityType,
    this.quizQuestions = const [],
    this.pollQuestion = '',
    this.pollOptions = const [],
    this.coding,
    this.about = '',
    this.aim = '',
    this.scope = '',
    this.lesson = '',
    this.streams = const [],
    this.careers = const [],
    this.resources = const [],
    this.videos = const [],
    this.miniGameEnabled = false,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class CodingChallenge {
  final String prompt;
  final List<TestCase> tests;

  const CodingChallenge({required this.prompt, required this.tests});
}

class TestCase {
  final String input;
  final String expectedOutput;

  const TestCase({required this.input, required this.expectedOutput});
}

class StreamInfo {
  final String name;
  final String description;
  const StreamInfo({required this.name, required this.description});
}

class ResourceLink {
  final String title;
  final String url;
  const ResourceLink({required this.title, required this.url});
}
