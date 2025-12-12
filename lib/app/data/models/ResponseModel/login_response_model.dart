// // models/login_response_model.dart
// class LoginResponseModel {
//   final String message;
//   final bool success;
//   final LoginData data;
//   final List<dynamic> errors;
//
//   LoginResponseModel({
//     required this.message,
//     required this.success,
//     required this.data,
//     required this.errors,
//   });
//
//   factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
//     return LoginResponseModel(
//       message: json['message'] ?? '',
//       success: json['success'] ?? false,
//       data: LoginData.fromJson(json['data'] ?? {}),
//       errors: json['errors'] ?? [],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       'success': success,
//       'data': data.toJson(),
//       'errors': errors,
//     };
//   }
// }
//
// class LoginData {
//   final Employee employee;
//   final String token;
//
//   LoginData({
//     required this.employee,
//     required this.token,
//   });
//
//   factory LoginData.fromJson(Map<String, dynamic> json) {
//     return LoginData(
//       employee: Employee.fromJson(json['employee'] ?? {}),
//       token: json['token'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'employee': employee.toJson(),
//       'token': token,
//     };
//   }
// }
//
// class Employee {
//   final int id;
//   final String employeeID;
//   final String employeeName;
//   final String designation;
//   final int roleId;
//   final String contact;
//   final String email;
//   final String address;
//   final double salary;
//   final String dateOfJoining;
//   final String dateOfBirth;
//   final String gender;
//   final String? profilePicture;
//   final String status;
//   final int isDeleted;
//   final String addedBy;
//   final int addedById;
//   final String createdAt;
//   final String updatedAt;
//   final String hotelOwnerName;
//   final String organizationName;
//
//   Employee({
//     required this.id,
//     required this.employeeID,
//     required this.employeeName,
//     required this.designation,
//     required this.roleId,
//     required this.contact,
//     required this.email,
//     required this.address,
//     required this.salary,
//     required this.dateOfJoining,
//     required this.dateOfBirth,
//     required this.gender,
//     this.profilePicture,
//     required this.status,
//     required this.isDeleted,
//     required this.addedBy,
//     required this.addedById,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.hotelOwnerName,
//     required this.organizationName,
//   });
//
//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       id: json['id'] ?? 0,
//       employeeID: json['employeeID'] ?? '',
//       employeeName: json['employeeName'] ?? '',
//       designation: json['designation'] ?? '',
//       roleId: json['role_id'] ?? 0,
//       contact: json['contact'] ?? '',
//       email: json['email'] ?? '',
//       address: json['address'] ?? '',
//       salary: (json['salary'] ?? 0).toDouble(),
//       dateOfJoining: json['dateOfJoining'] ?? '',
//       dateOfBirth: json['dateOfBirth'] ?? '',
//       gender: json['gender'] ?? '',
//       profilePicture: json['profilePicture'],
//       status: json['status'] ?? '',
//       isDeleted: json['is_deleted'] ?? 0,
//       addedBy: json['added_by'] ?? '',
//       addedById: json['added_by_id'] ?? 0,
//       createdAt: json['createdAt'] ?? '',
//       updatedAt: json['updatedAt'] ?? '',
//       hotelOwnerName: json['hotel_owner_name'] ?? '',
//       organizationName: json['organization_name'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'employeeID': employeeID,
//       'employeeName': employeeName,
//       'designation': designation,
//       'role_id': roleId,
//       'contact': contact,
//       'email': email,
//       'address': address,
//       'salary': salary,
//       'dateOfJoining': dateOfJoining,
//       'dateOfBirth': dateOfBirth,
//       'gender': gender,
//       'profilePicture': profilePicture,
//       'status': status,
//       'is_deleted': isDeleted,
//       'added_by': addedBy,
//       'added_by_id': addedById,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//       'hotel_owner_name': hotelOwnerName,
//       'organization_name': organizationName,
//     };
//   }
//
//   // Helper methods
//   String get fullName => employeeName;
//   String get role => designation;
//   bool get isActive => status.toLowerCase() == 'active';
//   bool get isChef => designation.toLowerCase() == 'chef';
//   bool get isWaiter => designation.toLowerCase() == 'waiter';
// }
//

// models/login_response_model.dart
class LoginResponseModel {
  final String message;
  final bool success;
  final LoginData data;
  final List<dynamic> errors;

  LoginResponseModel({
    required this.message,
    required this.success,
    required this.data,
    required this.errors,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: LoginData.fromJson(json['data'] ?? {}),
      errors: json['errors'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data.toJson(),
      'errors': errors,
    };
  }
}

class LoginData {
  final Employee employee;
  final HotelOwner hotelOwner;
  final String token;
  final String expiresIn;

  LoginData({
    required this.employee,
    required this.hotelOwner,
    required this.token,
    required this.expiresIn,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      employee: Employee.fromJson(json['employee'] ?? {}),
      hotelOwner: HotelOwner.fromJson(json['hotelOwner'] ?? {}),
      token: json['token'] ?? '',
      expiresIn: json['expiresIn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee': employee.toJson(),
      'hotelOwner': hotelOwner.toJson(),
      'token': token,
      'expiresIn': expiresIn,
    };
  }
}

class Employee {
  final int id;
  final String employeeID;
  final String employeeName;
  final String designation;
  final int roleId;
  final String contact;
  final String email;
  final String address;
  final double salary;
  final String dateOfJoining;
  final String dateOfBirth;
  final String gender;
  final String? profilePicture;
  final String status;
  final int isDeleted;
  final String addedBy;
  final int addedById;
  final String createdAt;
  final String updatedAt;
  final int hotelOwnerId;
  final String ownersName;
  final String ownerEmail;
  final String ownerContact;
  final String organizationType;
  final String organizationName;
  final String ownerAddress;
  final String startDate;
  final String endDate;
  final String ownerDescription;
  final String kycAdhaarNumber;
  final String? kycOtherDetails;
  final int ownerVerified;
  final String ownerUsername;
  final String? ownerDeletedAt;
  final int hotelOwnerCode;

