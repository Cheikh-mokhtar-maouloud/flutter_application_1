import 'package:flutter/material.dart';

class button extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  const button({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF7165D6),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                "$title",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 20),
        //   child: ElevatedButton(
        //     onPressed: onPressed,
        //     style: ElevatedButton.styleFrom(
        //       padding: EdgeInsets.symmetric(
        //           vertical: 15, horizontal: 20), // Ajustez la taille ici
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //       primary: Color(0xFF7165D6),
        //     ),
        //     child: Text(
        //       "$title",
        //       style: TextStyle(
        //         fontSize: 22,
        //         color: Colors.white,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        // );