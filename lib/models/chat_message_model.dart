enum MessageSender { merchant, support }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
  });

  bool get isFromMerchant => sender == MessageSender.merchant;
  bool get isFromSupport => sender == MessageSender.support;
}

List<ChatMessage> mockSupportMessages = [
  ChatMessage(
    id: '1',
    text: 'Hello! Welcome to SmartOne Merchant Support. How can I help you today?',
    sender: MessageSender.support,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
  ),
  ChatMessage(
    id: '2',
    text: 'Hi, I have submitted my application form. What are the next steps?',
    sender: MessageSender.merchant,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
    isRead: true,
  ),
  ChatMessage(
    id: '3',
    text: 'Great! Your application has been received. The next step is to upload your compliance documents. You\'ll need: Certificate of Incorporation, Company Registry Extract, UBO Declaration, Director Passport, Proof of Address, and Bank Account Confirmation.',
    sender: MessageSender.support,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
    isRead: true,
  ),
  ChatMessage(
    id: '4',
    text: 'How long does the KYC verification usually take?',
    sender: MessageSender.merchant,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    isRead: true,
  ),
  ChatMessage(
    id: '5',
    text: 'KYC verification via iDenfy typically takes 5-10 minutes for the identity check. The overall AML review may take 1-2 business days. We\'ll notify you at each stage!',
    sender: MessageSender.support,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
    isRead: true,
  ),
  ChatMessage(
    id: '6',
    text: 'Perfect, thank you! I\'ll start uploading the documents now.',
    sender: MessageSender.merchant,
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    isRead: true,
  ),
  ChatMessage(
    id: '7',
    text: 'Wonderful! If you have any questions during the process, don\'t hesitate to reach out. Our team is here Mon–Fri, 9AM–6PM CET. 😊',
    sender: MessageSender.support,
    timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    isRead: true,
  ),
];
