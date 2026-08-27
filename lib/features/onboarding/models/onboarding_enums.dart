enum Gender { male, female, other }

enum RelationshipStatus { single, married, inRelationship }

enum ProfileReviewStatus { draft, submitted, underReview, approved, rejected }

extension GenderLabel on Gender {
  String get label => switch (this) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.other => 'Other',
  };
}

extension RelationshipStatusLabel on RelationshipStatus {
  String get label => switch (this) {
    RelationshipStatus.single => 'Single',
    RelationshipStatus.married => 'Married',
    RelationshipStatus.inRelationship => 'In a relationship',
  };
}
