import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/theme.dart';
import '../widgets/chat_bubble.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(OnboardingProvider provider) {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    _messageCtrl.clear();

    setState(() => _isTyping = true);
    provider.sendMessage(text);

    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isTyping = false);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Text('S', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SmartOne Support', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('Online • Replies instantly', style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                onPressed: () => _showContactOptions(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Status banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: AppTheme.primarySurface,
                child: const Row(
                  children: [
                    Icon(Icons.support_agent_outlined, size: 16, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Support available Mon–Fri, 9AM–6PM CET. Avg. response: < 2 min',
                        style: TextStyle(fontSize: 12, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: provider.chatMessages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (_isTyping && i == provider.chatMessages.length) {
                      return _buildTypingIndicator();
                    }
                    return ChatBubble(message: provider.chatMessages[i]);
                  },
                ),
              ),
              // Quick replies
              _buildQuickReplies(provider),
              // Input bar
              _buildInputBar(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface, shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: const Center(child: Text('S', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16),
                bottomRight: Radius.circular(16), bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotIndicator(delay: 0),
                SizedBox(width: 4),
                _DotIndicator(delay: 200),
                SizedBox(width: 4),
                _DotIndicator(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(OnboardingProvider provider) {
    final quickReplies = [
      'What documents do I need?',
      'How long does KYC take?',
      'When will I receive my terminal?',
      'How do I sign the contract?',
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickReplies.length,
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTap: () {
              _messageCtrl.text = quickReplies[i];
              _sendMessage(provider);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Text(
                quickReplies[i],
                style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(OnboardingProvider provider) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: const Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _messageCtrl,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  isCollapsed: true,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(provider),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(provider),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Contact Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _contactOption(ctx, Icons.chat_outlined, 'Live Chat', 'Available now', AppTheme.primary),
            const SizedBox(height: 12),
            _contactOption(ctx, Icons.phone_outlined, 'Phone', '+44 20 7946 0100', AppTheme.success),
            const SizedBox(height: 12),
            _contactOption(ctx, Icons.email_outlined, 'Email', 'support@smartone.com', AppTheme.warning),
            const SizedBox(height: 12),
            _contactOption(ctx, Icons.schedule_outlined, 'Hours', 'Mon–Fri, 9AM–6PM CET', AppTheme.textSecondary),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _contactOption(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(value, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatefulWidget {
  final int delay;
  const _DotIndicator({required this.delay});

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7 + (_anim.value * 4),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.5 + _anim.value * 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
