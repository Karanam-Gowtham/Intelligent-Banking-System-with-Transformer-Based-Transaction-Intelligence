class CustomInput extends StatelessWidget {
  final String hint;

  const CustomInput({required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}