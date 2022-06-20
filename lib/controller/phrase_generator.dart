import 'package:bip39/bip39.dart';
import 'package:security/lib/types.dart';
import 'package:security/lib/wordlist.dart';

class PhraseGenerator
{
  static String generate(Strenght strength)
  {
    switch (strength)
    {
      case Strenght.twelve:
        return generateMnemonic(strength: 128);
      case Strenght.twentyFour:
        return generateMnemonic(strength: 256);
    }
  }

  static bool isValid(String wordString)
  {
    List<String> words = wordString.split(' ');

    if(![12,24].contains(words.length))
    {
      throw "Error at PhraseGenerator.isValid: Invalid mnemonic length";
    }

    for(String word in words)
    {
      if(!WORDLIST.contains(word.toLowerCase()))
      {
        throw "Error at PhraseGenerator.isValid: Unknown word found in mnemonic \"$word\"";
      }
    }
    return true;
  }
}