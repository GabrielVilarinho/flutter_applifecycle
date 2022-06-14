import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:security/lib/utils.dart';

enum AppRootFolder {
  json,
  managed,
  images,
}

class FileManager
{
  static final _self = FileManager._internal();
  Completer<bool> structureOk = Completer();

  FileManager._internal (){
    generateStructure();
  }

  factory FileManager() => _self;

  ///Generate folder inside Flutter's documents using
  ///the enum created above
  void generateStructure() async
  {
    Directory documentsFolder = await documents();
    for(AppRootFolder folderName in AppRootFolder.values)
    {
      Directory folder = Directory(documentsFolder.path + "/" + folderName.name + "/");
      if(folder.existsSync())
      {
        continue;
      }
      folder.createSync(recursive: true);
    }
    structureOk.complete(true);
  }

  static Future<Directory> documents({AppRootFolder? rootFolder}) async
  {
    Directory documentsFolder = await getApplicationDocumentsDirectory();
    if(rootFolder == null) {
      return documentsFolder;
    }
    return Directory(documentsFolder.path + "/${rootFolder.name}");
  }

  Future<Directory> _checkSubfolder(String path, {bool create = false}) async
  {
    List<String> folders = path.split("/\"");
    List<String> structureFolders = AppRootFolder.values.asNameMap().keys.toList();
    String validatingPath = (await documents()).path;
    for(int i = 0; i < folders.length; i++)
    {
      if(folders[i].contains(r'^.*\.[^\\]+$'))
      {
        /// Checking if the folder name has an extension...
        Utils.printWarning("Found filename \"${folders[i]}\"");
        continue;
      }
      if(i == 0 && structureFolders.contains(folders[i]))
      {
        /// Checking if the folder is a structure folder, since we create on
        ///every initialization of the App, is unnecessary to check it
        validatingPath += "/${folders[i]}";
        continue;
      }
      else if (i == 0)
      {
        throw "Error at FileManager: checkSubfolder is invalid, App is trying to create a new structural folder";
      }
      validatingPath += "/${folders[i]}";
      Directory subfolderPath = Directory(validatingPath);
      if(!subfolderPath.existsSync())
      {
        if(create) {
          subfolderPath.createSync(recursive: true);
        }
        else
        {
          throw 'Error at FileManager: Trying to access an non-existing folder';
        }
      }
      Utils.printMark(validatingPath);
    }
    return Directory(validatingPath);
  }

  static Future<bool> fileExists(String path, String filename) async
  {
    Directory documentsFolder = await documents();
    File file = File("${documentsFolder.path}/$path/$filename");
    return await file.exists();
  }

  static Future<bool> writeString(String path, String filename, dynamic object, {bool create = true}) async
  {
    // Utils.printWarning("What is this Object?$object");
    // await Future.delayed(Duration(seconds: 2));
    // return false;
    String content = "";
    if(object is! String) {
      content = jsonEncode(object);
    }
    else
    {
      content = object;
    }
    // Utils.printMark("Content $content");
    Directory directory = await _self._checkSubfolder(path, create: create);
    // Utils.printError(directory.absolute.path);
    File res = File("${directory.path}/$filename");
    // Utils.printWarning(res.absolute.path);
    if(await fileExists(path, filename))
    {
      Utils.printWarning("Overwriting \"$filename\" file at \"${res.absolute.path}\"");
    }
    else
    {
      Utils.printWarning("Creating \"$filename\" file at \"${res.absolute.path}\"");
    }
    try
    {
      await res.create();
      res.writeAsStringSync(content);
    }
    catch(e)
    {
      Utils.printWarning(e.toString());
      return false;
    }
    return true;
  }

  static Future<Object> readFile(String path, String filename, {asBytes = false}) async
  {
    Utils.printWarning("Reading file: \"$path/$filename\"");
    Directory directory = await _self._checkSubfolder(path);
    File res = File(directory.path + "/$filename");
    if(!(await fileExists(path, filename)))
    {
      // throw "Error at FileManager: File \"$fileName\" doesn't exists.";
      return false;
    }
    Uint8List bytes = res.readAsBytesSync();
    if(asBytes)
    {
      Utils.printApprove("Bytes<Uint8>: $bytes");
      return bytes;
    }
    String data = utf8.decode(bytes, allowMalformed: true);
    return data;
  }

  static Future<bool> removeFile(String path, String filename, {recursive = false}) async
  {
    Directory directory = await _self._checkSubfolder(path);
    File res = File(directory.path + "/$filename");
    if(!(await fileExists(path, filename)))
    {
      throw "Error at FileManager: File \"$filename\" doesn't exists.";
    }
    res.delete(recursive: recursive);
    return true;
  }
}