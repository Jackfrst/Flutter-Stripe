class StripeModel {
  String? amount;
  String? currency;
  String? paymentMethodTypes;

  StripeModel({this.amount, this.currency, this.paymentMethodTypes});

  StripeModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    currency = json['currency'];
    paymentMethodTypes = json['payment_method_types[]'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['payment_method_types[]'] = this.paymentMethodTypes;
    return data;
  }
}