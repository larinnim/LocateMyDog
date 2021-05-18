class Device {
  final String? id;
  final String? name;
  final int? batteryLevel;
  final String? latitude;
  final String? longitude;
  final String? color;
  final String? senderNumber;
  final bool? enabled;

  Device(
      {this.id,
      this.name,
      this.batteryLevel,
      this.latitude,
      this.longitude,
      this.color,
      this.senderNumber,
      this.enabled});
}
