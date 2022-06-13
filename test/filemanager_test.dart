import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:security/controller/file_manager.dart';

class FileManagerTest
{
  static void main()
  {
    FileManager fileManager = FileManager();
    String folder = 'json';
    String fileName = 'test.txt';
    String content = 'Lorem ipsum';
    group('FileManager', () {
      test('Is the Documents Directory accessible', () async {
        completion(FileManager.documents());
      });

      test('Can generate structure', () async {
        bool didGenerateStructure = await fileManager.structureOk.future;
        expect(didGenerateStructure, true);
      });

      test('Can Write file', () async {
        bool canWrite = await FileManager.writeString(folder, fileName, content);
        expect(canWrite, true);
      });

      test('Can Read file', () async {
        dynamic data = await FileManager.readFile(folder, fileName);
        if(data is String)
        {
          expect(data, content);
        }
        else
        {
          fail("Data returned from FileManager.readFile is not type of String");
        }
      });

      test('Can Remove file', () async {
        bool canRemove = await FileManager.removeFile(folder, fileName);
        expect(canRemove, true);
      });
    });
  }
}
