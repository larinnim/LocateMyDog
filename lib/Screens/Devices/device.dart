class Device {
  final String id;
  final String name;
  final int batteryLevel;
  final String latitude;
  final String longitude;

  Device({this.id, this.name, this.batteryLevel, this.latitude, this.longitude});

  // Device.fromJson(Map<String, dynamic> json)
  //     : name = json['name'],
  //       filling = json['filling'],
  //       topping = json['topping'],
  //       price = json['price'];

  // Map<String, dynamic> toJson() => {
  //   'name' : name,
  //   'filling' : filling,
  //   'topping' : topping,
  //   'price' : price
  // };
}