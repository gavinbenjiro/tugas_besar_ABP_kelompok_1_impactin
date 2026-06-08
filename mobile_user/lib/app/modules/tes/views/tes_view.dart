import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/tes_controller.dart';

class TesView extends GetView<TesController> {
  const TesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TesView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
