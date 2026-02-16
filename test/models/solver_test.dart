import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/models/solver.dart';

void main() {
  group('Solver.getDisplayName()', () {
    test('returns real name when isRegistered is true', () {
      const solver = Solver(
        rank: 1,
        name: 'Alice',
        solutionsCount: 5,
        rating: 4.5,
        specialty: 'Marine Biology',
        isRegistered: true,
      );
      expect(solver.getDisplayName(), equals('Alice'));
    });

    test('returns hashed nickname when isRegistered is false', () {
      const solver = Solver(
        rank: 1,
        name: 'Bob',
        solutionsCount: 3,
        rating: 3.0,
        specialty: 'Chemistry',
        isRegistered: false,
      );
      final displayName = solver.getDisplayName();
      expect(displayName, startsWith('User_'));
      // "User_" + 6 uppercase hex chars = 11 total
      expect(displayName.length, equals(11));
    });

    test('hashed nickname is deterministic for same name', () {
      const solver1 = Solver(
        rank: 1,
        name: 'Charlie',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'Physics',
        isRegistered: false,
      );
      const solver2 = Solver(
        rank: 2,
        name: 'Charlie',
        solutionsCount: 2,
        rating: 2.0,
        specialty: 'Biology',
        isRegistered: false,
      );
      expect(solver1.getDisplayName(), equals(solver2.getDisplayName()));
    });

    test('hashed nickname differs for different names', () {
      const solver1 = Solver(
        rank: 1,
        name: 'Alice',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'X',
        isRegistered: false,
      );
      const solver2 = Solver(
        rank: 1,
        name: 'Bob',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'X',
        isRegistered: false,
      );
      expect(
        solver1.getDisplayName(),
        isNot(equals(solver2.getDisplayName())),
      );
    });
  });

  group('Solver.getMaskedName()', () {
    test('returns real name when isRegistered is true', () {
      const solver = Solver(
        rank: 1,
        name: 'Alice',
        solutionsCount: 5,
        rating: 4.5,
        specialty: 'Marine Biology',
        isRegistered: true,
      );
      expect(solver.getMaskedName(), equals('Alice'));
    });

    test('returns "****" when name length <= 3 and unregistered', () {
      const solver = Solver(
        rank: 1,
        name: 'Bob',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'X',
        isRegistered: false,
      );
      expect(solver.getMaskedName(), equals('****'));
    });

    test('masks name correctly when name length > 3 and unregistered', () {
      const solver = Solver(
        rank: 1,
        name: 'Alexander',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'X',
        isRegistered: false,
      );
      // visibleLength = ceil(9/3) = 3, masked = 6 asterisks
      expect(solver.getMaskedName(), equals('Ale******'));
    });

    test('masks 4-char name correctly', () {
      const solver = Solver(
        rank: 1,
        name: 'John',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'X',
        isRegistered: false,
      );
      // visibleLength = ceil(4/3) = 2, masked = 2 asterisks
      expect(solver.getMaskedName(), equals('Jo**'));
    });

    test('masks 5-char name correctly', () {
      const solver = Solver(
        rank: 1,
        name: 'Maria',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'X',
        isRegistered: false,
      );
      // visibleLength = ceil(5/3) = 2, masked = 3 asterisks
      expect(solver.getMaskedName(), equals('Ma***'));
    });
  });

  group('Solver.getSpecialty()', () {
    test('returns actual specialty when registered', () {
      const solver = Solver(
        rank: 1,
        name: 'Alice',
        solutionsCount: 5,
        rating: 4.5,
        specialty: 'Marine Biology',
        isRegistered: true,
      );
      expect(solver.getSpecialty(), equals('Marine Biology'));
    });

    test('returns "Unknown" when not registered', () {
      const solver = Solver(
        rank: 1,
        name: 'Bob',
        solutionsCount: 1,
        rating: 1.0,
        specialty: 'Marine Biology',
        isRegistered: false,
      );
      expect(solver.getSpecialty(), equals('Unknown'));
    });
  });

  group('Solver constructor', () {
    test('stores all fields correctly', () {
      const solver = Solver(
        rank: 3,
        name: 'TestUser',
        solutionsCount: 10,
        rating: 4.8,
        specialty: 'Environmental Science',
        isRegistered: true,
      );
      expect(solver.rank, equals(3));
      expect(solver.name, equals('TestUser'));
      expect(solver.solutionsCount, equals(10));
      expect(solver.rating, equals(4.8));
      expect(solver.specialty, equals('Environmental Science'));
      expect(solver.isRegistered, isTrue);
    });
  });
}
