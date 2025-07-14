import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductViewPage extends StatelessWidget {
  const ProductViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('View Product', style: TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Image.asset(
                'assets/watch1.png',
                height: 220.h,
                fit: BoxFit.contain,
              ),
              // Static product image
              SizedBox(height: 12.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Fossil Neutra Chronograph',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(' 4.5 Rating', style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text('\$67', style: TextStyle(fontSize: 12.sp, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                        SizedBox(width: 8.w),
                        Text('\$55', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.red)),
                        SizedBox(width: 4.w),
                        Text('(regular offer)', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),
              _buildDetailText('Brand : Fossil'),
              _buildDetailText('Model : FS5878'),
              _buildDetailText('Color : Only Black'),
              _buildDetailText('Size : 44mm'),
              _buildDetailText('Category : Men\'s Watch'),
              _buildDetailText('Availability : 1 in Stock'),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                child: Text(
                  'Lorem ipsum is simply dummy text of the printing and typesetting industry. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                ),
              ),

              const Divider(),

              _buildSectionTitle('Shop Details'),
              _buildDetailText('Fashion.Hube - Clothing'),
              _buildDetailText('Jalalabad, Sylhet - +880 16 4738 723'),
              _buildDetailText('Open: 10:00 AM  |  Close: 9:30 PM'),

              SizedBox(height: 12.h),
              _buildSectionTitle('Review'),
              _buildReviewCard(),

              SizedBox(height: 24.h),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Upload', style: TextStyle(color: Colors.white)),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Text(text, style: TextStyle(fontSize: 12.sp)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 16,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fouzia Hussain', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        Text(' 4.5 Rating', style: TextStyle(fontSize: 10.sp)),
                      ],
                    ),
                  ],
                ),
              ),
              Text('11/12/2024', style: TextStyle(fontSize: 10.sp)),
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 14),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Lorem ipsum is simply dummy text of the printing and typesetting industry. It has become the industry\'s standard dummy text ever since the 1500s.',
            style: TextStyle(fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}
