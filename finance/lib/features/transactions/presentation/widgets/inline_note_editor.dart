import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/text_input.dart';
import '../../../../shared/widgets/app_text.dart';
import '../bloc/transaction_detail_bloc.dart';
import '../bloc/transaction_detail_event.dart';

class InlineNoteEditor extends StatefulWidget {
  final int transactionId;
  final String? initialNote;
  final bool isLoading;

  const InlineNoteEditor({
    super.key,
    required this.transactionId,
    this.initialNote,
    this.isLoading = false,
  });

  @override
  State<InlineNoteEditor> createState() => _InlineNoteEditorState();
}

class _InlineNoteEditorState extends State<InlineNoteEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
    _focusNode = FocusNode();
    
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(InlineNoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialNote != widget.initialNote) {
      _controller.text = widget.initialNote ?? '';
    }
  }

  void _onNoteChanged(String value) {
    context.read<TransactionDetailBloc>().add(
      UpdateTransactionNote(widget.transactionId, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              const AppText(
                'Note',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              const Spacer(),
              if (widget.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextInput(
            controller: _controller,
            focusNode: _focusNode,
            hintText: 'Add a note...',
            style: TextInputStyle.minimal,
            maxLines: _isExpanded ? 6 : 3,
            minLines: 1,
            onChanged: _onNoteChanged,
            padding: const EdgeInsetsDirectional.all(0),
            backgroundColor: Colors.transparent,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _focusNode.unfocus();
                  },
                  child: const AppText('Done', fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}