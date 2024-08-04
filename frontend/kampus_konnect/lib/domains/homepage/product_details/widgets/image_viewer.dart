import 'package:flutter/material.dart';
import 'package:Treddit/main.dart';

class ProductImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final baseUrl = MyApp.baseUrl;
  const ProductImageViewer({
    Key? key,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _ProductImageViewerState createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          height: MediaQuery.of(context).size.height * 0.4, // Max height
          width: double.infinity,
          child: PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return (widget.imageUrls[0] != null &&
                      (widget.imageUrls[0] as String) !=
                          "${widget.baseUrl}/res/")
                  ? Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.photo_rounded,
                      size: 100,
                      color: Colors.black,
                    );
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              widget.imageUrls.length,
              (index) => _currentIndex == index
                  ? Container(
                      width: 20,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    )
                  : Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.3),
                      ),
                    )),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
