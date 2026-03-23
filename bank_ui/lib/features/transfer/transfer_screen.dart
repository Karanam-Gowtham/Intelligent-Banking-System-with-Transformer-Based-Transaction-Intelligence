class TransferScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transfer")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInput(hint: "Recipient"),
            SizedBox(height: 10),
            CustomInput(hint: "Amount"),

            SizedBox(height: 20),

            GradientButton(
              text: "Confirm",
              onTap: () {
                Navigator.pushNamed(context, '/success');
              },
            )
          ],
        ),
      ),
    );
  }
}