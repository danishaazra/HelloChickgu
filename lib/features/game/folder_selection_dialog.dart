import 'package:flutter/material.dart';

class FolderSelectionDialog extends StatefulWidget {
  final List<String> existingFolders;
  final Function(String folderName) onFolderSelected;

  const FolderSelectionDialog({
    super.key,
    required this.existingFolders,
    required this.onFolderSelected,
  });

  @override
  State<FolderSelectionDialog> createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends State<FolderSelectionDialog> {
  final TextEditingController _newFolderController = TextEditingController();
  bool _isCreatingNew = false;

  @override
  void dispose() {
    _newFolderController.dispose();
    super.dispose();
  }

  void _selectFolder(String folderName) {
    widget.onFolderSelected(folderName);
    Navigator.of(context).pop();
  }

  void _createNewFolder() {
    final folderName = _newFolderController.text.trim();
    if (folderName.isNotEmpty) {
      widget.onFolderSelected(folderName);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.folder, color: Color(0xFF4FC3F7), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Save Quiz To',
                  style: TextStyle(
                    fontFamily: 'Baloo2',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E342E),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Existing folders
            Text(
              'Existing Folders',
              style: TextStyle(
                fontFamily: 'Baloo2',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4E342E),
              ),
            ),
            const SizedBox(height: 12),

            // Folder list
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: widget.existingFolders.length,
                itemBuilder: (context, index) {
                  final folder = widget.existingFolders[index];
                  return ListTile(
                    leading: const Icon(Icons.folder, color: Color(0xFF4FC3F7)),
                    title: Text(
                      folder,
                      style: const TextStyle(
                        fontFamily: 'Baloo2',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _selectFolder(folder),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Create new folder section
            Row(
              children: [
                Expanded(child: Container(height: 1, color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 20),

            // Create new folder button
            if (!_isCreatingNew)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isCreatingNew = true;
                    });
                  },
                  icon: const Icon(
                    Icons.create_new_folder,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Create New Folder',
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            // New folder input
            if (_isCreatingNew) ...[
              TextField(
                controller: _newFolderController,
                decoration: InputDecoration(
                  labelText: 'Folder Name',
                  labelStyle: TextStyle(
                    fontFamily: 'Baloo2',
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4FC3F7),
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Baloo2'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isCreatingNew = false;
                          _newFolderController.clear();
                        });
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Baloo2',
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createNewFolder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4FC3F7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create',
                        style: TextStyle(fontFamily: 'Baloo2'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
