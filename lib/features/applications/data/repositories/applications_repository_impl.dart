import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../../domain/entities/application_detail_entity.dart';
import '../../domain/entities/application_item_entity.dart';
import '../../domain/repositories/applications_repository.dart';
import '../datasources/applications_remote_datasource.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  ApplicationsRepositoryImpl(this._remote);

  final ApplicationsRemoteDataSource _remote;

  // In-memory cache for mock updates during runtime
  static List<ApplicationItemEntity> _mockPending = [
    const ApplicationItemEntity(
      id: 501,
      studentName: 'Olivia Davis',
      studentFirstName: 'Olivia',
      studentLastName: 'Davis',
      parentName: 'Emma Davis',
      parentEmail: 'emma.davis@example.com',
      parentPhone: '7035550199',
      applicationDate: '9/10/2026',
      status: 'Pending',
      isViewed: false,
    ),
    const ApplicationItemEntity(
      id: 502,
      studentName: 'Ethan Walker',
      studentFirstName: 'Ethan',
      studentLastName: 'Walker',
      parentName: 'Sarah Walker',
      parentEmail: 'sarah.w@example.com',
      parentPhone: '7035550177',
      applicationDate: '9/08/2026',
      status: 'Pending',
      isViewed: true,
      viewedDate: '9/09/2026',
      viewedDateFormatted: 'Viewed on 9/09/2026',
    ),
  ];

  static List<ApplicationItemEntity> _mockHistory = [
    const ApplicationItemEntity(
      id: 480,
      studentName: 'Lucas Brown',
      studentFirstName: 'Lucas',
      studentLastName: 'Brown',
      parentName: 'Michael Brown',
      parentEmail: 'mbrown@example.com',
      parentPhone: '7035550144',
      applicationDate: '8/30/2026',
      status: 'Enrolled',
      isViewed: true,
      viewedDate: '8/31/2026',
      viewedDateFormatted: 'Viewed on 8/31/2026',
    ),
    const ApplicationItemEntity(
      id: 472,
      studentName: 'Sophia Taylor',
      studentFirstName: 'Sophia',
      studentLastName: 'Taylor',
      parentName: 'David Taylor',
      parentEmail: 'dtaylor@example.com',
      parentPhone: '7035550122',
      applicationDate: '8/15/2026',
      status: 'Enrolled',
      isViewed: true,
      viewedDate: '8/16/2026',
      viewedDateFormatted: 'Viewed on 8/16/2026',
    ),
  ];

  @override
  Future<({List<ApplicationItemEntity> pending, List<ApplicationItemEntity> history})>
      getApplications(String dojangId) async {
    if (AppConstants.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return (pending: List.of(_mockPending), history: List.of(_mockHistory));
    }

    try {
      final response = await _remote.getApplications(dojangId);
      final pending = response.pendingApplications.map((m) => m.toEntity()).toList();
      final history = response.enrolledApplications.map((m) => m.toEntity()).toList();
      return (pending: pending, history: history);
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<ApplicationDetailEntity> getApplicationDetail(String applicationId) async {
    if (AppConstants.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Mark as viewed in mock list
      final id = int.tryParse(applicationId) ?? 501;
      final index = _mockPending.indexWhere((item) => item.id == id);
      if (index != -1) {
        _mockPending[index] = _mockPending[index].copyWith(
          isViewed: true,
          viewedDate: 'Today',
          viewedDateFormatted: 'Viewed on Today',
        );
      }

      if (id == 480 || id == 472) {
        return const ApplicationDetailEntity(
          id: 480,
          studentFirstName: 'Lucas',
          studentLastName: 'Brown',
          dateOfBirth: '2015-06-18',
          gender: 'M',
          schoolNameGrade: 'Vienna Elementary / 4th Grade',
          parentFullName: 'Michael Brown',
          relationshipToStudent: 'Father',
          parentPhoneNumber: '(703) 555-0144',
          parentEmail: 'mbrown@example.com',
          streetAddress: '456 Oak Avenue',
          city: 'Vienna',
          state: 'VA',
          zipCode: '22180',
          emergencyContactName: 'Laura Brown',
          emergencyContactPhone: '(703) 555-0145',
          hasMedicalConditions: 'no',
          applicationDate: '8/30/2026',
          applicationStatus: 'Enrolled',
          enrollmentDate: '8/31/2026',
        );
      }

      return const ApplicationDetailEntity(
        id: 501,
        studentFirstName: 'Olivia',
        studentLastName: 'Davis',
        dateOfBirth: '2016-04-02',
        gender: 'F',
        schoolNameGrade: 'Oakton Elementary / 3rd Grade',
        parentFullName: 'Emma Davis',
        relationshipToStudent: 'Mother',
        parentPhoneNumber: '(703) 555-0199',
        parentEmail: 'emma.davis@example.com',
        streetAddress: '123 Main St',
        city: 'Vienna',
        state: 'VA',
        zipCode: '22102',
        emergencyContactName: 'Robert Davis',
        emergencyContactPhone: '(703) 555-0188',
        hasMedicalConditions: 'yes',
        allergies: 'Peanuts',
        medicalConditionDetails: 'Asthma (mild)',
        currentMedication: 'Inhaler as needed',
        applicationDate: '9/10/2026',
        applicationStatus: 'Pending',
        viewedDate: '9/11/2026',
      );
    }

    try {
      final model = await _remote.getApplicationDetail(applicationId);
      return model.toEntity();
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  Failure _mapNetworkException(NetworkException error) {
    return switch (error) {
      UnauthorizedException() || ForbiddenException() || RateLimitException() =>
        AuthFailure(error.message),
      NoInternetException() || TimeoutException() =>
        NetworkFailure(error.message),
      ServerException() || BadRequestException() || NotFoundException() =>
        ServerFailure(error.message),
      UnknownNetworkException() => UnexpectedFailure(error.message),
    };
  }
}

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  return ApplicationsRepositoryImpl(ref.watch(applicationsRemoteDataSourceProvider));
});
