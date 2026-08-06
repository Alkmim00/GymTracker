import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';


class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> {


  final emailController = TextEditingController();

  final passwordController = TextEditingController();


  final AuthService auth = AuthService();


  bool loading = false;



  Future<void> login() async {


    setState(() {

      loading = true;

    });



    try {


      await auth.login(

        emailController.text.trim(),

        passwordController.text.trim(),

      );


    } catch (e) {


      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            e.toString(),

          ),

        ),

      );


    }



    setState(() {

      loading = false;

    });


  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: const Color(0xFF121212),



      body: Padding(

        padding: const EdgeInsets.all(25),


        child: Center(


          child: SingleChildScrollView(


            child: Column(


              children: [



                const Text(

                  "GYM TRACKER",

                  style: TextStyle(

                    fontSize: 34,

                    fontWeight: FontWeight.bold,

                    color: Colors.green,

                  ),

                ),



                const SizedBox(height: 10),



                const Text(

                  "Track your progress. Build yourself.",

                  style: TextStyle(

                    color: Colors.grey,

                    fontSize: 16,

                  ),

                ),



                const SizedBox(height: 40),




                Container(

                  padding: const EdgeInsets.all(20),


                  decoration: BoxDecoration(

                    color: const Color(0xFF1E1E1E),

                    borderRadius: BorderRadius.circular(20),

                  ),



                  child: Column(

                    children: [



                      TextField(

                        controller: emailController,

                        style: const TextStyle(
  color: Color(0xFFE0E0E0),
),

                        decoration: InputDecoration(

                          labelText: "Email",

                          prefixIcon: const Icon(

                            Icons.email,

                          ),


                          filled: true,

                          fillColor: const Color(0xFF2A2A2A),


                          border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(15),

                            borderSide: BorderSide.none,

                          ),

                        ),

                      ),



                      const SizedBox(height: 15),



                      TextField(

                        controller: passwordController,

                        style: const TextStyle(
  color: Color(0xFFE0E0E0),
),

                        obscureText: true,

                        decoration: InputDecoration(

                          labelText: "Password",

                          prefixIcon: const Icon(

                            Icons.lock,

                          ),


                          filled: true,

                          fillColor: const Color(0xFF2A2A2A),


                          border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(15),

                            borderSide: BorderSide.none,

                          ),

                        ),

                      ),



                      const SizedBox(height: 25),




                      SizedBox(

                        width: double.infinity,


                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(

                            backgroundColor: Colors.green,

                            foregroundColor: Colors.black,


                            padding: const EdgeInsets.all(16),


                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(15),

                            ),

                          ),


                          onPressed: loading ? null : login,


                          child: loading

                              ? const CircularProgressIndicator()

                              : const Text(

                                  "LOGIN",

                                  style: TextStyle(

                                    fontSize: 18,

                                    fontWeight: FontWeight.bold,

                                  ),

                                ),

                        ),

                      ),



                    ],

                  ),

                ),



                const SizedBox(height: 20),




                TextButton(

                  onPressed: () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) =>
                            const SignupScreen(),

                      ),

                    );


                  },


                  child: const Text(

                    "Create Account",

                    style: TextStyle(

                      color: Colors.green,

                    ),

                  ),

                ),



                const Divider(

                  color: Colors.grey,

                ),



                TextButton(

  onPressed: () async {


    try {

      await auth.signInGuest();


    } catch (e) {


      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(
            e.toString(),
          ),

        ),

      );


    }


  },

                  child: const Text(

                    "Continue as Guest",

                    style: TextStyle(

                      color: Colors.grey,

                    ),

                  ),

                ),



              ],

            ),

          ),

        ),

      ),

    );

  }

}