  Employee({
    required this.id,
    required this.employeeID,
    required this.employeeName,
    required this.designation,
    required this.roleId,
    required this.contact,
    required this.email,
    required this.address,
    required this.salary,
    required this.dateOfJoining,
    required this.dateOfBirth,
    required this.gender,
    this.profilePicture,
    required this.status,
    required this.isDeleted,
    required this.addedBy,
    required this.addedById,
    required this.createdAt,
    required this.updatedAt,
    required this.hotelOwnerId,
    required this.ownersName,
    required this.ownerEmail,
    required this.ownerContact,
    required this.organizationType,
    required this.organizationName,
    required this.ownerAddress,
    required this.startDate,
    required this.endDate,
    required this.ownerDescription,
    required this.kycAdhaarNumber,
    this.kycOtherDetails,
    required this.ownerVerified,
    required this.ownerUsername,
    this.ownerDeletedAt,
    required this.hotelOwnerCode,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      employeeID: json['employeeID'] ?? '',
      employeeName: json['employeeName'] ?? '',
      designation: json['designation'] ?? '',
      roleId: json['role_id'] ?? 0,
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      dateOfJoining: json['dateOfJoining'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      profilePicture: json['profilePicture'],
      status: json['status'] ?? '',
      isDeleted: json['is_deleted'] ?? 0,
      addedBy: json['added_by'] ?? '',
      addedById: json['added_by_id'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      hotelOwnerId: json['hotel_owner_id'] ?? 0,
      ownersName: json['owners_name'] ?? '',
      ownerEmail: json['owner_email'] ?? '',
      ownerContact: json['owner_contact'] ?? '',
      organizationType: json['organization_type'] ?? '',
      organizationName: json['organization_name'] ?? '',
      ownerAddress: json['owner_address'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      ownerDescription: json['owner_description'] ?? '',
      kycAdhaarNumber: json['kyc_adhaar_number'] ?? '',
      kycOtherDetails: json['kyc_other_details'],
      ownerVerified: json['owner_verified'] ?? 0,
      ownerUsername: json['owner_username'] ?? '',
      ownerDeletedAt: json['owner_deleted_at'],
      hotelOwnerCode: json['hotel_owner_code'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeID': employeeID,
      'employeeName': employeeName,
      'designation': designation,
      'role_id': roleId,
      'contact': contact,
      'email': email,
      'address': address,
      'salary': salary,
      'dateOfJoining': dateOfJoining,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profilePicture': profilePicture,
      'status': status,
      'is_deleted': isDeleted,
      'added_by': addedBy,
      'added_by_id': addedById,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'hotel_owner_id': hotelOwnerId,
      'owners_name': ownersName,
      'owner_email': ownerEmail,
      'owner_contact': ownerContact,
      'organization_type': organizationType,
      'organization_name': organizationName,
      'owner_address': ownerAddress,
      'start_date': startDate,
      'end_date': endDate,
      'owner_description': ownerDescription,
      'kyc_adhaar_number': kycAdhaarNumber,
      'kyc_other_details': kycOtherDetails,
      'owner_verified': ownerVerified,
      'owner_username': ownerUsername,
      'owner_deleted_at': ownerDeletedAt,
      'hotel_owner_code': hotelOwnerCode,
    };
  }

  // Helper methods
  String get fullName => employeeName;
  String get role => designation;
  bool get isActive => status.toLowerCase() == 'active';
  bool get isChef => designation.toLowerCase() == 'chef';
  bool get isWaiter => designation.toLowerCase() == 'waiter';
}

class HotelOwner {
  final int id;
  final String ownersName;
  final String organizationType;
  final String organizationName;
  final String address;
  final String startDate;
  final String endDate;
  final String description;
  final String kycAdhaarNumber;
  final String? kycOtherDetails;
  final int verified;
  final String username;
  final String? deletedAt;
  final int hotelOwnerCode;
  final String email;
  final String contact;

  HotelOwner({
    required this.id,
    required this.ownersName,
    required this.organizationType,
    required this.organizationName,
    required this.address,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.kycAdhaarNumber,
    this.kycOtherDetails,
    required this.verified,
    required this.username,
    this.deletedAt,
    required this.hotelOwnerCode,
    required this.email,
    required this.contact,
  });

  factory HotelOwner.fromJson(Map<String, dynamic> json) {
    return HotelOwner(
      id: json['id'] ?? 0,
      ownersName: json['owners_name'] ?? '',
      organizationType: json['organization_type'] ?? '',
      organizationName: json['organization_name'] ?? '',
      address: json['address'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      description: json['description'] ?? '',
      kycAdhaarNumber: json['kyc_adhaar_number'] ?? '',
      kycOtherDetails: json['kyc_other_details'],
      verified: json['verified'] ?? 0,
      username: json['username'] ?? '',
      deletedAt: json['deleted_at'],
      hotelOwnerCode: json['hotel_owner_code'] ?? 0,
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owners_name': ownersName,
      'organization_type': organizationType,
      'organization_name': organizationName,
      'address': address,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
      'kyc_adhaar_number': kycAdhaarNumber,
      'kyc_other_details': kycOtherDetails,
      'verified': verified,
      'username': username,
      'deleted_at': deletedAt,
      'hotel_owner_code': hotelOwnerCode,
      'email': email,
      'contact': contact,
    };
  }

  // Helper methods
  bool get isVerified => verified == 1;
  bool get isDeleted => deletedAt != null;
}