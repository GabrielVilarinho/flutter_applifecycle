import 'package:bip39/bip39.dart';

enum Strenght
{
  twelve,
  twentyFour,
}

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
}