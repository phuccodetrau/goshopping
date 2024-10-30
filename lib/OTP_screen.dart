import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> otpControllers =
  List.generate(4, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(4, (index) => FocusNode());
  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    // Thêm listener cho mỗi FocusNode để cập nhật trạng thái focus
    for (var focusNode in otpFocusNodes) {
      focusNode.addListener(() {
        setState(() {}); // Cập nhật UI khi trạng thái focus thay đổi
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to avoid memory leaks
    otpControllers.forEach((controller) => controller.dispose());
    otpFocusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
      } else {
        otpFocusNodes[index].unfocus(); // Unfocus last field
      }
    } else if (index > 0) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
    }
    setState(() {}); // Cập nhật UI sau khi thay đổi giá trị
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Nhập mã OTP"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Action quay lại
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nhập mã 4 chữ số được gửi đến",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "(+84 123 456 789)",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: otpFocusNodes[index].hasFocus
                        ? Colors.white // Màu trắng nếu ô đang được focus
                        : Colors.grey[300], // Màu xám cho các ô khác
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: TextFormField(
                      controller: otpControllers[index],
                      focusNode: otpFocusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black), // Viền đen mặc định
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black), // Viền đen khi ô không focus
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.black, width: 2), // Viền đen dày hơn khi focus
                        ),
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) => _onOtpChanged(index, value),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            if (isLoading) ...[
              Center(child: CircularProgressIndicator()),
            ] else ...[
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {
                      // Action khi chọn "Tôi không nhận được mã"
                    },
                  ),
                  Expanded(
                    child: Text(
                      "I didn’t receive a code",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (isError)
                Text(
                  "Mã OTP bạn nhập không hợp lệ!",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
