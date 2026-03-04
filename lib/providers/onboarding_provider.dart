import 'package:flutter/foundation.dart';
import '../models/onboarding_step_model.dart';
import '../models/document_model.dart';
import '../models/merchant_model.dart';
import '../models/chat_message_model.dart';
import '../utils/constants.dart';

class OnboardingProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isNewMerchant = false;
  MerchantApplication _merchant = MerchantApplication.demo();
  List<OnboardingStep> _steps = [];
  List<DocumentItem> _documents = [];
  List<ChatMessage> _chatMessages = List.from(mockSupportMessages);
  bool _kycStarted = false;
  bool _kycCompleted = false;
  bool _contractSigned = false;
  int _currentTabIndex = 0;

  bool get isLoggedIn => _isLoggedIn;
  bool get isNewMerchant => _isNewMerchant;
  MerchantApplication get merchant => _merchant;
  List<OnboardingStep> get steps => _steps;
  List<DocumentItem> get documents => _documents;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get kycStarted => _kycStarted;
  bool get kycCompleted => _kycCompleted;
  bool get contractSigned => _contractSigned;
  int get currentTabIndex => _currentTabIndex;

  int get currentStepIndex {
    final idx = _steps.indexWhere((s) => s.isCurrent);
    return idx >= 0 ? idx : _steps.length - 1;
  }

  double get progressPercentage {
    if (_steps.isEmpty) return 0;
    final completed = _steps.where((s) => s.isCompleted).length;
    return completed / _steps.length;
  }

  int get completedStepsCount => _steps.where((s) => s.isCompleted).length;
  int get totalStepsCount => _steps.length;

  int get uploadedDocumentsCount => _documents.where((d) => d.isUploaded).length;
  int get totalDocumentsCount => _documents.length;

  OnboardingProvider() {
    _initializeData();
  }

  void _initializeData() {
    // Initialize onboarding steps with demo at step 4 (index 3)
    _steps = List.generate(AppConstants.stepNames.length, (i) {
      StepStatus status;
      DateTime? completedAt;
      if (i < 3) {
        status = StepStatus.completed;
        completedAt = DateTime.now().subtract(Duration(days: 5 - i));
      } else if (i == 3) {
        status = StepStatus.current;
      } else {
        status = StepStatus.locked;
      }
      return OnboardingStep(
        index: i,
        name: AppConstants.stepNames[i],
        description: AppConstants.stepDescriptions[i],
        status: status,
        completedAt: completedAt,
      );
    });

    // Initialize documents – some uploaded for demo
    _documents = List.generate(AppConstants.requiredDocuments.length, (i) {
      if (i < 2) {
        return DocumentItem(
          name: AppConstants.requiredDocuments[i],
          description: AppConstants.documentDescriptions[i],
          status: DocumentStatus.verified,
          fileName: 'document_${i + 1}.pdf',
          uploadedAt: DateTime.now().subtract(Duration(days: 4 - i)),
        );
      } else if (i == 2) {
        return DocumentItem(
          name: AppConstants.requiredDocuments[i],
          description: AppConstants.documentDescriptions[i],
          status: DocumentStatus.uploaded,
          fileName: 'ubo_declaration.pdf',
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        );
      }
      return DocumentItem(
        name: AppConstants.requiredDocuments[i],
        description: AppConstants.documentDescriptions[i],
        status: DocumentStatus.missing,
      );
    });
  }

  void loginAsDemo() {
    _isLoggedIn = true;
    _isNewMerchant = false;
    notifyListeners();
  }

  void startAsNewMerchant() {
    _isLoggedIn = true;
    _isNewMerchant = true;
    _merchant = MerchantApplication();
    _steps = List.generate(AppConstants.stepNames.length, (i) {
      return OnboardingStep(
        index: i,
        name: AppConstants.stepNames[i],
        description: AppConstants.stepDescriptions[i],
        status: i == 0 ? StepStatus.current : StepStatus.locked,
      );
    });
    _documents = List.generate(AppConstants.requiredDocuments.length, (i) {
      return DocumentItem(
        name: AppConstants.requiredDocuments[i],
        description: AppConstants.documentDescriptions[i],
        status: DocumentStatus.missing,
      );
    });
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isNewMerchant = false;
    _merchant = MerchantApplication.demo();
    _initializeData();
    _currentTabIndex = 0;
    notifyListeners();
  }

  void submitApplication(MerchantApplication application) {
    _merchant = application;
    _merchant.isSubmitted = true;
    _merchant.submittedAt = DateTime.now();
    _advanceStep(0);
    notifyListeners();
  }

  void uploadDocument(int index, String fileName) {
    if (index >= 0 && index < _documents.length) {
      _documents[index] = _documents[index].copyWith(
        status: DocumentStatus.uploaded,
        fileName: fileName,
        uploadedAt: DateTime.now(),
      );
      // If all docs uploaded, advance step
      if (_documents.every((d) => d.isUploaded)) {
        _advanceStep(1);
      }
      notifyListeners();
    }
  }

  void startKyc() {
    _kycStarted = true;
    notifyListeners();
  }

  void completeKyc() {
    _kycCompleted = true;
    _advanceStep(2);
    notifyListeners();
  }

  void signContract() {
    _contractSigned = true;
    _advanceStep(6);
    notifyListeners();
  }

  // Admin panel: manually set step status
  void setStepStatus(int stepIndex, StepStatus status) {
    if (stepIndex < 0 || stepIndex >= _steps.length) return;

    // Rebuild all steps based on setting this one as the new target
    if (status == StepStatus.current) {
      _steps = _steps.map((step) {
        if (step.index < stepIndex) {
          return step.copyWith(
            status: StepStatus.completed,
            completedAt: DateTime.now().subtract(Duration(days: stepIndex - step.index)),
          );
        } else if (step.index == stepIndex) {
          return step.copyWith(status: StepStatus.current);
        } else {
          return step.copyWith(status: StepStatus.locked);
        }
      }).toList();
    } else if (status == StepStatus.completed) {
      _steps[stepIndex] = _steps[stepIndex].copyWith(
        status: StepStatus.completed,
        completedAt: DateTime.now(),
      );
      // Set next as current if locked
      if (stepIndex + 1 < _steps.length && _steps[stepIndex + 1].isLocked) {
        _steps[stepIndex + 1] = _steps[stepIndex + 1].copyWith(status: StepStatus.current);
      }
    } else {
      _steps[stepIndex] = _steps[stepIndex].copyWith(status: status);
    }
    notifyListeners();
  }

  void _advanceStep(int completedIndex) {
    if (completedIndex < _steps.length) {
      _steps[completedIndex] = _steps[completedIndex].copyWith(
        status: StepStatus.completed,
        completedAt: DateTime.now(),
      );
      if (completedIndex + 1 < _steps.length) {
        _steps[completedIndex + 1] = _steps[completedIndex + 1].copyWith(
          status: StepStatus.current,
        );
      }
    }
  }

  void sendMessage(String text) {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.merchant,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _chatMessages.add(msg);
    notifyListeners();

    // Simulate support auto-reply after delay
    Future.delayed(const Duration(seconds: 2), () {
      _addSupportReply(text);
    });
  }

  void _addSupportReply(String merchantMessage) {
    final lower = merchantMessage.toLowerCase();
    String reply;

    if (lower.contains('kyc') || lower.contains('verif')) {
      reply = 'KYC verification is handled by our partner iDenfy. Please tap "Start KYC Verification" on the KYC screen. The process takes about 5-10 minutes.';
    } else if (lower.contains('document') || lower.contains('upload')) {
      reply = 'You can upload your documents in the Documents tab. Make sure all 6 required documents are uploaded in PDF or image format.';
    } else if (lower.contains('terminal') || lower.contains('pos')) {
      reply = 'POS terminal preparation begins after Paynetics approval. Our DNA Payments team will contact you to arrange delivery and setup.';
    } else if (lower.contains('contract') || lower.contains('sign')) {
      reply = 'The merchant agreement will be available for signing once Paynetics approves your application. You\'ll receive a notification.';
    } else if (lower.contains('time') || lower.contains('long') || lower.contains('when')) {
      reply = 'The full onboarding process typically takes 5-7 business days from document submission. We\'ll keep you updated at every step!';
    } else {
      reply = 'Thank you for your message! Our onboarding team will review this and get back to you shortly. For urgent matters, please call +44 20 7946 0100.';
    }

    final supportMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: reply,
      sender: MessageSender.support,
      timestamp: DateTime.now(),
      isRead: false,
    );
    _chatMessages.add(supportMsg);
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
