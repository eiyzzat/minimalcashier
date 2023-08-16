import 'package:flutter/material.dart';

//Member Details design for the submodules
Widget memberDetailsContainerDesign(BuildContext context, String imagePath, String text,
    Widget Function(BuildContext) builder,
    {Widget? additionalChild}) {
  return Expanded(
    child: Container(
      height: 110,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet<dynamic>(
            enableDrag: false,
            isScrollControlled: true,
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            builder: (BuildContext context) {
              // ignore: sized_box_for_whitespace
              return Container(
                height: MediaQuery.of(context).size.height * 2.65 / 3,
                child: builder(context),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                imagePath,
                height: 40,
              ),
              const SizedBox(
                height: 10,
              ),
              if (additionalChild == null)
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (additionalChild != null) additionalChild,
            ],
          ),
        ),
      ),
    ),
  );
}

