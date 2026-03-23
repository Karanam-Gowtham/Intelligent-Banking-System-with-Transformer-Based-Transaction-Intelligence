class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome Back",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),

            SizedBox(height: 30),

            CustomInput(hint: "Email"),
            SizedBox(height: 15),
            CustomInput(hint: "Password"),

            SizedBox(height: 25),

            GradientButton(
              text: "Login",
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            )
          ],
        ),
      ),
    );
  }
}