enum AccountType { individual, organization }
enum PrimaryIntent { adopt, post }

String accountTypeLabel(AccountType v) =>
    v == AccountType.individual ? 'Individual' : 'Organization';

String intentLabel(PrimaryIntent v) =>
    v == PrimaryIntent.adopt ? 'Adopt a pet' : 'Post for adoption';
