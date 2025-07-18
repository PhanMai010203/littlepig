import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../../core/services/file_picker_service.dart';
import '../../domain/entities/attachment.dart';
import 'transaction_detail_event.dart';
import 'transaction_detail_state.dart';

class TransactionDetailBloc extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final TransactionRepository _transactionRepository;
  final AttachmentRepository _attachmentRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;
  final FilePickerService _filePickerService;
  final GoogleSignIn _googleSignIn;
  final ImagePicker _imagePicker;

  Timer? _noteUpdateTimer;

  TransactionDetailBloc({
    required TransactionRepository transactionRepository,
    required AttachmentRepository attachmentRepository,
    required CategoryRepository categoryRepository,
    required AccountRepository accountRepository,
    required FilePickerService filePickerService,
    required GoogleSignIn googleSignIn,
    required ImagePicker imagePicker,
  })  : _transactionRepository = transactionRepository,
        _attachmentRepository = attachmentRepository,
        _categoryRepository = categoryRepository,
        _accountRepository = accountRepository,
        _filePickerService = filePickerService,
        _googleSignIn = googleSignIn,
        _imagePicker = imagePicker,
        super(TransactionDetailInitial()) {
    on<LoadTransactionDetail>(_onLoadTransactionDetail);
    on<LoadTransactionAttachments>(_onLoadTransactionAttachments);
    on<UpdateTransactionDetail>(_onUpdateTransactionDetail);
    on<DeleteTransactionDetail>(_onDeleteTransactionDetail);
    on<RefreshTransactionDetail>(_onRefreshTransactionDetail);
    on<UpdateTransactionNote>(_onUpdateTransactionNote);
    on<AddAttachment>(_onAddAttachment);
    on<DeleteAttachment>(_onDeleteAttachment);
    on<CheckGoogleDriveAuth>(_onCheckGoogleDriveAuth);
    on<AuthenticateGoogleDrive>(_onAuthenticateGoogleDrive);
    on<AddAttachmentFromCamera>(_onAddAttachmentFromCamera);
    on<AddAttachmentFromGallery>(_onAddAttachmentFromGallery);
    on<AddAttachmentFromFiles>(_onAddAttachmentFromFiles);
  }

  @override
  Future<void> close() {
    _noteUpdateTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoadTransactionDetail(
    LoadTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    try {
      emit(TransactionDetailLoading());

      // Load transaction
      final transaction = await _transactionRepository.getTransactionById(event.transactionId);
      if (transaction == null) {
        emit(const TransactionDetailError('Transaction not found'));
        return;
      }

      // Load attachments
      final attachments = await _attachmentRepository.getAttachmentsByTransaction(event.transactionId);

      // Load category
      final category = await _categoryRepository.getCategoryById(transaction.categoryId);

      // Load account
      final account = await _accountRepository.getAccountById(transaction.accountId);

      // Check Google Drive authentication status
      final isAuthenticated = await _googleSignIn.isSignedIn();
      
      emit(TransactionDetailLoaded(
        transaction: transaction,
        attachments: attachments,
        category: category,
        account: account,
        isGoogleDriveAuthenticated: isAuthenticated,
      ));
    } catch (e) {
      emit(TransactionDetailError('Failed to load transaction: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransactionAttachments(
    LoadTransactionAttachments event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      try {
        final currentState = state as TransactionDetailLoaded;
        final attachments = await _attachmentRepository.getAttachmentsByTransaction(event.transactionId);
        
        emit(currentState.copyWith(attachments: attachments));
      } catch (e) {
        emit(TransactionDetailError('Failed to load attachments: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateTransactionDetail(
    UpdateTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    try {
      final updatedTransaction = await _transactionRepository.updateTransaction(event.transaction);
      
      emit(const TransactionDetailActionSuccess('Transaction updated successfully'));
      
      // Reload the transaction detail
      add(LoadTransactionDetail(updatedTransaction.id!));
    } catch (e) {
      emit(TransactionDetailError('Failed to update transaction: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransactionDetail(
    DeleteTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    try {
      // Delete all attachments first
      final attachments = await _attachmentRepository.getAttachmentsByTransaction(event.transactionId);
      for (final attachment in attachments) {
        if (attachment.id != null) {
          await _attachmentRepository.deleteAttachment(attachment.id!);
        }
      }

      // Delete the transaction
      await _transactionRepository.deleteTransaction(event.transactionId);
      
      emit(const TransactionDetailActionSuccess('Transaction deleted successfully'));
    } catch (e) {
      emit(TransactionDetailError('Failed to delete transaction: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshTransactionDetail(
    RefreshTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    add(LoadTransactionDetail(event.transactionId));
  }

  Future<void> _onUpdateTransactionNote(
    UpdateTransactionNote event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      final currentState = state as TransactionDetailLoaded;
      
      // Cancel any existing timer
      _noteUpdateTimer?.cancel();
      
      // Update the transaction note immediately in the UI
      final updatedTransaction = currentState.transaction.copyWith(note: event.note);
      emit(currentState.copyWith(transaction: updatedTransaction, isNoteSaving: true));
      
      // Set up a debounced save
      _noteUpdateTimer = Timer(const Duration(milliseconds: 500), () async {
        try {
          await _transactionRepository.updateTransaction(updatedTransaction);
          if (state is TransactionDetailLoaded) {
            emit((state as TransactionDetailLoaded).copyWith(isNoteSaving: false));
          }
        } catch (e) {
          if (state is TransactionDetailLoaded) {
            emit((state as TransactionDetailLoaded).copyWith(isNoteSaving: false));
          }
          emit(TransactionDetailError('Failed to save note: ${e.toString()}'));
        }
      });
    }
  }

  Future<void> _onAddAttachment(
    AddAttachment event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      final currentState = state as TransactionDetailLoaded;
      
      try {
        emit(currentState.copyWith(isAttachmentLoading: true));
        
        final newAttachments = await _filePickerService.addAttachments(event.transactionId);
        
        if (newAttachments.isNotEmpty) {
          final updatedAttachments = [...currentState.attachments, ...newAttachments];
          emit(currentState.copyWith(
            attachments: updatedAttachments, 
            isAttachmentLoading: false,
          ));
        } else {
          emit(currentState.copyWith(isAttachmentLoading: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isAttachmentLoading: false));
        emit(TransactionDetailError('Failed to add attachment: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteAttachment(
    DeleteAttachment event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      final currentState = state as TransactionDetailLoaded;
      
      try {
        await _attachmentRepository.deleteAttachment(event.attachmentId);
        
        final updatedAttachments = currentState.attachments
            .where((attachment) => attachment.id != event.attachmentId)
            .toList();
        
        emit(currentState.copyWith(attachments: updatedAttachments));
        emit(const TransactionDetailActionSuccess('Attachment deleted successfully'));
      } catch (e) {
        emit(TransactionDetailError('Failed to delete attachment: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCheckGoogleDriveAuth(
    CheckGoogleDriveAuth event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      try {
        final currentState = state as TransactionDetailLoaded;
        final isAuthenticated = await _googleSignIn.isSignedIn();
        
        emit(currentState.copyWith(
          isGoogleDriveAuthenticated: isAuthenticated,
        ));
      } catch (e) {
        emit(TransactionDetailError('Failed to check authentication: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAuthenticateGoogleDrive(
    AuthenticateGoogleDrive event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      final currentState = state as TransactionDetailLoaded;
      
      try {
        emit(currentState.copyWith(isAuthenticating: true));
        
        final account = await _googleSignIn.signIn();
        final isAuthenticated = account != null;
        
        emit(currentState.copyWith(
          isAuthenticating: false,
          isGoogleDriveAuthenticated: isAuthenticated,
        ));
        
        if (isAuthenticated) {
          emit(const TransactionDetailActionSuccess('Google Drive connected successfully'));
        } else {
          emit(TransactionDetailError('Google Drive authentication was cancelled'));
        }
      } catch (e) {
        emit(currentState.copyWith(isAuthenticating: false));
        emit(TransactionDetailError('Failed to authenticate with Google Drive: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddAttachmentFromCamera(
    AddAttachmentFromCamera event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      final currentState = state as TransactionDetailLoaded;
      
      try {
        emit(currentState.copyWith(isAttachmentLoading: true));
        
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        
        if (image != null) {
          final fileName = path.basename(image.path);
          final attachment = await _processAttachment(
            image.path,
            event.transactionId,
            fileName,
            isCapturedFromCamera: true,
          );
          
          final updatedAttachments = [...currentState.attachments, attachment];
          emit(currentState.copyWith(
            attachments: updatedAttachments,
            isAttachmentLoading: false,
          ));
          
          emit(TransactionDetailActionSuccess('Photo captured and saved'));
        } else {
          emit(currentState.copyWith(isAttachmentLoading: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isAttachmentLoading: false));
        emit(TransactionDetailError('Failed to capture photo: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddAttachmentFromGallery(
    AddAttachmentFromGallery event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      final currentState = state as TransactionDetailLoaded;
      
      try {
        emit(currentState.copyWith(isAttachmentLoading: true));
        
        final List<XFile> images = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        
        if (images.isNotEmpty) {
          final newAttachments = <Attachment>[];
          for (final image in images) {
            final fileName = path.basename(image.path);
            final attachment = await _processAttachment(
              image.path,
              event.transactionId,
              fileName,
              isCapturedFromCamera: false,
            );
            newAttachments.add(attachment);
          }
          
          final updatedAttachments = [...currentState.attachments, ...newAttachments];
          emit(currentState.copyWith(
            attachments: updatedAttachments,
            isAttachmentLoading: false,
          ));
          
          emit(TransactionDetailActionSuccess('${images.length} image(s) added'));
        } else {
          emit(currentState.copyWith(isAttachmentLoading: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isAttachmentLoading: false));
        emit(TransactionDetailError('Failed to select images: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAddAttachmentFromFiles(
    AddAttachmentFromFiles event,
    Emitter<TransactionDetailState> emit,
  ) async {
    if (state is TransactionDetailLoaded) {
      final currentState = state as TransactionDetailLoaded;
      
      try {
        emit(currentState.copyWith(isAttachmentLoading: true));
        
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any,
        );
        
        if (result != null && result.files.isNotEmpty) {
          final newAttachments = <Attachment>[];
          for (final file in result.files) {
            if (file.path != null) {
              final attachment = await _processAttachment(
                file.path!,
                event.transactionId,
                file.name,
                isCapturedFromCamera: false,
              );
              newAttachments.add(attachment);
            }
          }
          
          final updatedAttachments = [...currentState.attachments, ...newAttachments];
          emit(currentState.copyWith(
            attachments: updatedAttachments,
            isAttachmentLoading: false,
          ));
          
          emit(TransactionDetailActionSuccess('${result.files.length} file(s) added'));
        } else {
          emit(currentState.copyWith(isAttachmentLoading: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isAttachmentLoading: false));
        emit(TransactionDetailError('Failed to select files: ${e.toString()}'));
      }
    }
  }

  Future<Attachment> _processAttachment(
    String filePath,
    int transactionId,
    String fileName,
    {required bool isCapturedFromCamera}
  ) async {
    // Create attachment using the attachment repository
    final attachment = await _attachmentRepository.compressAndStoreFile(
      filePath,
      transactionId,
      fileName,
      isCapturedFromCamera: isCapturedFromCamera,
    );
    
    // Create the attachment record
    final createdAttachment = await _attachmentRepository.createAttachment(attachment);
    
    // Upload to Google Drive
    await _attachmentRepository.uploadToGoogleDrive(createdAttachment);
    
    return createdAttachment;
  }
}