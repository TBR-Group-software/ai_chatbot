import 'package:flutter/material.dart';

class DeletePopupMenuItem extends PopupMenuItem<String> {
  const DeletePopupMenuItem({
    super.key,
  }) : super(
          value: 'delete',
          child: const Row(
            children: <Widget>[
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        );
} 