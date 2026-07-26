/// An enquiry sent from the website's Contact form.
class ContactMessage {
  final String id;
  final String fullName;
  final String email;
  final String? subject;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const ContactMessage({
    required this.id,
    required this.fullName,
    required this.email,
    this.subject,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory ContactMessage.fromJson(Map<String, dynamic> json) {
    return ContactMessage(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      subject: json['subject'] as String?,
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

/// An email captured by the footer's subscribe box.
class NewsletterSubscriber {
  final String id;
  final String email;
  final DateTime? createdAt;

  const NewsletterSubscriber({
    required this.id,
    required this.email,
    this.createdAt,
  });

  factory NewsletterSubscriber.fromJson(Map<String, dynamic> json) {
    return NewsletterSubscriber(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
