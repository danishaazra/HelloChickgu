
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hellochickgu/features/community/community.dart';


class quiz2 extends StatelessWidget {
  const quiz2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/quiz.png"),
              fit: BoxFit.cover)
            ),
          ),

         

          SingleChildScrollView(
            child: Center(
              child: Column(

                children: [
                   SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/clock.png",
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "00.10",
                              style: GoogleFonts.baloo2(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                   
                   
                  
                ],
                
              ),

            )
          )

        ],
      )
    );
  }
}
