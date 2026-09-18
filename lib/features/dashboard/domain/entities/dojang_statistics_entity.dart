/// Domain entity representing member statistics for a Dojang.
class DojangStatisticsEntity {
  const DojangStatisticsEntity({
    this.currentStudents = 0,
    this.sevenDaysTrial = 0,
    this.thirtyDaysTrial = 0,
    this.newStudents = 0,
    this.totalMembers = 0,
    this.recommendationCount = 0,
  });

  final int currentStudents;
  final int sevenDaysTrial;
  final int thirtyDaysTrial;
  final int newStudents;
  final int totalMembers;
  final int recommendationCount;
}
