/// Returns a String representation with a coma every 3 digits
String numWithCommas(num i) {
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final Function matchFunc = (Match match) => '${match[1]},';
  return i.toString().replaceAllMapped(reg, matchFunc);
}
