import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'add_member.dart';

class AddGroup extends StatelessWidget {
  const AddGroup({super.key});

  @override
  Widget build(BuildContext context) {
    // Biến để lưu trữ hình ảnh đã upload
    String? uploadedImage;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Chuyển đến trang add_member.dart mà không lưu hình ảnh
              Navigator.pushNamed(context, '/add_member');
            },
            child: Text(
              "Bỏ qua",
              style: TextStyle(color: Colors.green[800]),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "Tùy chỉnh nhóm của bạn",
              style: TextStyle(
                fontSize: 22,
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Cá nhân hóa nhóm của bạn bằng cách đặt tên và thêm hình ảnh đại diện.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),

            // Cập nhật hình ảnh
            GestureDetector(
              onTap: () async {
                // Logic để upload hình ảnh
                uploadedImage = await uploadImage(); // Lưu trữ hình ảnh đã upload
                if (uploadedImage != null) {
                  // Hiển thị thông báo thành công khi upload thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Hình ảnh đã được upload thành công!")),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Cập nhật hình ảnh",
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Ô nhập tên nhóm
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                hintText: "Đặt tên cho nhóm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                counterText: "0/75",
              ),
              maxLength: 75,
            ),

            const SizedBox(height: 16),

            // Thông tin điều khoản
            Text(
              "Khi tạo nhóm, nghĩa là bạn đã đồng ý với ",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Nguyên tắc cộng đồng",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: " của Đi chợ tiện lợi.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Nút "Tiếp theo"
            ElevatedButton(
              onPressed: () async {
                if (uploadedImage == null) {
                  // Hiển thị cảnh báo nếu chưa upload hình ảnh
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vui lòng upload hình ảnh trước!")),
                  );
                } else {
                  // Giả sử bạn có một hàm để lưu ảnh
                  bool isImageSaved = await saveImage(); // Thay thế bằng hàm lưu ảnh của bạn

                  if (isImageSaved) {
                    // Nếu lưu ảnh thành công, điều hướng đến AddMember
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddMember()), // Điều hướng đến AddMember
                    );
                  } else {
                    // Xử lý khi lưu ảnh không thành công (nếu cần)
                    print('Lưu ảnh không thành công');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
              child: const Text(
                "Tiếp theo",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> uploadImage() async {
    // Sử dụng ImagePicker để chọn hình ảnh từ thư viện
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Trả về đường dẫn hình ảnh đã chọn
      return image.path;
    }
    return null; // Trả về null nếu không có hình ảnh nào được chọn
  }

  Future<bool> saveImage() async {
    // Thực hiện lưu ảnh ở đây và trả về true nếu thành công, false nếu không
    return true; // Thay thế bằng logic thực tế của bạn
  }
}
