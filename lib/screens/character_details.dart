import 'package:flutter/material.dart';

import '../widgets/loading_image.dart';

class CharacterView extends StatelessWidget {
  const CharacterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name'),
      ),
      body: const LoadingImage(
        url:
            'https://th.bing.com/th/id/OIP.xUCAx0_XTEM_P0u83zvZOgHaE8?pid=ImgDet&w=8256&h=5504&rs=1',
      ),
    );
  }
}
