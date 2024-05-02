import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'my_colors.dart';

class TextFields extends StatefulWidget {
  final TextEditingController controller;
  final String? title;
  final String? hint;
  final String? initialValue;
  final bool readOnly;
  final void Function(String val)? onChanged;
  final void Function()? onTap;
  final void Function(String val)? onSubmit;
  final void Function()? onCompleted;
  final bool obscureText;
  final bool showObscureSwitch;
  final EdgeInsets? padding;
  final bool enableBorder;
  final double borderWidth;
  final Color? borderColor;
  final Color? cursorColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fieldColor;
  final TextInputType? keyboardType;
  final TextInputAction? inputAction;
  final TextCapitalization capitalize;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final bool isSelect;
  final String? infotext;
  final double radius;
  const TextFields({
    Key? key,
    required this.controller,
    this.title,
    this.hint,
    this.initialValue,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.onSubmit,
    this.onCompleted,
    this.obscureText = false,
    this.showObscureSwitch = false,
    this.padding,
    this.enableBorder = true,
    this.borderWidth = 1,
    this.borderColor,
    this.cursorColor = colorPrimary,
    this.prefixIcon,
    this.suffixIcon,
    this.fieldColor,
    this.keyboardType,
    this.inputAction = TextInputAction.next,
    this.capitalize = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.focusNode,
    this.textStyle,
    this.isSelect = false,
    this.infotext,
    this.radius = 0,
  }) : super(key: key);

  @override
  State<TextFields> createState() => _TextFieldsState();
}

class _TextFieldsState extends State<TextFields> {
  bool obscureText = false;
  String? textHelper;
  FocusNode focusHelper = FocusNode();
  String? hint = "";
  @override
  void initState() {
    obscureText =
        !widget.obscureText ? widget.showObscureSwitch : widget.obscureText;
    textHelper = widget.initialValue;
    focusHelper = widget.focusNode ?? FocusNode();
    var nara = widget.isSelect ? "Pilih " : "Masukkan ";
    hint = widget.title ?? widget.hint;
    if (hint != null) {
      if (widget.hint != null) {
        hint = hint!.toString().replaceAll("*", "");
      } else {
        hint = nara + hint!.toString().replaceAll("*", "");
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TextEditingController textEditingController =
    //     TextEditingController(text: textHelper);
    // textEditingController.selection = TextSelection.fromPosition(
    //   TextPosition(offset: textEditingController.text.length),
    // );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Text(widget.title!,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 14.sp)),
        if (widget.title != null) SizedBox(height: 6.h),
        Container(
          padding: widget.padding == null && widget.enableBorder
              ? EdgeInsets.only(left: 14.w, right: 20.w, top: 5.w, bottom: 5.w)
              : widget.padding,
          decoration: BoxDecoration(
            color: widget.fieldColor ?? colorWhite,
            border: !widget.enableBorder
                ? null
                : Border.all(
                    width: widget.borderWidth,
                    color: widget.borderColor ?? colorGrey,
                  ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) widget.prefixIcon!,
              if (widget.prefixIcon != null) SizedBox(width: 7.w),
              Expanded(
                child: widget.readOnly
                    ? GestureDetector(
                        onTap: () {
                          if (widget.onTap != null) {
                            widget.onTap!();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 0,
                          ),
                          child: Text(
                            widget.initialValue ?? widget.hint ?? "",
                            textAlign: widget.textAlign,
                            maxLines: widget.maxLines,
                            style: widget.textStyle ??
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: widget.initialValue != null
                                          ? null
                                          : colorPrimary,
                                      fontSize: 16.spMin,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      )
                    : TextField(
                        autocorrect: false,
                        enableSuggestions: false,
                        cursorColor: widget.cursorColor,
                        focusNode: focusHelper,
                        obscureText: obscureText,
                        maxLines: widget.maxLines,
                        minLines: widget.minLines,
                        controller: widget.controller,
                        autofocus: false,
                        onEditingComplete: () {
                          if (widget.onCompleted != null) {
                            widget.onCompleted!();
                          }
                        },
                        onChanged: (val) {
                          textHelper = val;
                          if (widget.onChanged != null) {
                            widget.onChanged!(val);
                          }
                        },
                        onTap: () {
                          if (widget.onTap != null) {
                            widget.onTap!();
                          }
                        },
                        onSubmitted: (value) {
                          if (widget.onSubmit != null) {
                            widget.onSubmit!(value);
                          }
                        },
                        readOnly: widget.isSelect,
                        style: widget.textStyle,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.inputAction,
                        textAlign: widget.textAlign,
                        textAlignVertical: TextAlignVertical.center,
                        textCapitalization: widget.capitalize,
                        maxLength: widget.maxLength,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: widget.textStyle,
                          isDense: true,
                          contentPadding: EdgeInsets.only(top: 8.h),
                          border: InputBorder.none,
                          counter: const SizedBox(),
                        ),
                      ),
              ),
              if (widget.suffixIcon != null) SizedBox(width: 7.w),
              if (widget.suffixIcon != null) widget.suffixIcon!,
              if (widget.showObscureSwitch)
                InkWell(
                  onTap: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  child: Icon(
                    obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
            ],
          ),
        ),
        if (widget.infotext != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Text(
              widget.infotext!,
              style: TextStyle(
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
                color: Colors.red,
              ),
            ),
          ),
        if (!widget.enableBorder)
          Container(
            height: 1,
            color: colorSecondary,
          ),
        const SizedBox(height: 10),
      ],
    );
  }
}
