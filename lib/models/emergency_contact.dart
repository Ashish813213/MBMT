/// A saved contact the SOS screen can message on WhatsApp. Persisted to disk
/// via [StorageService] so it survives an app restart.
class EmergencyContact {
  final String id;
  final String name;
  final String phone;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'phone': phone,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
      );
}
